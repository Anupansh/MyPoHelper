//
//  PartsDBService.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 22/05/1942 Saka.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import GRDB

class PartRepository: BaseRepository {
    
    
    init() {
        super.init(table: .PARTS)
        createSelectedLayoutTable()
    }
    
    override func setIdKey() -> String {
        return COLUMNS.PART_ID
    }
    private func createSelectedLayoutTable() {
       let sql = """
            CREATE TABLE IF NOT EXISTS \(tableName)(
                \(COLUMNS.PART_ID)  INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL,
                \(COLUMNS.PART_NAME)                TEXT,
                \(COLUMNS.DESCRIPTION)              TEXT,
                \(COLUMNS.SAMPLE_PART)              INTEGER DEFAULT(0),
                \(COLUMNS.CREATED_DATE)             TEXT,
                \(COLUMNS.MODIFIED_DATE)            TEXT,
                \(COLUMNS.REMOVED)                  INTEGER DEFAULT(0),
                \(COLUMNS.REMOVED_DATE)             TEXT,
                \(COLUMNS.NUMBER_OF_ATTACHMENTS)    INTEGER DEFAULT(0))
        """
        AppDatabase.shared.executeSQL(sql: sql,
                                      arguments: [],typeOfAction: .create, updatedId: nil) { (_) in
            print("TABLE PARTS IS CREATED SUCCESSFULLY")
        } fail: { (error) in
            print(error)
        }
    }
    
    func fetchPart(showSelect: Bool = false, with key: String? = nil ,offset: Int,success: @escaping(_ parts: [Part]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        let searchable = makeSearchableItems(key: key)
      
        let noSelectCondition = """
            main.\(tableName).\(COLUMNS.PART_NAME) != '--SELECT--'
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
            let parts = try queue.read({ (db) -> [Part] in
                var parts: [Part] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    parts.append(.init(row: row))
                }
                return parts
            })
            success(parts)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    func fetchStockedParts(showRemoved: Bool, with key: String? = nil,isApproval: Bool,sortBy: StockedPartFields? = nil, sortType: SortType? = nil ,offset: Int,success: @escaping(_ users: [StockedPart]) -> (), failure: @escaping(_ error: Error) -> ()) {
    
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        let searchable = makeSearchableItems(key: key)
        let condition = ""//getShowRemoveCondition(showRemoved: showRemoved, searchable: searchable)
        
        
//        SELECT * FROM main.\(tableName)
        var sql2 = """
        SELECT
        p.\(COLUMNS.PART_ID) as \(COLUMNS.PART_ID),
        \(COLUMNS.PART_NAME) as \(COLUMNS.PART_NAME),
        \(COLUMNS.DESCRIPTION) as \(COLUMNS.DESCRIPTION),
        v.\(COLUMNS.VENDOR_NAME) as \(COLUMNS.VENDOR_NAME),
        pl.\(COLUMNS.LOCATION_NAME) as \(COLUMNS.LOCATION_NAME),
        pf.\(COLUMNS.QUANTITY) as \(COLUMNS.QUANTITY),
        u.\(COLUMNS.COUNT_WAITING_FOR) as \(COLUMNS.COUNT_WAITING_FOR),
        pf.\(COLUMNS.LAST_PURHCASED) as \(COLUMNS.LAST_PURHCASED)
        FROM \(tableName) p
        JOIN \(TABLES.PARTS_USED) u on p.\(COLUMNS.PART_ID) = u.\(COLUMNS.PART_ID)
        JOIN \(TABLES.PART_FINDERS) pf on p.\(COLUMNS.PART_ID) = pf.\(COLUMNS.PART_ID)
        JOIN \(TABLES.VENDORS) v on v.\(COLUMNS.VENDOR_ID) = pf.\(COLUMNS.WHERE_PURCHASED)
        JOIN \(TABLES.PART_LOCATIONS) pl on pl.\(COLUMNS.PART_LOCATION_ID) = pf.\(COLUMNS.PART_LOCATION_ID)
        WHERE u.\(COLUMNS.QUANTITY) != 0
        """
        
        var sql = """
        SELECT
        p.\(COLUMNS.PART_ID) as \(COLUMNS.PART_ID),
        p.\(COLUMNS.PART_NAME) as \(COLUMNS.PART_NAME),
        p.\(COLUMNS.DESCRIPTION) as \(COLUMNS.DESCRIPTION),
        v.\(COLUMNS.VENDOR_NAME) as \(COLUMNS.VENDOR_NAME),
        pl.\(COLUMNS.LOCATION_NAME) as \(COLUMNS.LOCATION_NAME),
        pf.\(COLUMNS.QUANTITY) as \(COLUMNS.QUANTITY),
        u.\(COLUMNS.COUNT_WAITING_FOR) as \(COLUMNS.COUNT_WAITING_FOR),
        pf.\(COLUMNS.LAST_PURHCASED) as \(COLUMNS.LAST_PURHCASED)
        FROM \(tableName) p
        JOIN main.\(tableName) op on p.\(COLUMNS.PART_ID) = op.\(COLUMNS.PART_ID)
        JOIN \(TABLES.PARTS_USED) u on p.\(COLUMNS.PART_ID) = u.\(COLUMNS.PART_ID)
        JOIN main.\(TABLES.PARTS_USED) ou on p.\(COLUMNS.PART_ID) = ou.\(COLUMNS.PART_ID)
        JOIN \(TABLES.PART_FINDERS) pf on p.\(COLUMNS.PART_ID) = pf.\(COLUMNS.PART_ID)
        JOIN \(TABLES.VENDORS) v on v.\(COLUMNS.VENDOR_ID) = pf.\(COLUMNS.WHERE_PURCHASED)
        JOIN \(TABLES.PART_LOCATIONS) pl on pl.\(COLUMNS.PART_LOCATION_ID) = pf.\(COLUMNS.PART_LOCATION_ID)
        WHERE u.\(COLUMNS.QUANTITY) != 0
        """
//        LIMIT \(LIMIT) OFFSET \(offset);
//        \(condition)
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        
        
//        sql += """
//                LIMIT \(LIMIT) OFFSET \(offset);
//        """
        
        do {
            let parts = try queue.read({ (db) -> [StockedPart] in
                var parts: [StockedPart] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    parts.append(.init(row: row))
                }
                return parts
            })
            success(parts)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    func insertPart(part: Part, success: @escaping(_ partID: Int64) -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "partName"              : part.partName,
            "description"           : part.description,
            "dateCreated"           : DateManager.getStandardDateString(date: part.dateCreated),
            "dateModified"          : DateManager.getStandardDateString(date: part.dateModified),
            "removed"               : part.removed,
            "removedDate"           : DateManager.getStandardDateString(date: part.removedDate),
            "numberOfAttachments"   : part.numberOfAttachments
        ]
        let sql = """
            INSERT INTO chg.\(tableName) (
                \(COLUMNS.PART_NAME),
                \(COLUMNS.DESCRIPTION),
                \(COLUMNS.CREATED_DATE),
                \(COLUMNS.MODIFIED_DATE),
                \(COLUMNS.REMOVED),
                \(COLUMNS.REMOVED_DATE),
                \(COLUMNS.NUMBER_OF_ATTACHMENTS))

            VALUES (:partName,
                    :description,
                    :dateCreated,
                    :dateModified,
                    :removed,
                    :removedDate,
                    :numberOfAttachments)
            """
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,typeOfAction: .insert, updatedId: nil,
                                     success: { id in
                                        success(id)
                                     },
                                     fail: failure)
    }
    
