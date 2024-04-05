//
//  CreateWagesViewModel.swift
//  MyProHelper
//
//  Created by sismac010 on 04/06/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

class CreateWagesViewModel: BaseAttachmentViewModel {
    private var wage = Wage()
    //    var worker = Box(Worker())
    private var isUpdatingWage  = false
    private let service = AssetTypeService()
    private var workers: [Worker] = []
    private let salaryPerTimeList = ["Year","Month","Hourly"]
    
    // Roles Members
    private var rolesGroup: [WorkerRolesGroup] = []
    
    func setWage(wage: Wage) {
        self.isUpdatingWage = true
        self.wage = wage
        self.sourceId = wage.wageID
    }
    
    
    func validateWorker() -> ValidationResult {
        if wage.workerID == nil && wage.workerName == nil{
            return .Invalid(message: Constants.Message.NAME_SELECT_ERROR)
        }
        
        if let workerName = wage.workerName , wage.workerID == nil{
            if workerName == Constants.DefaultValue.SELECT_LIST{

                return .Invalid(message: Constants.Message.NAME_SELECT_ERROR)
            }
            return .Valid
        }
        if let workerName = wage.workerName{
            if workerName == Constants.DefaultValue.SELECT_LIST{

                return .Invalid(message: Constants.Message.NAME_SELECT_ERROR)
            }
            return .Valid
        }
        
        return .Valid
    }
    
    // Getting Wage Information
    func getSalaryRate() -> String? {
        return getFormattedStringValue(value: wage.salaryRate ?? 0)
//        return String(wage.salaryRate ?? 0)
    }
    
    func getSalaryRateValue() -> Double {
        return wage.salaryRate ?? 0
    }
    
    func getSalaryPerTime() -> String? {
        return wage.salaryPerTime
    }
    
    func getSalaryPerTimeList() -> [String] {
        return salaryPerTimeList
    }
    
    func getHourlyRate() -> String? {
        return getFormattedStringValue(value: wage.hourlyRate ?? 0)
//        return String(wage.hourlyRate ?? 0)
    }
    
    func getW4WH() -> String? {
        return getFormattedStringValue(value: wage.w4wh ?? 0)
//        return String(wage.w4wh ?? 0)
    }
    
    func getw4Exemptions() -> String? {
        return String(wage.w4Exemptions ?? 0)
    }
    
    func isNeed1099() -> Bool {
        return wage.needs1099 ?? false
    }
    
    func getGarnishments() -> String? {
        return wage.garnishments
    }
    
    func getGarnishmentAmount() -> String? {
        return getFormattedStringValue(value: wage.garnishmentAmount ?? 0)
//        return String(wage.garnishmentAmount ?? 0)
    }
    func getfedTaxWH() -> String? {
        return getFormattedStringValue(value: wage.fedTaxWH ?? 0)
//        return String(wage.fedTaxWH ?? 0)
    }
    func getStateTaxWH() -> String? {
        return getFormattedStringValue(value: wage.stateTaxWH ?? 0)
//        return String(wage.stateTaxWH ?? 0)
    }
    
    func getStartEmploymentDate() -> String? {
       return DateManager.getStandardDateString(date: wage.startEmploymentDate)
    }
    
    func getEndEmploymentDate() -> String? {
       return DateManager.getStandardDateString(date: wage.endEmploymentDate)
    }
    
    func getCurrentVacationAmount() -> String? {
        return getFormattedStringValue(value: wage.currentVacationAmount ?? 0)
//        return String(wage.currentVacationAmount ?? 0)
    }
    
    func getVacationAccrualRateInHours() -> String? {
        return getFormattedStringValue(value: wage.vacationAccrualRateInHours ?? 0)
//        return String(wage.vacationAccrualRateInHours ?? 0)
    }
    
    func getVacationHoursPerYear() -> String? {
        return getFormattedStringValue(value: wage.vacationHoursPerYear ?? 0)
//        return String(wage.vacationHoursPerYear ?? 0)
    }
    
    func getContractPrice ()-> String? {
        return getFormattedStringValue(value: wage.contractPrice ?? 0)
//        return String(wage.contractPrice ?? 0)
    }
    
    func isFixedContractPrice() -> Bool {
        return wage.isFixedContractPrice ?? false
    }
    
    // Setting Wage Information
    
    func setSalaryRate(rate: String?) {
        guard let rate = rate else { return }
        wage.salaryRate = Double(rate)
    }
    
    func setSalaryPerTime(salary: String?) {
        wage.salaryPerTime = salary
    }
    
    func setHourlyRate(rate: String?) {
        guard let rate = rate else { return }
        wage.hourlyRate = Double(rate)
    }
    
