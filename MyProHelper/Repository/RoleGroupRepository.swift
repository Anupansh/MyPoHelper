//
//  RolesGroupDBService.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 23/06/1942 Saka.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB

class RoleGroupRepository: BaseRepository {
       
    init() {
        super.init(table: .WorkerRolesGroups)
        createSelectedLayoutTable()
    }

    override func setIdKey() -> String {
        return COLUMNS.WORKER_ROLES_GROUP_ID
    }
    
    func createSelectedLayoutTable() {
        let sql = """
             CREATE TABLE IF NOT EXISTS \(tableName) (
                \(COLUMNS.WORKER_ROLES_GROUP_ID)    INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL,
                \(COLUMNS.GROUP_NAME)                       TEXT,
                \(COLUMNS.ADMIN)                            INTEGER DEFAULT (0),
                \(COLUMNS.MPH_XX_TECH_SUPPORT)              INTEGER DEFAULT (0),
                \(COLUMNS.MPH_XX_OWNERS)                    INTEGER DEFAULT (0),
                \(COLUMNS.CAN_DO_COMPANY_SETUP)             INTEGER DEFAULT (0),
                \(COLUMNS.CAN_ADD_WORKERS)                  INTEGER DEFAULT (0),
                \(COLUMNS.CAN_ADD_CUSTOMERS)                INTEGER DEFAULT (0),
                \(COLUMNS.CAN_RUN_PAYROLL)                  INTEGER DEFAULT (0),
                \(COLUMNS.CAN_SEE_WAGES)                    INTEGER DEFAULT (0),
                \(COLUMNS.CAN_SCHEDULE)                     INTEGER DEFAULT (0),
                \(COLUMNS.CAN_DO_INVENTORY)                 INTEGER DEFAULT (0),
                \(COLUMNS.CAN_RUN_REPORTS)                  INTEGER DEFAULT (0),
                \(COLUMNS.CAN_ADD_REMOVE_INVENTORY_ITEMS)   INTEGER DEFAULT (0),
                \(COLUMNS.CAN_EDIT_TIME_ALREADY_ENTERED)    INTEGER DEFAULT (0),
                \(COLUMNS.CAN_REQUEST_VACATION)             INTEGER DEFAULT (0),
                \(COLUMNS.CAN_REQUEST_SICK)                 INTEGER DEFAULT (0),
                \(COLUMNS.CAN_REQUEST_PERSONAL_TIME)        INTEGER DEFAULT (0),
                \(COLUMNS.CAN_APPROVE_TIME_OFF)             INTEGER DEFAULT (0),
                \(COLUMNS.CAN_APPROVE_PAYROLL)              INTEGER DEFAULT (0),
                \(COLUMNS.CAN_EDIT_JOB_HISTORY)             INTEGER DEFAULT (0),
                \(COLUMNS.CAN_SCHEDULE_JOBS)                INTEGER DEFAULT (0),
                \(COLUMNS.RECEIVE_EMAILS_FOR_REJECTED_JOBS) INTEGER DEFAULT (0),
                \(COLUMNS.SAMPLE_WORKER_ROLES_GROUP)        INTEGER DEFAULT (0),
                \(COLUMNS.REMOVED)                          INTEGER DEFAULT (0),
                \(COLUMNS.REMOVED_DATE)                     TEXT,
                \(COLUMNS.REMOVED_BY)   INTEGER References \(TABLES.WORKERS) (\(COLUMNS.WORKER_ID))
            )
         """
         
         AppDatabase.shared.executeSQL(sql: sql,
                                       arguments: [],typeOfAction: .create, updatedId: nil) { (_) in
             print("TABLE Worker Roles Group is CREATED SUCCESSFULLY")
         } fail: { (error) in
             print(error)
         }
    }
    
