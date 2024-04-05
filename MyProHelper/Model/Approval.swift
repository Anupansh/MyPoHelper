//
//  Approval.swift
//  MyProHelper
//
//  Created by Deep on 1/31/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//


import GRDB

struct Approval: RepositoryBaseModel  {
   
    var removed         : Bool?
    
    var TimeOffRequestsID  : Int?
    var workerID        : Int?
    var workername      : String?
    var description     : String?
    var startdate       : String?
    var endDate         : String?
    var typeofleave     : String?
    var status          : String?
    var remark          : String?
    var requesteddate   : Date?
    var approvedby      : Int?
    var approveddate    : Date?
    var removedDate     : Date?
    var worker          : Worker?
    
    init() {
        worker               = Worker()
    }
    
    init(row: Row) {
        TimeOffRequestsID     = row[RepositoryConstants.Columns.TimeOffRequestsID]
        workerID              = row[RepositoryConstants.Columns.WORKER_ID]
        workername            = row[RepositoryConstants.Columns.WORKER_NAME]
        description           = row[RepositoryConstants.Columns.DESCRIPTION]
        startdate             =  row[RepositoryConstants.Columns.START_DATE] //createDate(with: row[RepositoryConstants.Columns.START_DATE])
        endDate               =  row[RepositoryConstants.Columns.END_DATE]  //createDate(with: row[RepositoryConstants.Columns.END_DATE])
        typeofleave           = row[RepositoryConstants.Columns.TYPEOF_LEAVE]
        status                = row[RepositoryConstants.Columns.STATUS]
        remark                = row[RepositoryConstants.Columns.Remarks]
        requesteddate         = row[RepositoryConstants.Columns.DATE_REQUESTED]
        approvedby            = row[RepositoryConstants.Columns.APPROVED_BY]
        approveddate          = row[RepositoryConstants.Columns.APPROVED_DATE]
        removed               = row[RepositoryConstants.Columns.REMOVED]
        removedDate           = createDate(with: row[RepositoryConstants.Columns.REMOVED_DATE])
        worker                = Worker(row: row)
    }
    
   

    func getDataArray() -> [Any] {
        
//        let formattedStartdate       = DateManager.dateToString(date: startdate)
//        let formattedEnddate         = DateManager.dateToString(date: enddate)
        let formattedRequesteddate   = DateManager.dateToString(date: requesteddate)
        let formattedApproveddate    = DateManager.dateToString(date: approveddate)
        let WorkerName = (worker?.firstName as String? ?? "") +  " " + (worker?.lastName as String? ?? "")
        var approverName = ""
        if approvedby != 0 {
            DBHelper.getWorker(workerId: approvedby) { worker in
                approverName = (worker?.fullName)!
            }
        }

        return [
            WorkerName,
            self.description   as String?  ?? "",
            self.startdate as String? ?? "",
            self.endDate as String? ?? "",
            self.typeofleave   as String?  ?? "",
            self.status        as String?  ?? "",
            self.remark        as String?  ?? "",
            formattedRequesteddate as String?  ?? "",
             approverName,
            getDateString(date:  self.approveddate) ,
     
            
        ]
    }
}
