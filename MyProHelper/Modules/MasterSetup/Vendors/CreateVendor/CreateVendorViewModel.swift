//
//  CreateVendorViewModel.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/21/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

class CreateVendorViewModel: BaseAttachmentViewModel {

    
    private var isUpdatingVendor = false
    private let vendorService = VendorService()
    
    var vendor: Box<Vendor> = Box(Vendor())
    
    func setVendor(vendor: Vendor) {
        self.vendor.value = vendor
        self.isUpdatingVendor = true
        self.sourceId = vendor.vendorID
    }
    
    func setVendorName(name: String?) {
        vendor.value.vendorName = name
    }
    
    func setContactName(name: String?) {
        vendor.value.contactName = name
    }
    
    func setPhone(phone: String?) {
        vendor.value.phone = phone
    }
    
    func setEmail(email: String?) {
        vendor.value.email = email
    }
    
    func setAccountNumber(number: String?) {
        vendor.value.accountNumber = number
    }
    
    func setMostRecentContact(date: String?) {
        guard let date = date else { return }
        vendor.value.mostRecentContact = DateManager.stringToDate(string: date)
    }
    
    func getVendorName() -> String? {
        return vendor.value.vendorName
    }
    
    func getVendorPhone() -> String? {
        return vendor.value.phone
    }
    
    func getVendorEmail() -> String? {
        return vendor.value.email
    }
    
    func getVendorContactName() -> String? {
        return vendor.value.contactName
    }
    
    func  getAccountNumber() -> String? {
        return vendor.value.accountNumber
    }
    
    func getMostRecentContact() -> String? {
        return DateManager.getStandardDateString(date: vendor.value.mostRecentContact)
    }
    
    func validateVendorName() -> ValidationResult {
        let name = getVendorName()
        return Validator.validateName(name: name)
    }
    
    func validateVendorPhone() -> ValidationResult {
        guard let phone = getVendorPhone(), !phone.isEmpty else {
            return .Valid
        }
        return Validator.validatePhone(phone: phone)
    }
    
    func validateVendorEmail() -> ValidationResult {
        guard let email = getVendorEmail(), !email.isEmpty else {
            return .Valid
        }
        return Validator.validateEmail(email: email)
    }
    
    func validateVendorContactName() -> ValidationResult {
        guard let name = getVendorContactName(), !name.isEmpty else {
            return .Valid
        }
        return Validator.validateName(name: name)
    }
    
    func validateVendorAccountNumber() -> ValidationResult {
        guard let number = getAccountNumber(), !number.isEmpty else {
            return .Valid
        }
        return Validator.validateAccountNumber(number: number)
    }
    
    func isValidData() -> Bool {
        return
            validateVendorName()            == .Valid &&
            validateVendorPhone()           == .Valid &&
            validateVendorEmail()           == .Valid &&
            validateVendorContactName()     == .Valid &&
            validateVendorAccountNumber()   == .Valid 
    }
    
    
    
    func saveVendor(completion: @escaping (_ error: String?, _ isValidData: Bool) -> ()) {
        if !isValidData() {
            completion(nil, false)
            return
        }
        vendor.value.numberOfAttachments = numberOfAttachment
        if isUpdatingVendor {
            updateVendor { (error) in
                completion(error, true)
            }
        }
        else {
            createVendor { (error) in
                completion(error, true)
            }
        }
    }
    
    private func updateVendor(completion: @escaping (_ error: String?)->()) {
        vendorService.updateVendor(vendor: vendor.value) { [unowned self] (result) in
            switch result {
            case .success(_):
                if let vendorID = self.vendor.value.vendorID {
                    self.saveAttachment(id: vendorID)
                }
                completion(nil)
                
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    private func createVendor(completion: @escaping (_ error: String?)->()) {
        vendorService.createVendor(vendor: vendor.value) { (result) in
            switch result {
            case .success(let vendorID):
                self.vendor.value.vendorID = Int(vendorID)
                self.saveAttachment(id: Int(vendorID))
                completion(nil)
                
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
}
