//
//  JobHistory.swift
//  MyProHelper
//
//  Created by Deep on 1/18/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import GRDB

struct JobHistory: RepositoryBaseModel {
    
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
    var jobShortDescription     : String?
    var jobDescription          : String?
    var startDateTime           : Date?
    var workerScheduled         : Int?
    var jobStatus               : String?
    var removed                 : Bool?
    var jobPrice                : Float?
    var salesTax                : Float?
    var paid                    : Int?
    var previousVisitOnThisJob  : Int?
    var nextVisitOnThisJob      : Int?
    var sampleJobHistory        : Int?
    var numberOfAttachments     : Int?
    var worker                  : Worker?
    var customer                : Customer?
    
    init() {
        worker      = Worker()
        customer    = Customer()
    }
    
    init(row: GRDB.Row) {
        let column = RepositoryConstants.Columns.self
        
        jobID                   = row[column.JOB_ID]
        customerID              = row[column.CUSTOMER_ID]
        jobLocationAddress1     = row[column.JOB_LOCATION_ADDRESS_1]
        jobLocationAddress2     = row[column.JOB_LOCATION_ADDRESS_2]
        jobLocationCity         = row[column.JOB_LOCATION_CITY]
        jobLocationState        = row[column.JOB_LOCATION_STATE]
        jobLocationZip          = row[column.JobLocationZIP]
        jobContactPersonName    = row[column.JOB_CONTACT_PERSON_NAME]
        jobContactPhone         = row[column.JOB_CONTACT_PHONE]
        jobContactEmail         = row[column.JOB_CONTACT_EMAIL]
        jobShortDescription     = row[column.JOB_SHORT_DESCRIPTION]
        jobDescription          = row[column.JOB_DESCRIPTION]
        startDateTime           = DateManager.stringToDate(string: row[RepositoryConstants.Columns.START_DATE_TIME] ?? "")
        workerScheduled         = row[RepositoryConstants.Columns.WORKER_SCHEDULED]
        jobStatus               = row[RepositoryConstants.Columns.JOB_STATUS]
        jobPrice                = row[RepositoryConstants.Columns.JOB_PRICE]
        salesTax                = row[RepositoryConstants.Columns.SALES_TAX]
        paid                    = row[RepositoryConstants.Columns.PAID]
        previousVisitOnThisJob  = row[RepositoryConstants.Columns.PREVIOUS_VISIT_ON_THIS_JOB]
        nextVisitOnThisJob      = row[RepositoryConstants.Columns.NEXT_VISIT_ON_THIS_JOB]
        sampleJobHistory        = row[RepositoryConstants.Columns.SAMPLE_JOB_HISTORY]
        numberOfAttachments     = row[RepositoryConstants.Columns.NUMBER_OF_ATTACHMENTS]
        worker                  = Worker(row: row)
        customer                = Customer(row: row)
    }
    
    func getWorkerName() -> String {
        return (worker?.firstName ?? "") + " " + (worker?.lastName ?? "")
    }
    
    func getCustomerName() -> String {
        return (customer?.customerName ?? "")
    }
    
    func getDataArray() -> [Any] {
        let scheduledDateTime = DateManager.getStandardDateString(date: startDateTime)
        
        return [
            getCustomerName(),
            getWorkerName(),
            scheduledDateTime       as String?  ?? "",
            jobLocationAddress1     as String?  ?? "",
            jobContactPhone         as String?  ?? "",
            jobShortDescription     as String?  ?? "",
            jobDescription          as String?  ?? "",
            jobStatus               as String?  ?? "",
            numberOfAttachments     as Int?     ?? 0
        ]
    }
}
