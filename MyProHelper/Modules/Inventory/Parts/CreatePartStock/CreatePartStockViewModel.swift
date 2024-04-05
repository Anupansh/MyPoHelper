//
//  CreatePartStockViewModel.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 11/9/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

class CreatePartStockViewModel {
    
    private var stock = PartFinder()
    private var vendors: [Vendor] = []
    private var partLocations: [PartLocation] = []
    private var isEditing = false
    
    func setStock(stock: PartFinder) {
        self.stock = stock
        isEditing = true
    }
    
    func getStock() -> PartFinder {
        return stock
    }
    
    func getVendors() -> [String] {
        return vendors.compactMap({ $0.vendorName })
    }
    
    func getPartLocations() -> [String] {
        return partLocations.compactMap({ $0.locationName })
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
        return DateManager.getStandardDateString(date: stock.lastPurchased)
    }
    
    func getVendor() -> String? {
        return stock.wherePurchased?.vendorName
    }
    
    func getPartLocation() -> String? {
        return stock.partLocation?.locationName
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
    
    func setPartLocation(at index: Int?) {
        guard let index = index, index < partLocations.count else { return }
        stock.partLocation = partLocations[index]
    }
    
    func setPartLocation(partLocation: PartLocation) {
        stock.partLocation = partLocation
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
    
    func canEditPartLocation() -> Bool {
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
    
    func validatePartLocation() -> ValidationResult {
        return Validator.validatePartLocation(location: stock.partLocation)
    }
    
    func isValidData() -> Bool {
        return
            validateQuantity()      == .Valid &&
            validatePricePaid()     == .Valid &&
            validatePriceToResell() == .Valid &&
            validatePartLocation()  == .Valid
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
    
    func fetchPartLocations(completion: @escaping () -> ()) {
        let partLocationService = PartLocationService()
        partLocationService.fetchPartLocations(offset: 0) { [weak self] (result) in
            guard let self = self else { return }
            
            switch result {
            case .success(let partLocations):
                self.partLocations = partLocations
                completion()
            case .failure(let error):
                print(error.localizedDescription)
                completion()
            }
        }
    }
}
