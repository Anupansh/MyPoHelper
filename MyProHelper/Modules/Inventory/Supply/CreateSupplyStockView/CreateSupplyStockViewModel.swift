//
//  CreateSupplyStockViewModel.swift
//  MyProHelper
//
//  Created by sismac010 on 12/03/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation


class CreateSupplyStockViewModel {
    
    private var stock = SupplyFinder()
    private var vendors: [Vendor] = []
    private var supplyLocations: [SupplyLocation] = []
    private var isEditing = false
    private var isRemovedValue = false

    func setStock(stock: SupplyFinder) {
        self.stock = stock
        isEditing = true
    }
    
    func getStock() -> SupplyFinder {
        return stock
    }
    
    func getVendors() -> [String] {
        return vendors.compactMap({ $0.vendorName })
    }
    
    func getSupplyLocations() -> [String] {
        return supplyLocations.compactMap({ $0.locationName })
    }
    
    func getQuantity() -> String {
        return String(stock.quantity ?? 0)
    }
    
    func getPricePaid() -> String? {
        return stock.pricePaid?.stringValue
    }
    
    func getPriceToResell() -> String? {
        return stock.priceToResell?.stringValue
    }

    func getLastPurchasedDate() -> String? {
        if stock.lastPurchased == nil{
            stock.lastPurchased = Date()
        }
        return DateManager.getStandardDateString(date: stock.lastPurchased)
    }
    
    func getVendor() -> String? {
        return stock.wherePurchased?.vendorName
    }
    
    func getSupplyLocation() -> String? {
        return stock.supplyLocation?.locationName
    }
    
    func setQuantity(quantity: String?) {
        guard let quantity = quantity else { return }
        stock.quantity = Int(quantity)
    }
    
    func setPricePaid(price: String?) {
        guard let price = price else { return }
        stock.pricePaid = Double(price)
    }
    
    func setPriceToResell(price: String?) {
        guard let price = price else { return }
        stock.priceToResell = Double(price)
    }
    
    func setLastPurchasedDate(date: String?) {
        guard let date = date else { return }
        stock.lastPurchased = DateManager.stringToDate(string: date)
    }

    func setVendor(at index: Int?) {
        guard let index = index, index < vendors.count else { return }
        stock.wherePurchased = vendors[index]
    }
    
    func setSuppleyLocation(at index: Int?) {
        guard let index = index, index < supplyLocations.count else { return }
        stock.supplyLocation = supplyLocations[index]
    }
    
    func setSupplyLocation(supplyLocation: SupplyLocation) {
        stock.supplyLocation = supplyLocation
    }
    
    func setVendor(vendor: Vendor) {
        stock.wherePurchased = vendor
    }
    
    func isUpdateStock() -> Bool {
        return isEditing
    }
    
    func canEditVendor() -> Bool {
        return stock.wherePurchased?.vendorID == nil
    }
    
    func canEditSupplyLocation() -> Bool {
        return !isEditing
    }

    func validateQuantity() -> ValidationResult {
        guard let quantity = stock.quantity else {
            return .Valid
        }
        return Validator.validateIntegerValue(value: quantity)
    }
    
    func validatePricePaid() -> ValidationResult {
        guard let pricePaid = stock.pricePaid else {
            return .Valid
        }
        return Validator.validatePrice(price: pricePaid)
    }
    
    func validatePriceToResell() -> ValidationResult {
        guard let priceToResell = stock.priceToResell else {
            return .Valid
        }
        return Validator.validatePrice(price: priceToResell)
    }
    
    func validateSupplyLocation() -> ValidationResult {
        return Validator.validateSupplyLocation(location: stock.supplyLocation)
    }
    
    func isValidData() -> Bool {
        return
            validateQuantity()          == .Valid &&
            validatePricePaid()         == .Valid &&
            validatePriceToResell()     == .Valid &&
            validateSupplyLocation()    == .Valid
    }
    
    func fetchVendors(completion: @escaping () -> ()) {
        let vendorService = VendorService()
        vendorService.fetchVendors(offset: 0) { [weak self] (result) in
            guard let self = self else { return }
            
            switch result {
            case .success(let vendors):
                self.vendors = vendors
                completion()
            case .failure(let error):
                print(error.localizedDescription)
                completion()
            }
        }
    }
    
    func fetchSupplyLocations(completion: @escaping () -> ()) {
        let supplyLocationService = SupplyLocationService()
        supplyLocationService.fetchSupplyLocations(offset: 0) { [weak self] (result) in
            guard let self = self else { return }
            
            switch result {
            case .success(let supplyLocations):
                self.supplyLocations = supplyLocations
                completion()
            case .failure(let error):
                print(error.localizedDescription)
                completion()
            }
        }
    }
    
    func setRemoved(value: Bool) {
        stock.removed = value
    }
    
    func isRemoved()->Bool {
        return stock.removed ?? false
    }
    
    
}
