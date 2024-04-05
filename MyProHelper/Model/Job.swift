//
//  Job.swift
//  MyProHelper

//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import GRDB

struct Job: RepositoryBaseModel {
    
    var jobID                   : Int?
    var customerID              : Int?
    var jobLocationAddress1     : String?
    var jobLocationAddress2     : String?
    var jobLocationCity         : String?
    var jobLocationState        : String?
    var jobLocationZip          : String?
    var jobContactPersonName    : String?
    var jobContactPhone         : String?
    var jobContactEmail         : String?
    var jobShortDescription     : String? // Job Title
    var jobDescription          : String?
    var startDateTime           : Date?
    var endDateTime             : Date?
    var estimateTimeDuration    : String? // Might be date need to verify with karen
    var workerScheduled         : Int?
    var jobStatus               : String?
    var rejected                : Bool?
    var rejectedReason          : String?
    var removed                 : Bool?
    var removedDate             : Date?
    var numberOfAttachments     : Int?
    var worker                  : Worker?
    var customer                : Customer?
    var previousVisitJobId      : Int64?
    var nextVisitJobId          : Int64?
    
    init() {
        worker      = Worker()
        customer    = Customer()
        estimateTimeDuration = Constants.COMPANY_TIME_FRAME
    }
    
    init(row: GRDB.Row) {
        jobID                   = row[RepositoryConstants.Columns.JOB_ID]
        customerID              = row[RepositoryConstants.Columns.CUSTOMER_ID]
        jobLocationAddress1     = row[RepositoryConstants.Columns.JOB_LOCATION_ADDRESS_1]
        jobLocationAddress2     = row[RepositoryConstants.Columns.JOB_LOCATION_ADDRESS_2]
        jobLocationCity         = row[RepositoryConstants.Columns.JOB_LOCATION_CITY]
        jobLocationState        = row[RepositoryConstants.Columns.JOB_LOCATION_STATE]
        jobLocationZip          = row[RepositoryConstants.Columns.JobLocationZIP]
        jobContactPersonName    = row[RepositoryConstants.Columns.JOB_CONTACT_PERSON_NAME]
        jobContactPhone         = row[RepositoryConstants.Columns.JOB_CONTACT_PHONE]
        jobContactEmail         = row[RepositoryConstants.Columns.JOB_CONTACT_EMAIL]
        jobShortDescription     = row[RepositoryConstants.Columns.JOB_SHORT_DESCRIPTION]
        jobDescription          = row[RepositoryConstants.Columns.JOB_DESCRIPTION]
        startDateTime           = DateManager.stringToDate(string: row[RepositoryConstants.Columns.START_DATE_TIME] ?? "")
        endDateTime             = DateManager.stringToDate(string: row[RepositoryConstants.Columns.END_DATE_TIME] ?? "")
        estimateTimeDuration    = row[RepositoryConstants.Columns.ESTIMATED_TIME_DURATION]
        workerScheduled         = row[RepositoryConstants.Columns.WORKER_SCHEDULED]
        jobStatus               = row[RepositoryConstants.Columns.JOB_STATUS]
        rejected                = row[RepositoryConstants.Columns.REJECTED]
        rejectedReason          = row[RepositoryConstants.Columns.REJECTED_REASON]
        removed                 = row[RepositoryConstants.Columns.REMOVED]
        removedDate             = DateManager.stringToDate(string: row[RepositoryConstants.Columns.REMOVED_DATE] ?? "")
        numberOfAttachments     = row[RepositoryConstants.Columns.NUMBER_OF_ATTACHMENTS]
        previousVisitJobId      = row[RepositoryConstants.Columns.PREVIOUS_VISIT_ON_THIS_JOB]
        nextVisitJobId          = row[RepositoryConstants.Columns.NEXT_VISIT_ON_THIS_JOB]
        worker                  = Worker(row: row)
        customer                = Customer(row: row)
    }
     
    func getWorkerName() -> String {
//        return (worker?.firstName ?? "") + " " + (worker?.lastName ?? "")
        return (worker?.firstName ?? "") == Constants.DefaultValue.SELECT_LIST ? "" : (worker?.firstName ?? "") + " " + (worker?.lastName ?? "")
    }
    
    func getDataArray() -> [Any] {
        return [
            getWorkerName(),
            estimateTimeDuration    as String?  ?? "",
            jobLocationAddress1     as String?  ?? "",
            jobContactPersonName    as String?  ?? "",
            jobContactPhone         as String?  ?? "",
            jobShortDescription     as String?  ?? "",
            jobDescription          as String?  ?? "",
            jobStatus               as String?  ?? "",
            numberOfAttachments     as Int?     ?? 0
        ]
    }
}
