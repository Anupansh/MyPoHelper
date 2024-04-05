//
//  CreateSuppliesUsedViewModel.swift
//  MyProHelper
//
//  Created by Deep on 2/11/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

class CreateSupplyUsedViewModel {
    
    private var supplyUsed = SupplyUsed()
    private var supplyUsedService = SupplyUsedService()
    
    private var vendors: [Vendor] = []
    private var supplyLocations: [SupplyLocation] = []
    private var supplies: [Supply] = []
    
    private var supplyFinder = SupplyFinder()
    
    private var isEditing           = false
    private var hasMoreSupplyFinder = true
    private var hasMoreVendors      = true
    private var hasMoreLocations    = true

    
    //MARK: - Getters
    
    func getFirtOptionLabel() -> String {
        guard let neededQuantity = supplyUsed.quantity, let stock = supplyFinder.quantity else {
            return ""
        }
        return "\(stock) have been installed and waiting for \(neededQuantity - stock) more."
    }
    
    func getSecondOptionLabel() -> String {
        guard let neededQuantity = supplyUsed.quantity else {
            return ""
        }
        return "Not installed and waiting for \(neededQuantity) parts."
    }
    
    func getVendors() -> [String] {
        return vendors.compactMap({ $0.vendorName })
    }
    
    func getSupplies() -> [String] {
        return supplies.compactMap({ $0.supplyName })
    }
    
    func getSupplyLocations() -> [String] {
        return supplyLocations.compactMap({ $0.locationName })
    }
    
    func getQuantity() -> String {
       // return "\(partUsed.quantity), W-\(partUsed.countWaitingFor)"
        return String(supplyUsed.quantity ?? 0)
    }
    
    func getPriceToResell() -> String? {
        supplyUsed.priceToResell = supplyFinder.priceToResell
        return supplyUsed.priceToResell?.stringValue
    }
    
    func getVendorName() -> String? {
        return supplyUsed.vendor?.vendorName
    }
    
    func getSupplyLocation() -> String? {
        return supplyUsed.supplyLocation?.locationName
    }
    
    func getSupplyName() -> String? {
        return supplyUsed.supply?.supplyName
    }
    
    func fetchSupplyLocations(isReload: Bool = true) {
        getLocations(isReload: isReload) {}
    }
    
    func fetchVendorList(isReload: Bool = true) {
        getVendorsList(isReload: isReload) {}
    }
    
//    func fetchSupplyFinders(isReload: Bool = true) {
//        getSupplyFinder(isReload: isReload) {}
//    }
    
    func getSupply() -> SupplyUsed {
        return supplyUsed
    }
    
    
    //MARK: - Setters
    
    func setSupply(supply: SupplyUsed) {
        self.supplyUsed = supply
        isEditing = true
        // ASK samir about this
        // I am refetching the values for the part wanted to be edited
        fetchSupplyLocations()
        fetchVendorList()
    }
    
    func isWaitingForSupply() -> Bool{
        guard let neededQuantity = supplyUsed.quantity, let stock = supplyFinder.quantity else {
            return false
        }
        if neededQuantity > stock {
            return true
        } else {
            return false
        }
    }
    
    func updateCountWaitingFor(selectedOption: Bool) {
        guard let neededQuantity = supplyUsed.quantity, let stock = supplyFinder.quantity else {
            return
        }
        if selectedOption {
            supplyUsed.countWaitingFor = neededQuantity - stock
        }else {
            supplyUsed.countWaitingFor = neededQuantity
        }
        supplyUsed.waitingForSupply = true
    }
    
    func setQuantity(quantity: String?) {
        guard let quantity = quantity else { return }
        supplyUsed.quantity = Int(quantity)
        
        // Can part Finder has many parts with the same partid ??
        guard let price = supplyFinder.priceToResell   else { return }
        supplyUsed.priceToResell = Double(price * Double(quantity)!)
    }
    
    func setPriceToResell(price: String?) {
        guard let price = price else { return }
        supplyUsed.priceToResell = Double(price)
    }
    
    func setVendor(at index: Int?) {
        guard let index = index, index < vendors.count else { return }
        supplyUsed.vendor =  vendors[index]
        supplyUsed.wherePurchased = vendors[index].vendorID
        supplyUsed.vendorName = vendors[index].vendorName
        
        supplyFinder.wherePurchased?.vendorID =  supplyUsed.wherePurchased
        getSupplyFinder(isReload: true) {}
    }
    
