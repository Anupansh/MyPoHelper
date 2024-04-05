//
//  CustomerJobHistory.swift
//  MyProHelper
//
//  Created by Deep on 1/25/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

import GRDB

struct CustomerJobHistory: RepositoryBaseModel {
    
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
    var paid                    : Bool?
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
        startDateTime           = DateManager.stringToDate(string: row[column.START_DATE_TIME] ?? "")
        workerScheduled         = row[column.WORKER_SCHEDULED]
        jobStatus               = row[column.JOB_STATUS]
        jobPrice                = row[column.JOB_PRICE]
        salesTax                = row[column.SALES_TAX]
        paid                    = row[column.PAID]
        previousVisitOnThisJob  = row[column.PREVIOUS_VISIT_ON_THIS_JOB]
        nextVisitOnThisJob      = row[column.NEXT_VISIT_ON_THIS_JOB]
        sampleJobHistory        = row[column.SAMPLE_JOB_HISTORY]
        numberOfAttachments     = row[column.NUMBER_OF_ATTACHMENTS]
        worker                  = Worker(row: row)
        customer                = Customer(row: row)
    }
    
    func getWorkerName() -> String {
        return (worker?.firstName ?? "") + " " + (worker?.lastName ?? "")
    }
    
    func getCustomerName() -> String {
        return (customer?.customerName ?? "")
    }
    
    private func getYesNo(value: Bool?) -> String {
        guard let value = value else {
            return "Yes".localize
        }
        return (value == true) ? "Yes".localize : "No".localize
    }
    
    func getDataArray() -> [Any] {
        let startDate = DateManager.getStandardDateString(date: startDateTime)
        
        return [
            jobID                   as Int?     ?? 0,
            startDate,
            jobLocationAddress1     as String?  ?? "",
            jobContactPersonName    as String?  ?? "",
            jobContactPhone         as String?  ?? "",
            jobDescription          as String?  ?? "",
            jobPrice                as Float?   ?? 0.0,
            salesTax                as Float?   ?? 0.0,
            jobStatus               as String?  ?? "",
            getYesNo(value: paid),
        ]
    }
}

