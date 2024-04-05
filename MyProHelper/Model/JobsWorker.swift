//
//  JobsWorker.swift
//  MyProHelper
//
//  Created by Samir on 12/23/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import GRDB

struct JobsWorkers: RepositoryBaseModel {
    var jobsWorkerId    : Int?
    var scheduledJobId  : Int?
    var workerId        : Int?
    var removed         : Bool?
    var removedDate     : Date?
    var job             : Job?
    var worker          : Worker?
    
    init() { }
    
    init(row: Row) {
        let columns = RepositoryConstants.Columns.self
        
        jobsWorkerId    = row[columns.JOBS_WORKER_ID]
        scheduledJobId  = row[columns.SCHEDULED_JOB_ID]
        workerId        = row[columns.WORKER_ID]
        removed         = row[columns.REMOVED]
        removedDate     = DateManager.stringToDate(string: row[columns.REMOVED_DATE] ?? "")
        job             = Job(row: row)
        worker          = Worker(row: row)
    }
    
    func getDataArray() -> [Any] {
        return []
    }
    
}
