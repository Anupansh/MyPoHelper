//
//  PartUsedRepository.swift
//  MyProHelper
//
//  Created by Deep on 2/10/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import GRDB

class PartUsedRepository: BaseRepository {
    
    init() {
        super.init(table: .PARTS_USED)
     // createSelectedLayoutTable()
    }
 
    override func setIdKey() -> String {
        return COLUMNS.PART_USED_ID
    }
    
    func fetchPartsUsed(invoiceSerivceId: Int? = nil, offset: Int, success: @escaping(_ parts: [PartUsed]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        guard let invoiceId = invoiceSerivceId else { return }
        
        let arguments: StatementArguments = []
        
        var sql = """
        SELECT * FROM main.\(tableName)
        LEFT JOIN main.\(TABLES.PARTS) ON main.\(tableName).\(COLUMNS.PART_ID) ==  main.\(TABLES.PARTS).\(COLUMNS.PART_ID)

        LEFT JOIN main.\(TABLES.PART_LOCATIONS) ON main.\(tableName).\(COLUMNS.PART_LOCATION_ID) ==  main.\(TABLES.PART_LOCATIONS).\(COLUMNS.PART_LOCATION_ID)

        LEFT JOIN main.\(TABLES.VENDORS) ON main.\(tableName).\(COLUMNS.WHERE_PURCHASED) ==  main.\(TABLES.VENDORS).\(COLUMNS.VENDOR_ID)

        WHERE main.\(tableName).\(COLUMNS.INVOICE_ID) == \(invoiceId)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            let parts = try queue.read({ (db) -> [PartUsed] in
                var parts: [PartUsed] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: arguments)
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
    
    func addPartUsed(part: PartUsed, success: @escaping (_ partUsedId: Int64)->(), failure: @escaping (_ error: Error)->()) {

        let arguments: StatementArguments = [
            "partID"                : part.partID,
            "partFinderId"          : part.partFinderId,
            "InvoiceId"             : part.InvoiceId,
            "priceToResell"         : part.priceToResell,
            "quantity"              : part.quantity,
            "partLocationId"        : part.partLocationId,
            "wherePurchased"        : part.wherePurchased,
            "waitingForPart"        : part.waitingForPart,
            "countWaitingFor"       : part.countWaitingFor,
            "dateAdded"             : DateManager.getStandardDateString(date: part.dateAdded),
            "dateModified"          : DateManager.getStandardDateString(date: part.dateModified),
            "removed"               : part.removed,
            "removedDate"           : DateManager.getStandardDateString(date: part.removedDate)
            
        ]
        let sql = """
            INSERT INTO chg.\(tableName) (
                \(COLUMNS.PART_ID),
                \(COLUMNS.PART_FINDER_ID),
                \(COLUMNS.INVOICE_ID),
                \(COLUMNS.PRICE_TO_RESELL),
                \(COLUMNS.QUANTITY),
                \(COLUMNS.PART_LOCATION_ID),
                \(COLUMNS.WHERE_PURCHASED),
                \(COLUMNS.WAITING_FOR_PART),
                \(COLUMNS.COUNT_WAITING_FOR),
                \(COLUMNS.DATE_ADDED),
                \(COLUMNS.DATE_MODIFIED),
                \(COLUMNS.REMOVED),
                \(COLUMNS.REMOVED_DATE))

            VALUES (:partID,
                    :partFinderId,
                    :InvoiceId,
                    :priceToResell,
                    :quantity,
                    :partLocationId,
                    :wherePurchased,
                    :waitingForPart,
                    :countWaitingFor,
                    :dateAdded,
                    :dateModified,
                    :removed,
                    :removedDate
            )
            """
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,typeOfAction: .insert, updatedId: nil,
                                     success: { id in
                                        success(id)
                                     },
                                     fail: failure)
    }
    
    func updatePartUsed(part: PartUsed, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        
        let arguments: StatementArguments = [
            "partUsedId"            : part.partUsedId,
            "partID"                : part.partID,
            "partFinderId"          : part.partFinderId,
            "InvoiceId"             : part.InvoiceId,
            "priceToResell"         : part.priceToResell,
            "quantity"              : part.quantity,
            "partLocationId"        : part.partLocationId,
            "wherePurchased"        : part.wherePurchased,
            "waitingForPart"        : part.waitingForPart,
            "countWaitingFor"       : part.countWaitingFor,
            "dateAdded"             : DateManager.getStandardDateString(date: part.dateAdded),
            "dateModified"          : DateManager.getStandardDateString(date: part.dateModified),
            "removed"               : part.removed,
            "removedDate"           : DateManager.getStandardDateString(date: part.removedDate)
        ]
        
        let sql = """
            UPDATE \(tableName) SET
            
                \(COLUMNS.PART_ID)                =:partID,
                \(COLUMNS.PART_FINDER_ID)         =:partFinderId,
                \(COLUMNS.INVOICE_ID)             =:InvoiceId,
                \(COLUMNS.PRICE_TO_RESELL)        =:priceToResell,
                \(COLUMNS.QUANTITY)               =:quantity,
                \(COLUMNS.PART_LOCATION_ID)       =:partLocationId,
                \(COLUMNS.WHERE_PURCHASED)        =:wherePurchased,
                \(COLUMNS.WAITING_FOR_PART)       =:waitingForPart,
                \(COLUMNS.COUNT_WAITING_FOR)      =:countWaitingFor,
                \(COLUMNS.DATE_ADDED)             =:dateAdded,
                \(COLUMNS.DATE_MODIFIED)          =:dateModified,
                \(COLUMNS.REMOVED)                =:removed,
                \(COLUMNS.REMOVED_DATE)           =:removedDate,

            WHERE \(tableName).\(setIdKey()) = :partUsedId;
            """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,
                                     typeOfAction: .update, updatedId: UInt64(part.partUsedId!),
                                     success: { _ in
                                        success()
                                     },
                                     fail: failure)
    }
    
    func deletePartUsed(part: PartUsed, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = part.partUsedId else { return }
        softDelete(atId: id, success: success, fail: failure)
    }
    
    func restorePartUsed(part: PartUsed, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = part.partUsedId else { return }
        restoreItem(atId: id, success: success, fail: failure)
    }
    
    func fetchPartLocations(with id: Int,success: @escaping(_ parts: [PartLocation]) -> (), failure: @escaping(_ error: Error) -> ()){
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        var sql = """
        SELECT * FROM main.\(TABLES.PART_LOCATIONS) WHERE main.\(TABLES.PART_LOCATIONS).\(COLUMNS.PART_LOCATION_ID) IN
        ( SELECT main.\(TABLES.PART_LOCATIONS).\(COLUMNS.PART_LOCATION_ID) FROM main.\(TABLES.PART_FINDERS) WHERE \(COLUMNS.PART_ID) = \(id))
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            let partlocations = try queue.read({ (db) -> [PartLocation] in
                var partlocations: [PartLocation] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    partlocations.append(.init(row: row))
                }
                return partlocations
            })
            success(partlocations)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    
    func fetchPartVendors(with id: Int,success: @escaping(_ parts: [Vendor]) -> (), failure: @escaping(_ error: Error) -> ()){
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        var sql = """
        SELECT * FROM main.\(TABLES.VENDORS) WHERE main.\(TABLES.VENDORS).\(COLUMNS.VENDOR_ID) IN
        ( SELECT main.\(TABLES.VENDORS).\(COLUMNS.VENDOR_ID) FROM main.\(TABLES.PART_FINDERS) WHERE \(COLUMNS.PART_ID) = \(id))
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            let vendors = try queue.read({ (db) -> [Vendor] in
                var vendors: [Vendor] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    vendors.append(.init(row: row))
                }
                return vendors
            })
            success(vendors)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    func fetchPartFinder(with id: Int,success: @escaping(_ parts: [PartFinder]) -> (), failure: @escaping(_ error: Error) -> ()){
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        var sql = """
        SELECT * FROM main.\(TABLES.PART_FINDERS)
        WHERE ( \(COLUMNS.PART_FINDER_ID) = \(id) )
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            let parts = try queue.read({ (db) -> [PartFinder] in
                var parts: [PartFinder] = []
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
    
    func fetchFinder(part: PartFinder,success: @escaping(_ parts: PartFinder?) -> (), failure: @escaping(_ error: Error) -> ()){
        print(part)
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        let arguments: StatementArguments = [
            "partId"            : part.partID,
            "wherePurchased"    : part.vendorId,
            "partLocationId"    : part.partLocationId
        ]
        var sql = """
        SELECT * FROM main.\(TABLES.PART_FINDERS)
        
            WHERE (main.\(TABLES.PART_FINDERS).\(COLUMNS.PART_ID)           = :partId)
            AND (main.\(TABLES.PART_FINDERS).\(COLUMNS.WHERE_PURCHASED)     = :wherePurchased)
            AND (main.\(TABLES.PART_FINDERS).\(COLUMNS.PART_LOCATION_ID)    = :partLocationId)
            AND (main.\(TABLES.PART_FINDERS).\(COLUMNS.REMOVED) = 0 OR main.\(TABLES.PART_FINDERS).\(COLUMNS.REMOVED) is NULL);
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            let parts = try queue.read({ (db) -> [PartFinder] in
                var parts: [PartFinder] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: arguments)
                rows.forEach { (row) in
                    parts.append(.init(row: row))
                }
                return parts
            })
            success(parts.first)
        }
        catch {
            failure(error)
            print(error)
        }
    }
}