    func setW4WH(value: String?) {
        guard let value = value else { return }
        wage.w4wh = Double(value)
    }
    
    func setW4Exemptions(value: String?) {
        guard let value = value else { return }
        wage.w4Exemptions = Int(value)
    }
    
    func setNeed1099(isNeed: Bool) {
        wage.needs1099 = isNeed
    }
    
    func setGarnishments(garnishment: String?) {
        wage.garnishments = garnishment
    }
    
    func setGarnishmentAmount(amount: String?) {
        guard let amount = amount else { return }
        wage.garnishmentAmount = Double(amount)
    }
    
    func setfedTaxWH(value: String?) {
        guard let value = value else { return }
        wage.fedTaxWH = Double(value)
    }
    
    func setStateTaxWH(value: String?) {
        guard let value = value else { return }
        wage.stateTaxWH = Double(value)
    }
    
    func setStartEmploymentDate(date: String?) {
        wage.startEmploymentDate = DateManager.stringToDate(string: date ?? "")
    }
    
    func setEndEmploymentDate(date: String?) {
        wage.endEmploymentDate = DateManager.stringToDate(string: date ?? "")
    }
    
    func setCurrentVacationAmount(amount: String?) {
        guard let amount = amount else { return }
        wage.currentVacationAmount = Double(amount)
    }
    
    func setVacationAccrualRateInHours(rate: String?) {
        guard let rate = rate else { return }
        wage.vacationAccrualRateInHours = Double(rate)
    }
    
    func setVacationHoursPerYear(vacation: String?) {
        guard let vacation = vacation else { return }
        wage.vacationHoursPerYear = Double(vacation)
    }
    
    func setContractPrice (price: String?) {
        guard let price = price else { return }
        wage.contractPrice = Double(price)
    }
    
    func setFixedContractPrice(isFixed: Bool) {
        wage.isFixedContractPrice = isFixed
    }
    
    func setSalaryPerTime(at index: Int) {
        wage.salaryPerTime = salaryPerTimeList[index]
    }
    
    // Validate Wage Info
    
    func validateSalaryPerTime() -> ValidationResult {
        return Validator.validateSalaryPerTime(salaryType: wage.salaryPerTime)
    }
    
    private func isValidWage() -> Bool {
        return  validateSalaryPerTime() == .Valid &&
                validateWorker()        == .Valid
    }
    
    private func createWage(completion: @escaping (_ error: String?)->()) {
//        guard let wage = wage else { return }
        let service = WagesService()
        service.createWage(wage) { (result) in
            switch result {
            case .success(let wageId):
                print(wageId)
                completion(nil)
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    private func editWage(completion: @escaping (_ error: String?)->()) {
//        guard let wage = wage else { return }
        let service = WagesService()
        service.updateWage(wage) { (result) in
            switch result {
            case .success:
                completion(nil)
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    func getWorkers(completion: @escaping () -> ()) {
        let workersService = WorkersService()
        workersService.fetchWorkers(showSelect: false,offset: 0) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let workers):
                self.workers = workers
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getWorkers() -> [String] {
        return workers.compactMap({ ($0.firstName! + " " + $0.lastName!)})
    }
    
    func setWorker(at index: Int?) {
        guard let index = index, index < workers.count else {return}
//        if index == 0{
//            let worker = workers[index]
//            workOrder.workerName = worker.firstName!
//            return
//        }
//        wage.workerID = workers[index].workerID
        wage.workerID = workers[index].workerID
        wage.workerName = workers[index].firstName! + " " + workers[index].lastName!
        
    }
    
    func getWorker() -> String? {
        return wage.workerName
    }
    
    func getWageID() -> Int? {
        return wage.wageID
    }
    
    func addWage(completion: @escaping (_ error: String?, _ isValidData: Bool) -> ()) {
//        isAddPerformed.updateValue(true, forKey: .WAGES)
        if !isValidWage() {
            completion(nil, false)
            return
        }
        wage.numberOfAttachments = numberOfAttachment
        if isUpdatingWage{//wage.wageID != nil {
            editWage(completion: { error in
                completion(error, true)
            })
        }
        else {
            createWage(completion: { error in
                completion(error, true)
            })
        }
    }
    /*
    func addWorkOrder(completion: @escaping (_ error: String?, _ isValidData: Bool) -> ()) {
        if !isValidData() {
            completion(nil,false)
            return
        }
        workOrder.numberOfAttachments = numberOfAttachment
        workOrder.dateCreated = Date()
        if isUpdatingWorkOrder {
            updateWorkOrder { (error) in
                completion(error,true)
            }
        }
        else {
            saveWorkOrder { (error) in
                completion(error,true)
            }
        }
        
    }
    */
    
}
