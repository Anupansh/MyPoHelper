//
//  CreateJobDetailViewModel.swift
//  MyProHelper
//
//  Created by sismac010 on 08/07/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

class CreateJobDetailViewModel: BaseAttachmentViewModel {
    
    private var jobDetail = JobDetail()
    private var customers: [Customer] = []
    private var isUpdatingJobDetail = false
    private var jobDetailService = JobDetailService()
    private var jobList = DBHelper.getScheduledJobs()
    private var jobs: [Job] = []
    private var hasMoreItems = false
    private var lineItems: [JobDetailLineItem] = []
    
    func setJobDetail(jobDetail: JobDetail) {
        self.isUpdatingJobDetail = true
        self.jobDetail = jobDetail
        self.sourceId = jobDetail.jobDetailID
        self.jobDetail.updateModifyDate()
    }
    
    func isNewRecord()->Bool{
        return jobDetail.jobDetailID == nil
    }
    
    func getLineItems() -> [JobDetailLineItem] {
        return lineItems
    }
    
    func getLineItem(at index: Int) -> JobDetailLineItem? {
        guard lineItems.count > index else { return nil }
        return lineItems[index]
    }
    
    func validateCustomer() -> ValidationResult {
        guard let customerName = jobDetail.customer?.customerName, !customerName.isEmpty else {
            return .Valid
        }
        return .Valid
    }
    
    func validateJob() -> ValidationResult {
        guard let _ = jobDetail.jobID else {
            return .Invalid(message: "Please select job.")
        }
        return .Valid
    }

    func validateCustomer2() -> ValidationResult {
        guard let customerName = jobDetail.customer?.customerName, !customerName.isEmpty else {
            return .Invalid(message: "Please select customer!")
        }
        return .Valid
    }
    
    func setJobs(at index: Int?) {
        guard let index = index, index < jobs.count else { return }
        jobDetail.scheduledJob = jobs[index]
        jobDetail.jobID = jobDetail.scheduledJob?.jobID
    }
    
    func getJobShortDescription2() -> String? {
        return jobDetail.scheduledJob?.jobShortDescription
    }
    
    func resetJob(){
        jobDetail.jobID = nil
        jobDetail.scheduledJob = nil
    }
    
    
    func getJobs() -> [String] {
        return jobs.compactMap({ $0.jobShortDescription })
    }
    
    func getJobs(completion: @escaping () -> ()) {
        let scheduleJobService = ScheduleJobService()
        let id = getCustomerID() ?? 0
        scheduleJobService.fetchJobs(customerId: id,offset: 0) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let jobs):
                self.jobs.removeAll()
                self.jobs.append(contentsOf: jobs)
                completion()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    func setCustomer(at index: Int?) {
        guard let index = index, index < customers.count else { return }
//        if index == 0{
//            let customer = customers[index]
//            expenseStatements.customerName = customer.customerName
//            return
//        }
        if jobDetail.customer != nil , jobDetail.customer?.customerID != customers[index].customerID{
            resetJob()
        }
        jobDetail.customer? = customers[index]
        jobDetail.customerID = jobDetail.customer?.customerID
        
//        expenseStatements.customerId = expenseStatements.customer?.customerID
//        expenseStatements.customerName = expenseStatements.customer?.customerName
    }
    
    func setJobDetail(at index: Int?) {
        guard let index = index, index < jobList.count else { return }
        jobDetail.scheduledJob = jobList[index]
        jobDetail.jobID = jobList[index].jobID
    }
    
    
    func getCustomers(completion: @escaping () -> ()) {
        let customersService = CustomersService()
        customersService.fetchCustomers(showSelect: false,offset: 0) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let customers):
                // Local added because values is not stored in db
//                var customer = Customer()
//                customer.customerName = Constants.DefaultValue.SELECT_LIST
                self.customers.removeAll()
//                self.customers.append(customer)
                self.customers.append(contentsOf: customers)
                
//                self.customers = customers
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getCustomers() -> [String] {
        return customers.compactMap({ $0.customerName })
    }
    
    func getJobList() -> [String] {
        return jobList.compactMap({ $0.jobShortDescription})
    }
    
    func getCustomer() -> String? {
        return jobDetail.customer?.customerName
    }
    
    func getJobTitle() -> String? {
        return jobDetail.scheduledJob!.jobShortDescription
    }
    func getCustomerID() -> Int? {
        return jobDetail.customer?.customerID
    }
    
