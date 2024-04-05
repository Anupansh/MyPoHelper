//
//  CreateServiceViewModel.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/26/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

class CreateServiceViewModel {
    
    var serviceType = ServiceType()
    private var isUpdatingService = false
    private let service = ServiceTypeService()
    
    func setService(serviceType: ServiceType) {
        self.serviceType = serviceType
        self.isUpdatingService = true
        self.serviceType.updateModifyDate()
    }
    
    func setDescription(description: String?) {
        serviceType.description = description
    }
    
    func setPriceQuote(price: String?) {
        serviceType.priceQuote = Double(price ?? "")
    }
    
    func getDescription() -> String? {
        return serviceType.description
    }
    
    func getPriceQuote() -> String? {
        guard let price = serviceType.priceQuote else {
            return nil
        }
        return price.stringValue
    }
    
    func validateDescription() -> ValidationResult {
        return Validator.validateDescription(description: getDescription())
    }
    
    func validatePriceQuote() -> ValidationResult {
        guard let price = serviceType.priceQuote else {
            return .Valid
        }
        return Validator.validatePrice(price: price)
    }
    
    private func isValidData() -> Bool {
        return
            validateDescription() == .Valid &&
            validatePriceQuote() == .Valid
    }
    
    func saveServiceType(completion: @escaping (_ error: String?, _ isValidData: Bool) -> ()) {
        if !isValidData() {
            completion(nil, false)
            return
        }
        if isUpdatingService {
            updateServiceType { (error) in
                completion(error, true)
            }
        }
        else {
            createServiceType { (error) in
                completion(error, true)
            }
        }
    }
    
    private func updateServiceType(completion: @escaping (_ error: String?)->()) {
        service.updateServiceType(serviceType: serviceType) { (result) in
            switch result {
            case .success(_):
                completion(nil)
                
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    private func createServiceType(completion: @escaping (_ error: String?)->()) {
        service.createServiceType(serviceType: serviceType) { (result) in
            switch result {
            case .success(_):
                completion(nil)
                
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
}
