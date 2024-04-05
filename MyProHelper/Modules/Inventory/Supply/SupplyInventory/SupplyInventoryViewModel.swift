//
//  SupplyInventoryViewModel.swift
//  MyProHelper
//
//  Created by sismac010 on 16/03/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

class SupplyInventoryViewModel {
 
    private var supplyLocations: [SupplyLocation] = []
    private var vendors: [Vendor] = []
    private var originalStock: SupplyFinder?
    private var stock: SupplyFinder?
    private var actionType: InventoryAction?
    private var quantity: Int = 0
    
    func setStock(stock: SupplyFinder, for action: InventoryAction) {
        self.originalStock  = stock
        self.stock          = stock
        self.actionType     = action
    }
    
    func getActionType() -> InventoryAction? {
        return actionType
    }
    
    func getLocationName() -> String? {
        return stock?.supplyLocation?.locationName
    }
    
    func getFromLocationName() -> String? {
        return originalStock?.supplyLocation?.locationName
    }
    
    func getSupplyLocations() -> [String] {
        return supplyLocations.compactMap({ $0.locationName })
    }
    
    func getVendors() -> [String] {
        return vendors.compactMap({ $0.vendorName })
    }
    
    func getVendorName() -> String? {
        return stock?.wherePurchased?.vendorName
    }
    
    func setSupplyLocation(at index: Int) {
        stock?.supplyLocation = supplyLocations[index]
    }
    
    func setSupplyLocation(supplyLocation: SupplyLocation) {
        stock?.supplyLocation = supplyLocation
    }
    
    func setVendor(at index: Int) {
        stock?.wherePurchased = vendors[index]
    }
    
    func setVendor(vendor: Vendor) {
        stock?.wherePurchased = vendor
    }
    
    func setQuanityt(value: String?) {
        guard let stringValue = value, let quantity = Int(stringValue) else { return }
        if quantity >= 0 {
            self.quantity = quantity
        }
        else {
            self.quantity = 0
        }
    }
    
    func setPricePaid(price: String?) {
        guard let price = price else {
            return
        }
        stock?.pricePaid = Double(price)
    }
    
    func setPriceToResell(price: String?) {
        guard let price = price else {
            return
        }
        stock?.priceToResell = Double(price)
    }
    
    func setLastPurchased(date: String?) {
        guard let date = date else {
            return
        }
        stock?.lastPurchased = DateManager.stringToDate(string: date)
    }
    
    func canEditVendor() -> Bool {
        return stock?.wherePurchased?.vendorID == nil
    }
    
    func getQuantity() -> Int {
        return quantity
    }
    
    func getQuantityString() -> String {
        return String(quantity)
    }
    
    func getPricePaid() -> String {
        guard let pricePaid = stock?.pricePaid else {
            return ""
        }
        return pricePaid.stringValue
    }
    
    func getPriceToResell() -> String {
        guard let priceToResell = stock?.priceToResell else {
            return ""
        }
        return priceToResell.stringValue
    }
    
    func getLastPurchasedDate() -> String {
        guard let date = stock?.lastPurchased else {
            return ""
        }
        return DateManager.getStandardDateString(date: date)
    }
    
    func getSupplyLocations(completion: @escaping () -> ()) {
        let supplyLocationService = SupplyLocationService()
        supplyLocationService.fetchSupplyLocations(offset: 0) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let supplyLocations):
                self.supplyLocations = supplyLocations
                completion()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getVendors(completion: @escaping () -> ()) {
        let vendorService = VendorService()
        vendorService.fetchVendors(offset: 0) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let vendors):
                self.vendors = vendors
                completion()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func validateQuantity() -> ValidationResult {
        guard let quantity = stock?.quantity else {
            return .Valid
        }
        return Validator.validateIntegerValue(value: quantity)
    }
    
    func validatePricePaid() -> ValidationResult {
        guard let pricePaid = stock?.pricePaid else {
            return .Valid
        }
        return Validator.validatePrice(price: pricePaid)
    }
    
    func validatePriceToResell() -> ValidationResult {
        guard let priceToResell = stock?.priceToResell else {
            return .Valid
        }
        return Validator.validatePrice(price: priceToResell)
    }
    
    func isValidData() -> Bool {
        return
            validateQuantity()      == .Valid &&
            validatePricePaid()     == .Valid &&
            validatePriceToResell() == .Valid
    }
    
    func addStockQuantity(completion: @escaping (_ error: String?)->()) {
        guard var stock = stock else { return }
        guard isValidData() else {
            return
        }
        let service = SupplyFinderService()
        stock.increaseQuantity(by: quantity)
        if stock == originalStock {
            service.addStock(stock: stock) { (result) in
                switch result{
                case .success(_):
                    completion(nil)
                case .failure(let error):
                    completion(error.localizedDescription)
                }
            }
        }
        else {
            addOrUpdateStock(completion: completion)
        }
    }
    
    func removeStockQuantity(completion: @escaping (_ isValid: Bool,_ error: String?)->()) {
        guard var stock = stock else { return }
        guard validateQuantity() == .Valid else {
            return
        }
        let service = SupplyFinderService()
        let isSuccessRemove = stock.decreaseQuantity(by: quantity)
        if !isSuccessRemove {
            completion(false,nil)
            return
        }
        service.addStock(stock: stock) { (result) in
            switch result{
            case .success(_):
                completion(true,nil)
            case .failure(let error):
                completion(true,error.localizedDescription)
            }
        }
    }
    
    func transferStockQuantity(completion: @escaping (_ isValid: Bool,_ error: String?)->()) {
        guard let stock = stock, var originalStock = originalStock else { return }
        let service = SupplyFinderService()
        let isSuccessRemove = originalStock.decreaseQuantity(by: quantity)
        if !isSuccessRemove {
            completion(false,nil)
            return
        }
        if originalStock.supplyLocation == stock.supplyLocation {
            completion(false,nil)
            return
        }
        addOrUpdateStock { (error) in
            if let error = error {
                completion(true,error)
            }
            else {
                service.addStock(stock: originalStock) { (result) in
                    switch result {
                    case .success(_):
                    completion(true,nil)
                    case .failure(let error):
                        completion(true,error.localizedDescription)
                    }
                }
            }
        }
    }
    
    private func addOrUpdateStock(completion: @escaping (_ error: String?)->()) {
        guard let stock = stock, quantity >= 0 else { return }
        let service = SupplyFinderService()
        
        service.updateQuantity(stock: stock, quantity: quantity) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let isUpdated):
                if isUpdated {
                    completion(nil)
                }
                else {
                    var newStock = SupplyFinder(stock: stock)
                    newStock.increaseQuantity(by: self.quantity)
                    self.addStock(stock: newStock, completion: completion)
                }
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    private func addStock(stock: SupplyFinder, completion: @escaping (_ error: String?)->()) {
        let service = SupplyFinderService()
        service.addStock(stock: stock) { (result) in
            switch result {
            case .success(_):
                completion(nil)
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }

}
