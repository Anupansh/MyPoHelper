//
//  CustomerJobHistoryRepository.swift
//  MyProHelper
//
//  Created by Deep on 1/25/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB

class CustomerJobHistoryRepository: BaseRepository {
    
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
    
    func fetchJob(for job: JobHistory,showRemoved: Bool, with key: String? = nil, sortBy: CustomerJobHistoryField? = nil, sortType: SortType? = nil ,offset: Int,success: @escaping(_ job: [CustomerJobHistory]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        guard let customerID = job.customerID else { return }
        
        let sortable = makeSortableItems(sortBy: sortBy, sortType: sortType)
        let searchable = makeSearchableItems(key: key)
        let condition = (searchable.isEmpty) ? "" : "AND \(searchable)"
        var sql = """
        SELECT * FROM main.\(tableName)
        LEFT JOIN main.\(TABLES.WORKERS) ON main.\(tableName).\(COLUMNS.WORKER_SCHEDULED) == main.\(TABLES.WORKERS).\(COLUMNS.WORKER_ID)
        LEFT JOIN main.\(TABLES.CUSTOMERS) ON main.\(tableName).\(COLUMNS.CUSTOMER_ID) == main.\(TABLES.CUSTOMERS).\(COLUMNS.CUSTOMER_ID)
        WHERE main.\(tableName).\(COLUMNS.CUSTOMER_ID) == \(customerID)
        \(condition)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        sql += """
                \(sortable)
                LIMIT \(LIMIT) OFFSET \(offset);
        """
        do {
            let jobsHistory = try queue.read({ (db) -> [CustomerJobHistory] in
                var jobsHistory: [CustomerJobHistory] = []
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
    
    func update(jobHistory: CustomerJobHistory, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "id"                    : jobHistory.jobID,
            "customerId"            : jobHistory.customerID,
            "addressOne"            : jobHistory.jobLocationAddress1,
            "addressTwo"            : jobHistory.jobLocationAddress2,
            "city"                  : jobHistory.jobLocationCity,
            "state"                 : jobHistory.jobLocationState,
            "zipCode"               : jobHistory.jobLocationZip,
            "contactPerson"         : jobHistory.jobContactPersonName,
            "contactPhone"          : jobHistory.jobContactPhone,
            "contactEmail"          : jobHistory.jobContactEmail,
            "jobShortDescription"   : jobHistory.jobShortDescription,
            "jobDescription"        : jobHistory.jobDescription,
            "startDate"             : DateManager.getStandardDateString(date: jobHistory.startDateTime),
            "workerScheduled"       : jobHistory.workerScheduled,
            "jobStatus"             : jobHistory.jobStatus,
            "jobPrice"              : jobHistory.jobPrice,
            "tax"                   : jobHistory.salesTax,
            "paid"                  : jobHistory.paid,
            "previousVisit"         : jobHistory.previousVisitOnThisJob,
            "nextVisit"             : jobHistory.nextVisitOnThisJob,
            "sampleJob"             : jobHistory.sampleJobHistory,
            "numberOfAttachement"   : jobHistory.numberOfAttachments
        ]
        let sql = """
            UPDATE \(tableName) SET
                \(COLUMNS.CUSTOMER_ID)                          = :customerId,
                \(COLUMNS.JOB_LOCATION_ADDRESS_1)               = :addressOne,
                \(COLUMNS.JOB_LOCATION_ADDRESS_2)               = :addressTwo,
                \(COLUMNS.JOB_LOCATION_CITY)                    = :city,
                \(COLUMNS.JOB_LOCATION_STATE)                   = :state,
                \(COLUMNS.JobLocationZIP)                       = :zipCode,
                \(COLUMNS.JOB_CONTACT_PERSON_NAME)              = :contactPerson,
                \(COLUMNS.JOB_CONTACT_PHONE)                    = :contactPhone,
                \(COLUMNS.JOB_CONTACT_EMAIL)                    = :contactEmail,
                \(COLUMNS.JOB_SHORT_DESCRIPTION)                = :jobShortDescription,
                \(COLUMNS.JOB_DESCRIPTION)                      = :jobDescription,
                \(COLUMNS.START_DATE_TIME)                      = :startDate,
                \(COLUMNS.WORKER_SCHEDULED)                     = :workerScheduled,
                \(COLUMNS.JOB_STATUS)                           = :jobStatus,
                \(COLUMNS.JOB_PRICE)                            = :jobPrice,
                \(COLUMNS.SALES_TAX)                            = :tax,
                \(COLUMNS.PAID)                                 = :paid,
                \(COLUMNS.PREVIOUS_VISIT_ON_THIS_JOB)           = :previousVisit,
                \(COLUMNS.NEXT_VISIT_ON_THIS_JOB)               = :nextVisit,
                \(COLUMNS.SAMPLE_JOB_HISTORY)                   = :sampleJob,
                \(COLUMNS.NUMBER_OF_ATTACHMENTS)                = :numberOfAttachement
            WHERE \(tableName).\(setIdKey()) = :id;
            """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,
                                     typeOfAction: .update, updatedId: UInt64(jobHistory.jobID!),
                                     success: { _ in
                                        success()
                                     },
                                     fail: failure)
    }
    
    private func makeSortableItems(sortBy: CustomerJobHistoryField?, sortType: SortType?) -> String {
        guard let sortBy = sortBy, let sortType = sortType else {
            return makeSortableCondition(key: COLUMNS.JOB_ID, sortType: .ASCENDING)
        }
        switch sortBy {
        case .JOB_ID:
            return makeSortableCondition(key: COLUMNS.JOB_ID, sortType: sortType)
        case .JOB_START_DATE:
            return makeSortableCondition(key: COLUMNS.START_DATE_TIME, sortType: sortType)
        case .JOB_LOCAION_ADDRESS:
            return makeSortableCondition(key: COLUMNS.JOB_LOCATION_ADDRESS_1, sortType: sortType)
        case .JOB_CONTACT_PERSON_NAME:
            return makeSortableCondition(key: COLUMNS.JOB_CONTACT_PERSON_NAME, sortType: sortType)
        case .JOB_CONTACT_PHONE:
            return makeSortableCondition(key: COLUMNS.JOB_CONTACT_PHONE, sortType: sortType)
        case .JOB_DESCRIPTION:
            return makeSortableCondition(key: COLUMNS.JOB_DESCRIPTION, sortType: sortType)
        case .JOB_PRICE:
            return makeSortableCondition(key: COLUMNS.JOB_PRICE, sortType: sortType)
        case .SALES_TAX:
            return makeSortableCondition(key: COLUMNS.SALES_TAX, sortType: sortType)
        case .JOB_STATUS:
            return makeSortableCondition(key: COLUMNS.JOB_STATUS, sortType: sortType)
        case .PAID:
            return makeSortableCondition(key: COLUMNS.PAID, sortType: sortType)
        }
    }
    
    private func makeSearchableItems(key: String?) -> String {
        guard let key = key else { return "" }
        return makeSearchableCondition(key: key,
                                       fields: [
                                        COLUMNS.JOB_ID,
                                        COLUMNS.START_DATE_TIME,
                                        COLUMNS.JOB_LOCATION_ADDRESS_1,
                                        COLUMNS.JOB_CONTACT_PERSON_NAME,
                                        COLUMNS.JOB_CONTACT_PHONE,
                                        COLUMNS.JOB_DESCRIPTION,
                                        COLUMNS.JOB_PRICE,
                                        COLUMNS.SALES_TAX,
                                        COLUMNS.JOB_STATUS,
                                        COLUMNS.PAID
                                       ])
    }
}
