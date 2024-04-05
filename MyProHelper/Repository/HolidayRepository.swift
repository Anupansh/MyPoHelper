//
//  HolidayRepository.swift
//  MyProHelper
//
//  Created by Deep on 1/13/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB

class HolidayRepository: BaseRepository {
    
    init() {
        super.init(table: .HOLIDAYS)
        createSelectedLayoutTable()
    }
    
    override func setIdKey() -> String {
        return COLUMNS.HOLIDAY_ID
    }
    
    private func createSelectedLayoutTable() {
        let sql = """
             CREATE TABLE IF NOT EXISTS \(tableName) (
                \(COLUMNS.HOLIDAY_ID)           INTEGER PRIMARY KEY  AUTOINCREMENT UNIQUE NOT NULL,
                \(COLUMNS.HOLIDAY_NAME)         TEXT,
                \(COLUMNS.YEAR)                 INTEGER DEFAULT (0),
                \(COLUMNS.ACTUAL_DATE)          INTEGER DEFAULT (0),
                \(COLUMNS.DATE_CELEBRATED)      INTEGER DEFAULT (0),
                \(COLUMNS.DATE_MODIFIED)        INTEGER DEFAULT (0),
                \(COLUMNS.REMOVED)              INTEGER DEFAULT(0),
                \(COLUMNS.REMOVED_DATE)         INTEGER DEFAULT (0)
            )
         """
         
         AppDatabase.shared.executeSQL(sql: sql,
                                       arguments: [],typeOfAction: .create, updatedId: nil) { (_) in
             print("TABLE ASSET_TYPES IS CREATED SUCCESSFULLY")
         } fail: { (error) in
             print(error)
         }
    }
    
    func createHoliday(holiday: Holiday, success: @escaping (_ typeID: Int64) -> (), fail: @escaping (_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "holidayName"     : holiday.holidayName,
            "year"            : holiday.year,
            "dateModified"    : DateManager.getStandardDateString(date: holiday.dateModified),
            "actualDate"      : DateManager.getStandardDateString(date: holiday.actualDate),
            "dateCelebrated"  : DateManager.getStandardDateString(date: holiday.dateCelebrated),
            "removed"         : holiday.removed,
            "removeDate"      : DateManager.getStandardDateString(date: holiday.removedDate)
        ]
        
        let sql = """
            INSERT INTO chg.\(tableName) (
                    \(COLUMNS.HOLIDAY_NAME),
                    \(COLUMNS.YEAR),
                    \(COLUMNS.ACTUAL_DATE),
                    \(COLUMNS.DATE_CELEBRATED),
                    \(COLUMNS.DATE_MODIFIED),
                    \(COLUMNS.REMOVED),
                    \(COLUMNS.REMOVED_DATE)
                     )

            VALUES (:holidayName,
                    :year,
                    :actualDate,
                    :dateCelebrated,
                    :dateModified,
                    :removed,
                    :removeDate
                    )
            """
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments
                                     ,typeOfAction: .insert, updatedId: nil,
                                     success: { id in
                                        success(id)
                                     },
                                     fail: fail)
    }
    
    func updateHoliday(holiday: Holiday, success: @escaping () -> (), fail: @escaping (_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "id"              : holiday.holidayID,
            "holidayName"     : holiday.holidayName,
            "year"            : holiday.year,
            "dateModified"    : DateManager.getStandardDateString(date: holiday.dateModified),
            "actualDate"      : DateManager.getStandardDateString(date: holiday.actualDate),
            "dateCelebrated"  : DateManager.getStandardDateString(date: holiday.dateCelebrated),
            "removed"         : holiday.removed,
            "removeDate"      : DateManager.getStandardDateString(date: holiday.removedDate)
        ]
        let sql = """
            UPDATE \(tableName) SET
                \(COLUMNS.HOLIDAY_NAME)               = :holidayName,
                \(COLUMNS.YEAR)                       = :year,
                \(COLUMNS.ACTUAL_DATE)                = :actualDate,
                \(COLUMNS.DATE_CELEBRATED)            = :dateCelebrated,
                \(COLUMNS.DATE_MODIFIED)              = :dateModified,
                \(COLUMNS.REMOVED)                    = :removed,
                \(COLUMNS.REMOVED_DATE)               = :removeDate
            WHERE \(tableName).\(setIdKey())          = :id
            """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,
                                     typeOfAction: .update, updatedId: UInt64(holiday.holidayID!),
                                     success: { _ in
                                        success()
                                     },
                                     fail: fail)
    }
    
    func delete(holiday: Holiday, success: @escaping () -> (), fail: @escaping (_ error: Error) -> ()) {
        guard let holidayId = holiday.holidayID else {
            return
        }
       softDelete(atId: holidayId, success: success, fail: fail)
    }
    
    func restoreHoliday(holiday: Holiday, success: @escaping () -> (), fail: @escaping (_ error: Error) -> ()) {
        guard let holidayId = holiday.holidayID else {
            return
        }
       restoreItem(atId: holidayId, success: success, fail: fail)
    }
    
    
    func fetchHolidays(showRemoved: Bool, with key: String? = nil, sortBy: HolidayField? = nil, sortType: SortType? = nil ,offset: Int,success: @escaping(_ users: [Holiday]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        let sortable = makeSortableItems(sortBy: sortBy, sortType: sortType)
        let searchable = makeSearchableItems(key: key)
        let condition = getShowRemoveCondition(showRemoved: showRemoved, searchable: searchable)
        var sql = """
        SELECT * FROM main.\(tableName)
        \(condition)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        sql += """
                \(sortable)
        """
        do {
            let holidays = try queue.read({ (db) -> [Holiday] in
                var holiday: [Holiday] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    if key == nil || key == "" {
                        let currentYear = Calendar.current.component(.year, from: Date())
                        let year = row["Year"] as? Int64 ?? Int64(0)
                        if year == currentYear && year != 0 {
                            holiday.append(.init(row: row))
                        }
                    }
                    else {
                        holiday.append(.init(row: row))
                    }
                }
                return holiday
            })
            success(holidays)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    private func makeSortableItems(sortBy: HolidayField?, sortType: SortType?) -> String {
        guard let sortBy = sortBy, let sortType = sortType else {
            return makeSortableCondition(key: COLUMNS.HOLIDAY_NAME, sortType: .ASCENDING)
        }
        switch sortBy {
        case .HOLIDAY_NAME:
            return makeSortableCondition(key: COLUMNS.HOLIDAY_NAME, sortType: sortType)
        case .YEAR:
            return makeSortableCondition(key: COLUMNS.YEAR, sortType: sortType)
        case .ACTUAL_DATE:
            return makeSortableCondition(key: COLUMNS.ACTUAL_DATE, sortType: sortType)
        case .DATE_CELEBRATED:
            return makeSortableCondition(key: COLUMNS.DATE_CELEBRATED, sortType: sortType)
        }
    }
    
    private func makeSearchableItems(key: String?) -> String {
        guard let key = key else { return "" }
        return makeSearchableCondition(key: key,
                                       fields: [
                                        COLUMNS.HOLIDAY_NAME,
                                        COLUMNS.YEAR,
                                        COLUMNS.ACTUAL_DATE,
                                        COLUMNS.DATE_CELEBRATED
                                        ]
        )
    }
}
