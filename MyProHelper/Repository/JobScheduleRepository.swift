//
//  ScheduleJobDBService.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 20/05/1942 Saka.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB


class JobScheduleRepository: BaseRepository {
        
    init() {
        super.init(table: .SCHEDULED_JOBS)
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
                \(COLUMNS.END_DATE_TIME)                TEXT,
                \(COLUMNS.ESTIMATED_TIME_DURATION)      TEXT,
                \(COLUMNS.WORKER_SCHEDULED)             INTEGER REFERENCES \(TABLES.WORKERS) (\(COLUMNS.WORKER_ID)),
                \(COLUMNS.JOB_STATUS)                   TEXT,
                \(COLUMNS.PREVIOUS_VISIT_ON_THIS_JOB)    INTEGER /* REFERENCES ScheduledJobs(JobID)*/ ,
                \(COLUMNS.NEXT_VISIT_ON_THIS_JOB)       INTEGER /*REFERENCES SCHEDULEDJOBS(JobID)*/ ,
                \(COLUMNS.SAMPLE_SCHEDULED_JOB)         INTEGER DEFAULT (0),
                \(COLUMNS.REMOVED)                      INTEGER DEFAULT (0),
                \(COLUMNS.REMOVED_DATE)                 TEXT,
                \(COLUMNS.NUMBER_OF_ATTACHMENTS)        INTEGER DEFAULT( 0),
                \(COLUMNS.REJECTED)                     INTEGER DEFAULT (0),
                \(COLUMNS.REJECTED_REASON)              TEXT
            )
        """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                      arguments: [],typeOfAction: .create, updatedId: nil) { (_) in
            print("TABLE SCHEDULED JOBS IS CREATED SUCCESSFULLY")
        } fail: { (error) in
            print(error)
        }
    }
    
    func insertJob(job: Job, success: @escaping(_ id: Int64) -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "customerID"            : job.customerID,
            "LocationAddress1"      : job.jobLocationAddress1,
            "locationAddress2"      : job.jobLocationAddress2,
            "locationCity"          : job.jobLocationCity,
            "locationState"         : job.jobLocationState,
            "locationZip"           : job.jobLocationZip,
            "personName"            : job.jobContactPersonName,
            "contactPhone"          : job.jobContactPhone,
            "contactEmail"          : job.jobContactEmail,
            "shortDescription"      : job.jobShortDescription,
            "description"           : job.jobDescription,
            "startDate"             : DateManager.getStandardDateString(date: job.startDateTime),
            "endDate"               : DateManager.getStandardDateString(date: job.endDateTime),
            "timeDuration"          : job.estimateTimeDuration,
            "workerScheduled"       : job.worker?.workerID,
            "jobStatus"             : job.jobStatus,
            "removed"               : job.removed,
            "removedDate"           : DateManager.getStandardDateString(date: job.removedDate),
            "numberOfAttachments"   : job.numberOfAttachments,
            "rejected"              : job.rejected,
            "rejectedReason"        : job.rejectedReason
        ]
        let sql = """
            INSERT INTO chg.\(tableName) (
                                \(COLUMNS.CUSTOMER_ID),
                                \(COLUMNS.JOB_LOCATION_ADDRESS_1),
                                \(COLUMNS.JOB_LOCATION_ADDRESS_2),
                                \(COLUMNS.JOB_LOCATION_CITY),
                                \(COLUMNS.JOB_LOCATION_STATE),
                                \(COLUMNS.JobLocationZIP),
                                \(COLUMNS.JOB_CONTACT_PERSON_NAME),
                                \(COLUMNS.JOB_CONTACT_PHONE),
                                \(COLUMNS.JOB_CONTACT_EMAIL),
                                \(COLUMNS.JOB_SHORT_DESCRIPTION),
                                \(COLUMNS.JOB_DESCRIPTION),
                                \(COLUMNS.START_DATE_TIME),
                                \(COLUMNS.END_DATE_TIME),
                                \(COLUMNS.ESTIMATED_TIME_DURATION),
                                \(COLUMNS.WORKER_SCHEDULED),
                                \(COLUMNS.JOB_STATUS),
                                \(COLUMNS.REMOVED),
                                \(COLUMNS.REMOVED_DATE),
                                \(COLUMNS.NUMBER_OF_ATTACHMENTS),
                                \(COLUMNS.REJECTED),
                                \(COLUMNS.REJECTED_REASON))

