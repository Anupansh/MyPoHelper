//
//  CreatedPurchaseOrderViewModel.swift
//  MyProHelper
//
//  Created by Pooja Mishra on 03/04/1943 Saka.
//  Copyright © 1943 Benchmark Computing. All rights reserved.
//
import Foundation

class CreatedPurchaseOrderViewModel: BaseAttachmentViewModel {
    
    private var purchaseOrder = PurchaseOrder()
    private var isUpdatingPurchaseOrder = false
    private var vendors: [Vendor] = []
    private var lineItems: [PurchaseOrderUsed] = []
    private var purchaseOrderService = PurchaseOrderService()
    private var hasMoreStocks = false
    
    
    func setPurchaseOrder(purchaseOrder: PurchaseOrder) {
        self.isUpdatingPurchaseOrder = true
        self.purchaseOrder = purchaseOrder
        self.sourceId = purchaseOrder.purchaseOrderId
        self.purchaseOrder.updateModifyDate()
    }
    
    func getLineItems() -> [PurchaseOrderUsed] {
        return lineItems
    }
    
    func getLineItem(at index: Int) -> PurchaseOrderUsed? {
        guard lineItems.count > index else { return nil }
        return lineItems[index]
    }
    
    
    func setVendor(vendor: Vendor) {
        purchaseOrder.purchasedFrom = vendor
    }
    
    func addLineItem(lineItem: PurchaseOrderUsed) {
        
        if let index = lineItems.firstIndex(of: lineItem) {
            lineItems[index].increaseQuantity(by: lineItem.quantity)
        }
        else {
            lineItems.append(lineItem)
        }
    }
    
    func updateLineItem(lineItem: PurchaseOrderUsed) {
        if let index = lineItems.firstIndex(where: { $0.purchaseOrderUsedId == lineItem.purchaseOrderUsedId && $0.lineItemId == lineItem.lineItemId}) {
            lineItems[index] = lineItem
        }
    }

    
    func setVendor(at index: Int?) {
        guard let index = index, index < vendors.count else { return }
        if index == 0{
            let vendor = vendors[index]
            purchaseOrder.purchasedFrom = vendor
            return
        }
        purchaseOrder.purchasedFrom = vendors[index]
        purchaseOrder.vendorId = purchaseOrder.purchasedFrom?.vendorID
    }
    
    func setOrderedDate(date: String?) {
        guard let date = date else { return }
        purchaseOrder.orderedDate = DateManager.stringToDate(string: date)
    }

    func setExpectedDate(date: String?) {
        guard let date = date else { return }
        purchaseOrder.expectedDate = DateManager.stringToDate(string: date)
    }

    
    func setSalesTax(price: String?) {
        guard let price = price else { return }
        purchaseOrder.salesTax = Double(price)
    }
    
