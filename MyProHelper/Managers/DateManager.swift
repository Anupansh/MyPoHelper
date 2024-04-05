//
//  DateManager.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/14/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

struct DateManager {
    
    static func getAnnualBillDate() -> String {
        let prevDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        var dateComponent = DateComponents()
        dateComponent.year = 1
        let annualBillDate = Calendar.current.date(byAdding: dateComponent, to: prevDate)
        return self.dateToString(date: annualBillDate)
    }
    
    static func getMonthlyBillDay() -> String {
        let prevDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        var dateComponent = DateComponents()
        dateComponent.month = 1
        let annualBillDate = Calendar.current.date(byAdding: dateComponent, to: prevDate)
        return self.dateToString(date: annualBillDate)
    }
    
    static func dateToString(date: Date?) -> String {
        guard let date = date else { return ""}
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.STANDARD_DATE
        return formatter.string(from: date)
    }
    
    static func dateToMonthFormat(date: Date?) -> String {
        guard let date = date else { return ""}
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.DATE_FORMAT
        return formatter.string(from: date)
    }
    
    static func date24HourFormat(date: String) -> Date? {
        let df = DateFormatter()
        df.dateFormat = Constants.TIME_FORMAT_24
        return df.date(from: date)
    }

    static func standardDateToStringWithoutHours(date: Date?) -> String {
        guard let date = date else { return ""}
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.STANDARD_DATE_WITHOUT_HOURS
        return formatter.string(from: date)
    }
    
    static func timeToString(date: Date?) -> String {
        guard let date = date else { return ""}
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.TIME_FORMAT
        return formatter.string(from: date)
    }
    
    static func timeFrameToString(date: Date?) -> String {
        guard let date = date else { return ""}
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.TIME_FRAME_FORMAT
        return formatter.string(from: date)
    }
    
    static func timeFrameStringToDate(time: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.TIME_FRAME_FORMAT
        return formatter.date(from: time)
    }
    
    static func stringToDate(string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.STANDARD_DATE
        if formatter.date(from: string) == nil {
            formatter.dateFormat = Constants.STANDARD_DATE_Z
        }
        if formatter.date(from: string) == nil {
            formatter.dateFormat = Constants.STANDARD_DATE_WITHOUT_SECONDS
        }
        return formatter.date(from: string)
    }
    
    static func stringToStandardFormatDate(string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.STANDARD_DATE_WITHOUT_HOURS
        return formatter.date(from: string)
    }
    
    static func stringToTimeFrameFormat(string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.TIME_FRAME_FORMAT
        return formatter.date(from: string)
    }
    
    static func formatStandardToLocal(string: String) -> String {
        guard let date = stringToDate(string: string) else {
            return ""
        }
        return dateToString(date: date)
    }
    
    static func formatStandardTimeString(string: String) -> String {
        guard let date = stringToDate(string: string) else {
            return ""
        }
        return timeToString(date: date)
    }
    
    static func getStandardDateString(date: Date?) -> String {
        guard let date = date else { return ""}
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.STANDARD_DATE
        return formatter.string(from: date)
    }
    
    static func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    static func roundDate(date: Date, minutesInterval: Int) -> Date? {
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: date)
        
        if minutes < minutesInterval {
            return calendar.date(byAdding: .minute, value: -minutes, to: date)
        }
        else {
            let nextDiff = minutesInterval - minutes
            return calendar.date(byAdding: .minute, value: nextDiff, to: date)
        }
    }
    
    static func getDateDifference(startDate : Date,endDate : Date) -> String {
        let components = Calendar.current.dateComponents([.hour,.minute,.second], from: startDate, to: endDate)
        return "\(String(format: "%02d", components.hour!)):\(String(format: "%02d", components.minute!)):\(String(format: "%02d", components.second!))"
    }
    
    static func getDateDifferenceIntoDate(startDate : Date,endDate : Date) -> Date? {
           let components = Calendar.current.dateComponents([.hour,.minute,.second], from: startDate, to: endDate)
           return Calendar.current.date(from: components)
   //        return "\(String(format: "%02d", components.hour!)):\(String(format: "%02d", components.minute!)):\(String(format: "%02d", components.second!))"
    }
    
    static func getMonthDifference(startDate: Date,endDate: Date) -> Int {
        let component = Calendar.current.dateComponents([.month], from: startDate, to: endDate)
        return component.month ?? 0
    }
    
    static func getYearDifference(startDate: Date,endDate: Date) -> Int {
        let component = Calendar.current.dateComponents([.year], from: startDate, to: endDate)
        return component.year ?? 0
    }

       static func getTotalSecondsFromTime(_ date:Date)->Int{

   //        let year = Calendar.current.component(.year, from: date)
           let hour = Calendar.current.component(.hour, from: date)
           let minutes = Calendar.current.component(.minute, from: date)
           let seconds = Calendar.current.component(.second, from: date)
           let totalSeconds = hour*3600+minutes*60+seconds
           return totalSeconds
       }

       static func getTotalSecondsFromHour(_ hour:Int)->Int{
           let totalSeconds = hour*3600
           return totalSeconds
       }

       static func timeFormatted(totalSeconds: Int) -> String {
           let seconds: Int = totalSeconds % 60
           let minutes: Int = (totalSeconds / 60) % 60
           let hours: Int = totalSeconds / 3600
           return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }


       static func addValueDate(_ date:Date,_ value:Int, _ component:Calendar.Component) -> Date? {
           let finalDate = Calendar.current.date(byAdding: component, value: value, to: date)!
   //        var dateComponent = DateComponents()
   //        let finalDate = Calendar.current.date(byAdding: dateComponent, to: prevDate)
           return finalDate
       }

       static func get24HoursDate()->Date?{
           var dateComponent = DateComponents()
           dateComponent.hour = 24
           return Calendar.current.date(from: dateComponent)


   //        Calendar.current.date
   //
   //        // Specify date components
   //        var dateComponents = DateComponents()
   //        dateComponents.year = 1980
   //        dateComponents.month = 7
   //        dateComponents.day = 11
   //        dateComponents.timeZone = TimeZone(abbreviation: "JST") // Japan Standard Time
   //        dateComponents.hour = 8
   //        dateComponents.minute = 34
       }

    
}
