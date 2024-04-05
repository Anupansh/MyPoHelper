//
//  Worker.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 13/07/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import GRDB

struct Worker: RepositoryBaseModel  {
    
    var workerID        : Int?
    var firstName       : String?
    var middleName      : String?
    var lastName        : String?
    var nickName        : String?
    var cellNumber      : String?
    var email           : String?
    var hourlyWorker    : Bool?
    var salary          : Bool?
    var contractor      : Bool?
    var workerTheme     : String?
    var backgroundColor : String?
    var fontColor       : String?
    var removed         : Bool?
    var removedDate     : Date?
    var createdDate     : Date?
    var modifiedDate    : Date?
    var address         : WorkerHomeAddress?
    var wage            : Wage?
    var workerRoles     : WorkerRoles?
    
    var fullName : String? {
        return (firstName ?? "") + " " + (lastName ?? "")
    }
    
    init() {
        address     = WorkerHomeAddress()
        wage        = Wage()
        workerRoles = WorkerRoles()
        createdDate = Date()
    }
    
    init(row: GRDB.Row) {
        workerID            = row[RepositoryConstants.Columns.WORKER_ID] ?? 0
        firstName           = row[RepositoryConstants.Columns.FIRST_NAME] ?? ""
        middleName          = row[RepositoryConstants.Columns.MIDDLE_NAME] ?? ""
        lastName            = row[RepositoryConstants.Columns.LAST_NAME] ?? ""
        nickName            = row[RepositoryConstants.Columns.NICKNAME] ?? ""
        cellNumber          = row[RepositoryConstants.Columns.CELL_NUMBER] ?? ""
        email               = row[RepositoryConstants.Columns.EMAIL] ?? ""
        hourlyWorker        = row[RepositoryConstants.Columns.HOURLY_WORKER]
        salary              = row[RepositoryConstants.Columns.SALARY]
        contractor          = row[RepositoryConstants.Columns.CONTRACTOR]
        workerTheme         = row[RepositoryConstants.Columns.WORKER_THEME]
        backgroundColor     = row[RepositoryConstants.Columns.BACKGROUND_COLOR]
        fontColor           = row[RepositoryConstants.Columns.FONT_COLOR]
        removed             = row[RepositoryConstants.Columns.REMOVED]
        removedDate         = DateManager.stringToDate(string: row[RepositoryConstants.Columns.REMOVED_DATE] ?? "")
        createdDate         = DateManager.stringToDate(string: row[RepositoryConstants.Columns.DATE_CREATED] ?? "")
        modifiedDate        = DateManager.stringToDate(string: row[RepositoryConstants.Columns.DATE_MODIFIED] ?? "")
        address             = WorkerHomeAddress(row: row)
        wage                = Wage(row: row)
        workerRoles         = WorkerRoles(row: row)
        
    }
    
    private func getYesNo(value: Bool?) -> String {
        guard let value = value else {
            return "YES".localize
        }
        return (value == true) ? "YES".localize : "NO".localize
    }
    
    func getDataArray() -> [Any] {
        let firstName = self.firstName == Constants.DefaultValue.SELECT_LIST ? "" : self.firstName
        
        return [
            firstName   as String?  ?? "",
            lastName    as String?  ?? "",
            cellNumber  as String?  ?? "",
            email       as String?  ?? "",
            getYesNo(value: hourlyWorker),
            getYesNo(value: salary),
            getYesNo(value: contractor)
        ]
    }
    
    mutating func updateModifyDate() {
        modifiedDate = Date()
    }
}
