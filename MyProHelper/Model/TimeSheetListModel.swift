//
//  TimeSheetListModel.swift
//  MyProHelper
//
//  Created by sismac010 on 25/11/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB

struct TimeSheetListModel: RepositoryBaseModel {
    
    var timeCardId  : Int?
    var workerId    : Int?
    var dateWorked  : Date?
    var startTime   : String?
    var endTime     : String?
    var breakStart  : String?
    var breakStop   : String?
    var lunchStart  : String?
    var lunchStop   : String?
    var workTime    : String?
    var breakTime   : String?
    var lunchTime   : String?
    var removedDate : Date?
    var removed     : Bool?
    var description : String?
    var approvedBy  : Int?
    var approvedDate: Date?
    var workerName  : String?
    var canEditTime : Bool?
    var isPayrollCreated : Bool?
    var sampleTimeCard  : Bool?
    var enteredDate     : Date?
    var dateModified    : Date?
    var isTwoMonthsBefore : Bool?
    
    init() {}
    
    init(row : Row) {
        let column = RepositoryConstants.Columns.self
        timeCardId      = row["TimeCardID"]
        workerId        = row["WorkerId"]
        dateWorked      = DateManager.stringToDate(string: (row["DateWorked"] ?? "") == "1900-01-01" ? "" : (row["DateWorked"] ?? ""))
        startTime       = row["StartTime"]
        endTime         = row["EndTime"]
        breakStart      = row["BreakStart"]
        breakStop       = row["BreakStop"]
        lunchStart      = row["LunchStart"]
        lunchStop       = row["LunchStop"]
        removed         = row["Removed"]
        description     = row["Description"]
        approvedBy      = row["ApprovedBy"]
//        approvedDate    = DateManager.stringToDate(string: row[column.DATE_APPROVED] ?? "")//row["DateApproved"]
//        workerName      = row["FirstName"] + " " + row["LastName"]
        canEditTime     = row["CanEditTimeAlreadyEntered"]
        isPayrollCreated = row["isPayrollCreated"]
        enteredDate     = DateManager.stringToDate(string: row[column.ENTERED_DATE] ?? "")
        dateModified    = DateManager.stringToDate(string: row[column.DATE_MODIFIED] ?? "")
        sampleTimeCard  = row[column.SampleTimeCard]
        removed         = row[column.REMOVED]
        removedDate     = createDate(with: column.REMOVED_DATE)
        let fName       = row["FirstName"] as? String ?? "----"
        let lName       = row["LastName"] as? String ?? "----"
        workerName      = fName + " " + lName

        let tmp = DateManager.stringToDate(string: row[column.DATE_APPROVED] ?? "")
        let tmpString = DateManager.standardDateToStringWithoutHours(date: tmp)
        if tmpString == "1900-01-01" || tmpString.isEmpty{
            approvedDate = nil
        }
        else{
            approvedDate    = DateManager.stringToDate(string: row[column.DATE_APPROVED] ?? "")
        }

        guard let _ = breakStart else {return }
        guard let _ = breakStop else {return }
        
        let breakStartTime:Date? = DateManager.stringToTimeFrameFormat(string: breakStart!)
        let breakStopTime:Date? = DateManager.stringToTimeFrameFormat(string: breakStop!)
        var breakFinalTime:Date?
        if breakStartTime != nil && breakStopTime != nil{
            breakFinalTime = DateManager.getDateDifferenceIntoDate(startDate: breakStartTime!, endDate: breakStopTime!)
            breakTime = DateManager.timeFrameToString(date: breakFinalTime)
        }
        else{
            breakTime = "00:00:00"
        }
        
        guard let _ = lunchStart else {return }
        guard let _ = lunchStop else {return }
        
        let lunchStartTime:Date? = DateManager.stringToTimeFrameFormat(string: lunchStart!)
        let lunchStopTime:Date? = DateManager.stringToTimeFrameFormat(string: lunchStop!)
        var lunchFinalTime:Date?
        if lunchStartTime != nil && lunchStopTime != nil{
            lunchFinalTime = DateManager.getDateDifferenceIntoDate(startDate: lunchStartTime!, endDate: lunchStopTime!)
            lunchTime = DateManager.timeFrameToString(date: lunchFinalTime)
        }
        else{
            lunchTime = "00:00:00"
        }
        
        guard let _ = startTime else {return }
        guard let _ = endTime else {return }
        
        let sDate = DateManager.stringToTimeFrameFormat(string: startTime!)
        let eDate = DateManager.stringToTimeFrameFormat(string: endTime!)
        
        if (breakTime == "00:00:00") && (lunchTime == "00:00:00") && (DateManager.timeFrameToString(date: eDate) == "00:00:00"){
            workTime = "00:00:00"
        }
        else if (breakTime == "00:00:00") && (lunchTime == "00:00:00") && (DateManager.timeFrameToString(date: eDate) != "00:00:00"){
            let fDate = DateManager.getDateDifferenceIntoDate(startDate: sDate!, endDate: eDate!)
            workTime = DateManager.timeFrameToString(date: fDate)
        }
        else if (sDate != nil){
            if (DateManager.timeFrameToString(date: eDate) == "00:00:00"){
                var totalSeconds:Int = 0
                
                if (breakTime != "00:00:00"){
                    totalSeconds = DateManager.getTotalSecondsFromHour(24) - DateManager.getTotalSecondsFromTime(breakFinalTime!)
                }
                if (lunchTime != "00:00:00"){
                    if totalSeconds == 0 {
                        totalSeconds = DateManager.getTotalSecondsFromHour(24) - DateManager.getTotalSecondsFromTime(lunchFinalTime!)
                    }
                    else{
                        totalSeconds = totalSeconds - DateManager.getTotalSecondsFromTime(lunchFinalTime!)
                    }
                }
                workTime = DateManager.timeFormatted(totalSeconds: totalSeconds)
            }
            else{
                let fDate = (DateManager.getDateDifferenceIntoDate(startDate: sDate!, endDate: eDate!))
                    var tmp:Date? = fDate
                if breakFinalTime != nil{
                    tmp = DateManager.getDateDifferenceIntoDate(startDate: breakFinalTime!, endDate: fDate!)
                }
                if lunchFinalTime != nil{
                    if tmp != nil {
                        tmp = DateManager.getDateDifferenceIntoDate(startDate: lunchFinalTime!, endDate: tmp!)
                    }
                    else{
                        tmp = DateManager.getDateDifferenceIntoDate(startDate: lunchFinalTime!, endDate: fDate!)
                    }
                }
                workTime = DateManager.timeFrameToString(date: tmp)
            }
        }
        else{
            workTime = "00:00:00"
        }
        let currentDate = Date()
        var component = DateComponents()
        component.month = -2
        let pastDate = Calendar.current.date(byAdding: component, to: currentDate)!
        print("Current Date",currentDate)
        print("Past Date",pastDate)
        if dateWorked! < pastDate {
            isTwoMonthsBefore = true
        }
        else {
            isTwoMonthsBefore = false
        }
//        if approvedDate == "1900-01-01" {
//            approvedDate = ""
//        }
//        if dateWorked == "1900-01-01" {
//            dateWorked = ""
//        }
    }
    
    func getDataArray() -> [Any] {
        return []
    }
        
    
    mutating func updateModifyDate() {
        dateModified = Date()
    }
    
    
}

