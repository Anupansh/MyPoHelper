//
//  RolesGroupDBService.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 23/06/1942 Saka.
//  Copyright © 1942 Sourabh Nag. All rights reserved.
//

import Foundation
import SQLite

class RoleGroupRepository: RepositoryBaseModel<WorkerRolesGroup> {
       
    init() {
        super.init(table: .rolesGroup)
        createSelectedLayoutTable()
    }
    
    //TODO: Handle Error
    /// This fucntion creates table by specifying table name
    func createSelectedLayoutTable() {
        guard let db = self.applicationDB else {
            return
        }
                
        do {
            try db.run(table.create(ifNotExists: true) { t in
                t.column(workerRolesGroupID, unique: true)
                t.column(groupName)
                t.column(admin)
                t.column(mPHxxTechSupport)
                t.column(mPHxxOwners)
                t.column(canDoCompanySetup)
                t.column(canAddWorkers)
                t.column(canAddCustomers)
                t.column(canRunPayroll)
                t.column(canSeeWages)
                t.column(canSchedule)
                t.column(canDoInventory)
                t.column(canRunReports)
                t.column(canAddRemoveInventoryItems)
                t.column(canEditTimeAlreadyEntered)
                t.column(canRequestVacation)
                t.column(canRequestSick)
                t.column(canRequestPersonalTime)
                t.column(sampleWorkerRolesGroup)
                t.column(removed)
                t.column(removedBy)
                t.column(removedDate)
            })
        }catch {
            print(error)
        }
    }
    
    func insertRolesGroup(rolesGroup: WorkerRolesGroup, success: @escaping() -> (), failure: @escaping() -> ()) {
        guard let db = self.applicationDB
            else {
            return
        }
        
        let rolesGroupId = self.getRolesGroupCount() ?? -1
        let insert = table.insert(workerRolesGroupID <- rolesGroupId,
                                            groupName <- rolesGroup.groupName ?? "",
                                            admin <- rolesGroup.admin ?? false,
                                            mPHxxTechSupport <- rolesGroup.mphxxTechSupport ?? false,
                                            mPHxxOwners <- rolesGroup.mphxxOwners ?? false,
                                            canDoCompanySetup <- rolesGroup.canDoCompanySetUp ?? false,
                                            canAddWorkers <- rolesGroup.canAddWorkers ?? false,
                                            canAddCustomers <- rolesGroup.canAddCustomers ?? false,
                                            canRunPayroll <- rolesGroup.canRunPayroll ?? false,
                                            canSeeWages <- rolesGroup.canSeeWages ?? false,
                                            canSchedule <- rolesGroup.canSchedule ?? false,
                                            canDoInventory <- rolesGroup.canDoInventory ?? false,
                                            canRunReports <- rolesGroup.canRunReports ?? false,
                                            canAddRemoveInventoryItems <- rolesGroup.canAddRemoveInventoryItems ?? false,
                                            canEditTimeAlreadyEntered <- rolesGroup.canEditAlreadyTimeEntered ?? false,
                                            canRequestVacation <- rolesGroup.canRequestVacation ?? false,
                                            canRequestSick <- rolesGroup.canRequestSick ?? false,
                                            canRequestPersonalTime <- rolesGroup.canRequestPersonalTime ?? false,
                                            sampleWorkerRolesGroup <- rolesGroup.sampleWorkerRolesGroup ?? false,
                                            removed <- rolesGroup.removed ?? false,
                                            removedBy <- rolesGroup.removedBy ?? -1,
                                            removedDate <- rolesGroup.removedDate ?? ""
        )
        do {
            let rowid = try db.run(insert)
            print(rowid)
            success()
        }catch {
            failure()
        }
    }
    
    func update(rolesGroup: WorkerRolesGroup, success: @escaping() -> (), failure: @escaping() -> ()) {
        guard let db = self.applicationDB
            else {
            return
        }
        
        let receiptUpdate = table.filter(workerRolesGroupID == (rolesGroup.workerRolesGroupID ?? -1))
        let update = receiptUpdate.update(
            groupName <- rolesGroup.groupName ?? "",
            admin <- rolesGroup.admin ?? false,
            mPHxxTechSupport <- rolesGroup.mphxxTechSupport ?? false,
            mPHxxOwners <- rolesGroup.mphxxOwners ?? false,
            canDoCompanySetup <- rolesGroup.canDoCompanySetUp ?? false,
            canAddWorkers <- rolesGroup.canAddWorkers ?? false,
            canAddCustomers <- rolesGroup.canAddCustomers ?? false,
            canRunPayroll <- rolesGroup.canRunPayroll ?? false,
            canSeeWages <- rolesGroup.canSeeWages ?? false,
            canSchedule <- rolesGroup.canSchedule ?? false,
            canDoInventory <- rolesGroup.canDoInventory ?? false,
            canRunReports <- rolesGroup.canRunReports ?? false,
            canAddRemoveInventoryItems <- rolesGroup.canAddRemoveInventoryItems ?? false,
            canEditTimeAlreadyEntered <- rolesGroup.canEditAlreadyTimeEntered ?? false,
            canRequestVacation <- rolesGroup.canRequestVacation ?? false,
            canRequestSick <- rolesGroup.canRequestSick ?? false,
            canRequestPersonalTime <- rolesGroup.canRequestPersonalTime ?? false,
            sampleWorkerRolesGroup <- rolesGroup.sampleWorkerRolesGroup ?? false,
            removed <- rolesGroup.removed ?? false,
            removedBy <- rolesGroup.removedBy ?? -1,
            removedDate <- rolesGroup.removedDate ?? ""
        )
        do {
            let rowid = try db.run(update)
            print(rowid)
            success()
        }catch {
            failure()
        }
    }
    
    func fetchRolesGroup(with rolesGroupId: Int) -> WorkerRolesGroup? {
        guard let db = self.applicationDB
            else {
            return nil
        }
        
        let rolesGroupTable = table.filter(workerRolesGroupID == rolesGroupId)
        
        do {
            var rolesGroup: WorkerRolesGroup?
            for row in try db.prepare(rolesGroupTable) {
                rolesGroup = WorkerRolesGroup(row: row)
            }
            return rolesGroup
        }catch {
            return nil
        }
    }
    
    func getRolesGroupCount() -> Int? {
        guard let db = self.applicationDB
            else {
            return nil
        }
        
        do {
            let count = try db.scalar(table.count)
            return count
        }catch {
            return nil
        }
    }
}
