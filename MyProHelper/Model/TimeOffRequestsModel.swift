//
//  TimeOffRequestsModel.swift
//  MyProHelper
//
//  Created by Anupansh on 15/03/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB

class TimeOffRequestsModel {
    
    var id : String?
    var workerId : String?
    var description : String?
    var startDate : String?
    var endDate : String?
    var typeOffLeave : String?
    var dateRequested : String?
    var remarks : String?
    var status : String?
    var dateApproved : String?
    var approvedBy : Int = 0
    var dateModified : String?
    var sampleTimeOffRequest : String?
    var removed : String?
    var removedDate : String?
    var workerName : String?
    
    init() {}
    
    init(row : Row) {
        id = row["TimeOffRequestID"]
        workerId = row["WorkerID"]
        description = row["Description"]
        startDate = row["StartDate"]
        endDate = row["EndDate"]
        typeOffLeave = row["TypeOfLeave"]
        dateRequested = row["DateRequested"]
        remarks = row["Remarks"]
        status = row["Status"]
        dateModified = row["DateModified"]
        sampleTimeOffRequest = row["SampleTimeOffRequest"]
        removed = row["Removed"]
        removedDate = row["RemovedDate"]
        let fname = row["FirstName"] as? String ?? "----"
        let lName = row["LastName"] as? String ?? "-----"
        workerName = fname + " " + lName
        approvedBy = row["ApprovedBy"] ?? 0
        dateApproved = row["DateApproved"]
        if startDate == "1900-01-01" {
            startDate = ""
        }
        if endDate == "1900-01-01" {
            endDate = ""
        }
        if dateRequested == "1900-01-01" {
            dateRequested = ""
        }
        if dateModified == "1900-01-01" {
            dateModified = ""
        }
        if removedDate == "1900-01-01" {
            removedDate = ""
        }
        if dateApproved == "1900-01-01" {
            dateApproved = ""
        }
    }    
    
}