    func setSupplyLocation(at index: Int?) {
        guard let index = index, index < supplyLocations.count else { return }
        supplyUsed.supplyLocation     = supplyLocations[index]
        supplyUsed.supplyLocationId   = supplyLocations[index].supplyLocationID
        supplyUsed.supplyLocationName = supplyLocations[index].locationName
        
        supplyFinder.supplyLocationID = supplyUsed.supplyLocationId
    }
    
    func setSupplyName(at index: Int?) {
        guard let index = index, index < supplies.count else { return }
        supplyUsed.supply      = supplies[index]
        supplyUsed.supplyId    = supplies[index].supplyId
        supplyUsed.supplyName  = supplies[index].supplyName
        
        supplyFinder.supplyId = supplyUsed.supplyId
    }
    
    func isUpdatingSupply() -> Bool {
        return isEditing
    }
    
    
    //MARK: - Validation
    
    func validateQuantity() -> ValidationResult {
        guard let quantity = supplyUsed.quantity else {
            return .Invalid(message: "Please enter a valid quantity")
        }
        return Validator.validateIntegerValue(value: quantity)
    }
    
    func validatePriceToResell() -> ValidationResult {
        guard let priceToResell = supplyUsed.priceToResell else {
            return .Valid
        }
        return Validator.validatePrice(price: priceToResell)
    }
    
    func validateSupplyName() -> ValidationResult {
        guard let supplyName = supplyUsed.supply?.supplyName  else {
            return .Invalid(message: "Please select part")
        }
        return Validator.validateName(name: supplyName)
    }
    
    func isValidData() -> Bool {
        return
            validateQuantity()        == .Valid &&
            validatePriceToResell()   == .Valid &&
            validateSupplyName()      == .Valid
    }

    
    //MARK: - Database services
    func fetchSupplies(completion: @escaping () -> ()) {
        let supplyService = SupplyService()
        supplyService.fetchSupplies(showRemoved: false, offset: 0) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let supplies):
                self.supplies = supplies
                completion()
            case .failure(let errror):
                print(errror.localizedDescription)
                completion()
            }
        }
    }
    
    func getLocations(isReload: Bool = true, completion: @escaping () -> ()) {
        if !isReload && !hasMoreLocations { return }
        guard let supplyId = supplyUsed.supplyId else { return }
        let offset = (isReload) ? 0 : supplyLocations.count
        supplyUsedService.fetchSupplyLocations(supplyId: supplyId, offset: offset) { (result) in
            switch result {
            case .success(let locations):
                self.hasMoreLocations = locations.count == Constants.DATA_OFFSET
                if isReload {
                    self.supplyLocations = locations
                }else {
                    self.supplyLocations.append(contentsOf: locations)
                }
                completion()
            case .failure(let error):
                print(error)
                completion()
            }
        }
    }
    
    func getVendorsList(isReload: Bool = true, completion: @escaping () -> ()) {
        if !isReload && !hasMoreVendors {
            return
        }
        guard let supplyId = supplyUsed.supplyId else { return }
        let offset = (isReload) ? 0 : vendors.count
        supplyUsedService.fetchSupplyVendors(supplyId: supplyId, offset: offset) { (result) in
            switch result {
            case .success(let vendors):
                self.hasMoreVendors = vendors.count == Constants.DATA_OFFSET
                if isReload {
                    self.vendors = vendors
                }else {
                    self.vendors.append(contentsOf: vendors)
                }
                completion()
            case .failure(let error):
                print(error)
                completion()
            }
        }
    }
    
//    func getSupplyFinder(isReload: Bool = true, completion: @escaping () -> ()) {
//        if !isReload && !hasMoreVendors { return }
//        guard let supplyId = supplyUsed.supplyId else { return }
//
//        supplyUsedService.fetchSupplyFinder(supplyId: supplyId, offset: true) { (result) in
//            switch result {
//            case .success(let supplies):
//                self.hasMoreSupplyFinder = supplies.count == Constants.DATA_OFFSET
//                if isReload {
//                    self.supplyFinder = supplies
//                }else {
//                    self.supplyFinder.append(contentsOf: supplies)
//                }
//                completion()
//            case .failure(let error):
//                print(error)
//                completion()
//            }
//        }
//    }
    
    func getSupplyFinder(isReload: Bool = true, completion: @escaping () -> ()) {
        supplyUsedService.fetchFinder(supply: supplyFinder) { (result) in
            switch result {
            case .success(let supplyFinder):
                guard let supplyFinder = supplyFinder else {
                    return
                }
                self.supplyFinder = supplyFinder
                self.supplyUsed.supplyFinderId = supplyFinder.supplyFinderId
                print("*** supplyFinder ***", supplyFinder)
                completion()
            case .failure(let error):
                print(error)
                completion()
            }
        }
    }
    
}
