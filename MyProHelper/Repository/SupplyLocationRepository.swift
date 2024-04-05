//
//  SupplyLocationDBService.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 17/06/1942 Saka.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import GRDB

class SupplyLocationRepository: BaseRepository {
    
    
    init() {
        super.init(table: .SUPPLY_LOCATIONS)
        createSelectedLayoutTable()
    }
    
    override func setIdKey() -> String {
        return COLUMNS.SUPPLY_LOCATION_ID
    }
    
    private func createSelectedLayoutTable() {
        let sql = """
        CREATE TABLE IF NOT EXISTS \(tableName)(
            \(COLUMNS.SUPPLY_LOCATION_ID)   INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL,
            \(COLUMNS.LOCATION_NAME)            TEXT,
            \(COLUMNS.LOCATION_DESCRIPTION)     TEXT,
            \(COLUMNS.DATE_CREATED)             TEXT,
            \(COLUMNS.DATE_MODIFIED)            TEXT,
            \(COLUMNS.SAMPLE_SUPPLY_LOCATION)   INTEGER DEFAULT(0),
            \(COLUMNS.REMOVED)                  INTEGER DEFAULT(0),
            \(COLUMNS.REMOVED_DATE)             TEXT
        )
        """
        AppDatabase.shared.executeSQL(sql: sql,
                                      arguments: [],typeOfAction: .create, updatedId: nil) { (_) in
            print("TABLE SUPPLY_LOCATIONS IS CREATED SUCCESSFULLY")
        } fail: { (error) in
            print(error)
        }
    }
    
    func insertSupplyLocation(supplyLocation: SupplyLocation, success: @escaping(_ id: Int64) -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "locationName"          : supplyLocation.locationName,
            "locationDescription"   : supplyLocation.locationDescription,
            "dateCreated"           : DateManager.getStandardDateString(date: supplyLocation.dateCreated),
            "dateModified"          : DateManager.getStandardDateString(date: supplyLocation.dateModified),
            "removed"               : supplyLocation.removed,
            "removedDate"           : DateManager.getStandardDateString(date: supplyLocation.removedDate)
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
                                     fail: failure)
    }
    
    func update(supplyLocation: SupplyLocation, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "id"                    : supplyLocation.supplyLocationID,
            "locationName"          : supplyLocation.locationName,
            "locationDescription"   : supplyLocation.locationDescription,
            "dateCreated"           : DateManager.getStandardDateString(date: supplyLocation.dateCreated),
            "dateModified"          : DateManager.getStandardDateString(date: supplyLocation.dateModified),
            "removed"               : supplyLocation.removed,
            "removedDate"           : DateManager.getStandardDateString(date: supplyLocation.removedDate)
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
                                     typeOfAction: .update, updatedId: UInt64(supplyLocation.supplyLocationID!),
                                     success: { _ in
                                        success()
                                     },
                                     fail: failure)
    }
    
    func delete(supplyLocation: SupplyLocation, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = supplyLocation.supplyLocationID else {
            return
        }
        softDelete(atId: id, success: success, fail: failure)
    }
    
    func restoreSupplyLocation(supplyLocation: SupplyLocation, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = supplyLocation.supplyLocationID else {
            return
        }
        restoreItem(atId: id, success: success, fail: failure)
    }
    
    func fetchSupplyLocations(showRemoved: Bool, with key: String? = nil, sortBy: SupplyLocationField? = nil, sortType: SortType? = nil ,offset: Int,success: @escaping(_ locations: [SupplyLocation]) -> (), failure: @escaping(_ error: Error) -> ()) {
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
            let locations = try queue.read({ (db) -> [SupplyLocation] in
                var locations: [SupplyLocation] = []
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
    
    private func makeSortableItems(sortBy: SupplyLocationField?, sortType: SortType?) -> String {
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
