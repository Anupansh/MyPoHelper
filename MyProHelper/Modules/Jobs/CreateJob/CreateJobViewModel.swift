//
//  CreateJobViewModel.swift
//  MyProHelper
//
//  Created by Samir on 12/15/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

class CreateJobViewModel: BaseAttachmentViewModel {
    
    private let service = ScheduleJobService()
    private var job = Job()
    private var isUpdatingJob = false
    private var useDifferentAddress = false
    private var customers: [Customer] = []
    private var workers: [Worker] = []
    private let jobStatus = ["Waiting", "Scheduled", "Invoiced", "Complete", "Rejected"]
    
    func setJob(job: Job) {
        self.isUpdatingJob = true
        self.job = job
        self.sourceId = job.jobID
    }
    
    func canEditDuration() -> Bool {
        return true // will check the current use if has the privilege to change duartion
    }
    
    //MARK: - Getters
    
    func getJobTitle() -> String? {
        job.jobShortDescription
    }
    
    func getCustomerName() -> String? {
        return job.customer?.customerName
    }
    
    func getIssueDescription() -> String? {
        return job.jobDescription
    }
    
    func getWorkerName() -> String? {
        return job.worker?.fullName
    }
    
    func getStartTime() -> String? {
        guard let time = job.startDateTime else {
            return nil
        }
        return DateManager.getStandardDateString(date: time)
    }
    
    func getEndTime() -> String? {
        guard let time = job.endDateTime else {
            return nil
        }
        return DateManager.getStandardDateString(date: time)
    }
    
    func getEstimateDuration() -> String? {
        return job.estimateTimeDuration
    }
    
    func getJobStatus() -> String? {
        return job.jobStatus
    }
    
    func setJobStatus(status: String) {
        job.jobStatus = status
    }
    
    func getContactName() -> String? {
        return job.jobContactPersonName
    }
    
    func getContactPhone() -> String? {
        return job.jobContactPhone
    }
    
    func getContactEmail() -> String? {
        return job.jobContactEmail
    }
    
    func getContactAddressOne() -> String? {
        return job.jobLocationAddress1
    }
    
    func getContactAddressTwo() -> String? {
        return job.jobLocationAddress2
    }
    
    func getContactCity() -> String? {
        return job.jobLocationCity
    }
    
    func getContactState() -> String? {
        return job.jobLocationState
    }
    
    func getContactZip() -> String? {
        return job.jobLocationZip
    }
    
    func getWorkers() -> [String] {
        return workers.compactMap({ $0.fullName })
    }
    
    func getCustomers() -> [String] {
        return customers.compactMap({ $0.customerName })
    }
    
    func getAllJobStatus() -> [String] {
        return jobStatus
    }
    
    //MARK: - Setters
    
    func setJobTitle(title: String?) {
        job.jobShortDescription = title
    }
    
    func setIssueDescription(description: String?) {
        job.jobDescription = description
    }
    
    func  setPersonName(name: String?){
        job.jobContactPersonName = name
    }
    
    func setPhone(phone: String?) {
        job.jobContactPhone = phone
    }
    
    func setEmail(email: String?) {
        job.jobContactEmail = email
    }
    
    func setAddressOne(address: String?) {
        job.jobLocationAddress1 = address
    }
    
    func setAddressTwo(address: String?) {
        job.jobLocationAddress2 = address
    }
    
    func setCity(city: String?) {
        job.jobLocationCity = city
    }
    
    func setState(state: String?) {
        job.jobLocationState = state
    }
    
    func setZip(zip: String?) {
        job.jobLocationZip = zip
    }
    
    func setStartTimeDate(time: String?) {
        guard let time = time else { return }
        job.startDateTime = DateManager.stringToDate(string: time)
        calculateDuration()
    }
    
    func setEndTimeDate(time: String?) {
        guard let time = time else { return }
        job.endDateTime = DateManager.stringToDate(string: time)
        calculateDuration()
    }
    
    func setStartTimeDate(time: Date?) {
        guard let time = time else { return }
        job.startDateTime = time
    }
    
    func setEndTimeDate(time: Date?) {
        guard let time = time else { return }
        job.endDateTime = time
    }
    
    func setEstimateDuration(duration: String?) {
        job.estimateTimeDuration = duration
    }
    
    func setInitialDuration() {
        let jobDuration = DBHelper.getCompanyInformation().minimumJobDuration
        let date = Calendar.current.date(bySettingHour: 0, minute: Int(jobDuration)!, second: 0, of: Date())
        let duration = DateManager.timeFrameToString(date: date)
        self.setEstimateDuration(duration: duration)
    }
    
    func setCustomer(at index: Int) {
        let customer = customers[index]
        job.customerID = customer.customerID
        job.customer = customer
        syncAddressInfo(customer: customer)
    }
    
    func setCustomer(with customer: Customer) {
        job.customerID = customer.customerID
        job.customer = customer
        syncAddressInfo(customer: customer)
    }
    
    func setUseDifferentAddress(isDifferent: Bool) {
        if isDifferent {
            useDifferentAddress = true
            setAddressOne(address: nil)
            setAddressTwo(address: nil)
            setCity(city: nil)
            setState(state: nil)
            setZip(zip: nil)
        }
        else {
            useDifferentAddress = false
            setAddressOne(address: job.customer?.billingAddress1)
            setAddressTwo(address: job.customer?.billingAddress2)
            setCity(city: job.customer?.billingAddressCity)
            setState(state: job.customer?.billingAddressState)
            setZip(zip: job.customer?.billingAddressZip)
        }
    }
    
