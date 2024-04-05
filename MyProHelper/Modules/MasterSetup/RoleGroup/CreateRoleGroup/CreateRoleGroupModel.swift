//
//  CreateRoleGroupModel.swift
//  MyProHelper
//
//  Created by sismac010 on 03/08/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

class CreateRoleGroupModel {
    
    // Roles Member
    private var rolesGroup: WorkerRolesGroup = WorkerRolesGroup()
    private var isUpdatingRoleGroup = false
    
    func getRolesGroupName() -> String? {
        return rolesGroup.groupName
    }
    
    func setRolesGroupName(name:String?) {
        return rolesGroup.groupName = name
    }
    
    func getRolesGroup() -> WorkerRolesGroup {
        return rolesGroup
    }
    
    func setRolesGroup(group: WorkerRolesGroup) {
        rolesGroup = group
        isUpdatingRoleGroup = true
    }
    
    func isEditingRoleGroup() -> Bool {
        return isUpdatingRoleGroup
    }
    
    func validateGroupName() -> ValidationResult {
        return Validator.validateName(name:rolesGroup.groupName)
    }
    
    func isValidData() -> Bool {
        return  validateGroupName()        == .Valid
    }
    
    
    func isRoleOpen(for role: CreateRoleGroupFields2) -> Bool? {
        let rolesGroup = self.rolesGroup 
        switch role {
        case .ADMIN:
            return rolesGroup.role.admin
        case .OWNER:
            return rolesGroup.role.owner
        case .TECH_SUPPORT:
            return rolesGroup.role.techSupport
        case .CAN_DO_COMPANY_SETUP:
            return rolesGroup.role.canDoCompanySetup
        case .CAN_ADD_WORKERS:
            return rolesGroup.role.canAddWorkers
        case .CAN_ADD_CUSTOMERS:
            return rolesGroup.role.canAddCustomers
        case .CAN_RUN_PAYROLL:
            return rolesGroup.role.canRunPayroll
        case .CAN_SEE_WAGES:
            return rolesGroup.role.canSeeWages
//        case .CAN_SCHEDULE:
//            return rolesGroup.role.canSchedule
        case .CAN_DO_INVENTORY:
            return rolesGroup.role.canDoInventory
        case .CAN_RUN_REPORT:
            return rolesGroup.role.canRunReports
        case .CAN_ADD_REMOVE_INVENTORY_ITEMS:
            return rolesGroup.role.canAddRemoveInventoryItems
        case .CAN_EDIT_TIME_ALREADY_ENTERED:
            return rolesGroup.role.canEditTimeAlreadyEntered
        case .CAN_REQUEST_VACATION:
            return rolesGroup.role.canRequestVacation
        case .CAN_REQUEST_SICK:
            return rolesGroup.role.canRequestSick
        case .CAN_REQUEST_PERSONAL_TIME:
            return rolesGroup.role.canRequestPersonalTime
        case .CAN_APPROVE_TIMEOFF:
            return rolesGroup.role.canApproveTimeoff
        case .CAN_APPROVE_PAYROLL:
            return rolesGroup.role.canApprovePayroll
        case .CAN_EDIT_JOB_HISTORY:
            return rolesGroup.role.canEditJobHistory
        case .CAN_SCHEDULE_JOBS:
            return rolesGroup.role.canScheduleJobs
        case .CAN_APPROVE_PURCHASE_ORDERS:
            return rolesGroup.role.canApprovePurchaseOrders
        case .CAN_APPROVE_WORK_ORDERS:
            return rolesGroup.role.canApproveWorkOrders
        case .CAN_APPROVE_INVOICES:
            return rolesGroup.role.canApproveInvoices
        case .RECEIVE_EMAIL_FOR_REJECTED_JOBS:
            return rolesGroup.role.receiveEmailForRejectedJobs
        }
    }
    
    func changeRoleState(for role: CreateRoleGroupFields2, value: Bool){
        switch role {
        case .ADMIN:
            rolesGroup.role.admin = value
        case .OWNER:
            rolesGroup.role.owner = value
        case .TECH_SUPPORT:
            rolesGroup.role.techSupport = value
        case .CAN_DO_COMPANY_SETUP:
            rolesGroup.role.canDoCompanySetup = value
        case .CAN_ADD_WORKERS:
            rolesGroup.role.canAddWorkers = value
        case .CAN_ADD_CUSTOMERS:
            rolesGroup.role.canAddCustomers = value
        case .CAN_RUN_PAYROLL:
            rolesGroup.role.canRunPayroll = value
        case .CAN_SEE_WAGES:
            rolesGroup.role.canSeeWages = value
//        case .CAN_SCHEDULE:
//            rolesGroup.role.canSchedule = value
        case .CAN_DO_INVENTORY:
            rolesGroup.role.canDoInventory = value
        case .CAN_RUN_REPORT:
            rolesGroup.role.canRunReports = value
        case .CAN_ADD_REMOVE_INVENTORY_ITEMS:
            rolesGroup.role.canAddRemoveInventoryItems = value
        case .CAN_EDIT_TIME_ALREADY_ENTERED:
            rolesGroup.role.canEditTimeAlreadyEntered = value
        case .CAN_REQUEST_VACATION:
            rolesGroup.role.canRequestVacation = value
        case .CAN_REQUEST_SICK:
            rolesGroup.role.canRequestSick = value
        case .CAN_REQUEST_PERSONAL_TIME:
            rolesGroup.role.canRequestPersonalTime = value
        case .CAN_APPROVE_TIMEOFF:
            rolesGroup.role.canApproveTimeoff = value
        case .CAN_APPROVE_PAYROLL:
            rolesGroup.role.canApprovePayroll = value
        case .CAN_EDIT_JOB_HISTORY:
            rolesGroup.role.canEditJobHistory = value
        case .CAN_SCHEDULE_JOBS:
            rolesGroup.role.canScheduleJobs = value
        case .CAN_APPROVE_PURCHASE_ORDERS:
            rolesGroup.role.canApprovePurchaseOrders = value
        case .CAN_APPROVE_WORK_ORDERS:
            rolesGroup.role.canApproveWorkOrders = value
        case .CAN_APPROVE_INVOICES:
            rolesGroup.role.canApproveInvoices = value
        case .RECEIVE_EMAIL_FOR_REJECTED_JOBS:
            rolesGroup.role.receiveEmailForRejectedJobs = value
        }
    }
    
    func saveRoles(completion: @escaping (_ error: String?, _ isValidData: Bool)->()) {
        if !isValidData() {
            completion(nil, false)
            return
        }
        
        if  isUpdatingRoleGroup {
            editRole{ (error) in
                completion(error, true)
            }
        }
        else {
            createRole{ (error) in
                completion(error, true)
            }
        }
    }
    
    private func createRole(completion: @escaping (_ error: String?)->()) {
        let group = rolesGroup
        let roleGroupService = RoleGroupService()
        roleGroupService.createRolesGroup(group: group) { (result) in
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
        let group = rolesGroup
        let roleGroupService = RoleGroupService()
        roleGroupService.updateRolesGroup(group: group) { (result) in
            switch result {
            case .success:
                completion(nil)
            case .failure(let error):
                completion(error.localizedDescription)
                print(error)
            }
        }
    }
    
    
    
}