    func setShipping(price: String?) {
        guard let price = price else { return }
        purchaseOrder.shipping = Double(price)
    }
    
    
    func getVendors(completion: @escaping () -> ()) {
        let vendorService = VendorService()
        vendorService.fetchVendors(offset: 0) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let vendors):
                // Local added because values is not stored in db
                var vendor = Vendor()
                vendor.vendorName = Constants.DefaultValue.SELECT_LIST
                self.vendors.removeAll()
                self.vendors.append(vendor)
                self.vendors.append(contentsOf: vendors)
                
//                self.vendors = vendors
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getMaxLineItemId(completion: @escaping (_ ID:Int?) -> ()){
        let purchaseOrderLineItemService = PurchaseOrderLineItemService()

        purchaseOrderLineItemService.fetchMaxPurchaseOrderUsedID { (result) in
            switch result {
            case .success(let ID):
                completion(ID)
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }
    
    func getPurchaseOrderLineItems(isReload: Bool = true, showRemoved:Bool, completion: @escaping () -> ()) {
        if !isReload && !hasMoreStocks {
            return
        }
        guard let purchaseOrderId = purchaseOrder.purchaseOrderId else {
            return
        }
        
        let offset = (isReload) ? 0 : lineItems.count
        let purchaseOrderLineItemService = PurchaseOrderLineItemService()

        purchaseOrderLineItemService.fetchLineItem(lineItemID: purchaseOrderId, showRemoved: showRemoved, offset: offset) { (result) in
            switch result {

            case .success(let lineItems):
                self.hasMoreStocks = lineItems.count == Constants.DATA_OFFSET
                if isReload {
                    self.lineItems = lineItems
                }
                else {
                    self.lineItems.append(contentsOf: lineItems)
                }

                completion()
            case .failure(let error):
                print(error)
                completion()
            }
        }
    }
    
    func getVendors() -> [String] {
        return vendors.compactMap({ $0.vendorName })
    }
    
    func getVendorsList() -> [Vendor] {
        return vendors
    }
    
    func getVendor() -> String? {
        return purchaseOrder.purchasedFrom?.vendorName
    }
    
    func validateName() -> ValidationResult {
        return Validator.validateName(name: purchaseOrder.purchasedFrom?.vendorName)
    }
    
    func validateSalesTax() -> ValidationResult {
        guard let salesTax = purchaseOrder.salesTax else {
            return .Valid
        }
        return Validator.validatePrice(price: salesTax)
    }
    
    func validateShipping() -> ValidationResult {
        guard let shipping = purchaseOrder.shipping else {
            return .Valid
        }
        return Validator.validatePrice(price: shipping)
    }
    
    func validateVendor() -> ValidationResult {
        if purchaseOrder.vendorId == nil && purchaseOrder.purchasedFrom?.vendorName == nil{
            return .Invalid(message: Constants.Message.NAME_SELECT_ERROR)
        }
        
        if let vendorName = purchaseOrder.purchasedFrom?.vendorName , purchaseOrder.vendorId == nil{
            if vendorName == Constants.DefaultValue.SELECT_LIST{

                return .Invalid(message: Constants.Message.NAME_SELECT_ERROR)
            }
            return .Valid
        }
        if let vendorName = purchaseOrder.purchasedFrom?.vendorName{
            if vendorName == Constants.DefaultValue.SELECT_LIST{

                return .Invalid(message: Constants.Message.NAME_SELECT_ERROR)
            }
            return .Valid
        }
        
        return .Valid
    }
    
    func isValidData() -> Bool {
        return  validateVendor()        == .Valid &&
                validateSalesTax()      == .Valid &&
                validateShipping()      == .Valid
    }
    
    func canEditVendor() -> Bool {
        return purchaseOrder.purchasedFrom?.vendorID == nil
    }
    
    func getOrderedDate() -> String? {
        return DateManager.getStandardDateString(date: purchaseOrder.orderedDate)
    }
    
    func getExpectedDate() -> String? {
        return DateManager.getStandardDateString(date: purchaseOrder.expectedDate)
    }
    
    func getSalesTax() -> String? {
        return purchaseOrder.salesTax?.stringValue
    }
    
    func getShipping() -> String? {
        return purchaseOrder.shipping?.stringValue
    }
    
    func addPurchaseOrder(completion: @escaping (_ error: String?, _ isValidData: Bool) -> ()) {
        if !isValidData() {
            completion(nil,false)
            return
        }
        purchaseOrder.numberOfAttachments = numberOfAttachment
        purchaseOrder.enteredDate = Date()
        if isUpdatingPurchaseOrder {
            updatePurchaseOrder { (error) in
                completion(error,true)
            }
        }
        else {
            savePurchaseOrder { (error) in
                completion(error,true)
            }
        }
        
    }
    
    private func updatePurchaseOrder(completion: @escaping (_ error: String?) -> ()) {
        guard let purchaseOrderID = purchaseOrder.purchaseOrderId else {
            completion("an error has occurred")
            return
        }
        
        purchaseOrderService.editPurchaseOrder(purchaseOrder: purchaseOrder) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.saveAttachment(id: Int(purchaseOrderID))
                self.saveLineItem(for: Int(purchaseOrderID)) { error in
                    completion(error)
                }
                break
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    private func savePurchaseOrder(completion: @escaping (_ error: String?) -> ()) {
        purchaseOrderService.createPurchaseOrder(purchaseOrder: purchaseOrder) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let purchaseOrderID):
                self.saveAttachment(id: Int(purchaseOrderID))
                self.saveLineItem(for: Int(purchaseOrderID)) { error in
                    completion(error)
                }
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    private func saveLineItem(for purchaseOrderID: Int, completion: @escaping (_ error: String?)->()) {
        
        let purchaseOrderLineItemService = PurchaseOrderLineItemService()
        var numberOfLineItems = lineItems.count
        
        if numberOfLineItems == 0 {
            completion(nil)
            return
        }
        
        for var lineItem in lineItems {
            lineItem.purchaseOrderId = purchaseOrderID
            purchaseOrderLineItemService.addLineItem(lineItem: lineItem) { (result) in
                switch result {
                case .success(_):
                    numberOfLineItems -= 1
                    if numberOfLineItems == 0 {
                        completion(nil)
                    }
                case .failure(let error):
                    completion(error.localizedDescription)
                }
            }
        }
        
    }
    
    func deleteLineItem(lineItem: PurchaseOrderUsed, completion: @escaping (_ error: String?)->()) {
        let purchaseOrderLineItemService = PurchaseOrderLineItemService()
        purchaseOrderLineItemService.delete(lineItem: lineItem) { (result) in
            switch result {
            case .success(_):
                completion(nil)
                
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    func undeleteLineItem(lineItem: PurchaseOrderUsed, completion: @escaping (_ error: String?)->()) {
        let purchaseOrderLineItemService = PurchaseOrderLineItemService()
        purchaseOrderLineItemService.undelete(lineItem: lineItem) { (result) in
            switch result {
            case .success(_):
                completion(nil)
                
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    func removeLineItem(lineItem: PurchaseOrderUsed) {
        if let index = lineItems.firstIndex(of: lineItem) {
            lineItems.remove(at: index)
        }
    }
    
}
    
    

