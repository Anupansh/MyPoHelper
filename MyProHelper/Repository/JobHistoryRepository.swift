//
//  JobHistoryRepository.swift
//  MyProHelper
//
//  Created by Deep on 1/18/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB

class JobHistoryRepository: BaseRepository {
    
    init() {
        super.init(table: .JOBS_HISTORY)
        createSelectedLayoutTable()
    }
    
    override func setIdKey() -> String {
        return COLUMNS.JOB_ID
    }
    
    private func createSelectedLayoutTable() {
        let sql = """
            CREATE TABLE IF NOT EXISTS \(tableName)
            (
                \(COLUMNS.JOB_ID)       INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
                \(COLUMNS.CUSTOMER_ID)  INTEGER NOT NULL REFERENCES \(TABLES.CUSTOMERS) (\(COLUMNS.CUSTOMER_ID)),
                \(COLUMNS.JOB_LOCATION_ADDRESS_1)       TEXT NOT NULL,
                \(COLUMNS.JOB_LOCATION_ADDRESS_2)       TEXT,
                \(COLUMNS.JOB_LOCATION_CITY)            TEXT NOT NULL,
                \(COLUMNS.JOB_LOCATION_STATE)           TEXT,
                \(COLUMNS.JobLocationZIP)               TEXT  NOT NULL,
                \(COLUMNS.JOB_CONTACT_PERSON_NAME)      TEXT NOT NULL,
                \(COLUMNS.JOB_CONTACT_PHONE)            TEXT  NOT NULL,
                \(COLUMNS.JOB_CONTACT_EMAIL)            TEXT,
                \(COLUMNS.JOB_SHORT_DESCRIPTION)        TEXT,
                \(COLUMNS.JOB_DESCRIPTION)              TEXT,
                \(COLUMNS.START_DATE_TIME)              TEXT,
                \(COLUMNS.WORKER_SCHEDULED)             INTEGER REFERENCES \(TABLES.WORKERS) (\(COLUMNS.WORKER_ID)),
                \(COLUMNS.JOB_STATUS)                   TEXT,
                \(COLUMNS.JOB_PRICE)                    REAL,
                \(COLUMNS.SALES_TAX)                    REAL,
                \(COLUMNS.PAID)                         INTEGER,
                \(COLUMNS.PREVIOUS_VISIT_ON_THIS_JOB)    INTEGER /* REFERENCES ScheduledJobs(JobID)*/ ,
                \(COLUMNS.NEXT_VISIT_ON_THIS_JOB)       INTEGER /*REFERENCES SCHEDULEDJOBS(JobID)*/ ,
                \(COLUMNS.SAMPLE_JOB_HISTORY)         INTEGER DEFAULT (0),
                \(COLUMNS.NUMBER_OF_ATTACHMENTS)        INTEGER DEFAULT( 0)
            )
        """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                      arguments: [],typeOfAction: .create, updatedId: nil) { (_) in
            print("TABLE SCHEDULED JOBS IS CREATED SUCCESSFULLY")
        } fail: { (error) in
            print(error)
        }
    }
    
    func fetchJob(showRemoved: Bool, with key: String? = nil, sortBy: JobHistoryField? = nil, sortType: SortType? = nil ,offset: Int,success: @escaping(_ job: [JobHistory]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        let sortable = makeSortableItems(sortBy: sortBy, sortType: sortType)
        let searchable = makeSearchableItems(key: key)
        let condition = (searchable.isEmpty) ? "" : "WHERE \(searchable)"
        var sql = """
        SELECT * FROM main.\(tableName)
        LEFT JOIN main.\(TABLES.WORKERS) ON main.\(tableName).\(COLUMNS.WORKER_SCHEDULED) == main.\(TABLES.WORKERS).\(COLUMNS.WORKER_ID)
        LEFT JOIN main.\(TABLES.CUSTOMERS) ON main.\(tableName).\(COLUMNS.CUSTOMER_ID) == main.\(TABLES.CUSTOMERS).\(COLUMNS.CUSTOMER_ID)
        \(condition)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        sql += """
                \(sortable)
                LIMIT \(LIMIT) OFFSET \(offset);
        """
        do {
            let jobsHistory = try queue.read({ (db) -> [JobHistory] in
                var jobsHistory: [JobHistory] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    jobsHistory.append(.init(row: row))
                }
                return jobsHistory
            })
            success(jobsHistory)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    private func makeSortableItems(sortBy: JobHistoryField?, sortType: SortType?) -> String {
        guard let sortBy = sortBy, let sortType = sortType else {
            return makeSortableCondition(key: COLUMNS.FIRST_NAME, sortType: .ASCENDING)
        }
        switch sortBy {
        case .CUSTOMER_NAME:
            return makeSortableCondition(key: COLUMNS.CUSTOMER_NAME, sortType: sortType)
        case .WORKER_NAME:
            return makeSortableCondition(key: COLUMNS.FIRST_NAME, sortType: sortType)
        case .SCHEDULED_DATE_TIME:
            return makeSortableCondition(key: COLUMNS.START_DATE_TIME, sortType: sortType)
        case .ADDRESS:
            return makeSortableCondition(key: COLUMNS.JOB_LOCATION_ADDRESS_1, sortType: sortType)
        case .CONTACT_PHONE:
            return makeSortableCondition(key: COLUMNS.JOB_CONTACT_PHONE, sortType: sortType)
        case .JOB_TITLE:
            return makeSortableCondition(key: COLUMNS.JOB_SHORT_DESCRIPTION, sortType: sortType)
        case .DESCRIPTION:
            return makeSortableCondition(key: COLUMNS.JOB_DESCRIPTION, sortType: sortType)
        case .STATUS:
            return makeSortableCondition(key: COLUMNS.JOB_STATUS, sortType: sortType)
        case .ATTACHMENTS:
            return makeSortableCondition(key: COLUMNS.NUMBER_OF_ATTACHMENTS, sortType: sortType)
        }
    }
    
    private func makeSearchableItems(key: String?) -> String {
        guard let key = key else { return "" }
        return makeSearchableCondition(key: key,
                                       fields: [
                                        COLUMNS.CUSTOMER_NAME,
                                        COLUMNS.FIRST_NAME,
                                        COLUMNS.START_DATE_TIME,
                                        COLUMNS.JOB_LOCATION_ADDRESS_1,
                                        COLUMNS.JOB_CONTACT_PHONE,
                                        COLUMNS.JOB_SHORT_DESCRIPTION,
                                        COLUMNS.JOB_DESCRIPTION,
                                        COLUMNS.JOB_STATUS,
                                        COLUMNS.NUMBER_OF_ATTACHMENTS
                                       ])
    }
}