            VALUES (:customerID,
                    :LocationAddress1,
                    :locationAddress2,
                    :locationCity,
                    :locationState,
                    :locationZip,
                    :personName,
                    :contactPhone,
                    :contactEmail,
                    :shortDescription,
                    :description,
                    :startDate,
                    :endDate,
                    :timeDuration,
                    :workerScheduled,
                    :jobStatus,
                    :removed,
                    :removedDate,
                    :numberOfAttachments,
                    :rejected,
                    :rejectedReason)
            """
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments
                                     ,typeOfAction: .insert, updatedId: nil,
                                     success: { id in
                                        success(id)
                                     },
                                     fail: failure)
    }
    
    
    func updateJob(job: Job, success: @escaping () -> (), failure: @escaping (_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "id"                    : job.jobID,
            "customerID"            : job.customerID,
            "LocationAddress1"      : job.jobLocationAddress1,
            "locationAddress2"      : job.jobLocationAddress2,
            "locationCity"          : job.jobLocationCity,
            "locationState"         : job.jobLocationState,
            "locationZip"           : job.jobLocationZip,
            "personName"            : job.jobContactPersonName,
            "contactPhone"          : job.jobContactPhone,
            "contactEmail"          : job.jobContactEmail,
            "shortDescription"      : job.jobShortDescription,
            "description"           : job.jobDescription,
            "startDate"             : DateManager.getStandardDateString(date: job.startDateTime),
            "endDate"               : DateManager.getStandardDateString(date: job.endDateTime),
            "timeDuration"          : job.estimateTimeDuration,
            "workerScheduled"       : job.worker?.workerID,
            "jobStatus"             : job.jobStatus,
            "removed"               : job.removed,
            "removedDate"           : DateManager.getStandardDateString(date: job.removedDate),
            "numberOfAttachments"   : job.numberOfAttachments,
            "rejected"              : job.rejected,
            "rejectedReason"        : job.rejectedReason]
            
        let sql = """
            UPDATE \(tableName) SET
                \(COLUMNS.CUSTOMER_ID)                  = :customerID,
                \(COLUMNS.JOB_LOCATION_ADDRESS_1)       = :LocationAddress1,
                \(COLUMNS.JOB_LOCATION_ADDRESS_2)       = :locationAddress2,
                \(COLUMNS.JOB_LOCATION_CITY)            = :locationCity,
                \(COLUMNS.JOB_LOCATION_STATE)           = :locationState,
                \(COLUMNS.JobLocationZIP)               = :locationZip,
                \(COLUMNS.JOB_CONTACT_PERSON_NAME)      = :personName,
                \(COLUMNS.JOB_CONTACT_PHONE)            = :contactPhone,
                \(COLUMNS.JOB_CONTACT_EMAIL)            = :contactEmail,
                \(COLUMNS.JOB_SHORT_DESCRIPTION)        = :shortDescription,
                \(COLUMNS.JOB_DESCRIPTION)              = :description,
                \(COLUMNS.START_DATE_TIME)              = :startDate,
                \(COLUMNS.END_DATE_TIME)                = :endDate,
                \(COLUMNS.ESTIMATED_TIME_DURATION)      = :timeDuration,
                \(COLUMNS.WORKER_SCHEDULED)             = :workerScheduled,
                \(COLUMNS.JOB_STATUS)                   = :jobStatus,
                \(COLUMNS.REMOVED)                      = :removed,
                \(COLUMNS.REMOVED_DATE)                 = :removedDate,
                \(COLUMNS.NUMBER_OF_ATTACHMENTS)        = :numberOfAttachments,
                \(COLUMNS.REJECTED)                     = :rejected,
                \(COLUMNS.REJECTED_REASON)              = :rejectedReason

