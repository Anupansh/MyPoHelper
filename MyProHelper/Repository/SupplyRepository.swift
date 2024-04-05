//
//  SupplyRepository.swift
//  MyProHelper
//
//  Created by Deep on 2/17/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import GRDB

class SupplyRepository: BaseRepository {
    
    
    init() {
        super.init(table: .SUPPLIES)
    }
    
    override func setIdKey() -> String {
        return COLUMNS.SUPPLY_ID
    }
    
    func insertSupply(supply: Supply, success: @escaping(_ supplyID: Int64) -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "supplyName"            : supply.supplyName,
            "description"           : supply.description,
//            "dateCreated"           : DateManager.getStandardDateString(date: part.dateCreated),
//            "dateModified"          : DateManager.getStandardDateString(date: part.dateModified),
            "removed"               : supply.removed,
            "removedDate"           : DateManager.getStandardDateString(date: supply.removedDate),
            "numberOfAttachments"   : supply.numberOfAttachments
        ]
        let sql = """
            INSERT INTO chg.\(tableName) (
                \(COLUMNS.SUPPLY_NAME),
                \(COLUMNS.DESCRIPTION),
                \(COLUMNS.REMOVED),
                \(COLUMNS.REMOVED_DATE),
                \(COLUMNS.NUMBER_OF_ATTACHMENTS))

            VALUES (:supplyName,
                    :description,
                    :removed,
                    :removedDate,
                    :numberOfAttachments)
            """
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,
                                     typeOfAction: .insert, updatedId: nil,
                                     success: { id in
                                        success(id)
                                     },
                                     fail: failure)
    }
    
    func update(supplies: Supply, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "id"                    : supplies.supplyId,
            "supplyName"              : supplies.supplyName,
            "description"           : supplies.description,
//            "dateCreated"           : DateManager.getStandardDateString(date: supplies.dateCreated),
//            "dateModified"          : DateManager.getStandardDateString(date: supplies.dateModified),
            "removed"               : supplies.removed,
            "removedDate"           : DateManager.getStandardDateString(date: supplies.removedDate),
            "numberOfAttachments"   : supplies.numberOfAttachments
        ]
        let sql = """
            UPDATE \(tableName) SET
                \(COLUMNS.SUPPLY_NAME)              = :supplyName,
                \(COLUMNS.DESCRIPTION)              = :description,
                \(COLUMNS.REMOVED)                  = :removed,
                \(COLUMNS.REMOVED_DATE)             = :removedDate,
                \(COLUMNS.NUMBER_OF_ATTACHMENTS)    = :numberOfAttachments
            WHERE \(tableName).\(setIdKey()) = :id;
            """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,
                                     typeOfAction: .update, updatedId: UInt64(supplies.supplyId!),
                                     success: { _ in
                                        success()
                                     },
                                     fail: failure)
    }
    
    func removeSupply(supply: Supply, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = supply.supplyId else {
                return
        }
        softDelete(atId: id, success: success, fail: failure)
    }
    
    func unremoveSupply(supply: Supply, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = supply.supplyId else {
                return
        }
        restoreItem(atId: id, success: success, fail: failure)
    }
    
    func fetchSupplies(with id: Int,success: @escaping(_ supplies: Supply?) -> (), failure: @escaping(_ error: Error) -> ()){
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        var sql = """
        SELECT * FROM main.\(tableName)
        LEFT JOIN main.\(TABLES.SUPPLY_FINDERS) ON main.\(tableName).\(COLUMNS.SUPPLY_ID) == main.\(TABLES.SUPPLY_FINDERS).\(COLUMNS.SUPPLY_ID)
        LEFT JOIN main.\(TABLES.VENDORS) ON main.\(TABLES.SUPPLY_FINDERS).\(COLUMNS.WHERE_PURCHASED) == main.\(TABLES.VENDORS).\(COLUMNS.VENDOR_ID)
        LEFT JOIN main.\(TABLES.SUPPLY_LOCATIONS) ON main.\(TABLES.SUPPLY_FINDERS).\(COLUMNS.SUPPLY_LOCATION_ID) == main.\(TABLES.SUPPLY_LOCATIONS).\(COLUMNS.SUPPLY_LOCATION_ID);
        WHERE main.\(tableName).\(COLUMNS.SUPPLY_ID) = ?
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            let part = try queue.read({ (db) -> Supply? in
                if let row = try Row.fetchOne(db,
                                  sql: sql,
                                  arguments: [id]) {
                    return Supply(row: row)
                }
                return nil
            })
            success(part)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    func fetchSupplies(showRemoved: Bool, with key: String? = nil, sortBy: SupplyField? = nil , sortType: SortType? = nil ,offset: Int,success: @escaping(_ supplies: [Supply]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        let sortable = makeSortableItems(sortBy: sortBy, sortType: sortType)
        let searchable = makeSearchableItems(key: key)
        let removedCondition = """
                WHERE (main.\(tableName).\(COLUMNS.REMOVED) = 0
                OR main.\(tableName).\(COLUMNS.REMOVED) is NULL)
                AND (main.\(TABLES.SUPPLY_FINDERS).\(COLUMNS.REMOVED) = 0
                OR main.\(TABLES.SUPPLY_FINDERS).\(COLUMNS.REMOVED) is NULL)
                AND main.\(tableName).\(COLUMNS.SUPPLY_NAME) != '--SELECT--'
            """
        
        let showRemovedCondition = """
                WHERE (main.\(tableName).\(COLUMNS.REMOVED) = 1)
                AND main.\(tableName).\(COLUMNS.SUPPLY_NAME) != '--SELECT--'
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
        LEFT JOIN main.\(TABLES.SUPPLY_FINDERS) ON main.\(tableName).\(COLUMNS.SUPPLY_ID) == main.\(TABLES.SUPPLY_FINDERS).\(COLUMNS.SUPPLY_ID)
        LEFT JOIN main.\(TABLES.VENDORS) ON main.\(TABLES.SUPPLY_FINDERS).\(COLUMNS.WHERE_PURCHASED) == main.\(TABLES.VENDORS).\(COLUMNS.VENDOR_ID)
        LEFT JOIN main.\(TABLES.SUPPLY_LOCATIONS) ON main.\(TABLES.SUPPLY_FINDERS).\(COLUMNS.SUPPLY_LOCATION_ID) == main.\(TABLES.SUPPLY_LOCATIONS).\(COLUMNS.SUPPLY_LOCATION_ID)
        \(condition)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        sql += """
                \(sortable.replaceMain())
                LIMIT \(LIMIT) OFFSET \(offset);
        """

        do {
            let supplies = try queue.read({ (db) -> [Supply] in
                var supplies: [Supply] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    supplies.append(.init(row: row))
                }
                return supplies
            })
            success(supplies)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    func fetchSupplies(showSelect: Bool, with key: String? = nil, offset: Int,success: @escaping(_ supplies: [Supply]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        let searchable = makeSearchableItems(key: key)
        
        let noSelectCondition = """
                main.\(tableName).\(COLUMNS.SUPPLY_NAME) != '--SELECT--'
            """

        var condition = ""
        if showSelect {
            condition = (searchable.isEmpty) ? "" : "WHERE \(searchable)"
        }
        else {
            condition = (searchable.isEmpty) ? "WHERE \(noSelectCondition)" : """
                WHERE \(noSelectCondition)
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
                LIMIT \(LIMIT) OFFSET \(offset);
        """

        do {
            let supplies = try queue.read({ (db) -> [Supply] in
                var supplies: [Supply] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    supplies.append(.init(row: row))
                }
                return supplies
            })
            success(supplies)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    private func makeSortableItems(sortBy: SupplyField?, sortType: SortType?) -> String {
        guard let sortBy = sortBy, let sortType = sortType else {
            return makeSortableCondition(key: COLUMNS.SUPPLY_NAME, sortType: .ASCENDING)
        }
        switch sortBy {
        case .SUPPLY_NAME:
            return makeSortableCondition(key: COLUMNS.SUPPLY_NAME, sortType: sortType)
        case .DESCRIPTION:
            return makeSortableCondition(key: COLUMNS.DESCRIPTION, sortType: sortType)
        case .PURCHASED_FROM:
            return makeSortableCondition(key: COLUMNS.WHERE_PURCHASED, sortType: sortType)
        case .SUPPLY_LOCATION:
            return makeSortableCondition(key: COLUMNS.LOCATION_NAME, sortType: sortType)
        case .QUANTITY:
            return makeSortableCondition(key: COLUMNS.QUANTITY, sortType: sortType)
        case .PRICE_PAID:
            return makeSortableCondition(key: COLUMNS.PRICE_PAID, sortType: sortType)
        case .PRICE_TO_RESELL:
            return makeSortableCondition(key: COLUMNS.PRICE_TO_RESELL, sortType: sortType)
//        case .WAITING_COUNT:
//            return ""
        case .PURCHASED_DATE:
            return makeSortableCondition(key: COLUMNS.LAST_PURHCASED, sortType: sortType)
        case .ATTACHMENTS:
            return makeSortableCondition(key: COLUMNS.NUMBER_OF_ATTACHMENTS, sortType: sortType)
        }
    }
    
    private func makeSearchableItems(key: String?) -> String {
        guard let key = key else { return "" }
        return makeSearchableCondition(key: key,
                                       fields: [
                                        COLUMNS.SUPPLY_NAME,
                                        COLUMNS.DESCRIPTION,
                                        COLUMNS.VENDOR_NAME,
                                        COLUMNS.LOCATION_NAME,
                                        COLUMNS.QUANTITY,
                                        COLUMNS.PRICE_PAID,
                                        COLUMNS.PRICE_TO_RESELL,
                                        COLUMNS.LAST_PURHCASED,
                                        "main.\(tableName).\(COLUMNS.NUMBER_OF_ATTACHMENTS)"])
    }
}
