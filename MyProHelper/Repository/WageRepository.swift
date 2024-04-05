//
//  WageRepository.swift
//  MyProHelper
//
//  Created by Anupansh on 05/08/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB

class WageRepository: BaseRepository {
    
    init() {
        super.init(table: .WAGES)
        createSelectedLayoutTable()
    }
    
    override func setIdKey() -> String {
        return COLUMNS.WAGE_ID
    }

    private func createSelectedLayoutTable() {
        let sql = """
            CREATE TABLE IF NOT EXISTS \(tableName)(
                \(COLUMNS.WAGE_ID)      INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
                \(COLUMNS.WORKER_ID)    INTEGER REFERENCES \(TABLES.WORKERS)(\(COLUMNS.WORKER_ID)) NOT NULL,
                \(COLUMNS.SALARY_RATE)                  Real DEFAULT(0.00),
                \(COLUMNS.SALARY_PER_TIME)              TEXT DEFAULT Year,
                \(COLUMNS.HOURLY_RATE)                  Real(0.0) DEFAULT(0.0),
                \(COLUMNS.W4WH)                         REAL(0.0) DEFAULT(0.0),
                \(COLUMNS.W4_EXEPMTIONS)                INTEGER,
                \(COLUMNS.NEEDS_1099)                   INTEGER DEFAULT(0),
                \(COLUMNS.GARNISHMENTS)                 TEXT,
                \(COLUMNS.GARNISHMENT_AMOUNT)           REAL(0.0) DEFAULT(0.0),
                \(COLUMNS.FED_TAX_WH)                   REAL(0.0) DEFAULT(0.0),
                \(COLUMNS.STATE_TAX_WH)                 REAL(0,0) DEFAULT(0.0),
                \(COLUMNS.START_EMPLOYMENT_DATE)        TEXT,
                \(COLUMNS.END_EMPLOYMENT_DATE)          TEXT,
                \(COLUMNS.CURRENT_VACATION_AMOUNT)      REAL(0.0) DEFAULT(0.0),
                \(COLUMNS.VACATION_ACCRUAL_IN_HOURS)    REAL(0.0) DEFAULT(0.0),
                \(COLUMNS.VACATION_HOURS_PER_YEAR)      REAL(0.0) DEFAULT(0.0),
                \(COLUMNS.IS_FIXED_CONTRACT_PRICE)      INTEGER DEFAULT(0),
                \(COLUMNS.CONTRACT_PRICE)               REAL(0.0) DEFAULT(0.0),
                \(COLUMNS.SAMPLE_WAGE)                  INTEGER     DEFAULT(0),
                \(COLUMNS.REMOVED)                      INTEGER     DEFAULT(0),
                \(COLUMNS.REMOVED_DATE)                 TEXT,
                \(COLUMNS.NUMBER_OF_ATTACHMENTS)        NTEGER DEFAULT(0)
            )
        """
        AppDatabase.shared.executeSQL(sql: sql, arguments: [], typeOfAction: .create, updatedId: nil) { (_) in
            print("TABLE WAGES IS CREATED SUCCESSFULLY")
        } fail: { (error) in
            print(error)
        }
    }
    
