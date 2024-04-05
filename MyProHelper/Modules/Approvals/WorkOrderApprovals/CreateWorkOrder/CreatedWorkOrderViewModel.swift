//
//  CreateViewOrderViewModel.swift
//  MyProHelper
//
//  Created by Pooja Mishra on 14/03/1943 Saka.
//  Copyright © 1943 Benchmark Computing. All rights reserved.
//

import Foundation

class CreatedViewOrderViewModel:  BaseAttachmentViewModel {
    private var workOrder = WorkOrder()
    private var isUpdatingWorkOrder = false
    private var customers: [Customer] = []
    private var workers: [Worker] = []
    private var lineItems: [WorkOrderUsed] = []
    private var workOrderService = WorkOrderService()
    private var hasMoreStocks = false


    func setWorkOrder(workOrder: WorkOrder) {
        self.isUpdatingWorkOrder = true
        self.workOrder = workOrder
        self.sourceId = workOrder.workOrderId
        self.workOrder.updateModifyDate()
    }
    
    func getLineItems() -> [WorkOrderUsed] {
        return lineItems
    }

    func getLineItem(at index: Int) -> WorkOrderUsed? {
        guard lineItems.count > index else { return nil }
        return lineItems[index]
    }
    
    
    func getCustomers(completion: @escaping () -> ()) {
        let customersService = CustomersService()
        customersService.fetchCustomers(showSelect: true,offset: 0) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let customers):
                // Local added because values is not stored in db
                var customer = Customer()
                customer.customerName = Constants.DefaultValue.SELECT_LIST
                self.customers.removeAll()
                self.customers.append(customer)
                self.customers.append(contentsOf: customers)
                
//                self.customers = customers
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getWorkers(completion: @escaping () -> ()) {
        let workersService = WorkersService()
        workersService.fetchWorkers(showSelect: true,offset: 0) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let workers):
                self.workers = workers
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func setWorker(at index: Int?) {
        guard let index = index, index < workers.count else {return}
        if index == 0{
            let worker = workers[index]
            workOrder.workerName = worker.firstName!
            return
        }
        workOrder.worker = workers[index]
        workOrder.workerId = workOrder.worker?.workerID
        workOrder.workerName = workOrder.worker!.firstName! + " " + workOrder.worker!.lastName!
        
    }
    
    
    func setCustomer(at index: Int?) {
        guard let index = index, index < customers.count else { return }
        if index == 0{
            //Custom code added
            let customer = customers[index]
            workOrder.customerName = customer.customerName
            workOrder.customerId = nil
            return
        }
        workOrder.customer = customers[index]
        workOrder.customerId = workOrder.customer?.customerID
        workOrder.customerName = workOrder.customer?.customerName
    }
    
    func getCustomers() -> [String] {
        return customers.compactMap({ $0.customerName })
    }
    
    func getWorkers() -> [String] {
        return workers.compactMap({ ($0.firstName! + " " + $0.lastName!)})
    }
    
    func getCustomer() -> String? {
        return workOrder.customerName//workOrder.customer?.customerName
    }
    
    func getWorker() -> String? {
        return workOrder.workerName
    }
    
    func isValidData() -> Bool {
        return  validateCustomer()          == .Valid &&
                validateWorker()            == .Valid &&
                validateDescription()       == .Valid
    }
    
    func validateDescription() -> ValidationResult {
        guard let description = workOrder.description, !description.isEmpty else {
            return .Valid
        }
        return Validator.validateName(name: description)
    }
    
    func validateWorker() -> ValidationResult {
        if workOrder.workerId == nil && workOrder.workerName == nil{
            return .Invalid(message: Constants.Message.NAME_SELECT_ERROR)
        }
        
        if let workerName = workOrder.workerName , workOrder.workerId == nil{
            if workerName == Constants.DefaultValue.SELECT_LIST{

                return .Invalid(message: Constants.Message.NAME_SELECT_ERROR)
            }
            return .Valid
        }
        if let workerName = workOrder.workerName{
            if workerName == Constants.DefaultValue.SELECT_LIST{

                return .Invalid(message: Constants.Message.NAME_SELECT_ERROR)
            }
            return .Valid
        }
        
        return .Valid
    }
    
