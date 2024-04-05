//
//  CreateCustomerViewModel.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 28/05/1942 Saka.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

class CreateCustomerViewModel {
    
    var customer: Box<Customer> = Box(Customer())
    
    private let service = CustomersService()
    private var isUpdatingCustomer = false
    
    func setCustomer(customer: Customer) {
        self.isUpdatingCustomer = true
        self.customer.value = customer
    }
    
    //MARK: - Getting User Data
    func getName() -> String? {
        return customer.value.customerName
    }
    
    func getContactName() -> String? {
        return customer.value.contactName
    }
    
    func getContactPhone() -> String? {
        return customer.value.contactPhone
    }
    
    func getContactEmail() -> String? {
        return customer.value.contactEmail
    }
    
    func getMostRecentContact() -> String? {
        return DateManager.getStandardDateString(date: customer.value.mostRecentContact)
    }
    
    func getBillingAddress() -> String? {
        return customer.value.billingAddress1
    }
    
    func getSecondBillingAddress() -> String? {
        return customer.value.billingAddress2
    }
    
    func getBillingCity() -> String? {
        return customer.value.billingAddressCity
    }
    
    func getBillingState() -> String? {
        return customer.value.billingAddressState
    }
    
    func getBillingZip() -> String? {
        return customer.value.billingAddressZip
    }
    
    //MARK: - Setting User Data
    func setName(name: String?) {
        customer.value.customerName = name
    }
    
    func setContactName(name: String?) {
        customer.value.contactName = name
    }
    
    func setContactPhone(phone: String?) {
        customer.value.contactPhone = phone
    }
    
    func setContactEmail(email: String?) {
        customer.value.contactEmail = email
    }
    
    func setMostRecentContact(contact: String?) {
        customer.value.mostRecentContact = DateManager.stringToDate(string: contact ?? "")
    }
    
    func setInitialMostRecentContact() {
        customer.value.mostRecentContact = Date()
    }
    
    func setBillingAddress(address: String?) {
        customer.value.billingAddress1 = address
    }
    
    func setSecondBillingAddress(address: String?) {
        customer.value.billingAddress2 = address
    }
    
    func setBillingCity(city: String?) {
        customer.value.billingAddressCity = city
    }
    
    func setBillingState(state: String?) {
        customer.value.billingAddressState = state
    }
    
    func setBillingZip(zip: String?) {
        customer.value.billingAddressZip = zip ?? ""
    }
    
    //MARK: - Setting User Data
    func validateName() -> ValidationResult {
        let name = getName()
        return Validator.validateName(name: name)
    }
    
    func validateContactName() -> ValidationResult {
        guard let name = getContactName(), !name.isEmpty else {
            return .Valid
        }
        return Validator.validateName(name: name)
    }
    
    func validateContactPhone() -> ValidationResult {
        let phone = getContactPhone()
        return Validator.validatePhone(phone: phone)
    }
    
    func validateContactEmail() -> ValidationResult  {
        guard let email = getContactEmail(), !email.isEmpty else {
            return .Valid
        }
        return Validator.validateEmail(email: email)
    }
    
    func validateBillingAddress() -> ValidationResult  {
        let address = getBillingAddress()
        return Validator.validateAddress(address: address)
    }
    
    func validateSecondBillingAddress() -> ValidationResult  {
        guard let address = getSecondBillingAddress(), !address.isEmpty else {
            return .Valid
        }
        return Validator.validateAddress(address: address)
    }
    
    func validateBillingCity() -> ValidationResult  {
        let city = getBillingCity()
        return Validator.validateCity(city: city)
    }
    
    func validateBillingState() -> ValidationResult  {
        let state = getBillingState()
        return Validator.validateState(state: state)
    }
    
    func validateBillingZip() -> ValidationResult  {
        guard let code = getBillingZip(), !code.isEmpty else {
            return .Invalid(message: Constants.Message.ZIP_CODE_ERROR)
        }
        return Validator.validateZipCode(code: code)
    }
    
    func isValidData() -> Bool {
        return
            validateName()                  == .Valid &&
            validateContactName()           == .Valid &&
            validateContactPhone()          == .Valid &&
            validateContactEmail()          == .Valid &&
            validateBillingAddress()        == .Valid &&
            validateSecondBillingAddress()  == .Valid &&
            validateBillingState()          == .Valid &&
            validateBillingZip()            == .Valid
    }
    
    //MARK: - perform saving Data
    func saveCustomer(completion: @escaping (_ error: String?, _ isValid: Bool) -> ()) {
        guard isValidData() else {
            completion(nil, false)
            return
        }
        if isUpdatingCustomer {
            update { error in
                completion(error,true)
            }
        }
        else {
            save { error in
                completion(error,true)
            }
        }
    }
    
    private func save(completion: @escaping (_ error: String?) -> ()) {
        service.createCustomer(customer.value, completion: { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let customerID):
                self.customer.value.customerID = Int(customerID)
                completion(nil)
            case .failure(let error):
                completion(error.localizedDescription)
            }
        })
    }
    
    private func update(completion: @escaping (_ error: String?) -> ()) {
        service.updateCustomer(customer.value, completion: { (result) in
            switch result {
            case .success(_):
                completion(nil)
            case .failure(let error):
                completion(error.localizedDescription)
            }
        })
    }
}
