//
//  JobDetailRepository.swift
//  MyProHelper
//
//  Created by Deep on 2/22/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB

class JobDetailRepository: BaseRepository {

    init() {
        super.init(table: .JOB_DETAILS)
    }

    override func setIdKey() -> String {
        return COLUMNS.JOB_DETAIL_ID
    }
    
    func insert(jobDetail: JobDetail, success: @escaping(_ id: Int64) -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "jobID"                 : jobDetail.jobID,
            "customerId"            : jobDetail.customerID,
            "details"               : jobDetail.details,
            "createdBy"             : jobDetail.createdBy ?? AppLocals.worker.workerID,
            "createdDate"           : DateManager.getStandardDateString(date: jobDetail.createdDate),
            "modifiedBy"            : jobDetail.modifiedBy ?? AppLocals.worker.workerID,
            "modifiedDate"          : DateManager.getStandardDateString(date: jobDetail.modifiedDate),
            "sampleJobDetail"       : jobDetail.sampleJobDetail ?? 0,
            "removed"               : jobDetail.removed ?? 0,
            "removedDate"           : DateManager.getStandardDateString(date: jobDetail.removedDate),
            "numberOfAttachments"   : jobDetail.numberOfAttachments
            
        ]
        let sql = """
                INSERT INTO chg.\(tableName) (
                                        \(COLUMNS.JOB_ID),
                                        \(COLUMNS.CUSTOMER_ID),
                                        \(COLUMNS.DETAILS),
                                        \(COLUMNS.CREATED_BY),
                                        \(COLUMNS.CREATED_DATE),
                                        \(COLUMNS.MODIFIED_BY),
                                        \(COLUMNS.MODIFIED_DATE),
                                        \(COLUMNS.SAMPLE_JOB_DETAIL),
                                        \(COLUMNS.REMOVED),
                                        \(COLUMNS.REMOVED_DATE),
                                        \(COLUMNS.NUMBER_OF_ATTACHMENTS))
            
                VALUES (:jobID,
                        :customerId,
                        :details,
                        :createdBy,
                        :createdDate,
                        :modifiedBy,
                        :modifiedDate,
                        :sampleJobDetail,
                        :removed,
                        :removedDate,
                        :numberOfAttachments)
            """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                      arguments: arguments,
                                      typeOfAction: .insert, updatedId: nil,
                                      success: { id in
                                         success(id)
                                      },
                                      fail: failure)
    }
    
    func update(jobDetail: JobDetail, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "id"                    : jobDetail.jobDetailID,
            "jobID"                 : jobDetail.jobID,
            "customerId"            : jobDetail.customerID,
            "details"               : jobDetail.details,
            "createdBy"             : jobDetail.createdBy ?? AppLocals.worker.workerID,
            "createdDate"           : DateManager.getStandardDateString(date: jobDetail.createdDate),
            "modifiedBy"            : jobDetail.modifiedBy ?? AppLocals.worker.workerID,
            "modifiedDate"          : DateManager.getStandardDateString(date: jobDetail.modifiedDate),
            "sampleJobDetail"       : jobDetail.sampleJobDetail ?? 0,
            "removed"               : jobDetail.removed ?? 0,
            "removedDate"           : DateManager.getStandardDateString(date: jobDetail.removedDate),
            "numberOfAttachments"   : jobDetail.numberOfAttachments
        ]
        let sql = """
            UPDATE \(tableName) SET
                \(COLUMNS.JOB_ID)                   = :jobID,
                \(COLUMNS.CUSTOMER_ID)              = :customerId,
                \(COLUMNS.DETAILS)                  = :details,
                \(COLUMNS.CREATED_BY)               = :createdBy,
                \(COLUMNS.CREATED_DATE)             = :createdDate,
                \(COLUMNS.MODIFIED_BY)              = :modifiedBy,
                \(COLUMNS.MODIFIED_DATE)            = :modifiedDate,
                \(COLUMNS.SAMPLE_JOB_DETAIL)        = :sampleJobDetail,
                \(COLUMNS.REMOVED)                  = :removed,
                \(COLUMNS.REMOVED_DATE)             = :removedDate,
                \(COLUMNS.NUMBER_OF_ATTACHMENTS)    = :numberOfAttachments
            WHERE \(tableName).\(setIdKey()) = :id;
            """
        
        AppDatabase.shared.executeSQL(sql: sql, arguments: arguments, typeOfAction: .update, updatedId: UInt64(jobDetail.jobDetailID!)) { _ in
            success()
        } fail: { (error) in
            print(error)
        }

    }
    
    func fetchJobDetail(showRemoved: Bool, with key: String? = nil, sortBy: JobDetailListField? = nil, sortType: SortType? = nil ,offset: Int,success: @escaping(_ service: [JobDetail]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        let sortable = makeSortableItems(sortBy: sortBy, sortType: sortType)
        let searchable = makeSearchableItems(key: key)
        let condition = getShowRemoveCondition(showRemoved: showRemoved, searchable: searchable)
        
        var sql = """
        SELECT * FROM main.\(tableName)
        LEFT JOIN main.\(TABLES.CUSTOMERS) ON main.\(tableName).\(COLUMNS.CUSTOMER_ID) == main.\(TABLES.CUSTOMERS).\(COLUMNS.CUSTOMER_ID)
        LEFT JOIN main.\(TABLES.SCHEDULED_JOBS) ON main.\(tableName).\(COLUMNS.JOB_ID) == main.\(TABLES.SCHEDULED_JOBS).\(COLUMNS.JOB_ID)
        LEFT JOIN main.\(TABLES.WORKERS) ON main.\(tableName).\(COLUMNS.CREATED_BY) ==
                    main.\(TABLES.WORKERS).\(COLUMNS.WORKER_ID)

        \(condition)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        sql += """
                \(sortable.replaceMain())
        """
        do {
            let jobDetails = try queue.read({ (db) -> [JobDetail] in
                var jobDetails: [JobDetail] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    jobDetails.append(.init(row: row))
                }
                return jobDetails
            })
            success(jobDetails)
        }
        catch {
            failure(error)
        }
    }
    
    func fetchJobDetail(jobID: Int? = nil,showRemoved: Bool, with key: String? = nil, sortBy: JobDetailListField? = nil, sortType: SortType? = nil ,offset: Int,success: @escaping(_ service: [JobDetailLineItem]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        var arguments: StatementArguments = []
        let sortable = makeSortableItems2(sortBy: sortBy, sortType: sortType)
        let searchable = ""//makeSearchableItems(key: key)
        let condition = getShowRemoveCondition(showRemoved: showRemoved, searchable: searchable)
        
        var sql = """
        SELECT * FROM main.\(tableName)
        LEFT JOIN main.\(TABLES.WORKERS) ON main.\(tableName).\(COLUMNS.CREATED_BY) ==
                            main.\(TABLES.WORKERS).\(COLUMNS.WORKER_ID)

                
        \(condition)
        """
        
        if let jobID = jobID {
            arguments = [jobID]
            sql += " AND main.\(tableName).\(COLUMNS.JOB_ID) = ?"
            arguments += [jobID] // Only for using 'uniun' below
            
        }
        
        
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        sql += """
                \(sortable.replaceMain())
                LIMIT \(LIMIT) OFFSET \(offset);
        """
        do {
            let jobDetails = try queue.read({ (db) -> [JobDetailLineItem] in
                var jobDetails: [JobDetailLineItem] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: arguments)
                rows.forEach { (row) in
                    jobDetails.append(.init(row: row))
                }
                return jobDetails
            })
            success(jobDetails)
        }
        catch {
            failure(error)
        }
    }
    
    func removeJobDetail(jobDetail: JobDetail, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = jobDetail.jobDetailID else {
            return
        }
        softDelete(atId: id, success: success, fail: failure)
    }

    func unremoveJobDetail(jobDetail: JobDetail, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = jobDetail.jobDetailID else {
            return
        }
        restoreItem(atId: id, success: success, fail: failure)
    }
    
    private func makeSortableItems(sortBy: JobDetailListField?, sortType: SortType?) -> String {
        guard let sortBy = sortBy, let sortType = sortType else {
            return makeSortableCondition(key:"main.\(TABLES.CUSTOMERS).\(COLUMNS.CUSTOMER_NAME)",
                                         sortType: .ASCENDING)
        }
        switch sortBy {
        case .CUSTOMER_NAME:
            return makeSortableCondition(key:"main.\(TABLES.CUSTOMERS).\(COLUMNS.CUSTOMER_NAME)", sortType: sortType)
        case .SHORT_DESCRIPTION:
            return makeSortableCondition(key: COLUMNS.JOB_SHORT_DESCRIPTION, sortType: sortType)
        case .DETAILS:
            return makeSortableCondition(key: COLUMNS.DETAILS, sortType: sortType)
        case .CREATED_DATE:
            return makeSortableCondition(key: COLUMNS.DATE_CREATED, sortType: sortType)
        case .ATTACHMENTS:
            return makeSortableCondition(key: COLUMNS.NUMBER_OF_ATTACHMENTS, sortType: sortType)
        }
    }
    
    private func makeSortableItems2(sortBy: JobDetailListField?, sortType: SortType?) -> String {
        guard let sortBy = sortBy, let sortType = sortType else {
            return makeSortableCondition(key:COLUMNS.DETAILS,
                                         sortType: .ASCENDING)
        }
        switch sortBy {
//        case .CUSTOMER_NAME:
//            return makeSortableCondition(key:"main.\(TABLES.CUSTOMERS).\(COLUMNS.CUSTOMER_NAME)", sortType: sortType)
//        case .SHORT_DESCRIPTION:
//            return makeSortableCondition(key: COLUMNS.JOB_SHORT_DESCRIPTION, sortType: sortType)
        case .DETAILS:
            return makeSortableCondition(key: COLUMNS.DETAILS, sortType: sortType)
        case .CREATED_DATE:
            return makeSortableCondition(key: COLUMNS.DATE_CREATED, sortType: sortType)
//        case .ATTACHMENTS:
//            return makeSortableCondition(key: COLUMNS.NUMBER_OF_ATTACHMENTS, sortType: sortType)
        default:
            return ""
            break
        }
    }
    

    private func makeSearchableItems(key: String?) -> String {
        guard let key = key else { return "" }
        return  makeSearchableCondition(key: key,
                                        fields: [
                                            "main.\(TABLES.CUSTOMERS).\(COLUMNS.CUSTOMER_NAME)",
                                            "main.\(TABLES.SCHEDULED_JOBS).\(COLUMNS.JOB_SHORT_DESCRIPTION)",
                                            "main.\(tableName).\(COLUMNS.DETAILS)",
                                            "main.\(tableName).\(COLUMNS.NUMBER_OF_ATTACHMENTS)"])
    }

}