    private func syncAddressInfo(customer: Customer) {
        guard useDifferentAddress == false else { return }
        
        job.jobLocationAddress1 = customer.billingAddress1
        job.jobLocationAddress2 = customer.billingAddress2
        job.jobLocationCity     = customer.billingAddressCity
        job.jobLocationState    = customer.billingAddressState
        job.jobLocationZip      = customer.billingAddressZip
    }
    
    func setWorker(at index: Int) {
        let worker = workers[index]
        job.workerScheduled = worker.workerID
        job.worker = worker
    }
    
    func setWorker(with worker: Worker) {
        job.workerScheduled = worker.workerID
        job.worker = worker
    }
    
    func setStatus(at index: Int) {
        job.jobStatus = jobStatus[index]
    }
    
    func syncScheduleJob(scheduledJob: ScheduleJobModel) {
        guard let worker = scheduledJob.worker else { return }
        setWorker(with: worker)
        setStartTimeDate(time: scheduledJob.startTime)
        setEndTimeDate(time: scheduledJob.endTime)
        setEstimateDuration(duration: scheduledJob.duration)
    }
    
    func getWorker(atIndex: Int) -> Worker {
        return workers[atIndex]
    }
    
    private func calculateDuration() {
        if let startTime = job.startDateTime , let endTime = job.endDateTime {
            let timeInerval = endTime.distance(to: startTime)
            let date = Date(timeIntervalSince1970: timeInerval)
            job.estimateTimeDuration = DateManager.timeFrameToString(date: date)
        }
    }
    
    //MARK: - Data Validation
    func validateJobTitle() -> ValidationResult{
        return Validator.validateTitle(title: job.jobShortDescription)
    }
    
    func validateCustomer() -> ValidationResult {
        return Validator.validateCustomerID(id: job.customerID)
    }
    
    func validateIsssueDescription() -> ValidationResult {
        return Validator.validateDescription(description: job.jobDescription)
    }
    
    func validateWorkerName() -> ValidationResult {
        return Validator.validateName(name: job.worker?.fullName)
    }
    
    func validateStartTime() -> ValidationResult {
        return Validator.validateDate(date: job.startDateTime)
    }
    
    func validateEndTime() -> ValidationResult {
        return Validator.validateEndDate(startDate: job.startDateTime, endDate: job.endDateTime)
    }
    
    func validatePersonName() -> ValidationResult {
        return Validator.validateName(name: job.jobContactPersonName)
    }
    
    func validatePersonPhone() -> ValidationResult {
        return Validator.validatePhone(phone: job.jobContactPhone)
    }
    
    func validatePersonEmail() -> ValidationResult {
        guard let email = job.jobContactEmail, !email.isEmpty else {
            return .Valid
        }
        return Validator.validateEmail(email: email)
    }
    
    func validateAddressOne() -> ValidationResult {
        return Validator.validateAddress(address: job.jobLocationAddress1)
    }
    
    func validateAddressTwo() -> ValidationResult {
        guard let address = job.jobLocationAddress2, !address.isEmpty else {
            return .Valid
        }
        return Validator.validateAddress(address: address)
    }
    
    func validateCity() -> ValidationResult {
        return Validator.validateCity(city: job.jobLocationCity)
    }
    
    func validateState() -> ValidationResult {
        return Validator.validateState(state: job.jobLocationState)
    }
    
    func validateZip() -> ValidationResult {
        return Validator.validateZipCode(code: job.jobLocationZip)
    }
    
    func isValidData() -> Bool {
        return validateJobTitle()           == .Valid &&
            validateIsssueDescription()     == .Valid &&
            validateWorkerName()            == .Valid &&
            validateStartTime()             == .Valid &&
            validateEndTime()               == .Valid &&
            validatePersonName()            == .Valid &&
            validatePersonPhone()           == .Valid &&
            validatePersonEmail()           == .Valid &&
            validateAddressOne()            == .Valid &&
            validateAddressTwo()            == .Valid &&
            validateCity()                  == .Valid &&
            validateState()                 == .Valid &&
            validateZip()                   == .Valid
    }
    
    //MARK: - DB Requests
    func fetchWorkers(completion: @escaping ()->()) {
        let workerService = WorkersService()
        workerService.fetchWorkers(offset: 0) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let workers):
                self.workers = workers
                completion()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchCustomers(completion: @escaping ()->()) {
        let customerService = CustomersService()
        customerService.fetchCustomers(offset: 0) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let customers):
                self.customers = customers
                completion()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func saveJob(completion: @escaping (_ error: String?, _ isValid: Bool) -> ()) {
        guard isValidData() else {
            completion(nil, false)
            return
        }
        job.numberOfAttachments = numberOfAttachment
        
        if isUpdatingJob {
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
        service.createJob(job) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let jobId):
                self.saveJobWorkers(with: Int(jobId))
                completion(nil)
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    private func update(completion: @escaping (_ error: String?) -> ()) {
        service.updateJob(job: job) { (result) in
            switch result {
            case .success(_):
                if let jobId = self.job.jobID {
                    self.saveAttachment(id: jobId)
                }
                completion(nil)
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    private func saveJobWorkers(with jobId: Int) {
        let jobsWorkersService = JobsWorkersService()

        var jobsWorkers = JobsWorkers()
        jobsWorkers.workerId = self.job.worker?.workerID
        jobsWorkers.scheduledJobId = jobId
        
        jobsWorkersService.createJobsWorker(jobsWorkers: jobsWorkers) { (result) in
            switch result {
            case .success(_):
                self.saveAttachment(id: jobId)
            case .failure(let error):
                print(error)
            }
        }
    }
}
