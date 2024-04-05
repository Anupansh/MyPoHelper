//
//  TimeOffApprovalRepository.swift
//  MyProHelper
//
//  Created by Samir on 11/29/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import GRDB

class TimeOffApprovalRepository: BaseRepository{
    
    init() {
        super.init(table: .APPROVALS)
        createSelectedLayoutTable()
    }
    
    override func setIdKey() -> String {
        return COLUMNS.TIME_OFF_REQUEST_ID
    }
    
    private func createSelectedLayoutTable() {
        let sql = """
            CREATE TABLE IF NOT EXISTS \(tableName)(
               \(COLUMNS.TIME_OFF_REQUEST_ID) INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL,
                \(COLUMNS.WORKER_ID) INTEGER REFERENCES Workers (WorkerID) NOT NULL,
                \(COLUMNS.WORKER_NAME)      TEXT (100) NOT NULL,
                \(COLUMNS.DESCRIPTION)      TEXT(100),
                \(COLUMNS.START_DATE)       TEXT,
                \(COLUMNS.END_DATE)         TEXT,
                \(COLUMNS.TYPEOF_LEAVE)     TEXT(100),
                \(COLUMNS.STATUS)           TEXT(100),
                \(COLUMNS.Remarks)           TEXT(100),
                \(COLUMNS.DATE_REQUESTED)   TEXT,
                \(COLUMNS.APPROVER_NAME)    TEXT (100),
                \(COLUMNS.APPROVED_BY)      INTEGER,
                \(COLUMNS.APPROVED_DATE)    INTEGER,
                \(COLUMNS.REMOVED)          INTEGER DEFAULT (0),
                \(COLUMNS.REMOVED_DATE)     TEXT
            )
        """
        AppDatabase.shared.executeSQL(sql: sql,
                                      arguments: [],typeOfAction: .create,updatedId: nil) { (_) in
            print("TABLE APPRPVAL IS CREATED SUCCESSFULLY")
        } fail: { (error) in
            print(error)
        }
    }
    