    func update(part: Part, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "id"                    : part.partID,
            "partName"              : part.partName,
            "description"           : part.description,
            "dateCreated"           : DateManager.getStandardDateString(date: part.dateCreated),
            "dateModified"          : DateManager.getStandardDateString(date: part.dateModified),
            "removed"               : part.removed,
            "removedDate"           : DateManager.getStandardDateString(date: part.removedDate),
            "numberOfAttachments"   : part.numberOfAttachments
        ]
        let sql = """
            UPDATE \(tableName) SET
                \(COLUMNS.PART_NAME)                = :partName,
                \(COLUMNS.DESCRIPTION)              = :description,
                \(COLUMNS.CREATED_DATE)             = :dateCreated,
                \(COLUMNS.MODIFIED_DATE)            = :dateModified,
                \(COLUMNS.REMOVED)                  = :removed,
                \(COLUMNS.REMOVED_DATE)             = :removedDate,
                \(COLUMNS.NUMBER_OF_ATTACHMENTS)    = :numberOfAttachments
            WHERE \(tableName).\(setIdKey()) = :id;
            """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,
                                     typeOfAction: .update, updatedId: UInt64(part.partID!),
                                     success: { _ in
                                        success()
                                     },
                                     fail: failure)
    }
    
    func removePart(part: Part, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = part.partID else {
                return
        }
        softDelete(atId: id, success: success, fail: failure)
    }
    
    func unremovePart(part: Part, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = part.partID else {
                return
        }
        restoreItem(atId: id, success: success, fail: failure)
    }
    
    func fetchPart(with id: Int,success: @escaping(_ parts: Part?) -> (), failure: @escaping(_ error: Error) -> ()){
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        var sql = """
        SELECT * FROM main.\(tableName)
        LEFT JOIN main.\(TABLES.PART_FINDERS) ON main.\(tableName).\(COLUMNS.PART_ID) == main.\(TABLES.PART_FINDERS).\(COLUMNS.PART_ID)
        LEFT JOIN main.\(TABLES.VENDORS) ON main.\(TABLES.PART_FINDERS).\(COLUMNS.WHERE_PURCHASED) == main.\(TABLES.VENDORS).\(COLUMNS.VENDOR_ID)
        LEFT JOIN main.\(TABLES.PART_LOCATIONS) ON main.\(TABLES.PART_FINDERS).\(COLUMNS.PART_LOCATION_ID) == main.\(TABLES.PART_LOCATIONS).\(COLUMNS.PART_LOCATION_ID);
        WHERE main.\(tableName).\(COLUMNS.PART_ID) = ?
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            let part = try queue.read({ (db) -> Part? in
                if let row = try Row.fetchOne(db,
                                  sql: sql,
                                  arguments: [id]) {
                    return Part(row: row)
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
    
    func fetchPart(showRemoved: Bool, with key: String? = nil, sortBy: PartField? = nil, sortType: SortType? = nil ,offset: Int,success: @escaping(_ parts: [Part]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        let sortable = makeSortableItems(sortBy: sortBy, sortType: sortType)
        let searchable = makeSearchableItems(key: key)
        let removedCondition = """
                WHERE (main.\(tableName).\(COLUMNS.REMOVED) = 0
                OR main.\(tableName).\(COLUMNS.REMOVED) is NULL)
                AND (main.\(TABLES.PART_FINDERS).\(COLUMNS.REMOVED) = 0
                OR main.\(TABLES.PART_FINDERS).\(COLUMNS.REMOVED) is NULL)
                AND main.\(tableName).\(COLUMNS.PART_NAME) != '--SELECT--'
            """
        
        let showRemovedCondition = """
                WHERE (main.\(tableName).\(COLUMNS.REMOVED) = 1)
                AND main.\(tableName).\(COLUMNS.PART_NAME) != '--SELECT--'
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
        LEFT JOIN main.\(TABLES.PART_FINDERS) ON main.\(tableName).\(COLUMNS.PART_ID) == main.\(TABLES.PART_FINDERS).\(COLUMNS.PART_ID)
        LEFT JOIN main.\(TABLES.VENDORS) ON main.\(TABLES.PART_FINDERS).\(COLUMNS.WHERE_PURCHASED) == main.\(TABLES.VENDORS).\(COLUMNS.VENDOR_ID)
        LEFT JOIN main.\(TABLES.PART_LOCATIONS) ON main.\(TABLES.PART_FINDERS).\(COLUMNS.PART_LOCATION_ID) == main.\(TABLES.PART_LOCATIONS).\(COLUMNS.PART_LOCATION_ID)
        \(condition)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        sql += """
                \(sortable.replaceMain())
                
        """
//        LIMIT \(LIMIT) OFFSET \(offset);
        do {
            let parts = try queue.read({ (db) -> [Part] in
                var parts: [Part] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    parts.append(.init(row: row))
                }
                return parts
            })
            success(parts)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    private func makeSortableItems(sortBy: PartField?, sortType: SortType?) -> String {
        guard let sortBy = sortBy, let sortType = sortType else {
            return makeSortableCondition(key: COLUMNS.PART_NAME, sortType: .ASCENDING)
        }
        switch sortBy {
        case .PART_NAME:
            return makeSortableCondition(key: COLUMNS.PART_NAME, sortType: sortType)
        case .DESCRIPTION:
            return makeSortableCondition(key: COLUMNS.DESCRIPTION, sortType: sortType)
        case .PURCHASED_FROM:
            return makeSortableCondition(key: COLUMNS.VENDOR_NAME, sortType: sortType)
        case .PART_LOCATION:
            return makeSortableCondition(key: COLUMNS.LOCATION_NAME, sortType: sortType)
        case .QUANTITY:
            return makeSortableCondition(key: COLUMNS.QUANTITY, sortType: sortType)
        case .PRICE_PAID:
            return makeSortableCondition(key: COLUMNS.PRICE_PAID, sortType: sortType)
        case .PRICE_TO_RESELL:
            return makeSortableCondition(key: COLUMNS.PRICE_TO_RESELL, sortType: sortType)
        case .WAITING_COUNT:
            return ""
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
                                        COLUMNS.PART_NAME,
                                        COLUMNS.DESCRIPTION,
                                        COLUMNS.VENDOR_NAME,
                                        COLUMNS.LOCATION_NAME,
                                        COLUMNS.QUANTITY,
                                        COLUMNS.PRICE_PAID,
                                        COLUMNS.PRICE_TO_RESELL,
                                        COLUMNS.LAST_PURHCASED,
                                        "main.\(tableName).\(COLUMNS.NUMBER_OF_ATTACHMENTS)"])
    }
    
    override func getShowRemoveCondition(showRemoved: Bool, searchable: String) -> String {
        let removedCondition = """
        WHERE (\(tableName).\(COLUMNS.REMOVED) = 0
        OR \(tableName).\(COLUMNS.REMOVED) is NULL)
        """
        
        let removedItemsCondition = """
        WHERE (\(tableName).\(COLUMNS.REMOVED) = 1)
        """
        var condition = ""
        if showRemoved {
            condition = (searchable.isEmpty) ? removedItemsCondition : """
                \(removedItemsCondition)
                AND \(searchable)
            """
        }
        else {
            condition = (searchable.isEmpty) ? removedCondition : """
                \(removedCondition)
                AND \(searchable)
            """
        }
        return condition
    }
}
