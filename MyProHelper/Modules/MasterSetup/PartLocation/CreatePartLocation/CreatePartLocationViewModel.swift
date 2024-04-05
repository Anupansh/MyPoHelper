//
//  CreatePartLocationViewModel.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/22/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

class CreatePartLocationViewModel {
    
    var partLocation:Box<PartLocation> = Box(PartLocation())
    private var isUpdatingPartLocation = false
    private let partLocationService = PartLocationService()
    
    func setPartLocation(partLocation: PartLocation) {
        self.partLocation.value = partLocation
        self.isUpdatingPartLocation = true
        self.partLocation.value.updateModifyDate()
    }
    
    func getName() -> String? {
        return partLocation.value.locationName
    }
    
    func getDescription() -> String? {
        return partLocation.value.locationDescription
    }
    
    func setName(name: String?) {
        partLocation.value.locationName = name
    }
    
    func setDescription(description: String?) {
        partLocation.value.locationDescription = description
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
    
    func savePartLocation(completion: @escaping (_ error: String?, _ isValidData: Bool) -> ()) {
        if !isValidData() {
            completion(nil, false)
            return
        }
        if isUpdatingPartLocation {
            updatePartLocation { (error) in
                completion(error, true)
            }
        }
        else {
            createPartLocation { (error) in
                completion(error, true)
            }
        }
    }
    
    private func updatePartLocation(completion: @escaping (_ error: String?)->()) {
        partLocationService.updatePartLocations(partLocation: partLocation.value) { (result) in
            switch result {
            case .success(_):
                completion(nil)
                
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    private func createPartLocation(completion: @escaping (_ error: String?)->()) {
        partLocationService.createPartLocations(partLocation: partLocation.value) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let locationID):
                self.partLocation.value.partLocationID = Int(locationID)
                completion(nil)
                
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
}
