//
//  Validator.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/14/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

enum ValidationResult: Equatable {
    case Valid
    case Invalid(message: String)
}

struct Validator {
    
    static func validateName(name: String?) -> ValidationResult {
        guard let name = name else {
            return .Invalid(message: Constants.Message.NAME_ERROR)
        }
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .Invalid(message: Constants.Message.NAME_ERROR)
        }
        else {
            return .Valid
        }
    }
    
    static func validatePhone(phone: String?) -> ValidationResult {
        let phoneRegex = "^\\d{3}-\\d{3}-\\d{4}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        if predicate.evaluate(with: phone) {
            return .Valid
        }
        else {
            return .Invalid(message: Constants.Message.EMAIL_ERROR)
        }
    }
    
    static func validateEmail(email: String?) -> ValidationResult {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if predicate.evaluate(with: email) {
            return .Valid
        }
        else {
            return .Invalid(message: Constants.Message.EMAIL_ERROR)
        }
    }
    
    static func validateAddress(address: String?) -> ValidationResult {
        guard let address = address else {
            return .Invalid(message: Constants.Message.ADDRESS_ERROR)
        }
        if address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .Invalid(message: Constants.Message.ADDRESS_ERROR)
        }
        else {
            return .Valid
        }
    }
    
    static func validateCity(city: String?) -> ValidationResult {
        guard let city = city else {
            return .Invalid(message: Constants.Message.CITY_ERROR)
        }
        if city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .Invalid(message: Constants.Message.CITY_ERROR)
        }
        else {
            return .Valid
        }
    }
    
    static func validateState(state: String?) -> ValidationResult {
        guard let state = state else {
            return .Invalid(message: Constants.Message.STATE_ERROR)
        }
        if state.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .Invalid(message: Constants.Message.STATE_ERROR)
        }
        else {
            return .Valid
        }
    }
    
    static func validateZipCode(code: String?) -> ValidationResult {
        guard let code = code else {
            return .Invalid(message: Constants.Message.ZIP_CODE_ERROR)
        }
        let zipRegex = "(^\\d{5}$)|(^\\d{9}$)|(^\\d{5}-\\d{4}$)"
        let predicate = NSPredicate(format: "SELF MATCHES %@", zipRegex)
        if predicate.evaluate(with: code) {
            return .Valid
        }
        else {
            return .Invalid(message: Constants.Message.ZIP_CODE_ERROR)
        }
    }
    
    static func validateDate(date: Date?) -> ValidationResult {
        if date == nil {
            return .Invalid(message: Constants.Message.DATE_ERROR)
        }
        return .Valid
    }
    
    static func validateEndDate(startDate: Date?,endDate: Date?) -> ValidationResult {
        if endDate == nil {
            return .Invalid(message: Constants.Message.DATE_ERROR)
        }
        if startDate == nil {
            return .Valid
        }
        if endDate! <= startDate! {
            return .Invalid(message: Constants.Message.END_DATE_LESS)
        }
        return .Valid
    }
    
    static func validateAccountNumber(number: String?) -> ValidationResult {
        guard let number = number else {
            return .Invalid(message: Constants.Message.ACCOUNT_NUMBER_ERROR)
        }
        if number.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .Invalid(message: Constants.Message.ACCOUNT_NUMBER_ERROR)
        }
        else {
            return .Valid
        }
    }
    
    static func validateDescription(description: String?) -> ValidationResult {
        guard let description = description else {
            return .Invalid(message: Constants.Message.DESCRIPTION_ERROR)
        }
        if description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .Invalid(message: Constants.Message.DESCRIPTION_ERROR)
        }
        else {
            return .Valid
        }
    }
    
    static func validatePrice(price: Double?) -> ValidationResult {
        guard let price = price else {
            return .Invalid(message: Constants.Message.PRICE_ERROR)
        }
        if price >= 0 {
            return .Valid
        }
        else {
            return .Invalid(message: Constants.Message.PRICE_ERROR)
        }
    }
    
    static func validateAssetType(type: AssetType?) -> ValidationResult {
        guard let type = type, type.id != nil else {
            return .Invalid(message: Constants.Message.TYPE_ERRPR)
        }
        return .Valid
    }
    
    static func validateInfo(info: String?) -> ValidationResult {
        guard let info = info else {
            return .Invalid(message: Constants.Message.INFO_ERROR)
        }
        
        if info.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .Invalid(message: Constants.Message.INFO_ERROR)
        }
        else {
            return .Valid
        }
    }
    
    static func validateSerialNumber(number: String?) -> ValidationResult {
        guard let number = number else {
            return .Invalid(message: Constants.Message.SERIAL_NUMBER_ERROR)
        }
        
        if number.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .Invalid(message: Constants.Message.SERIAL_NUMBER_ERROR)
        }
        else {
            return .Valid
        }
    }
    
    static func validateIntegerValue(value: Int?) -> ValidationResult {
        guard let value = value else {
            return .Invalid(message: Constants.Message.GENERIC_FIELD_ERROR)
        }
        if value >= 0 {
            return .Valid
        }
        else {
            return .Invalid(message: Constants.Message.GENERIC_FIELD_ERROR)
        }
    }
    
    static func validatePartLocation(location: PartLocation?) -> ValidationResult {
        guard let location = location, location.partLocationID != nil else {
            return .Invalid(message: "PART_LOCATION_ERROR_MESSAGE".localize)
        }
        return .Valid
    }
    
    static func validateTitle(title: String?) -> ValidationResult {
        guard let title = title else {
            return .Invalid(message: Constants.Message.TITLE_ERROR)
        }
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .Invalid(message: Constants.Message.TITLE_ERROR)
        }
        else {
            return .Valid
        }
    }
    
    static func validateCustomerID(id: Int?) -> ValidationResult {
        guard let id = id else {
            return .Invalid(message: Constants.Message.SELECT_CUSTOMER)
        }
        if id >= 0 {
            return .Valid
        }
        else {
            return .Invalid(message: Constants.Message.SELECT_CUSTOMER)
        }
    }
    
    static func validateSalaryPerTime(salaryType: String?) -> ValidationResult {
        guard let salaryType = salaryType else {
            return .Invalid(message: Constants.Message.SALARY_PER_TIME_ERROR)
        }
        if salaryType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .Invalid(message: Constants.Message.SALARY_PER_TIME_ERROR)
        }
        else {
            return .Valid
        }
    }
    
    static func validateDeviceType(type: String?) -> ValidationResult {
        guard let type = type else {
            return .Invalid(message: "DEVICE_TYPE_ERROR".localize)
        }
        if type.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .Invalid(message: "DEVICE_TYPE_ERROR".localize)
        }
        else {
            return .Valid
        }
    }
    
    static func validateSupplyLocation(location: SupplyLocation?) -> ValidationResult {
        guard let location = location, location.supplyLocationID != nil else {
            return .Invalid(message: "SUPPLY_LOCATION_ERROR_MESSAGE".localize)
        }
        return .Valid
    }
        
}
