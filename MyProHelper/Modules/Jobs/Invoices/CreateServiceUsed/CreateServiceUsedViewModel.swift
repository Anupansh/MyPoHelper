//
//  CreateServiceUsedViewModel.swift
//  MyProHelper
//
//  Created by Deep on 2/7/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

class CreateServiceUsedViewModel {
    
    private var serviceUsed = ServiceUsed()
    private var services: [ServiceType] = []
    private var isEditing = false
    
   
    
    //MARK: - setters
    
    func setQuantity(quantity: String?) {
        guard let quantity = quantity else { return }
        serviceUsed.quantity = Int(quantity)
        guard let price = serviceUsed.serviceType?.priceQuote  else { return }
        serviceUsed.priceToResell = Double(price * Double(quantity)!)
    }
    
    func setPriceToResell(price: String?) {
        guard let price = price else {
            return
        }
        serviceUsed.priceToResell = Double(price)
    }
    
    func setServiceUsed(at index: Int?) {
        guard let index = index, index < services.count else { return }
        serviceUsed.serviceType = services[index]
        serviceUsed.serviceTypeId = serviceUsed.serviceType?.serviceTypeID
        serviceUsed.quantity = 1
        serviceUsed.priceToResell = serviceUsed.serviceType?.priceQuote
    }
    
    func setService(service: ServiceUsed) {
        self.serviceUsed = service
        isEditing = true
    }
    
    //MARK: - Getters
    func getQuantity() -> String? {
        guard let quantity = serviceUsed.quantity else {
            return nil
        }
        return "\(quantity)"
    }
    
    func getPriceToResell() -> String? {
        return serviceUsed.priceToResell?.stringValue
    }
    
    func getServiceUsed() -> String? {
        return serviceUsed.serviceType?.description
    }
    
    func getServices() -> [String] {
        return services.compactMap({ $0.description })
    }
    
    func getService() -> ServiceUsed {
        return serviceUsed
    }
    
    func isUpdateService() -> Bool {
        return isEditing
    }

    
    //MARK: - Validation
    
    func validateQuantity() -> ValidationResult {
        guard let quantity = serviceUsed.quantity  else {
            return .Invalid(message: "Please provide quantity")
        }
        return Validator.validateIntegerValue(value: quantity)
    }
    
    func validatePriceToResell() -> ValidationResult {
        guard let priceToResell = serviceUsed.priceToResell else {
            return .Invalid(message: "Please provide price to resell")
        }
        return Validator.validatePrice(price: priceToResell)
    }
    
    func validateService() -> ValidationResult {
        guard  let serviceName = serviceUsed.serviceType?.description else {
            return .Invalid(message: "Please Select a service")
        }
        return Validator.validateName(name: serviceName)
    }
    
    func isValidData() -> Bool {
        return
            validateQuantity()      == .Valid &&
            validatePriceToResell() == .Valid &&
            validateService()       == .Valid
    }
    
    //MARK: - Database
    
    func fetchServices(completion: @escaping () -> ()) {
        let serviceTypeService = ServiceTypeService()
        
        serviceTypeService.fetchServiceTypes(offset: 0) { [weak self] (result) in
            guard let self = self else { return }
            
            switch result {
            case .success(let services):
                self.services = services
                completion()
            case .failure(let error):
                print(error.localizedDescription)
                completion()
            }
        }
    }
}
