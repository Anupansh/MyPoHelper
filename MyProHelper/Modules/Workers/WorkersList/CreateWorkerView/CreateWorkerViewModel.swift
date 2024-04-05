//
//  CreateWorkerViewModel.swift
//  MyProHelper
//
//  Created by Samir on 05/01/2021.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

class CreateWorkerViewModel {
    
    var worker = Box(Worker())
    private var isUpdatingWorker = false
    private let service = AssetTypeService()
    private var isAddPerformed: [WorkerTab: Bool] = [.PERSONAL_INFO : false,
                                                     .ADDRESS : false,
                                                     .WAGES : false]
    private var themes: [String] = ["Blue and White",
                                    "Gray and White"]
    private let salaryPerTimeList = ["Year","Month","Hourly"]
    
    // Roles Members
    private var rolesGroup: [WorkerRolesGroup] = []
    
    // Devices Members
    private var hasMoreDevices = true
    private var devices: [Device]   = []

    func setWorker(worker: Worker) {
        self.worker.value = worker
        self.isUpdatingWorker = true
    }
    
    func getWorker() -> Worker {
        return worker.value
    }
    
    func isEditingWorker() -> Bool {
        return isUpdatingWorker
    }
    
    func didPerformAdd(for tab: WorkerTab) -> Bool {
        return isAddPerformed[tab] ?? false
    }
    
    func saveWorker(completion: @escaping (_ error: String?, _ isValidData: Bool) -> ()) {
        isAddPerformed.updateValue(true, forKey: .PERSONAL_INFO)
        if !isValidPersonalInformation() {
            completion(nil, false)
            return
        }
        if worker.value.workerID != nil {
            editWorker(completion: { error in
                completion(error, true)
            })
        }
        else {
            createWorker(completion: { error in
                completion(error, true)
            })
        }
    }
    
    func saveAddress(completion: @escaping (_ error: String?, _ isValidData: Bool) -> ()) {
        isAddPerformed.updateValue(true, forKey: .ADDRESS)
        if !isValidAddress() {
            completion(nil, false)
            return
        }
        if worker.value.address?.thId != nil {
            editAddress(completion: { error in
                completion(error, true)
            })
        }
        else {
            createAddress(completion: { error in
                completion(error, true)
            })
        }
    }
    
    func saveRoles(completion: @escaping (_ error: String?, _ isValidData: Bool)->()) {
//        guard let workerRoles = worker.workerRoles else { return }
        
        if !isValidGroupName(){
            completion(nil/*"Please select Role Group!"*/, false)
            return
        }
        if  isUpdatingWorker {
            editRole(completion: { error in
                completion(error, true)
            })
        }
        else {
            createRole(completion: { error in
                completion(error, true)
            })
        }
    }
    