    func createApproval(worker: Approval, success: @escaping(_ id: Int64) -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "workerid"         : worker.workerID,
            "description"        : worker.description,
            "startdate"          : worker.startdate,
            "enddate"            : worker.endDate,
            "typeofleave"        : worker.typeofleave,
            "status"             : worker.status,
            "remark"             : worker.remark,
            "requesteddate"      : worker.requesteddate,
            "approvedby"         : worker.approvedby ?? 0,
            "approveddate"       : worker.approveddate
//            "removed"            : worker.removed,
//            "removedDate"        : worker.removedDate

        ]
        /*let sql = """
            INSERT INTO \(tableName) (
                \(COLUMNS.WORKER_ID),
                \(COLUMNS.DESCRIPTION),
                \(COLUMNS.START_DATE),
                \(COLUMNS.END_DATE),
                \(COLUMNS.TYPEOF_LEAVE),
                \(COLUMNS.STATUS),
                \(COLUMNS.Remarks),
                \(COLUMNS.DATE_REQUESTED),
                \(COLUMNS.APPROVED_BY),
                \(COLUMNS.REMOVED),
                \(COLUMNS.REMOVED_DATE),
                
            )
            VALUES (:workerid,
                    :description,
                    :startdate,
                    :enddate,
                    :typeofleave,
                    :status,
                    :remark,
                    :requesteddate,
                    :removed,
                    :approvedby,
                    :approveddate
            )
            """*/
        
        
        let sql = """
            INSERT INTO chg.\(tableName) (
                \(COLUMNS.WORKER_ID),
                \(COLUMNS.DESCRIPTION),
                \(COLUMNS.START_DATE),
                \(COLUMNS.END_DATE),
                \(COLUMNS.TYPEOF_LEAVE),
                \(COLUMNS.STATUS),
                \(COLUMNS.Remarks),
                \(COLUMNS.DATE_REQUESTED),
                \(COLUMNS.APPROVED_BY),
                \(COLUMNS.APPROVED_DATE)
                
            )
            VALUES (:workerid,
            :description,
            :startdate,
            :enddate,
            :typeofleave,
            :status,
            :remark,
            :requesteddate,
            :approvedby,
            :approveddate
            )
            """
        //                    :approvername,
        //  \(COLUMNS.APPROVER_NAME),
        print("ARGUMENTS: \(arguments)")
        AppDatabase.shared.executeSQL(sql: sql,
                                      arguments: arguments,
                                      typeOfAction: .insert,updatedId: nil,
                                      success: { id in
                                        success(id)
                                      },
                                      fail: failure)
    }
    
    
    func updateApproval(worker: Approval, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {

        let arguments: StatementArguments = [
                        
                       "description"      : worker.description,
                       "startdate"        : worker.startdate,
                       "enddate"          : worker.endDate,
                       "typeofleave"      : worker.typeofleave,
                       "status"           : worker.status,
                       "remark"           : worker.remark,
                       "requesteddate"    : worker.requesteddate,
                       "approvedby"       : worker.approvedby,
                       "approveddate"     : worker.approveddate,
                       "Fid"             : worker.TimeOffRequestsID
        ]
        
        let sql = """
            UPDATE \(tableName) SET
            
               \(COLUMNS.DESCRIPTION)          = :description,
               \(COLUMNS.START_DATE)           = :startdate,
                \(COLUMNS.END_DATE)            = :enddate,
               \(COLUMNS.TYPEOF_LEAVE)         = :typeofleave,
                \(COLUMNS.STATUS)              = :status,
               \(COLUMNS.Remarks)              = :remark,
                \(COLUMNS.DATE_REQUESTED)      = :requesteddate,
                \(COLUMNS.APPROVED_BY)         = :approvedby,
                \(COLUMNS.APPROVED_DATE)       = :approveddate
             
            WHERE \(tableName).\(setIdKey()) = :Fid;
            """
       print("ARGUMENTS: \(arguments)")
       AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,
                                     typeOfAction: .update,updatedId: UInt64(worker.TimeOffRequestsID!),
                                     success: { _ in
                                        success()
                                     },
                                     fail: failure)
    }
    
    func deleteApproval(worker: Approval, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id =  worker.TimeOffRequestsID else { return }
        softDelete(atId: id, success: success, fail: failure)
    }
    
    

    func restoreApproval(worker: Approval, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = worker.TimeOffRequestsID else { return }
        restoreItem(atId: id, success: success, fail: failure)
    }
    
    
    func fetchApproval(showRemoved: Bool, with key: String? = nil, sortBy: TimeOffApprovalField? = nil, sortType: SortType? = nil ,offset: Int,success: @escaping(_ approval: [Approval]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        let sortable = makeSortableItems(sortBy: sortBy, sortType: sortType)
        let searchable = makeSearchableItems(key: key)
        let condition = getShowRemoveCondition(showRemoved: showRemoved, searchable: searchable)
        var sql1 = """
        SELECT * FROM main.\(tableName)
        LEFT JOIN main.\(TABLES.WORKERS) ON main.\(tableName).\(COLUMNS.WORKER_ID) ==
            main.\(TABLES.WORKERS).\(COLUMNS.WORKER_ID)
              \(condition)
        """
        let chgSql = " union \(sql1.replaceMain())"
        sql1 += chgSql
        do {
            let timeoffapproval = try queue.read({ (db) -> [Approval] in
                var timeoffapproval: [Approval] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql1,
                                            arguments: [])
                rows.forEach { (row) in
                    timeoffapproval.append(.init(row: row))
                }
                return timeoffapproval
            })
            success(timeoffapproval)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    
    private func makeSortableItems(sortBy: TimeOffApprovalField?, sortType: SortType?) -> String {
        guard let sortBy = sortBy, let sortType = sortType else {
            return makeSortableCondition(key: COLUMNS.WORKER_NAME, sortType: .ASCENDING)
        }
        switch sortBy {
        case .WORKER_NAME:
            return makeSortableCondition(key: COLUMNS.WORKER_NAME, sortType: sortType)
        case .DESCRIPTION:
            return makeSortableCondition(key: COLUMNS.DESCRIPTION, sortType: sortType)
        case .START_DATE:
            return makeSortableCondition(key: COLUMNS.START_DATE, sortType: sortType)
        case .END_DATE:
            return makeSortableCondition(key: COLUMNS.END_DATE, sortType: sortType)
        case .TYPEOF_LEAVE:
            return makeSortableCondition(key: COLUMNS.TYPEOF_LEAVE, sortType: sortType)
        case .STATUS:
            return makeSortableCondition(key: COLUMNS.STATUS, sortType: sortType)
        case .REMARK:
            return makeSortableCondition(key: COLUMNS.Remarks, sortType: sortType)
        case .REQUESTED_DATE:
            return makeSortableCondition(key: COLUMNS.DATE_REQUESTED, sortType: sortType)
        case .APPROVER_NAME:
            return makeSortableCondition(key: COLUMNS.APPROVER_NAME, sortType: sortType)
        case .APPROVED_DATE:
            return makeSortableCondition(key: COLUMNS.APPROVED_DATE, sortType: sortType)
        
            
        }
    }
    

private func makeSearchableItems(key: String?) -> String {
    guard let key = key else { return "" }
    return makeSearchableCondition(key: key,
                                   fields: [
                                    COLUMNS.FIRST_NAME,
                                    COLUMNS.LAST_NAME,
                                   
                                   ])
}
}