    func insertRolesGroup(rolesGroup: WorkerRolesGroup, success: @escaping(_ id: Int64) -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "groupName"                     : rolesGroup.groupName,
            "admin"                         : rolesGroup.role.admin,
            "techSupport"                   : rolesGroup.role.techSupport,
            "owners"                        : rolesGroup.role.owner,
            "canDoCompanySetup"             : rolesGroup.role.canDoCompanySetup,
            "canAddWorkers"                 : rolesGroup.role.canAddWorkers,
            "canAddCustomer"                : rolesGroup.role.canAddCustomers,
            "canRunPayroll"                 : rolesGroup.role.canRunPayroll,
            "canSeeWages"                   : rolesGroup.role.canSeeWages,
//            "canSchedule"                   : rolesGroup.role.canSchedule,
            "canDoInventory"                : rolesGroup.role.canDoInventory,
            "canRunReport"                  : rolesGroup.role.canRunReports,
            "canAddRemoveInventoryItems"    : rolesGroup.role.canAddRemoveInventoryItems,
            "canEditTimeAlreadyEntered"     : rolesGroup.role.canEditTimeAlreadyEntered,
            "canRequestVacation"            : rolesGroup.role.canRequestVacation,
            "canRequestSick"                : rolesGroup.role.canRequestSick,
            "canRequestPersonalTime"        : rolesGroup.role.canRequestPersonalTime,
            "canApproveTimeOff"             : rolesGroup.role.canApproveTimeoff,
            "canApprovePayroll"             : rolesGroup.role.canApprovePayroll,
            "canEditJobHistory"             : rolesGroup.role.canEditJobHistory,
            "canScheduleJobs"               : rolesGroup.role.canScheduleJobs,
            "canApprovePurchaseOrders"      : rolesGroup.role.canApprovePurchaseOrders,
            "canApproveWorkOrders"          : rolesGroup.role.canApproveWorkOrders,
            "canApproveInvoices"            : rolesGroup.role.canApproveInvoices,
            "receiveEmailForRejectedJobs"   : rolesGroup.role.receiveEmailForRejectedJobs,
            "removed"                       : rolesGroup.removed,
            "removedDate"                   : DateManager.getStandardDateString(date: rolesGroup.removedDate),
            "removedBy"                     : rolesGroup.removedBy
        ]
        
