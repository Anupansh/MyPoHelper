//
//  Holiday.swift
//  MyProHelper
//
//  Created by Deep on 1/13/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//


import GRDB

struct Holiday: RepositoryBaseModel, Codable {
   
    var holidayID           : Int?
    var holidayName         : String?
    var year                : Int?
    var actualDate          : Date?
    var dateCelebrated      : Date?
    var dateModified        : Date?
    var removed             : Bool?
    var removedDate         : Date?
    
    init() { }
    
    init(row: GRDB.Row) {
        holidayID               = row[RepositoryConstants.Columns.HOLIDAY_ID]
        holidayName             = row[RepositoryConstants.Columns.HOLIDAY_NAME]
        year                    = row[RepositoryConstants.Columns.YEAR]
        actualDate              = DateManager.stringToDate(string: row[RepositoryConstants.Columns.ACTUAL_DATE] ?? "")
        dateCelebrated          = DateManager.stringToDate(string: row[RepositoryConstants.Columns.DATE_CELEBRATED] ?? "")
        dateModified            = DateManager.stringToDate(string: row[RepositoryConstants.Columns.DATE_MODIFIED] ?? "")
        removed                 = row[RepositoryConstants.Columns.REMOVED]
        removedDate             = DateManager.stringToDate(string: row[RepositoryConstants.Columns.REMOVED_DATE] ?? "")
    }
    
    func getDataArray() -> [Any] {
        let formattedActualDate      = DateManager.dateToString(date: actualDate)
        let formattedDateCelebrated  = DateManager.dateToString(date: dateCelebrated)
        let formattedDateModified    = DateManager.dateToString(date: dateModified)
        
        return [
            self.holidayName            as String?  ??  "",
            self.year                   as Int?  ??  0,
            formattedActualDate         as String? ?? "",
            formattedDateCelebrated     as String? ?? "",
            formattedDateModified       as String? ?? "",
        ]
    }
    
    mutating func updateModifyDate() {
            dateModified = Date()
        }
}
