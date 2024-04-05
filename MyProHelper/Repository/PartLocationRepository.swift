//
//  PartLocationRepository.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/21/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import GRDB

class PartLocationRepository: BaseRepository {
    
    init() {
        super.init(table: .PART_LOCATIONS)
        self.createSelectedLayoutTable()
    }
    
    override func setIdKey() -> String {
        return COLUMNS.PART_LOCATION_ID
    }
    
    private func createSelectedLayoutTable() {
        let sql = """
        CREATE TABLE IF NOT EXISTS \(tableName)(
            \(COLUMNS.PART_LOCATION_ID) INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL,
            \(COLUMNS.LOCATION_NAME)        TEXT,
            \(COLUMNS.LOCATION_DESCRIPTION) TEXT,
            \(COLUMNS.DATE_CREATED)         TEXT,
            \(COLUMNS.DATE_MODIFIED)        TEXT,
            \(COLUMNS.SAMPLE_PART_LOCATION) INTEGER DEFAULT(0),
            \(COLUMNS.REMOVED)              INTEGER DEFAULT(0),
            \(COLUMNS.REMOVED_DATE)         TEXT
        )
        """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                      arguments: [],typeOfAction: .create, updatedId: nil) { (_) in
            print("TABLE PART_LOCATIONS IS CREATED SUCCESSFULLY")
        } fail: { (error) in
            print(error)
        }
    }
    
    func insertPartLocation(partLocation: PartLocation, success: @escaping (_ locationID: Int64) -> (), fail: @escaping (_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "locationName"          : partLocation.locationName,
            "locationDescription"   : partLocation.locationDescription,
            "dateCreated"           : DateManager.getStandardDateString(date: partLocation.dateCreated),
            "dateModified"          : DateManager.getStandardDateString(date: partLocation.dateModified),
            "removed"               : partLocation.removed,
            "removedDate"           : DateManager.getStandardDateString(date: partLocation.removedDate)
        ]
        let sql = """
            INSERT INTO chg.\(tableName) (
                \(COLUMNS.LOCATION_NAME),
                \(COLUMNS.LOCATION_DESCRIPTION),
                \(COLUMNS.DATE_CREATED),
                \(COLUMNS.DATE_MODIFIED),
                \(COLUMNS.REMOVED),
                \(COLUMNS.REMOVED_DATE))

            VALUES (:locationName,
                    :locationDescription,
                    :dateCreated,
                    :dateModified,
                    :removed,
                    :removedDate)
            """
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,typeOfAction: .insert, updatedId: nil,
                                     success: { id in
                                        success(id)
                                     },
                                     fail: fail)
    }
    
    func updatePartLocation(partLocation: PartLocation, success: @escaping () -> (), fail: @escaping (_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "id"                    : partLocation.partLocationID,
            "locationName"          : partLocation.locationName,
            "locationDescription"   : partLocation.locationDescription,
            "dateCreated"           : DateManager.getStandardDateString(date: partLocation.dateCreated),
            "dateModified"          : DateManager.getStandardDateString(date: partLocation.dateModified),
            "removed"               : partLocation.removed,
            "removedDate"           : DateManager.getStandardDateString(date: partLocation.removedDate)
        ]
        let sql = """
            UPDATE \(tableName) SET
                \(COLUMNS.LOCATION_NAME)        = :locationName,
                \(COLUMNS.LOCATION_DESCRIPTION) = :locationDescription,
                \(COLUMNS.DATE_CREATED)         = :dateCreated,
                \(COLUMNS.DATE_MODIFIED)        = :dateModified,
                \(COLUMNS.REMOVED)              = :removed,
                \(COLUMNS.REMOVED_DATE)         = :removedDate
            WHERE \(tableName).\(setIdKey()) = :id;
            """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,
                                     typeOfAction: .create, updatedId: UInt64(partLocation.partLocationID!),
                                     success: { _ in
                                        success()
                                     },
                                     fail: fail)
    }
    
    func deletePartLocation(partLocation: PartLocation, success: @escaping () -> (), fail: @escaping (_ error: Error) -> ()) {
        guard  let locationId = partLocation.partLocationID else {
            return
        }
        softDelete(atId: locationId, success: success, fail: fail)
    }
    
    func restorePartLocation(partLocation: PartLocation, success: @escaping () -> (), fail: @escaping (_ error: Error) -> ()) {
        guard  let locationId = partLocation.partLocationID else {
            return
        }
        restoreItem(atId: locationId, success: success, fail: fail)
    }
    
    func fetchPartLocation(showRemoved: Bool, with key: String? = nil, sortBy: PartLocationField? = nil, sortType: SortType? = nil ,offset: Int,success: @escaping(_ locations: [PartLocation]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        let sortable = makeSortableItems(sortBy: sortBy, sortType: sortType)
        let searchable = makeSearchableItems(key: key)
        let removedCondition = """
        WHERE (main.\(tableName).\(COLUMNS.REMOVED) = 0
        OR main.\(tableName).\(COLUMNS.REMOVED) is NULL)
        """
        
        let showRemovedCondition = """
                WHERE (main.\(tableName).\(COLUMNS.REMOVED) = 1)
                AND main.\(tableName).\(COLUMNS.LOCATION_NAME) != '--SELECT--'
            """
        
        
        var condition = ""
        if showRemoved {
//            condition = (searchable.isEmpty) ? "" : "WHERE \(searchable)"
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
        SELECT * FROM main.\(tableName)
        \(condition)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        sql += """
                \(sortable)
        """
//        LIMIT \(LIMIT) OFFSET \(offset);
        do {
            let locations = try queue.read({ (db) -> [PartLocation] in
                var locations: [PartLocation] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    locations.append(.init(row: row))
                }
                return locations
            })
            success(locations)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    
    
    private func makeSortableItems(sortBy: PartLocationField?, sortType: SortType?) -> String {
        guard let sortBy = sortBy, let sortType = sortType else {
            return makeSortableCondition(key: COLUMNS.LOCATION_NAME, sortType: .ASCENDING)
        }
        switch sortBy {
        
        case .NAME:
            return makeSortableCondition(key: COLUMNS.LOCATION_NAME, sortType: sortType)
        case .DESCRIPTION:
            return makeSortableCondition(key: COLUMNS.LOCATION_DESCRIPTION, sortType: sortType)
        case .CREATED_DATE:
            return makeSortableCondition(key: COLUMNS.DATE_CREATED, sortType: sortType)
        }
    }
    
    private func makeSearchableItems(key: String?) -> String {
        guard let key = key else { return "" }
        return makeSearchableCondition(key: key,
                                       fields: [
                                        COLUMNS.LOCATION_NAME,
                                        COLUMNS.LOCATION_DESCRIPTION,
                                        COLUMNS.DATE_CREATED])
    }
}