    func saveWage(completion: @escaping (_ error: String?, _ isValidData: Bool) -> ()) {
        isAddPerformed.updateValue(true, forKey: .WAGES)
        if !isValidWage() {
            completion(nil, false)
            return
        }
        if worker.value.wage?.wageID != nil {
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
    
    private func setWorkerId(id: Int64) {
        worker.value.workerID                 = Int(id)
        worker.value.address?.workerID        = Int(id)
        worker.value.wage?.workerID           = Int(id)
        worker.value.workerRoles?.workerID    = Int(id)
    }
    func isSavedInitialData()->Bool{
        return worker.value.workerID != nil
    }
}

protocol CreateWorkerViewModel2Delegate:AnyObject{
    func fetchRolesGroup2()
    func fetchMoreData()
}

extension CreateWorkerViewModel2Delegate {
    func fetchRolesGroup2 (){
        //Empty block
    }
    func fetchMoreData(){
        //Empty block
    }
}

class CreateWorkerViewModel2 {
    var createWorkerViewModel           = CreateWorkerViewModel()
    weak var delegate2:CreateWorkerViewModel2Delegate?
    var hasMoreData = true
    func reloadData() {
        hasMoreData = true
//        FetchJob(reloadData: true)
        delegate2?.fetchRolesGroup2()
    }

    func fetchMoreData() {
//        FetchJob(reloadData: false)
        delegate2?.fetchMoreData()
    }
    
    func FetchList(reloadData: Bool, showRemoved: Bool = false, searchKey: String? = nil, showSelect: Bool = true, completion: @escaping () -> ()) {
//        guard hasMoreData else { return }
        let offset = (reloadData == false) ? createWorkerViewModel.countRolesGroup() : 0
        let roleGroupService = RoleGroupService()
        roleGroupService.fetchRolesGroup(showRemoved: showRemoved, key: searchKey, showSelect: showSelect, offset: offset) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let groups):
//                self.hasMoreData = groups.count == Constants.DATA_OFFSET  //Uncomment by Salman
//                if reloadData {
                    self.createWorkerViewModel.setRoleGroup(groups)
//                }
//                else {
//                    self.createWorkerViewModel.addRoleGroup(groups)
//                }
                completion()
            case .failure(let error):
                print(error)
                completion()
//                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }

}

//MARK:- Personal Infomation Methods
extension CreateWorkerViewModel {
    
    // Geting personal information
    func getFirstName() -> String? {
        return worker.value.firstName
    }
    
    func getMiddleName() -> String? {
        return worker.value.middleName
    }
    
    func getLastName() -> String? {
        return worker.value.lastName
    }
    
    func getNickname() -> String? {
        return worker.value.nickName
    }
    
    func getCellNumber() -> String? {
        return worker.value.cellNumber
    }
    
    func getEmail() -> String? {
        return worker.value.email
    }
    
    func isHourlyWorker() -> Bool {
        return worker.value.hourlyWorker ?? false
    }
    
    func isSalaryWorker() -> Bool {
        return worker.value.salary ?? false
    }
    
    func isContractor() -> Bool {
        return worker.value.contractor ?? false
    }
    
    func getWorkerTheme() -> String? {
        return worker.value.workerTheme
    }
    
    func getbackgroundColor() -> String? {
        return worker.value.backgroundColor
    }
    
    func getFontColor() -> String? {
        return worker.value.fontColor
    }
    
    func getThemes() -> [String] {
        return themes
    }
    
    // Setting personal information
    func setFirstName(name: String?) {
        worker.value.firstName = name
    }
    
    func setMiddleName(name: String?) {
        worker.value.middleName = name
    }
    
    func setLasttName(name: String?) {
        worker.value.lastName = name
    }
    
    func setNickname(name: String?) {
        worker.value.nickName = name
    }
    
    func setCellNumber(number: String?) {
        worker.value.cellNumber = number
    }
    
    func setEmail(email: String?) {
        worker.value.email = email
    }
    
    func setHourlyWorker() {
        worker.value.hourlyWorker = true
        worker.value.salary       = false
    }
    
    func setSalaryWorker() {
        worker.value.hourlyWorker = false
        worker.value.salary       = true
    }
    
    func setContractor(isContractor: Bool) {
        worker.value.contractor = isContractor
    }
    
    func setWorkerTheme(theme: String?) {
        worker.value.workerTheme = theme
    }
    
    func setWorkerTheme(at index: Int) {
        worker.value.workerTheme = themes[index]
    }
    
    func setBackgroundColor(color: String?) {
        worker.value.backgroundColor = color
    }
    
    func setFontColor(color: String?) {
        worker.value.fontColor = color
    }
    
    // Validating Perosnal Information
    func validateFirstName() -> ValidationResult {
        return Validator.validateName(name: worker.value.firstName)
    }
    
    func validateMiddleName() -> ValidationResult {
        guard let name = worker.value.middleName, !name.isEmpty else {
            return .Valid
        }
        return Validator.validateName(name: name)
    }
    
    func validateLastName() -> ValidationResult {
        return Validator.validateName(name: worker.value.lastName)
    }
    
    func validateNickname() -> ValidationResult {
        guard let name = worker.value.nickName, !name.isEmpty else {
            return .Valid
        }
        return Validator.validateName(name: name)
    }
    
    func validateCellNumber() -> ValidationResult {
        guard let number = worker.value.cellNumber, !number.isEmpty else {
            return .Valid
        }
        return Validator.validatePhone(phone: number)
    }
    
    func validateEmail() -> ValidationResult {
        return Validator.validateEmail(email: worker.value.email)
    }
    
    private func isValidPersonalInformation() -> Bool {
        return validateFirstName()  == .Valid &&
            validateMiddleName()    == .Valid &&
            validateLastName()      == .Valid &&
            validateNickname()      == .Valid &&
            validateCellNumber()    == .Valid &&
            validateEmail()         == .Valid
    }
    
    private func createWorker(completion: @escaping (_ error: String?)->()) {
        let service = WorkersService()
        service.createWorker(worker.value) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let workerId):
                self.setWorkerId(id: workerId)
                completion(nil)
                
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    private func editWorker(completion: @escaping (_ error: String?)->()) {
        let service = WorkersService()
        service.updateWorker(worker.value) { (result) in
            switch result {
            case .success:
                completion(nil)
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
}

//MARK:- Address Methods
extension CreateWorkerViewModel {
    // Geting address information
    
    func getPrimaryAddress() -> String? {
        return worker.value.address?.streetAddress1
    }
    
    func getSecondryAddress() -> String? {
        return worker.value.address?.streetAddress2
    }
    
    func getCity() -> String? {
        return worker.value.address?.city
    }
    
    func getState() -> String? {
        return worker.value.address?.state
    }
    
    func getZipCode() -> String? {
        return worker.value.address?.zip
    }
    
    func setPrimaryAddress(address: String?) {
        worker.value.address?.streetAddress1 = address
    }
    
    func setSecondryAddress(address: String?) {
        worker.value.address?.streetAddress2 = address
    }
    
    func setCity(city: String?) {
        worker.value.address?.city = city
    }
    
    func setState(state: String?) {
        worker.value.address?.state = state
    }
    
    func setZipCode(code: String?) {
        worker.value.address?.zip = code
    }
    
    func validatePrimaryAddress() -> ValidationResult {
        return Validator.validateAddress(address: worker.value.address?.streetAddress1)
    }
    
    func validateSecondryAddress() -> ValidationResult {
        guard let address = worker.value.address?.streetAddress2, !address.isEmpty else {
            return .Valid
        }
        return Validator.validateAddress(address: address)
    }
    
    func validateCity() -> ValidationResult {
        return Validator.validateCity(city: worker.value.address?.city)
    }
    
    func validateState() -> ValidationResult {
        return Validator.validateState(state: worker.value.address?.state)
    }
    
    func validateZipCode() -> ValidationResult {
        return Validator.validateZipCode(code: worker.value.address?.zip)
    }
    
    func isValidAddress() -> Bool {
        return  validatePrimaryAddress()    == .Valid &&
                validateSecondryAddress()   == .Valid &&
                validateCity()              == .Valid &&
                validateState()             == .Valid &&
                validateZipCode()           == .Valid
    }
    
    private func createAddress(completion: @escaping (_ error: String?)->()) {
        guard let address = worker.value.address else { return }
        let service = WorkerHomeAddressesService()
        service.createWorkerAddress(address) { (result) in
            switch result {
            case .success(let addressId):
                print(addressId)
                completion(nil)
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    private func editAddress(completion: @escaping (_ error: String?)->()) {
        guard let address = worker.value.address else { return }
        let service = WorkerHomeAddressesService()
        service.updateWorkerAddress(address) { (result) in
            switch result {
            case .success:
                completion(nil)
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
}

//MARK:-  Roles Methods
extension CreateWorkerViewModel{
    
    func getRolesGroup(at index: Int) -> WorkerRolesGroup {
        return rolesGroup[index]
    }
    
    func setRoleGroup(_ group:[WorkerRolesGroup]){
        rolesGroup = group
    }
    
    func addRoleGroup(_ group:[WorkerRolesGroup]){
        rolesGroup.append(contentsOf: group)
    }
    
    func getRolesGroup() -> [String] {
        return rolesGroup.compactMap({ $0.groupName })
    }
    
    func getRolesGroup(at index: Int) -> String? {
        return rolesGroup[index].groupName
    }
    
    func countRolesGroup() -> Int {
        return rolesGroup.count
    }
    
    func getSelectedRolesGroup() -> String? {
        return worker.value.workerRoles?.rolesGroup?.groupName
    }
    
    func selectRolesGroup(at index: Int) {
        let group = rolesGroup[index]
        worker.value.workerRoles?.workerRoleGroupID = group.workerRolesGroupID
        worker.value.workerRoles?.rolesGroup = group
        worker.value.workerRoles?.role = group.role
    }
    
    func isRolesGroupRemoved(at index: Int) -> Bool {
        return rolesGroup[index].removed ?? false
    }
    
    func validateGroupName() -> ValidationResult {
//        guard let _ = worker.value.workerRoles?.workerRoleGroupID else {
//            return .Invalid(message: Constants.Message.NAME_SELECT_ERROR)
//        }
        
        guard let groupName = worker.value.workerRoles?.rolesGroup?.groupName, groupName != Constants.DefaultValue.SELECT_LIST else {
            return .Invalid(message: Constants.Message.NAME_SELECT_ERROR)
        }
        return.Valid
    }
    
    func isValidGroupName() -> Bool {
        return  validateGroupName()    == .Valid
    }
    
    
    func fetchRolesGroup(showRemoved: Bool = false, searchKey: String? = nil, showSelect: Bool = true, offset: Int = 0, completion: @escaping () -> ()) {
        let roleGroupService = RoleGroupService()
        roleGroupService.fetchRolesGroup(showRemoved: showRemoved, key: searchKey, showSelect: showSelect, offset: offset) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let groups):
                self.rolesGroup = groups
                completion()
            case .failure(let error):
                print(error)
                completion()
            }
        }
    }
    
    func isRoleOpen(for role: RoleOption) -> Bool? {
        guard let workerRoles = worker.value.workerRoles else { return false }
        switch role {
        case .ADMIN:
            return workerRoles.role.admin
        case .OWNER:
            return workerRoles.role.owner
        case .TECH_SUPPORT:
            return workerRoles.role.techSupport
        case .CAN_DO_COMPANY_SETUP:
            return workerRoles.role.canDoCompanySetup
        case .CAN_ADD_WORKERS:
            return workerRoles.role.canAddWorkers
        case .CAN_ADD_CUSTOMERS:
            return workerRoles.role.canAddCustomers
        case .CAN_RUN_PAYROLL:
            return workerRoles.role.canRunPayroll
        case .CAN_SEE_WAGES:
            return workerRoles.role.canSeeWages
//        case .CAN_SCHEDULE:
//            return workerRoles.role.canSchedule
        case .CAN_DO_INVENTORY:
            return workerRoles.role.canDoInventory
        case .CAN_RUN_REPORT:
            return workerRoles.role.canRunReports
        case .CAN_ADD_REMOVE_INVENTORY_ITEMS:
            return workerRoles.role.canAddRemoveInventoryItems
        case .CAN_EDIT_TIME_ALREADY_ENTERED:
            return workerRoles.role.canEditTimeAlreadyEntered
        case .CAN_REQUEST_VACATION:
            return workerRoles.role.canRequestVacation
        case .CAN_REQUEST_SICK:
            return workerRoles.role.canRequestSick
        case .CAN_REQUEST_PERSONAL_TIME:
            return workerRoles.role.canRequestPersonalTime
        case .CAN_APPROVE_TIMEOFF:
            return workerRoles.role.canApproveTimeoff
        case .CAN_APPROVE_PAYROLL:
            return workerRoles.role.canApprovePayroll
        case .CAN_EDIT_JOB_HISTORY:
            return workerRoles.role.canEditJobHistory
        case .CAN_SCHEDULE_JOBS:
            return workerRoles.role.canScheduleJobs
        case .CAN_APPROVE_PURCHASE_ORDERS:
            return workerRoles.role.canApprovePurchaseOrders
        case .CAN_APPROVE_WORK_ORDERS:
            return workerRoles.role.canApproveWorkOrders
        case .CAN_APPROVE_INVOICES:
            return workerRoles.role.canApproveInvoices
        case .RECEIVE_EMAIL_FOR_REJECTED_JOBS:
            return workerRoles.role.receiveEmailForRejectedJobs
        }
    }
    
    func changeRoleState(for role: RoleOption, value: Bool){
        switch role {
        case .ADMIN:
            worker.value.workerRoles?.role.admin = value
        case .OWNER:
            worker.value.workerRoles?.role.owner = value
        case .TECH_SUPPORT:
            worker.value.workerRoles?.role.techSupport = value
        case .CAN_DO_COMPANY_SETUP:
            worker.value.workerRoles?.role.canDoCompanySetup = value
        case .CAN_ADD_WORKERS:
            worker.value.workerRoles?.role.canAddWorkers = value
        case .CAN_ADD_CUSTOMERS:
            worker.value.workerRoles?.role.canAddCustomers = value
        case .CAN_RUN_PAYROLL:
            worker.value.workerRoles?.role.canRunPayroll = value
        case .CAN_SEE_WAGES:
            worker.value.workerRoles?.role.canSeeWages = value
//        case .CAN_SCHEDULE:
//            worker.value.workerRoles?.role.canSchedule = value
        case .CAN_DO_INVENTORY:
            worker.value.workerRoles?.role.canDoInventory = value
        case .CAN_RUN_REPORT:
            worker.value.workerRoles?.role.canRunReports = value
        case .CAN_ADD_REMOVE_INVENTORY_ITEMS:
            worker.value.workerRoles?.role.canAddRemoveInventoryItems = value
        case .CAN_EDIT_TIME_ALREADY_ENTERED:
            worker.value.workerRoles?.role.canEditTimeAlreadyEntered = value
        case .CAN_REQUEST_VACATION:
            worker.value.workerRoles?.role.canRequestVacation = value
        case .CAN_REQUEST_SICK:
            worker.value.workerRoles?.role.canRequestSick = value
        case .CAN_REQUEST_PERSONAL_TIME:
            worker.value.workerRoles?.role.canRequestPersonalTime = value
        case .CAN_APPROVE_TIMEOFF:
            worker.value.workerRoles?.role.canApproveTimeoff = value
        case .CAN_APPROVE_PAYROLL:
            worker.value.workerRoles?.role.canApprovePayroll = value
        case .CAN_EDIT_JOB_HISTORY:
            worker.value.workerRoles?.role.canEditJobHistory = value
        case .CAN_SCHEDULE_JOBS:
            worker.value.workerRoles?.role.canScheduleJobs = value
        case .CAN_APPROVE_PURCHASE_ORDERS:
            worker.value.workerRoles?.role.canApprovePurchaseOrders = value
        case .CAN_APPROVE_WORK_ORDERS:
            worker.value.workerRoles?.role.canApproveWorkOrders = value
        case .CAN_APPROVE_INVOICES:
            worker.value.workerRoles?.role.canApproveInvoices = value
        case .RECEIVE_EMAIL_FOR_REJECTED_JOBS:
            worker.value.workerRoles?.role.receiveEmailForRejectedJobs = value
        }
    }
    
    private func createRole(completion: @escaping (_ error: String?)->()) {
        guard let workerRoles = worker.value.workerRoles else { return }
        let rolesService = WorkerRolesService()
        rolesService.addWorkerRoles(role: workerRoles) { (result) in
            switch result {
            case .success:
                completion(nil)
            case .failure(let error):
                completion(error.localizedDescription)
                print(error)
            }
        }
    }
    
    private func editRole(completion: @escaping (_ error: String?)->()) {
        guard let workerRoles = worker.value.workerRoles else { return }
        let rolesService = WorkerRolesService()
        rolesService.updateWorkerRoles(role: workerRoles) { (result) in
            switch result {
            case .success:
                completion(nil)
            case .failure(let error):
                completion(error.localizedDescription)
                print(error)
            }
        }
    }
    
    func deleteRolesGroupAt(at index: Int, completion: @escaping () -> ()) {
        let roleGroupService = RoleGroupService()
        let group = rolesGroup[index]
        roleGroupService.deleteRoleGroup(group: group) { (result) in
            switch result {
            case .success:
                completion()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func restoreRolesGroupAt(at index: Int, completion: @escaping () -> ()) {
        let roleGroupService = RoleGroupService()
        let group = rolesGroup[index]
        roleGroupService.restoreRoleGroup(group: group) { (result) in
            switch result {
            case .success:
                completion()
            case .failure(let error):
                print(error)
            }
        }
    }
}

//extension BaseDataTableViewModel where Self: CreateWorkerViewModel {
//
//    override func reloadData() {
//        hasMoreData = true
////        FetchJob(reloadData: true)
//    }
//
//    override func fetchMoreData() {
////        FetchJob(reloadData: false)
//    }
//
//}


//MARK:-  Devices Methods
extension CreateWorkerViewModel {
    
    func getDevice(at index: Int) -> Device {
        return devices[index]
    }
    
    func countDevices() -> Int {
        return devices.count
    }
    
    func getDevices() -> [Device] {
        return devices
    }

    func isDeviceRemoved(at index: Int) -> Bool {
        return devices[index].removed ?? false
    }
    
    func fetchDevices(showRemoved: Bool, searchKey: String? = nil, isFilter:Bool, isDeviceSetup:Bool, sortBy: DeviceFields? = nil, sortType: SortType? = nil, completion: @escaping () -> ()) {
        let devicesService = DevicesService()
        devicesService.fetchDevicesList(showRemoved: showRemoved, for: worker.value, isFilter: isFilter, isDeviceSetup: isDeviceSetup, key: searchKey, sortBy: sortBy, sortType: sortType, offset: 0) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let devices):
                self.devices = devices
                self.hasMoreDevices = devices.count == Constants.DATA_OFFSET
                completion()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchMoreDevices(showRemoved: Bool, searchKey: String? = nil, isFilter:Bool, isDeviceSetup:Bool, sortBy: DeviceFields? = nil, sortType: SortType? = nil, completion: @escaping () -> ()) {
        guard hasMoreDevices else { return }
        let devicesService = DevicesService()
        let offset = devices.count
        devicesService.fetchDevicesList(showRemoved: showRemoved, for: worker.value, isFilter: isFilter, isDeviceSetup: isDeviceSetup, key: searchKey, sortBy: sortBy, sortType: sortType, offset: offset) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let devices):
                self.devices.append(contentsOf: devices)
                self.hasMoreDevices = devices.count == Constants.DATA_OFFSET
                completion()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    func fetchDevices(searchKey: String? = nil, sortBy: DeviceFields? = nil, sortType: SortType? = nil, completion: @escaping () -> ()) {
        let devicesService = DevicesService()
        devicesService.fetchDevicesList(showRemoved: false, for: worker.value, key: searchKey, sortBy: sortBy, sortType: sortType, offset: 0) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let devices):
                self.devices = devices
                self.hasMoreDevices = devices.count == Constants.DATA_OFFSET
                completion()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchMoreDevices(searchKey: String? = nil, sortBy: DeviceFields? = nil, sortType: SortType? = nil, completion: @escaping () -> ()) {
        guard hasMoreDevices else { return }
        let devicesService = DevicesService()
        let offset = devices.count
        devicesService.fetchDevicesList(showRemoved: false, for: worker.value, key: searchKey, sortBy: sortBy, sortType: sortType, offset: offset) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let devices):
                self.devices.append(contentsOf: devices)
                self.hasMoreDevices = devices.count == Constants.DATA_OFFSET
                completion()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func deleteDeviceAt(at index: Int, completion: @escaping () -> ()) {
        let devicesService = DevicesService()
        let device = devices[index]
        devicesService.deleteDevice(device: device) { (result) in
            switch result {
            case .success:
                completion()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func restoreDeviceAt(at index: Int, completion: @escaping () -> ()) {
        let devicesService = DevicesService()
        let device = devices[index]
        devicesService.restoreDevice(device: device) { (result) in
            switch result {
            case .success:
                completion()
            case .failure(let error):
                print(error)
            }
        }
    }
}

//MARK:-  Wage Methods
extension CreateWorkerViewModel {
    func getFormattedStringValue(value: Double?) -> String{
        let result = value as Double? ?? 0.0
        return String(format:"%.2f ", result)
    }
    
    // Getting Wage Information
    func getSalaryRate() -> String? {
        return getFormattedStringValue(value: worker.value.wage?.salaryRate ?? 0)
//        return String(worker.value.wage?.salaryRate ?? 0)
    }
    
    func getSalaryPerTime() -> String? {
        return worker.value.wage?.salaryPerTime
    }
    
    func getSalaryPerTimeList() -> [String] {
        return salaryPerTimeList
    }
    
    func getHourlyRate() -> String? {
        return getFormattedStringValue(value: worker.value.wage?.hourlyRate ?? 0)
//        return String(worker.value.wage?.hourlyRate ?? 0)
    }
    
    func getW4WH() -> String? {
        return getFormattedStringValue(value: worker.value.wage?.w4wh ?? 0)
//        return String(worker.value.wage?.w4wh ?? 0)
    }
    
    func isNeed1099() -> Bool {
        return worker.value.wage?.needs1099 ?? false
    }
    
    func getGarnishments() -> String? {
        return worker.value.wage?.garnishments
    }
    
    func getGarnishmentAmount() -> String? {
        return getFormattedStringValue(value: worker.value.wage?.garnishmentAmount ?? 0)
//        return String(worker.value.wage?.garnishmentAmount ?? 0)
    }
    func getfedTaxWH() -> String? {
        return getFormattedStringValue(value: worker.value.wage?.fedTaxWH ?? 0)
//        return String(worker.value.wage?.fedTaxWH ?? 0)
    }
    func getStateTaxWH() -> String? {
        return getFormattedStringValue(value: worker.value.wage?.stateTaxWH ?? 0)
//        return String(worker.value.wage?.stateTaxWH ?? 0)
    }
    
    func getStartEmploymentDate() -> String? {
       return DateManager.getStandardDateString(date: worker.value.wage?.startEmploymentDate)
    }
    
    func getEndEmploymentDate() -> String? {
       return DateManager.getStandardDateString(date: worker.value.wage?.endEmploymentDate)
    }
    
    func getCurrentVacationAmount() -> String? {
        return getFormattedStringValue(value: worker.value.wage?.currentVacationAmount ?? 0)
//        return String(worker.value.wage?.currentVacationAmount ?? 0)
    }
    
    func getVacationAccrualRateInHours() -> String? {
        return getFormattedStringValue(value: worker.value.wage?.vacationAccrualRateInHours ?? 0)
//        return String(worker.value.wage?.vacationAccrualRateInHours ?? 0)
    }
    
    func getVacationHoursPerYear() -> String? {
        return getFormattedStringValue(value: worker.value.wage?.vacationHoursPerYear ?? 0)
//        return String(worker.value.wage?.vacationHoursPerYear ?? 0)
    }
    
    func getContractPrice ()-> String? {
        return getFormattedStringValue(value: worker.value.wage?.contractPrice ?? 0)
//        return String(worker.value.wage?.contractPrice ?? 0)
    }
    
    func isFixedContractPrice() -> Bool {
        return worker.value.wage?.isFixedContractPrice ?? false
    }
    
    // Setting Wage Information
    
    func setSalaryRate(rate: String?) {
        guard let rate = rate else { return }
        worker.value.wage?.salaryRate = Double(rate)
    }
    
    func setSalaryPerTime(salary: String?) {
        worker.value.wage?.salaryPerTime = salary
    }
    
    func setHourlyRate(rate: String?) {
        guard let rate = rate else { return }
        worker.value.wage?.hourlyRate = Double(rate)
    }
    
    func setW4WH(value: String?) {
        guard let value = value else { return }
        worker.value.wage?.w4wh = Double(value)
    }
    
    func setNeed1099(isNeed: Bool) {
        worker.value.wage?.needs1099 = isNeed
    }
    
    func setGarnishments(garnishment: String?) {
        worker.value.wage?.garnishments = garnishment
    }
    
    func setGarnishmentAmount(amount: String?) {
        guard let amount = amount else { return }
        worker.value.wage?.garnishmentAmount = Double(amount)
    }
    
    func setfedTaxWH(value: String?) {
        guard let value = value else { return }
        worker.value.wage?.fedTaxWH = Double(value)
    }
    
    func setStateTaxWH(value: String?) {
        guard let value = value else { return }
        worker.value.wage?.stateTaxWH = Double(value)
    }
    
    func setStartEmploymentDate(date: String?) {
        worker.value.wage?.startEmploymentDate = DateManager.stringToDate(string: date ?? "")
    }
    
    func setEndEmploymentDate(date: String?) {
        worker.value.wage?.endEmploymentDate = DateManager.stringToDate(string: date ?? "")
    }
    
    func setCurrentVacationAmount(amount: String?) {
        guard let amount = amount else { return }
        worker.value.wage?.currentVacationAmount = Double(amount)
    }
    
    func setVacationAccrualRateInHours(rate: String?) {
        guard let rate = rate else { return }
        worker.value.wage?.vacationAccrualRateInHours = Double(rate)
    }
    
    func setVacationHoursPerYear(vacation: String?) {
        guard let vacation = vacation else { return }
        worker.value.wage?.vacationHoursPerYear = Double(vacation)
    }
    
    func setContractPrice (price: String?) {
        guard let price = price else { return }
        worker.value.wage?.contractPrice = Double(price)
    }
    
    func setFixedContractPrice(isFixed: Bool) {
        worker.value.wage?.isFixedContractPrice = isFixed
    }
    
    func setSalaryPerTime(at index: Int) {
        worker.value.wage?.salaryPerTime = salaryPerTimeList[index]
    }
    
    // Validate Wage Info
    
    func validateSalaryPerTime() -> ValidationResult {
        return Validator.validateSalaryPerTime(salaryType: worker.value.wage?.salaryPerTime)
    }
    
    private func isValidWage() -> Bool {
        return validateSalaryPerTime() == .Valid
    }
    
    private func createWage(completion: @escaping (_ error: String?)->()) {
        guard let wage = worker.value.wage else { return }
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
        guard let wage = worker.value.wage else { return }
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
}
