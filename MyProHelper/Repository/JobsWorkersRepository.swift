//
//  JobsWorkers.swift
//  MyProHelper
//
//  Created by Samir on 12/23/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import GRDB

class JobsWorkersRepository: BaseRepository {
    
    init() {
        super.init(table: .JOBS_WORKERS)
        createSelectedLayoutTable()
    }
    
    override func setIdKey() -> String {
        return COLUMNS.JOBS_WORKER_ID
    }
    
    private func createSelectedLayoutTable() {
        let sql = """
            CREATE TABLE IF NOT EXISTS \(tableName)
            (
                \(COLUMNS.JOBS_WORKER_ID) INTEGER PRIMARY KEY  AUTOINCREMENT UNIQUE NOT NULL,
                \(COLUMNS.SCHEDULED_JOB_ID)             INTEGER,
                \(COLUMNS.WORKER_ID)                    INTEGER REFERENCES Workers (WorkerID),
                \(COLUMNS.SAMPLE_JOBS_WORKERS)          INTEGER DEFAULT (0),
                \(COLUMNS.REMOVED)                      INTEGER DEFAULT (0),
                \(COLUMNS.REMOVED_DATE)                 TEXT
            )
        """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                      arguments: [],typeOfAction: .create, updatedId: nil) { (_) in
            print("TABLE SCHEDULED JOBS IS CREATED SUCCESSFULLY")
        } fail: { (error) in
            print(error)
        }
    }
    
    func insertJobsWorkers(jobsWorkers: JobsWorkers, success: @escaping(_ id: Int64) -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "scheduledJobID"        : jobsWorkers.scheduledJobId,
            "workerID"              : jobsWorkers.workerId,
            "removed"               : jobsWorkers.removed,
            "removedDate"           : DateManager.getStandardDateString(date: jobsWorkers.removedDate)
        ]
        let sql = """
            INSERT INTO chg.\(tableName) (
                                \(COLUMNS.SCHEDULED_JOB_ID),
                                \(COLUMNS.WORKER_ID),
                                \(COLUMNS.REMOVED),
                                \(COLUMNS.REMOVED_DATE))

            VALUES (:scheduledJobID,
                    :workerID,
                    :removed,
                    :removedDate)
            """
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,typeOfAction: .insert, updatedId: nil,
                                     success: { id in
                                        success(id)
                                     },
                                     fail: failure)
    }
    
    
    func updateJobsWorkers(jobsWorkers: JobsWorkers, success: @escaping () -> (), failure: @escaping (_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "id"                    : jobsWorkers.jobsWorkerId,
            "scheduledJobID"        : jobsWorkers.scheduledJobId,
            "workerID"              : jobsWorkers.workerId,
            "removed"               : jobsWorkers.removed,
            "removedDate"           : DateManager.getStandardDateString(date: jobsWorkers.removedDate)
        ]
            
        let sql = """
            UPDATE \(tableName) SET
                \(COLUMNS.SCHEDULED_JOB_ID)             = :scheduledJobID,
                \(COLUMNS.WORKER_ID)                    = :workerID,
                \(COLUMNS.REMOVED)                      = :removed,
                \(COLUMNS.REMOVED_DATE)                 = :removedDate

            WHERE \(tableName).\(setIdKey()) = :id;
            """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,
                                     typeOfAction: .update, updatedId: UInt64(jobsWorkers.jobsWorkerId!),
                                     success: { _ in
                                        success()
                                     },
                                     fail: failure)
    }
    
    func deleteJobsWorkers(with jobsWorkersId: Int?,success: @escaping () -> (), failure: @escaping (_ error: Error) -> ()) {
        guard let id = jobsWorkersId else { return }
        softDelete(atId: id, success: success, fail: failure)
    }
    
    func fetchJobsWorkers(offset: Int,success: @escaping(_ jobsWorkers: [JobsWorkers]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        var sql = """
        SELECT * FROM main.\(tableName)
        WHERE (main.\(tableName).\(COLUMNS.REMOVED) = 0
        OR main.\(tableName).\(COLUMNS.REMOVED) is NULL)
        LIMIT \(LIMIT) OFFSET \(offset);
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            let jobsWorkers = try queue.read({ (db) -> [JobsWorkers] in
                var jobsWorkers: [JobsWorkers] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    jobsWorkers.append(.init(row: row))
                }
                return jobsWorkers
            })
            success(jobsWorkers)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    func fetchJobsWorkers(for workersId: [Int],date: String, success: @escaping(_ assetTypes: [JobsWorkers]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        let removedCondition = """
            (main.\(tableName).\(COLUMNS.REMOVED) = 0
            OR main.\(tableName).\(COLUMNS.REMOVED) is NULL)
        """
        
        let filter = """
            WHERE main.\(TABLES.WORKERS).\(COLUMNS.WORKER_ID) IN \(createRange(from: workersId))
            AND main.\(TABLES.SCHEDULED_JOBS).\(COLUMNS.START_DATE_TIME) LIKE '\(date)%'
            AND \(removedCondition)
        """
        
        var sql = """
        SELECT * FROM main.\(tableName)
        JOIN main.\(TABLES.WORKERS) ON main.\(tableName).\(COLUMNS.WORKER_ID) == main.\(TABLES.WORKERS).\(COLUMNS.WORKER_ID)
        JOIN main.\(TABLES.SCHEDULED_JOBS) ON main.\(tableName).\(COLUMNS.SCHEDULED_JOB_ID) == main.\(TABLES.SCHEDULED_JOBS).\(COLUMNS.JOB_ID)
        \(filter)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            let jobsWorkers = try queue.read({ (db) -> [JobsWorkers] in
                var jobsWorkers: [JobsWorkers] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    jobsWorkers.append(.init(row: row))
                }
                return jobsWorkers
            })
            success(jobsWorkers)
        }
        catch {
            failure(error)
            print(error)
        }
    }
}