    func validateCustomer() -> ValidationResult {
        
        guard let customerName = workOrder.customerName, !customerName.isEmpty else {
            return .Valid
        }
        return .Valid
    }
    
    func setDescription(description: String?) {
        workOrder.description = description
    }
    
    func getDescription() -> String? {
        return workOrder.description
    }
    
    func addLineItem(lineItem: WorkOrderUsed) {
        
        if let index = lineItems.firstIndex(of: lineItem) {
            lineItems[index].increaseQuantity(by: lineItem.quantity)
        }
        else {
            lineItems.append(lineItem)
        }
    }
    
    func updateLineItem(lineItem: WorkOrderUsed) {
        if let index = lineItems.firstIndex(where: { $0.workOrderUsedId == lineItem.workOrderUsedId && $0.lineItemId == lineItem.lineItemId}) {
            lineItems[index] = lineItem
        }
    }
    
    func getMaxLineItemId(completion: @escaping (_ ID:Int?) -> ()){
        let workOrderLineItemService = WorkOrderLineItemService()

        workOrderLineItemService.fetchMaxWorkOrderUsedID { (result) in
            switch result {
            case .success(let ID):
                completion(ID)
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }
    
    func getWorkOrderLineItems(isReload: Bool = true, showRemoved:Bool, completion: @escaping () -> ()) {
        if !isReload && !hasMoreStocks {
            return
        }
        guard let workOrderId = workOrder.workOrderId else {
            return
        }
        
        let offset = (isReload) ? 0 : lineItems.count
        let workOrderLineItemService = WorkOrderLineItemService()

        workOrderLineItemService.fetchLineItem(lineItemID: workOrderId, showRemoved: showRemoved, offset: offset) { (result) in
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
    
    func addWorkOrder(completion: @escaping (_ error: String?, _ isValidData: Bool) -> ()) {
        if !isValidData() {
            completion(nil,false)
            return
        }
        workOrder.numberOfAttachments = numberOfAttachment
        workOrder.dateCreated = Date()
        if isUpdatingWorkOrder {
            updateWorkOrder { (error) in
                completion(error,true)
            }
        }
        else {
            saveWorkOrder { (error) in
                completion(error,true)
            }
        }
        
    }
    
    private func updateWorkOrder(completion: @escaping (_ error: String?) -> ()) {
        guard let workOrderId = workOrder.workOrderId else {
            completion("an error has occurred")
            return
        }
        //edit by
        workOrderService.editWorkOrder(workOrder: workOrder) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.saveAttachment(id: Int(workOrderId))
                self.saveLineItem(for: Int(workOrderId)) { error in
                    completion(error)
                }
                break
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    private func saveWorkOrder(completion: @escaping (_ error: String?) -> ()) {
        workOrderService.createWorkOrder(workOrder: workOrder) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let workOrderID):
                self.saveAttachment(id: Int(workOrderID))//mili
                self.saveLineItem(for: Int(workOrderID)) { error in
                    completion(error)
                }
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    private func saveLineItem(for workOrderID: Int, completion: @escaping (_ error: String?)->()) {
        
        let workOrderLineItemService = WorkOrderLineItemService()
        var numberOfLineItems = lineItems.count
        
        if numberOfLineItems == 0 {
            completion(nil)
            return
        }
        
        for var lineItem in lineItems {
            lineItem.workOrderId = workOrderID
            workOrderLineItemService.addLineItem(lineItem: lineItem) { (result) in
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
    
    func deleteLineItem(lineItem: WorkOrderUsed, completion: @escaping (_ error: String?)->()) {
        let workOrderLineItemService = WorkOrderLineItemService()
        workOrderLineItemService.delete(lineItem: lineItem) { (result) in
            switch result {
            case .success(_):
                completion(nil)
                
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    func undeleteLineItem(lineItem: WorkOrderUsed, completion: @escaping (_ error: String?)->()) {
        let workOrderLineItemService = WorkOrderLineItemService()
        workOrderLineItemService.undelete(lineItem: lineItem) { (result) in
            switch result {
            case .success(_):
                completion(nil)
                
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    func removeLineItem(lineItem: WorkOrderUsed) {
        if let index = lineItems.firstIndex(of: lineItem) {
            lineItems.remove(at: index)
        }
    }
    

}
