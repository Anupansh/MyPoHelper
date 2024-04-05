//
//  WorkerRolesGroup.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 30/07/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB

struct WorkerRolesGroup: RepositoryBaseModel {
    var workerRolesGroupID  : Int?
    var groupName           : String?
    var role                : Role
    var removed             : Bool?
    var removedBy           : Int?
    var removedDate         : Date?
    
    init() {
        role = Role()
    }
    
    init(row: Row) {
        let columns = RepositoryConstants.Columns.self
        workerRolesGroupID  = row[columns.WORKER_ROLES_GROUP_ID]
        groupName           = row[columns.GROUP_NAME]
        removedBy           = row[columns.REMOVED_BY] ?? 0
        removed             = row[columns.REMOVED]
        removedDate         = DateManager.stringToDate(string: row[columns.REMOVED_DATE] ?? "")
        role                = Role(row: row)
    }
    
    func getDataArray() -> [Any] {
        //Do To implement this method
        return [
            getStringValue(value: groupName),
            getYesNo(value: role.admin),
            getYesNo(value: role.canDoCompanySetup),
            getYesNo(value: role.canAddWorkers),
            getYesNo(value: role.canAddCustomers),
            getYesNo(value: role.canRunPayroll),
            getYesNo(value: role.canSeeWages),
//            getYesNo(value: role.canSchedule),
            getYesNo(value: role.canDoInventory),
            getYesNo(value: role.canRunReports),
            getYesNo(value: role.canAddRemoveInventoryItems),
            getYesNo(value: role.canEditTimeAlreadyEntered),
            getYesNo(value: role.canRequestVacation),
            getYesNo(value: role.canRequestSick),
            getYesNo(value: role.canRequestPersonalTime),
            getYesNo(value: role.canEditJobHistory),
            getYesNo(value: role.canScheduleJobs),
            getYesNo(value: role.canApprovePurchaseOrders),
            getYesNo(value: role.canApproveWorkOrders),
            getYesNo(value: role.canApproveInvoices),
            getYesNo(value: role.receiveEmailForRejectedJobs),
        ]
    }
}

