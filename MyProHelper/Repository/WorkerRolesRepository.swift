//
//  WorkerRolesRepository.swift
//  MyProHelper
//
//  Created by Samir on 17/01/2021.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB

class WorkerRolesRepository: BaseRepository {
    
    init() {
        super.init(table: .WorkerRoles)
        createTableLayout()
    }
    
    override func setIdKey() -> String {
        return COLUMNS.WORKER_ID
    }
    
    private func createTableLayout() {
        let sql = """
             CREATE TABLE IF NOT EXISTS \(tableName) (
                \(COLUMNS.WORKER_ID)    INTEGER PRIMARY KEY REFERENCES \(TABLES.WORKERS) (\(COLUMNS.WORKER_ID)) UNIQUE,
                \(COLUMNS.WORKER_ROLES_GROUP_ID) INTEGER REFERENCES \(TABLES.WORKER_ROLES_GROUPS) (\(COLUMNS.WORKER_ROLES_GROUP_ID)),
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
                \(COLUMNS.SAMPLE_ROLE)                      INTEGER DEFAULT (0)
            )
         """
         
         AppDatabase.shared.executeSQL(sql: sql,
                                       arguments: [],typeOfAction: .create, updatedId: nil) { (_) in
             print("TABLE Worker Roles is CREATED SUCCESSFULLY")
         } fail: { (error) in
             print(error)
         }
    }
    
    func createWorkerRole(workerRole: WorkerRoles, success: @escaping () -> (), failure: @escaping (_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "workerId"                      : workerRole.workerID,
            "rolesGroupId"                  : workerRole.workerRoleGroupID,
            "admin"                         : workerRole.role.admin,
            "techSupport"                   : workerRole.role.techSupport,
            "owners"                        : workerRole.role.owner,
            "canDoCompanySetup"             : workerRole.role.canDoCompanySetup,
            "canAddWorkers"                 : workerRole.role.canAddWorkers,
            "canAddCustomer"                : workerRole.role.canAddCustomers,
            "canRunPayroll"                 : workerRole.role.canRunPayroll,
            "canSeeWages"                   : workerRole.role.canSeeWages,
//            "canSchedule"                   : workerRole.role.canSchedule,
            "canDoInventory"                : workerRole.role.canDoInventory,
            "canRunReport"                  : workerRole.role.canRunReports,
            "canAddRemoveInventoryItems"    : workerRole.role.canAddRemoveInventoryItems,
            "canEditTimeAlreadyEntered"     : workerRole.role.canEditTimeAlreadyEntered,
            "canRequestVacation"            : workerRole.role.canRequestVacation,
            "canRequestSick"                : workerRole.role.canRequestSick,
            "canRequestPersonalTime"        : workerRole.role.canRequestPersonalTime,
            "canApproveTimeOff"             : workerRole.role.canApproveTimeoff,
            "canApprovePayroll"             : workerRole.role.canApprovePayroll,
            "canEditJobHistory"             : workerRole.role.canEditJobHistory,
            "canScheduleJobs"               : workerRole.role.canScheduleJobs,
            "receiveEmailForRejectedJobs"   : workerRole.role.receiveEmailForRejectedJobs
        ]
        let sql = """
            INSERT INTO \(tableName) (
                    \(COLUMNS.WORKER_ID),
                    \(COLUMNS.WORKER_ROLES_GROUP_ID),
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
                    \(COLUMNS.RECEIVE_EMAILS_FOR_REJECTED_JOBS)
                )

            VALUES (:workerId,
                    :rolesGroupId,
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
                    :receiveEmailForRejectedJobs)
            """
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,
                                     typeOfAction: .create, updatedId: nil,
                                     success: { id in
                                        success()
                                     },
                                     fail: failure)
    }
    
    func updateWorkerRole(workerRole: WorkerRoles, success: @escaping () -> (), failure: @escaping (_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "id"                            : workerRole.workerID,
            "rolesGroupId"                  : workerRole.workerRoleGroupID,
            "admin"                         : workerRole.role.admin,
            "techSupport"                   : workerRole.role.techSupport,
            "owners"                        : workerRole.role.owner,
            "canDoCompanySetup"             : workerRole.role.canDoCompanySetup,
            "canAddWorkers"                 : workerRole.role.canAddWorkers,
            "canAddCustomer"                : workerRole.role.canAddCustomers,
            "canRunPayroll"                 : workerRole.role.canRunPayroll,
            "canSeeWages"                   : workerRole.role.canSeeWages,
//            "canSchedule"                   : workerRole.role.canSchedule,
            "canDoInventory"                : workerRole.role.canDoInventory,
            "canRunReport"                  : workerRole.role.canRunReports,
            "canAddRemoveInventoryItems"    : workerRole.role.canAddRemoveInventoryItems,
            "canEditTimeAlreadyEntered"     : workerRole.role.canEditTimeAlreadyEntered,
            "canRequestVacation"            : workerRole.role.canRequestVacation,
            "canRequestSick"                : workerRole.role.canRequestSick,
            "canRequestPersonalTime"        : workerRole.role.canRequestPersonalTime,
            "canApproveTimeOff"             : workerRole.role.canApproveTimeoff,
            "canApprovePayroll"             : workerRole.role.canApprovePayroll,
            "canEditJobHistory"             : workerRole.role.canEditJobHistory,
            "canScheduleJobs"               : workerRole.role.canScheduleJobs,
            "receiveEmailForRejectedJobs"   : workerRole.role.receiveEmailForRejectedJobs
        ]
        
        let sql = """
            UPDATE \(tableName) SET
               \(COLUMNS.WORKER_ROLES_GROUP_ID)             = :rolesGroupId,
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
               \(COLUMNS.RECEIVE_EMAILS_FOR_REJECTED_JOBS)  = :receiveEmailForRejectedJobs
            WHERE \(tableName).\(setIdKey()) = :id;
            """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,
                                     typeOfAction: .update, updatedId: UInt64(workerRole.workerID ?? 2),
                                     success: { _ in
                                        success()
                                     },
                                     fail: failure)
    }
    
    func deleteWorkerRole(workerRole: WorkerRoles, success: @escaping () -> (), failure: @escaping (_ error: Error) -> ()) {
        guard let id = workerRole.workerID else { return }
        softDelete(atId: id, success: success, fail: failure)
    }
    
    func fetchWorkerRoles(id: Int, success: @escaping (_ roles: WorkerRoles?) -> (), failure: @escaping (_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        
        let sql = """
        SELECT * FROM main.\(tableName)
        LEFT JOIN main.\(TABLES.WORKER_ROLES_GROUPS) ON main.\(tableName).\(COLUMNS.WORKER_ROLES_GROUP_ID) = \(TABLES.WORKER_ROLES_GROUPS).\(COLUMNS.WORKER_ROLES_GROUP_ID)
        where main.\(tableName).\(COLUMNS.WORKER_ID) = \(id);
        """
        do {
            let roles = try queue.read({ (db) -> WorkerRoles? in
                var roles: [WorkerRoles] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    roles.append(.init(row: row))
                }
                return roles.first
            })
            success(roles)
        }
        catch {
            failure(error)
            print(error)
        }
    }
}