    func validatejobShortDescription() -> ValidationResult {
        guard let description = jobDetail.scheduledJob?.jobShortDescription, !description.isEmpty else {
            return .Valid
        }
        return Validator.validateName(name: description)
    }
    
    func validatejobShortDescription2() -> ValidationResult {
        guard let description = jobDetail.scheduledJob?.jobShortDescription, !description.isEmpty else {
            return .Invalid(message: "Please select job!")
        }
        return Validator.validateName(name: description)
    }
    
    func validatejobDetails() -> ValidationResult {
        guard let description = jobDetail.details, !description.isEmpty else {
            return .Valid
        }
        return Validator.validateName(name: description)
    }
    
    func getJobShortDescription() -> String? {
        return jobDetail.scheduledJob?.jobShortDescription
    }
    
    func setJobShortDescription(description: String?) {
        jobDetail.scheduledJob?.jobShortDescription = description
    }
    
    
    func getDetails() -> String? {
        return jobDetail.details?.trimHTMLTags()
    }
    
    func setDetails(detail: String?) {
        jobDetail.details = detail
    }
    
    func getCreatedDate() -> String? {
        return DateManager.getStandardDateString(date: jobDetail.createdDate)
    }
    
    func setCreatedDate(date: String?) {
        guard let date = date else { return }
        jobDetail.createdDate = DateManager.stringToDate(string: date)
    }
    
    func getCurrentWorker() -> String? {
        
        if let workerID = UserDefaults.standard.value(forKey: UserDefaultKeys.userId) as? String{
            let worker = CommonController().getWorker(workerId: Int(workerID))
            return (worker?.firstName ?? "") + " " + (worker?.lastName ?? "")
        }
        return ""
    }
    
    
    func getWorker() -> String? {
        return (jobDetail.worker?.firstName ?? "") + " " + (jobDetail.worker?.lastName ?? "")
//        return jobDetail.worker?.firstName
    }
    
    func isValidData() -> Bool {
        
        if isNewRecord(){
            return validateCustomer2() == .Valid &&
                validatejobShortDescription2() == .Valid &&
                validatejobDetails()        == .Valid
        }
        
        return  validatejobDetails()        == .Valid
    }
    
    func addJobDetail(completion: @escaping (_ error: String?, _ isValidData: Bool) -> ()) {
        if !isValidData() {
            completion(nil,false)
            return
        }
        jobDetail.numberOfAttachments = numberOfAttachment
        let workerID = AppLocals.worker.workerID
        if isNewRecord(){
            jobDetail.createdBy = Int(workerID ?? 2)
        }
        else{
            jobDetail.modifiedBy = Int(workerID ?? 2)
        }
        if isUpdatingJobDetail {
            updateJobDetail { (error) in
                completion(error,true)
            }
        }
        else {
            saveJobDetail { (error) in
                completion(error,true)
            }
        }
        
    }
    
    private func updateJobDetail(completion: @escaping (_ error: String?) -> ()) {
        guard let jobDetailID = jobDetail.jobDetailID else {
            completion("an error has occurred")
            return
        }
        
        jobDetailService.updateJobDetail(jobDetail: jobDetail) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.saveAttachment(id: Int(jobDetailID))
                completion(nil)
                break
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    private func saveJobDetail(completion: @escaping (_ error: String?) -> ()) {
        jobDetailService.saveJobDetail(jobDetail: jobDetail) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let jobId):
                self.saveAttachment(id: Int(jobId))
                completion(nil)
                break
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    func getLineItems(isReload: Bool = true, showRemoved:Bool, completion: @escaping () -> ()) {
        if !isReload && !hasMoreItems {
            return
        }
        guard let jobID = jobDetail.jobID else {
            return
        }
        
        let offset = (isReload) ? 0 : lineItems.count
//        let expenseStatementsLineItemService = ExpenseStatementsLineItemService()

        jobDetailService.fetchJobDetail(jobID: jobID,showRemoved: showRemoved, offset: offset) { (result) in
            switch result {

            case .success(let lineItems):
                self.hasMoreItems = lineItems.count == Constants.DATA_OFFSET
                if isReload {
                    self.lineItems = lineItems
                }
                else {
                    self.lineItems.append(contentsOf: lineItems)
                }

                completion()
            case .failure(let error):
                print(error)
                completion()
            }
        }
    }


    
    
    
}
