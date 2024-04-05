//
//  CreatePartsUsedViewModel.swift
//  MyProHelper
//
//  Created by Deep on 2/9/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

class CreatePartUsedViewModel {
    
    private var partUsed = PartUsed()
    private var partUsedService = PartsUsedService()
    
    private var vendors: [Vendor] = []
    private var partLocations: [PartLocation] = []
    private var parts: [Part] = []
    
    private var partFinder =  PartFinder()
    
    private var isEditing         = false
    private var hasMorePartFinder = true
    private var hasMoreVendors    = true
    private var hasMoreLocations  = true
    
    func isWaitingForPart() -> Bool{
        guard let neededQuantity = partUsed.quantity, let stock = partFinder.quantity else {
            return false
        }
        if neededQuantity > stock {
            return true
        } else {
            return false
        }
    }
    
    //MARK: - Getters
    
    func getFirtOptionLabel() -> String {
        guard let neededQuantity = partUsed.quantity, let stock = partFinder.quantity else {
            return ""
        }
        return "\(stock) have been installed and waiting for \(neededQuantity - stock) more."
    }
    
    func getSecondOptionLabel() -> String {
        guard let neededQuantity = partUsed.quantity else {
            return ""
        }
        return "Not installed and waiting for \(neededQuantity) parts."
    }
    
    func getVendors() -> [String] {
        return vendors.compactMap({ $0.vendorName })
    }
    
    func getParts() -> [String] {
        return parts.compactMap({ $0.partName })
    }
    
    func getPartLocations() -> [String] {
        return partLocations.compactMap({ $0.locationName })
    }
    
    func getQuantity() -> String {
       // return "\(partUsed.quantity), W-\(partUsed.countWaitingFor)"
        return String(partUsed.quantity ?? 0)
    }
    
    func getPriceToResell() -> String? {
        partUsed.priceToResell = partFinder.priceToResell
        return partUsed.priceToResell?.stringValue
    }
    
    func getVendor() -> String? {
        return partUsed.vendor?.vendorName
    }
    
    func getPartLocation() -> String? {
        return partUsed.partLocation?.locationName
    }
    
    func getPartName() -> String? {
        return partUsed.part?.partName
    }
    
    func fetchPartLocations(isReload: Bool = true) {
        getLocations(isReload: isReload) {}
    }
    
    func fetchVendorList(isReload: Bool = true) {
        getVendorsList(isReload: isReload) {}
    }
    
    func getPart() -> PartUsed {
        return partUsed
    }
    
    //MARK: - Setters
    
    func setPart(part: PartUsed) {
        self.partUsed = part
        isEditing = true
        fetchPartLocations()
        fetchVendorList()
    }
    
    func updateCountWaitingFor(selectedOption: Bool) {
        guard let neededQuantity = partUsed.quantity, let stock = partFinder.quantity else {
            return
        }
        if selectedOption {
            partUsed.countWaitingFor = neededQuantity - stock
        }else {
            partUsed.countWaitingFor = neededQuantity
        }
        partUsed.waitingForPart = true
    }
    
    func setQuantity(quantity: String?) {
        guard let quantity = quantity else { return }
        partUsed.quantity = Int(quantity)
        guard let price = partFinder.priceToResell   else { return }
        partUsed.priceToResell = Double(price * Double(quantity)!)
    }
    
    func setPriceToResell(price: String?) {
        guard let price = price else { return }
        partUsed.priceToResell = Double(price)
    }
    
    func setVendor(at index: Int?) {
        guard let index = index, index < vendors.count else { return }
        partUsed.vendor =  vendors[index]
        partUsed.wherePurchased = vendors[index].vendorID
        
        partFinder.vendorId =  partUsed.wherePurchased
        getPartFinder(isReload: true) {}
    }
    
    func setPartLocation(at index: Int?) {
        guard let index = index, index < partLocations.count else { return }
        partUsed.partLocation = partLocations[index]
        partUsed.partLocationId = partLocations[index].partLocationID
        partFinder.partLocationId = partUsed.partLocationId
    }
    
    func setPartName(at index: Int?) {
        guard let index = index, index < parts.count else { return }
        partUsed.part = parts[index]
        partUsed.partID = partUsed.part?.partID
        partFinder.partID = partUsed.partID
    }
    
    func isUpdatingPart() -> Bool {
        return isEditing
    }
    
    //MARK: - Validation
    
    func validateQuantity() -> ValidationResult {
        guard let quantity = partUsed.quantity else {
            return .Invalid(message: "Please enter a valid quantity")
        }
        return Validator.validateIntegerValue(value: quantity)
    }
    
    func validatePriceToResell() -> ValidationResult {
        guard let priceToResell = partUsed.priceToResell else {
            return .Valid
        }
        return Validator.validatePrice(price: priceToResell)
    }
    
    func validatePartLocation() -> ValidationResult {
        guard let location = partUsed.partLocation  else {
            return .Invalid(message: "Please select a location")
        }
        return Validator.validatePartLocation(location: location)
    }
    
    func validatePartName() -> ValidationResult {
        guard let partName = partUsed.part?.partName  else {
            return .Invalid(message: "Please select part")
        }
        return Validator.validateName(name: partName)
    }
    
    func isValidData() -> Bool {
        return
            validateQuantity()      == .Valid &&
            validatePriceToResell() == .Valid &&
            validatePartLocation()  == .Valid &&
            validatePartName()      == .Valid
    }
    
    //MARK: - Database services
    
    func fetchParts(completion: @escaping () -> ()) {
        let partsService = PartsService()
        partsService.fetchParts(showRemoved: false, offset: 0) { [weak self] (result) in
            guard let self = self else { return }
            
            switch result {
            case .success(let parts):
                self.parts = parts
                completion()
            case .failure(let errror):
                print(errror.localizedDescription)
                completion()
            }
        }
    }
    
    func getLocations(isReload: Bool = true, completion: @escaping () -> ()) {
        if !isReload && !hasMoreLocations {
            return
        }
        guard let partID = partUsed.partID else {
            return
        }
        
        let offset = (isReload) ? 0 : partLocations.count
        partUsedService.fetchPartLocationList(partId: partID, offset: offset) { (result) in
            switch result {
            case .success(let locations):
                self.hasMoreLocations = locations.count == Constants.DATA_OFFSET
                if isReload {
                    self.partLocations = locations
                }else {
                    self.partLocations.append(contentsOf: locations)
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
        guard let partID = partUsed.partID else {
            return
        }
        
        let offset = (isReload) ? 0 : vendors.count
        
        partUsedService.fetchPartVendors(partId: partID, offset: offset) { (result) in
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
    
    func getPartFinder(isReload: Bool = true, completion: @escaping () -> ()) {
        partUsedService.fetchFinder(part: partFinder) { (result) in
            switch result {
            case .success(let partFinder):
                guard let partFinder = partFinder else {
                    return
                }
                self.partFinder = partFinder
                self.partUsed.partFinderId = partFinder.partFinderId
                completion()
            case .failure(let error):
                print(error)
                completion()
            }
        }
    }
}

