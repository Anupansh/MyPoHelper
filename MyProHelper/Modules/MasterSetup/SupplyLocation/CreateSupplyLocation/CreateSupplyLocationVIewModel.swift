//
//  CreateSupplyLocationVIewModel.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/25/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

class CreateSupplyLocationViewModel {
    
    var supplyLocation:Box<SupplyLocation> = Box(SupplyLocation())
    private var isUpdatingSupplyLocation = false
    private let supplyLocationService = SupplyLocationService()
    
    func setSupplyLocation(supplyLocation: SupplyLocation) {
        self.supplyLocation.value = supplyLocation
        self.isUpdatingSupplyLocation = true
        self.supplyLocation.value.updateModifyDate()
    }
    
    func getName() -> String? {
        return supplyLocation.value.locationName
    }
    
    func getDescription() -> String? {
        return supplyLocation.value.locationDescription
    }
    
    func setName(name: String?) {
        supplyLocation.value.locationName = name
    }
    
    func setDescription(description: String?) {
        supplyLocation.value.locationDescription = description
    }
    
    func validateName() -> ValidationResult {
        return Validator.validateName(name: getName())
    }
    
    func validateDescription() -> ValidationResult {
        guard let description = getDescription(), !description.isEmpty else {
            return .Valid
        }
        return Validator.validateDescription(description: description)
    }
    
    private func isValidData() -> Bool {
        return validateName() == .Valid &&
            validateDescription() == .Valid
    }
    
    func saveSupplyLocation(completion: @escaping (_ error: String?, _ isValidData: Bool) -> ()) {
        if !isValidData() {
            completion(nil, false)
            return
        }
        if isUpdatingSupplyLocation {
            updateSupplyLocation { (error) in
                completion(error, true)
            }
        }
        else {
            createSupplyLocation { (error) in
                completion(error, true)
            }
        }
    }
    
    private func updateSupplyLocation(completion: @escaping (_ error: String?)->()) {
        supplyLocationService.updateSupplyLocation(supplyLocation: supplyLocation.value) { (result) in
            switch result {
            case .success(_):
                completion(nil)
                
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    private func createSupplyLocation(completion: @escaping (_ error: String?)->()) {
        supplyLocationService.createSupplyLocation(supplyLocation: supplyLocation.value) { (result) in
            switch result {
            case .success(let supplyLocation):
                self.supplyLocation.value = supplyLocation
                completion(nil)
                
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
}
