//
//  ShowJobHistoryViewModel.swift
//  MyProHelper
//
//  Created by Deep on 1/27/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

class ShowJobHistoryViewModel: BaseAttachmentViewModel {
    
    private var isUpdatingJobHistory = false
    private let jobHistoryService = CustomerJobHistoryService()
    
    var jobHistory: Box<CustomerJobHistory> = Box(CustomerJobHistory())
    
    //MARK: - SETTERS
    
    func setJobHistory(jobHistory: CustomerJobHistory){
        self.jobHistory.value = jobHistory
        self.isUpdatingJobHistory = true
        self.sourceId = jobHistory.jobID
    }

    func setCustomerName(name: String?){
        jobHistory.value.customer?.customerName = name
    }
    
    func setJobLocationAddress1(address: String?){
        jobHistory.value.jobLocationAddress1 = address
    }
    
    func setJobLocationAddress2(address: String?){
        jobHistory.value.jobLocationAddress2 = address
    }
    
    func setJobLocationCity(city: String?){
        jobHistory.value.jobLocationCity = city
    }
    
    
    func setJobLocationState(state: String?){
        jobHistory.value.jobLocationState = state
    }
    
    func setJobLocationZip(LocationZip: String?){
        jobHistory.value.jobLocationZip = LocationZip
    }
    
    
    func setContactPersonName(name: String?) {
        jobHistory.value.jobContactPersonName = name
    }
    
    func setJobContactPhone(phone: String?) {
        jobHistory.value.jobContactPhone = phone
    }
    
    func setJobContactEmail(email: String?) {
        jobHistory.value.jobContactEmail = email
    }
    
    func setJobShortDescription(description: String?) {
        jobHistory.value.jobShortDescription = description
    }
    
    func setJobDescription(description: String?) {
        jobHistory.value.jobDescription = description
    }
    
    func setJobStartDate(date: String?){
        guard let date = date else { return }
        jobHistory.value.startDateTime = DateManager.stringToDate(string: date)
    }
    
    func setSheduledWorker(worker: String?) {
        guard let worker = worker else { return }
        jobHistory.value.workerScheduled = Int(worker) ?? 0
    }
    
    func setStatus(status: String?){
        jobHistory.value.jobStatus = status
    }
    
    func setJobPrice(price: String?){
        guard let price = price else { return }
        jobHistory.value.jobPrice = Float(price) ?? 0.0
    }
    
    func setSalesTax(tax: String?) {
        guard let tax = tax else { return }
        jobHistory.value.salesTax =  Float(tax) ?? 0.0
    }
    
    func setPaid(paid: String?) {
        guard let paid = paid else {return}
        jobHistory.value.paid = Bool(paid) ?? false
    }
    
    //MARK: - Getters
    
    func getCustomerName() -> String? {
         return jobHistory.value.customer?.customerName
    }
    
    func getJobLocationAddress1() -> String?{
        return jobHistory.value.jobLocationAddress1
    }
    
    func getJobLocationAddress2() -> String? {
        return jobHistory.value.jobLocationAddress2
    }
    
    func getJobLocationCity() -> String? {
        return jobHistory.value.jobLocationCity
    }
    
    
    func getJobLocationState() -> String?{
        return jobHistory.value.jobLocationState
    }
    
    func getJobLocationZip() -> String? {
        return jobHistory.value.jobLocationZip
    }
    
    
    func getContactPersonName() -> String? {
        return jobHistory.value.jobContactPersonName
    }
    
    func getJobContactPhone() -> String? {
        return jobHistory.value.jobContactPhone
    }
    
    func getJobContactEmail() -> String? {
        return jobHistory.value.jobContactEmail
    }
    
    func getJobShortDescription() -> String? {
        return jobHistory.value.jobShortDescription
    }
    
    func getJobDescription() -> String? {
        return jobHistory.value.jobDescription
    }
    
