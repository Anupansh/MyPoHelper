//
//  Wage.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 20/07/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB

struct Wage: RepositoryBaseModel {
    
    var wageID                      : Int?
    var workerID                    : Int?
    var workerName                  : String?
    var salaryRate                  : Double?
    var salaryPerTime               : String?
    var hourlyRate                  : Double?
    var w4wh                        : Double?
    var w4Exemptions                : Int?
    var needs1099                   : Bool?
    var garnishments                : String?
    var garnishmentAmount           : Double?
    var fedTaxWH                    : Double?
    var stateTaxWH                  : Double?
    var startEmploymentDate         : Date?
    var endEmploymentDate           : Date?
    var currentVacationAmount       : Double?
    var vacationAccrualRateInHours  : Double?
    var vacationHoursPerYear        : Double?
    var isFixedContractPrice        : Bool?
    var contractPrice               : Double?
    var removed                     : Bool?
    var removedDate                 : Date?
    var numberOfAttachments         : Int?
    
    init() { }
    
    init(row: Row) {
        let columns = RepositoryConstants.Columns.self
        
        wageID                      = row[columns.WAGE_ID]
        workerID                    = row[columns.WORKER_ID]
//        let fname     =                     row[columns.FIRST_NAME] as? String ?? "----"
//        let lName =                     row[columns.LAST_NAME] as? String ?? "-----"
//        workerName = fname + " " + lName
        workerName                  = row[columns.WORKER_NAME]
        salaryRate                  = row[columns.SALARY_RATE]
        salaryPerTime               = row[columns.SALARY_PER_TIME]
        hourlyRate                  = row[columns.HOURLY_RATE]
        w4wh                        = row[columns.W4WH]
        w4Exemptions                = row[columns.W4_EXEPMTIONS]
        needs1099                   = row[columns.NEEDS_1099]
        garnishments                = row[columns.GARNISHMENTS]
        garnishmentAmount           = row[columns.GARNISHMENT_AMOUNT]
        fedTaxWH                    = row[columns.FED_TAX_WH]
        stateTaxWH                  = row[columns.STATE_TAX_WH]
        startEmploymentDate         = DateManager.stringToDate(string: row[columns.START_EMPLOYMENT_DATE] ?? "")
        endEmploymentDate           = DateManager.stringToDate(string: row[columns.END_EMPLOYMENT_DATE] ?? "")
        currentVacationAmount       = row[columns.CURRENT_VACATION_AMOUNT]
        vacationAccrualRateInHours  = row[columns.VACATION_ACCRUAL_IN_HOURS]
        vacationHoursPerYear        = row[columns.VACATION_HOURS_PER_YEAR]
        isFixedContractPrice        = row[columns.IS_FIXED_CONTRACT_PRICE]
        contractPrice               = row[columns.CONTRACT_PRICE]
        removed                     = row[columns.REMOVED]
        removedDate                 = DateManager.stringToDate(string: row[columns.REMOVED_DATE] ?? "" )
        numberOfAttachments         = row[columns.NUMBER_OF_ATTACHMENTS]
    }
    
    func getDataArray() -> [Any] {
        //Do To implement this method
        let formattedStartEmploymentDate = DateManager.standardDateToStringWithoutHours(date: startEmploymentDate)
        return [
            getStringValue(value: workerName),
            getFormattedStringValue(value: salaryRate),
            getStringValue(value: salaryPerTime),
            getFormattedStringValue(value: hourlyRate),
            getFormattedStringValue(value: w4wh),
            getIntValue(value: w4Exemptions),
            getStringValue(value: garnishments),
            getFormattedStringValue(value: garnishmentAmount),
            getYesNo(value: needs1099),
            getIntValue(value: numberOfAttachments),
            formattedStartEmploymentDate
        ]
    }
}
