//
//  WorkerOrderApprovel.swift
//  MyProHelper
//
//  Created by Sarvesh on 21/04/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import GRDB

struct WorkerOrderApprovel: RepositoryBaseModel  {
   
    var removed         : Bool?
    var workerID        : Int?
    var workername      : String?
    var customername    : String?
    var totalamount     : Int?
    var description     : String?
    var status          : String?
    var remark          : String?
    var approvername    : String?
    var requesteddate   : Date?
    var attachment      : Int?
    var worker          : Worker?
    
    init() {
        worker               = Worker()
    }
    
    init(row: Row) {
        workerID              = row[RepositoryConstants.Columns.WORKER_ID]
        workername            = row[RepositoryConstants.Columns.WORKER_NAME]
        description           = row[RepositoryConstants.Columns.DESCRIPTION]
        status                = row[RepositoryConstants.Columns.STATUS]
        remark                = row[RepositoryConstants.Columns.REMARK]
        requesteddate         = row[RepositoryConstants.Columns.DATE_REQUESTED]
        approvername                = row[RepositoryConstants.Columns.APPROVER_NAME]
        removed               = row[RepositoryConstants.Columns.REMOVED]
        worker                = Worker(row: row)
    }
    
   

    func getDataArray() -> [Any] {
        
        let formattedRequesteddate   = DateManager.dateToString(date: requesteddate)
        let WorkerName = workername
            
            //worker?.fullName!//(worker?.firstName)! + " " + (worker?.lastName)!

        return [
            WorkerName         as String?  ?? "ghgff",
            self.description   as String?  ?? "",
            self.status        as String?  ?? "",
            self.remark        as String?  ?? "",
            formattedRequesteddate        as String?  ?? ""
            
        ]
    }
}