    func getJobStartDate() -> String? {
        return DateManager.getStandardDateString(date: jobHistory.value.startDateTime)
    }
    
    func getSheduledWorker() -> String? {
        guard  let  workerFirstName = jobHistory.value.worker?.firstName,
               let  workerLastName = jobHistory.value.worker?.lastName else {
            return nil
        }
        return "\(workerFirstName) " + "\(workerLastName)"
    }
    
    func getStatus() -> String? {
        return jobHistory.value.jobStatus
    }
    
    func getJobPrice() -> String? {
        return String(jobHistory.value.jobPrice ?? 0.0)
    }
    
    func getSalesTax() -> String?{
        return String(jobHistory.value.salesTax ?? 0.0)
    }
    
    func getPaid() -> String? {
        return getYesOrNo(paid: jobHistory.value.paid)
    }
    
    func getYesOrNo (paid: Bool?) -> String {
        if let paid = paid {
            if paid {
                return "Yes"
            }else {
                return "No"
            }
        }else {
            return "No"
        }
    }
    
    //MARK: - Data Validation
    
    func validateCustomerName() -> ValidationResult{
        return Validator.validateName(name: jobHistory.value.customer?.contactName)
    }
    
    func validateAddress1() -> ValidationResult {
        return Validator.validateAddress(address:  jobHistory.value.jobLocationAddress1)
    }
    
    func validateAddress2() -> ValidationResult {
        guard let address = jobHistory.value.jobLocationAddress1, !address.isEmpty else {
            return .Valid
        }
        return Validator.validateAddress(address: address)
    }
    
    func validateCity() -> ValidationResult {
        return Validator.validateCity(city: jobHistory.value.jobLocationCity)
    }
    
    func validateState() -> ValidationResult {
        return Validator.validateState(state: jobHistory.value.jobLocationState)
    }
    
    func validateZip() -> ValidationResult {
        return Validator.validateZipCode(code: jobHistory.value.jobLocationZip)
    }
    
    func validateContactPersonName() -> ValidationResult {
        return Validator.validateName(name: jobHistory.value.jobContactPersonName)
    }
    
    func validatePersonEmail() -> ValidationResult {
        guard let email = jobHistory.value.jobContactEmail, !email.isEmpty else {
            return .Valid
        }
        return Validator.validateEmail(email: email)
    }
    
    func validateContactPhone() -> ValidationResult {
        return Validator.validatePhone(phone: jobHistory.value.jobContactPhone)
    }
    
    func isValidData() -> Bool {
        return validateCustomerName()              == .Valid &&
            validateAddress1()                     == .Valid &&
            validateAddress2()                     == .Valid &&
            validateCity()                         == .Valid &&
            validateState()                        == .Valid &&
            validateZip()                          == .Valid &&
            validateContactPersonName()            == .Valid &&
            validatePersonEmail()                  == .Valid &&
            validateCity()                         == .Valid &&
            validateState()                        == .Valid &&
            validateZip()                          == .Valid
    }
    
    func saveJobHistory(completion: @escaping (_ error: String?, _ isValidData: Bool) -> ()) {
        if !isValidData() {
            completion(nil, false)
            return
        }
        jobHistory.value.numberOfAttachments = numberOfAttachment
        if isUpdatingJobHistory {
            updateJobHistory { (error) in
                completion(error, true)
            }
        }
    }
    
    // TBD
    // ERROR IN UPDATING WORKER SCHEDULED
    // WHAT DOES SHE MEAN BY WORKER SCEDULED ? TO CHANGE THE WORKER
    private func updateJobHistory(completion: @escaping (_ error: String?)->()) {
        jobHistoryService.updateJobHistory(jobHistory: jobHistory.value) { [unowned self] (result) in
            switch result {
            case .success(_):
                if let jobId = self.jobHistory.value.jobID {
                    self.saveAttachment(id: jobId)
                }
                completion(nil)
                
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
}