    func createWage(wage: Wage, success: @escaping(_ id: Int64) -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "workerId"                      : wage.workerID,
            "salaryRate"                    : wage.salaryRate,
            "SalaryPerTime"                 : wage.salaryPerTime,
            "HourlyRate"                    : wage.hourlyRate,
            "W4WH"                          : wage.w4wh,
            "W4Exeptions"                   : wage.w4Exemptions,
            "needs1099"                     : wage.needs1099,
            "garnishment"                   : wage.garnishments,
            "garnishmnetAmount"             : wage.garnishmentAmount,
            "fedTaxWH"                      : wage.fedTaxWH,
            "stateTaxWH"                    : wage.stateTaxWH,
            "startEmploymentDate"           : DateManager.getStandardDateString(date: wage.startEmploymentDate),
            "endEmploymentDate"             : DateManager.getStandardDateString(date:wage.endEmploymentDate),
            "currentVacationAmount"         : wage.currentVacationAmount,
            "vacationAccrualRateInHours"    : wage.vacationAccrualRateInHours,
            "vacationHoursPerYear"          : wage.vacationHoursPerYear,
            "isFixedContractPrice"          : wage.isFixedContractPrice,
            "contractPrice"                 : wage.contractPrice,
            "removed"                       : wage.removed ?? 0,
            "removeDate"                    : DateManager.getStandardDateString(date: wage.removedDate),
            "numberOfAttachments"           : wage.numberOfAttachments
        ]
        let sql = """
            INSERT INTO chg.\(tableName) (
                \(COLUMNS.WORKER_ID),
                \(COLUMNS.SALARY_RATE),
                \(COLUMNS.SALARY_PER_TIME),
                \(COLUMNS.HOURLY_RATE),
                \(COLUMNS.W4WH),
                \(COLUMNS.W4_EXEPMTIONS),
                \(COLUMNS.NEEDS_1099),
                \(COLUMNS.GARNISHMENTS),
                \(COLUMNS.GARNISHMENT_AMOUNT),
                \(COLUMNS.FED_TAX_WH),
                \(COLUMNS.STATE_TAX_WH),
                \(COLUMNS.START_EMPLOYMENT_DATE),
                \(COLUMNS.END_EMPLOYMENT_DATE),
                \(COLUMNS.CURRENT_VACATION_AMOUNT),
                \(COLUMNS.VACATION_ACCRUAL_IN_HOURS),
                \(COLUMNS.VACATION_HOURS_PER_YEAR),
                \(COLUMNS.IS_FIXED_CONTRACT_PRICE),
                \(COLUMNS.CONTRACT_PRICE),
                \(COLUMNS.REMOVED),
                \(COLUMNS.REMOVED_DATE),
                \(COLUMNS.NUMBER_OF_ATTACHMENTS)
            )

            VALUES (:workerId,
                    :salaryRate,
                    :SalaryPerTime,
                    :HourlyRate,
                    :W4WH,
                    :W4Exeptions,
                    :needs1099,
                    :garnishment,
                    :garnishmnetAmount,
                    :fedTaxWH,
                    :stateTaxWH,
                    :startEmploymentDate,
                    :endEmploymentDate,
                    :currentVacationAmount,
                    :vacationAccrualRateInHours,
                    :vacationHoursPerYear,
                    :isFixedContractPrice,
                    :contractPrice,
                    :removed,
                    :removeDate,
                    :numberOfAttachments
            )
            """
        AppDatabase.shared.executeSQL(sql: sql, arguments: arguments, typeOfAction: .insert, updatedId: nil) { (id) in
            success(id)
        } fail: { (error) in
            print(error)
        }

    }
    
    func updateWage(wage: Wage, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "id"                            : wage.wageID,
            "workerId"                      : wage.workerID,
            "salaryRate"                    : wage.salaryRate,
            "SalaryPerTime"                 : wage.salaryPerTime,
            "HourlyRate"                    : wage.hourlyRate,
            "W4WH"                          : wage.w4wh,
            "W4Exeptions"                   : wage.w4Exemptions,
            "needs1099"                     : wage.needs1099,
            "garnishment"                   : wage.garnishments,
            "garnishmnetAmount"             : wage.garnishmentAmount,
            "fedTaxWH"                      : wage.fedTaxWH,
            "stateTaxWH"                    : wage.stateTaxWH,
            "startEmploymentDate"           : DateManager.getStandardDateString(date: wage.startEmploymentDate),
            "endEmploymentDate"             : DateManager.getStandardDateString(date: wage.endEmploymentDate),
            "currentVacationAmount"         : wage.currentVacationAmount,
            "vacationAccrualRateInHours"    : wage.vacationAccrualRateInHours,
            "vacationHoursPerYear"          : wage.vacationHoursPerYear,
            "isFixedContractPrice"          : wage.isFixedContractPrice,
            "contractPrice"                 : wage.contractPrice,
            "removed"                       : wage.removed,
            "removeDate"                    : DateManager.getStandardDateString(date: wage.removedDate),
            "numberOfAttachments"           : wage.numberOfAttachments
        ]
        
        let sql = """
            UPDATE \(tableName) SET
                \(COLUMNS.WORKER_ID)                    = :workerId,
                \(COLUMNS.SALARY_RATE)                  = :salaryRate,
                \(COLUMNS.SALARY_PER_TIME)              = :SalaryPerTime,
                \(COLUMNS.HOURLY_RATE)                  = :HourlyRate,
                \(COLUMNS.W4WH)                         = :W4WH,
                \(COLUMNS.W4_EXEPMTIONS)                = :W4Exeptions,
                \(COLUMNS.NEEDS_1099)                   = :needs1099,
                \(COLUMNS.GARNISHMENTS)                 = :garnishment,
                \(COLUMNS.GARNISHMENT_AMOUNT)           = :garnishmnetAmount,
                \(COLUMNS.FED_TAX_WH)                   = :fedTaxWH,
                \(COLUMNS.STATE_TAX_WH)                 = :stateTaxWH,
                \(COLUMNS.START_EMPLOYMENT_DATE)        = :startEmploymentDate,
                \(COLUMNS.END_EMPLOYMENT_DATE)          = :endEmploymentDate,
                \(COLUMNS.CURRENT_VACATION_AMOUNT)      = :currentVacationAmount,
                \(COLUMNS.VACATION_ACCRUAL_IN_HOURS)    = :vacationAccrualRateInHours,
                \(COLUMNS.VACATION_HOURS_PER_YEAR)      = :vacationHoursPerYear,
                \(COLUMNS.IS_FIXED_CONTRACT_PRICE)      = :isFixedContractPrice,
                \(COLUMNS.CONTRACT_PRICE)               = :contractPrice,
                \(COLUMNS.REMOVED)                      = :removed,
                \(COLUMNS.REMOVED_DATE)                 = :removeDate,
                \(COLUMNS.NUMBER_OF_ATTACHMENTS)        = :numberOfAttachments

            WHERE \(tableName).\(setIdKey()) = :id;
            """
        AppDatabase.shared.executeSQL(sql: sql, arguments: arguments, typeOfAction: .update, updatedId: UInt64(wage.wageID ?? 0)) { (_) in
            success()
        } fail: { (error) in
            print(error)
        }

    }
    
    func fetchWages(showRemoved: Bool, with key: String? = nil, sortBy: WagesField? = nil , sortType: SortType? = nil ,offset: Int,success: @escaping(_ wages: [Wage]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        let sortable = makeSortableItems(sortBy: sortBy, sortType: sortType)
        let searchable = makeSearchableItems(key: key)
        let removedCondition = """
                WHERE (WG.\(COLUMNS.REMOVED) = 0
                OR WG.\(COLUMNS.REMOVED) is NULL)
                """
        
        let showRemovedCondition = """
            WHERE (WG.\(COLUMNS.REMOVED) = 1)
            """
        
        var condition = ""
        if showRemoved {
            condition = (searchable.isEmpty) ? showRemovedCondition : """
                \(showRemovedCondition)
                AND \(searchable)
            """
        }
        else {
            condition = (searchable.isEmpty) ? removedCondition : """
                \(removedCondition)
                AND \(searchable)
            """
        }
        
        var sql = """
        SELECT *,
        W.\(COLUMNS.FIRST_NAME) || ' ' || W.\(COLUMNS.LAST_NAME) AS WorkerName,
        ROW_NUMBER() OVER (ORDER BY WG.\(COLUMNS.WAGE_ID)) AS RowNum
        FROM main.\(tableName) WG
        JOIN main.\(TABLES.WORKERS) W ON WG.\(COLUMNS.WORKER_ID) == W.\(COLUMNS.WORKER_ID)
        \(condition)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        sql += """
            \(sortable.replaceMain())
            LIMIT \(LIMIT) OFFSET \(offset);
        """

        
        do {
            let wages = try queue.read({ (db) -> [Wage] in
                var wages: [Wage] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    print("Wage",row)
                    wages.append(.init(row: row))
                }
                return wages
            })
            success(wages)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    private func makeSearchableItems(key: String?) -> String {
        guard let key = key else { return "" }
        return makeSearchableCondition(key: key,
                                       fields: [
                                        "W.\(COLUMNS.FIRST_NAME) || ' ' || W.\(COLUMNS.LAST_NAME)",
                                        "WG.\(COLUMNS.SALARY_RATE)",
                                        "WG.\(COLUMNS.SALARY_PER_TIME)",
                                        "WG.\(COLUMNS.HOURLY_RATE)",
                                        "WG.\(COLUMNS.W4WH)",
                                        "WG.\(COLUMNS.W4_EXEPMTIONS)",
                                        "WG.\(COLUMNS.GARNISHMENTS)",
                                        "WG.\(COLUMNS.GARNISHMENT_AMOUNT)",
                                        "WG.\(COLUMNS.NEEDS_1099)",
                                        "WG.\(COLUMNS.NUMBER_OF_ATTACHMENTS)",
                                        "WG.\(COLUMNS.START_EMPLOYMENT_DATE)"])
    }
    
    private func makeSortableItems(sortBy: WagesField?, sortType: SortType?) -> String {
        guard let sortBy = sortBy, let sortType = sortType else {
            let q = "W.\(COLUMNS.FIRST_NAME) || ' ' || W.\(COLUMNS.LAST_NAME)"
            return makeSortableCondition(key: q, sortType: .ASCENDING)
        }
        switch sortBy {
        case .WORKER_NAME:
            let q = "W.\(COLUMNS.FIRST_NAME) || ' ' || W.\(COLUMNS.LAST_NAME)"
            return makeSortableCondition(key: q, sortType: sortType)
        case .SALARY_RATE:
            let q = "WG.\(COLUMNS.SALARY_RATE)"
            return makeSortableCondition(key: q, sortType: sortType)
        case .SALART_PER_TIME:
            let q = "WG.\(COLUMNS.SALARY_PER_TIME)"
            return makeSortableCondition(key: q, sortType: sortType)
        case .HOURLY_RATE:
            let q = "WG.\(COLUMNS.HOURLY_RATE)"
            return makeSortableCondition(key: q, sortType: sortType)
        case .W4WH:
            let q = "WG.\(COLUMNS.W4WH)"
            return makeSortableCondition(key: q, sortType: sortType)
        case .W4EXEMPTIONS:
            let q = "WG.\(COLUMNS.W4_EXEPMTIONS)"
            return makeSortableCondition(key: q, sortType: sortType)
        case .GARNISHMENTS:
            let q = "WG.\(COLUMNS.GARNISHMENTS)"
            return makeSortableCondition(key: q, sortType: sortType)
        case .GARNISHMENT_AMOUNT:
            let q = "WG.\(COLUMNS.GARNISHMENT_AMOUNT)"
            return makeSortableCondition(key: q, sortType: sortType)
        case .NEEDS_1099:
            let q = "WG.\(COLUMNS.NEEDS_1099)"
            return makeSortableCondition(key: q, sortType: sortType)
        case .ATTACHMENTS:
            let q = "WG.\(COLUMNS.NUMBER_OF_ATTACHMENTS)"
            return makeSortableCondition(key: q, sortType: sortType)
        case .START_EMPLOYMENT_DATE:
            let q = "WG.\(COLUMNS.START_EMPLOYMENT_DATE)"
            return makeSortableCondition(key: q, sortType: sortType)
        default: return  ""
        }
    }
    
    func deleteWage(wage: Wage, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = wage.wageID else { return }
        softDelete(atId: id, success: success, fail: failure)
    }
    
    func restoreWage(wage: Wage, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = wage.wageID else { return }
        restoreItem(atId: id, success: success, fail: failure)
    }
}