        let sql = """
            INSERT INTO chg.\(tableName) (
                    \(COLUMNS.GROUP_NAME),
                    \(COLUMNS.ADMIN),
                    \(COLUMNS.MPH_XX_TECH_SUPPORT),
                    \(COLUMNS.MPH_XX_OWNERS),
                    \(COLUMNS.CAN_DO_COMPANY_SETUP),
                    \(COLUMNS.CAN_ADD_WORKERS),
                    \(COLUMNS.CAN_ADD_CUSTOMERS),
                    \(COLUMNS.CAN_RUN_PAYROLL),
                    \(COLUMNS.CAN_SEE_WAGES),
                    \(COLUMNS.CAN_DO_INVENTORY),
                    \(COLUMNS.CAN_RUN_REPORTS),
                    \(COLUMNS.CAN_ADD_REMOVE_INVENTORY_ITEMS),
                    \(COLUMNS.CAN_EDIT_TIME_ALREADY_ENTERED),
                    \(COLUMNS.CAN_REQUEST_VACATION),
                    \(COLUMNS.CAN_REQUEST_SICK),
                    \(COLUMNS.CAN_REQUEST_PERSONAL_TIME),
                    \(COLUMNS.CAN_APPROVE_TIME_OFF),
                    \(COLUMNS.CAN_APPROVE_PAYROLL),
                    \(COLUMNS.CAN_EDIT_JOB_HISTORY),
                    \(COLUMNS.CAN_SCHEDULE_JOBS),
                    \(COLUMNS.CAN_APPROVE_PURCHASE_ORDERS),
                    \(COLUMNS.CAN_APPROVE_WORK_ORDERS),
                    \(COLUMNS.CAN_APPROVE_INVOICES),
                    \(COLUMNS.RECEIVE_EMAILS_FOR_REJECTED_JOBS),
                    \(COLUMNS.REMOVED),
                    \(COLUMNS.REMOVED_DATE),
                    \(COLUMNS.REMOVED_BY)
                )

            VALUES (:groupName,
                    :admin,
                    :techSupport,
                    :owners,
                    :canDoCompanySetup,
                    :canAddWorkers,
                    :canAddCustomer,
                    :canRunPayroll,
                    :canSeeWages,
                    :canDoInventory,
                    :canRunReport,
                    :canAddRemoveInventoryItems,
                    :canEditTimeAlreadyEntered,
                    :canRequestVacation,
                    :canRequestSick,
                    :canRequestPersonalTime,
                    :canApproveTimeOff,
                    :canApprovePayroll,
                    :canEditJobHistory,
                    :canScheduleJobs,
                    :canApprovePurchaseOrders,
                    :canApproveWorkOrders,
                    :canApproveInvoices,
                    :receiveEmailForRejectedJobs,
                    :removed,
                    :removedDate,
                    :removedBy)
            """
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,
                                     typeOfAction: .insert, updatedId: nil,
                                     success: { id in
                                        success(id)
                                     },
                                     fail: failure)
    }
    
    func update(rolesGroup: WorkerRolesGroup, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "id"                            : rolesGroup.workerRolesGroupID,
            "groupName"                     : rolesGroup.groupName,
            "admin"                         : rolesGroup.role.admin,
            "techSupport"                   : rolesGroup.role.techSupport,
            "owners"                        : rolesGroup.role.owner,
            "canDoCompanySetup"             : rolesGroup.role.canDoCompanySetup,
            "canAddWorkers"                 : rolesGroup.role.canAddWorkers,
            "canAddCustomer"                : rolesGroup.role.canAddCustomers,
            "canRunPayroll"                 : rolesGroup.role.canRunPayroll,
            "canSeeWages"                   : rolesGroup.role.canSeeWages,
//            "canSchedule"                   : rolesGroup.role.canSchedule,
            "canDoInventory"                : rolesGroup.role.canDoInventory,
            "canRunReport"                  : rolesGroup.role.canRunReports,
            "canAddRemoveInventoryItems"    : rolesGroup.role.canAddRemoveInventoryItems,
            "canEditTimeAlreadyEntered"     : rolesGroup.role.canEditTimeAlreadyEntered,
            "canRequestVacation"            : rolesGroup.role.canRequestVacation,
            "canRequestSick"                : rolesGroup.role.canRequestSick,
            "canRequestPersonalTime"        : rolesGroup.role.canRequestPersonalTime,
            "canApproveTimeOff"             : rolesGroup.role.canApproveTimeoff,
            "canApprovePayroll"             : rolesGroup.role.canApprovePayroll,
            "canEditJobHistory"             : rolesGroup.role.canEditJobHistory,
            "canScheduleJobs"               : rolesGroup.role.canScheduleJobs,
            "canApprovePurchaseOrders"      : rolesGroup.role.canApprovePurchaseOrders,
            "canApproveWorkOrders"          : rolesGroup.role.canApproveWorkOrders,
            "canApproveInvoices"            : rolesGroup.role.canApproveInvoices,
            "receiveEmailForRejectedJobs"   : rolesGroup.role.receiveEmailForRejectedJobs,
            "removed"                       : rolesGroup.removed,
            "removedDate"                   : DateManager.getStandardDateString(date: rolesGroup.removedDate),
            "removedBy"                     : rolesGroup.removedBy
        ]
        
        let sql = """
            UPDATE \(tableName) SET
               \(COLUMNS.GROUP_NAME)                        = :groupName,
               \(COLUMNS.ADMIN)                             = :admin,
               \(COLUMNS.MPH_XX_TECH_SUPPORT)               = :techSupport,
               \(COLUMNS.MPH_XX_OWNERS)                     = :owners,
               \(COLUMNS.CAN_DO_COMPANY_SETUP)              = :canDoCompanySetup,
               \(COLUMNS.CAN_ADD_WORKERS)                   = :canAddWorkers,
               \(COLUMNS.CAN_ADD_CUSTOMERS)                 = :canAddCustomer,
               \(COLUMNS.CAN_RUN_PAYROLL)                   = :canRunPayroll,
               \(COLUMNS.CAN_SEE_WAGES)                     = :canSeeWages,
               \(COLUMNS.CAN_DO_INVENTORY)                  = :canDoInventory,
               \(COLUMNS.CAN_RUN_REPORTS)                   = :canRunReport,
               \(COLUMNS.CAN_ADD_REMOVE_INVENTORY_ITEMS)    = :canAddRemoveInventoryItems,
               \(COLUMNS.CAN_EDIT_TIME_ALREADY_ENTERED)     = :canEditTimeAlreadyEntered,
               \(COLUMNS.CAN_REQUEST_VACATION)              = :canRequestVacation,
               \(COLUMNS.CAN_REQUEST_SICK)                  = :canRequestSick,
               \(COLUMNS.CAN_REQUEST_PERSONAL_TIME)         = :canRequestPersonalTime,
               \(COLUMNS.CAN_APPROVE_TIME_OFF)              = :canApproveTimeOff,
               \(COLUMNS.CAN_APPROVE_PAYROLL)               = :canApprovePayroll,
               \(COLUMNS.CAN_EDIT_JOB_HISTORY)              = :canEditJobHistory,
               \(COLUMNS.CAN_SCHEDULE_JOBS)                 = :canScheduleJobs,
               \(COLUMNS.CAN_APPROVE_PURCHASE_ORDERS)       = :canApprovePurchaseOrders,
               \(COLUMNS.CAN_APPROVE_WORK_ORDERS)           = :canApproveWorkOrders,
               \(COLUMNS.CAN_APPROVE_INVOICES)              = :canApproveInvoices,
               \(COLUMNS.RECEIVE_EMAILS_FOR_REJECTED_JOBS)  = :receiveEmailForRejectedJobs,
               \(COLUMNS.REMOVED)                           = :removed,
               \(COLUMNS.REMOVED_DATE)                      = :removedDate,
               \(COLUMNS.REMOVED_BY)                        = :removedBy
            WHERE \(tableName).\(setIdKey()) = :id;
            """
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,
                                     typeOfAction: .update, updatedId: UInt64(rolesGroup.workerRolesGroupID!),
                                     success: { _ in
                                        success()
                                     },
                                     fail: failure)
    }
    
    func deleteWorkerRole(group: WorkerRolesGroup, success: @escaping () -> (), failure: @escaping (_ error: Error) -> ()) {
        guard let id = group.workerRolesGroupID else { return }
        softDelete(atId: id, success: success, fail: failure)
    }
    
    func restoreWorkerRole(group: WorkerRolesGroup, success: @escaping () -> (), failure: @escaping (_ error: Error) -> ()) {
        guard let id = group.workerRolesGroupID else { return }
        restoreItem(atId: id, success: success, fail: failure)
    }
    
    func fetchRolesGroup(showRemoved: Bool, key: String? = nil, showSelect: Bool, offset: Int, success: @escaping(_ groups: [WorkerRolesGroup]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        let searchable = makeSearchableItems(key: key)
        
        let removedCondition = " WHERE (main.\(tableName).\(COLUMNS.REMOVED) = 0 OR main.\(tableName).\(COLUMNS.REMOVED) is NULL) "
        let showRemovedCondition = " WHERE (main.\(tableName).\(COLUMNS.REMOVED) = 1) "
        
        let noSelectCondition = " AND main.\(tableName).\(COLUMNS.GROUP_NAME) != '--SELECT--' "

        var condition = (searchable.isEmpty) ? (showRemoved ? showRemovedCondition : removedCondition) : " \((showRemoved ? showRemovedCondition : removedCondition)) AND \(searchable)"
        
        if !showSelect {
            condition += noSelectCondition
        }

        var sql = """
        SELECT * FROM main.\(tableName)
        \(condition)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
//        sql += """
//                LIMIT \(LIMIT) OFFSET \(offset);
//        """
        
        
        do {
            let groups = try queue.read({ (db) -> [WorkerRolesGroup] in
                var groups: [WorkerRolesGroup] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    groups.append(.init(row: row))
                }
                return groups
            })
            success(groups)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    private func makeSearchableItems(key: String?) -> String {
           guard let key = key else { return "" }
           return  makeSearchableCondition(key: key,
                                           fields: [
                                               COLUMNS.GROUP_NAME,
                                               ])
       }
    
}