            WHERE \(tableName).\(setIdKey()) = :id;
            """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,
                                     typeOfAction: .update, updatedId: UInt64(job.jobID!),
                                     success: { _ in
                                        success()
                                     },
                                     fail: failure)
    }
    
    func deleteJob(with jobId: Int?,success: @escaping () -> (), failure: @escaping (_ error: Error) -> ()) {
        guard let id = jobId else { return }
        softDelete(atId: id, success: success, fail: failure)
    }
    
    func restoreJob(jobId: Int?, success: @escaping () -> (), fail: @escaping (Error) -> ()) {
        guard let id = jobId else { return }
        restoreItem(atId: id, success: success, fail: fail)
    }
    
    func fetchJob(customerId: Int ,offset: Int,success: @escaping(_ jobs: [Job]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        let removedCondition = """
        WHERE (main.\(tableName).\(COLUMNS.REMOVED) = 0
        OR main.\(tableName).\(COLUMNS.REMOVED) is NULL)
        """
        var condition = ""
        
        condition = removedCondition
        
        condition += " AND \(tableName).\(COLUMNS.CUSTOMER_ID) == \(customerId)"
        
        var sql = """
        SELECT * FROM main.\(tableName)
        LEFT JOIN main.\(TABLES.CUSTOMERS) ON main.\(tableName).\(COLUMNS.CUSTOMER_ID) == main.\(TABLES.CUSTOMERS).\(COLUMNS.CUSTOMER_ID)
        \(condition)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        sql += """
                LIMIT \(LIMIT) OFFSET \(offset);
        """

        
        do {
            let jobs = try queue.read({ (db) -> [Job] in
                var jobs: [Job] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    jobs.append(.init(row: row))
                }
                return jobs
            })
            success(jobs)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    func fetchJob(showRemoved: Bool, with key: String? = nil, sortBy: JobField? = nil, sortType: SortType? = nil ,offset: Int,success: @escaping(_ jobs: [Job]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        let sortable = makeSortableItems(sortBy: sortBy, sortType: sortType)
        let searchable = makeSearchableItems(key: key)
        let removedCondition = """
        WHERE (main.\(tableName).\(COLUMNS.REMOVED) = 0
        OR main.\(tableName).\(COLUMNS.REMOVED) is NULL)
        """
        var condition = ""
        if showRemoved {
            condition = (searchable.isEmpty) ? "" : "WHERE \(searchable)"
        }
        else {
            condition = (searchable.isEmpty) ? removedCondition : """
                \(removedCondition)
                AND \(searchable)
            """
        }
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
            let jobs = try queue.read({ (db) -> [Job] in
                var jobs: [Job] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
//                    if row["FirstName"] != "--SELECT--"{
//                        jobs.append(.init(row: row))
//                    }
                    
                    if row["FirstName"] == nil {
                        return
                    }else{
                        if row["FirstName"] != "--SELECT--"{
                            jobs.append(.init(row: row))
                        }
                    }
                }
                return jobs
            })
            success(jobs)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    private func makeSortableItems(sortBy: JobField?, sortType: SortType?) -> String {
        guard let sortBy = sortBy, let sortType = sortType else {
            return makeSortableCondition(key: COLUMNS.FIRST_NAME, sortType: .ASCENDING)
        }
        switch sortBy {
        
        case .WORKER_NAME:
            return makeSortableCondition(key: COLUMNS.FIRST_NAME, sortType: sortType)
        case .SCHEDULED_DATE_TIME:
            return makeSortableCondition(key: COLUMNS.ESTIMATED_TIME_DURATION, sortType: sortType)
        case .ADDRESS:
            return makeSortableCondition(key: COLUMNS.JOB_LOCATION_ADDRESS_1, sortType: sortType)
        case .CONTACT_PERSON_NAME:
            return makeSortableCondition(key: COLUMNS.JOB_CONTACT_PERSON_NAME, sortType: sortType)
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
                                        COLUMNS.FIRST_NAME,
                                        COLUMNS.LAST_NAME,
                                        COLUMNS.ESTIMATED_TIME_DURATION,
                                        COLUMNS.JOB_LOCATION_ADDRESS_1,
                                        COLUMNS.JOB_CONTACT_PERSON_NAME,
                                        COLUMNS.JOB_CONTACT_PHONE,
                                        COLUMNS.JOB_SHORT_DESCRIPTION,
                                        COLUMNS.JOB_DESCRIPTION,
                                        COLUMNS.JOB_STATUS,
                                        COLUMNS.NUMBER_OF_ATTACHMENTS
                                       ])
    }
}
