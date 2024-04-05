//
//  SupplyFinderRepository.swift
//  MyProHelper
//
//  Created by sismac010 on 10/03/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import GRDB

class SupplyFinderRepository: BaseRepository {
 
    init() {
        super.init(table: .SUPPLY_FINDERS)
//        createSelectedLayoutTable()
    }
    
    override func setIdKey() -> String {
        return COLUMNS.SUPPLY_FINDER_ID
    }
    
    func addStock(stock: SupplyFinder, success: @escaping (_ stockID: Int64)->(), failure: @escaping (_ error: Error)->()) {
        if let id = stock.supplyFinderId  {
            updateStock(stock: stock) {
                success(Int64(id))
            } failure: { (error) in
                failure(error)
            }
            return
        }
        let arguments: StatementArguments = [
            "supplyId"          : stock.supplyId,
            "supplyLocationID"  : stock.supplyLocation?.supplyLocationID,
            "quantity"          : stock.quantity,
            "wherePurchased"    : stock.wherePurchased?.vendorID,
            "lastPurchased"     : DateManager.getStandardDateString(date: stock.lastPurchased),
            "pricePaid"         : stock.pricePaid,
            "priceToResell"     : stock.priceToResell,
            "removed"           : stock.removed,
            "removedDate"       : DateManager.getStandardDateString(date: stock.removedDate)
        ]
        let sql = """
            INSERT INTO chg.\(tableName) (
                \(COLUMNS.SUPPLY_ID),
                \(COLUMNS.SUPPLY_LOCATION_ID),
                \(COLUMNS.QUANTITY),
                \(COLUMNS.WHERE_PURCHASED),
                \(COLUMNS.LAST_PURHCASED),
                \(COLUMNS.PRICE_PAID),
                \(COLUMNS.PRICE_TO_RESELL),
                \(COLUMNS.REMOVED),
                \(COLUMNS.REMOVED_DATE))

            VALUES (:supplyId,
                    :supplyLocationID,
                    :quantity,
                    :wherePurchased,
                    :lastPurchased,
                    :pricePaid,
                    :priceToResell,
                    :removed,
                    :removedDate)
            """
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,
                                     typeOfAction: .insert, updatedId: nil,
                                     success: { id in
                                        success(id)
                                     },
                                     fail: failure)
    }
    
    func updateStock(stock: SupplyFinder, success: @escaping ()->(), failure: @escaping (_ error: Error)->()) {
        let arguments: StatementArguments = [
            "id"                : stock.supplyFinderId,
            "supplyId"          : stock.supplyId,
            "supplyLocationID"  : stock.supplyLocation?.supplyLocationID,
            "quantity"          : stock.quantity,
            "wherePurchased"    : stock.wherePurchased?.vendorID,
            "lastPurchased"     : DateManager.getStandardDateString(date: stock.lastPurchased),
            "pricePaid"         : stock.pricePaid,
            "priceToResell"     : stock.priceToResell,
            "removed"           : stock.removed,
            "removedDate"       : DateManager.getStandardDateString(date: stock.removedDate)
        ]
        let sql = """
            UPDATE \(tableName) SET
                \(COLUMNS.SUPPLY_ID)            = :supplyId,
                \(COLUMNS.SUPPLY_LOCATION_ID)   = :supplyLocationID,
                \(COLUMNS.QUANTITY)             = :quantity,
                \(COLUMNS.WHERE_PURCHASED)      = :wherePurchased,
                \(COLUMNS.LAST_PURHCASED)       = :lastPurchased,
                \(COLUMNS.PRICE_PAID)           = :pricePaid,
                \(COLUMNS.PRICE_TO_RESELL)      = :priceToResell,
                \(COLUMNS.REMOVED)              = :removed,
                \(COLUMNS.REMOVED_DATE)         = :removedDate
            WHERE \(tableName).\(setIdKey()) = :id;
            """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,
                                     typeOfAction: .update, updatedId: UInt64(stock.supplyFinderId!),
                                     success: { _ in
                                        success()
                                     },
                                     fail: failure)
    }

    func deleteStock(stock: SupplyFinder, success: @escaping ()->(), failure: @escaping (_ error: Error)->()) {
        guard let id = stock.supplyFinderId else { return }
        softDelete(atId: id, success: success, fail: failure)
    }
    
    func undeleteStock(stock: SupplyFinder, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = stock.supplyFinderId else {return}
        restoreItem(atId: id, success: success, fail: failure)
    }
    
    func updateQuantity(stock: SupplyFinder, quantity: Int, success: @escaping (_ isUpdated: Bool)->(), failure: @escaping (_ error: Error)->()) {
        let arguments: StatementArguments = [
            "supplyLocationId"  : stock.supplyLocation?.supplyLocationID,
            "quantity"          : quantity,
            "wherePurchased"    : stock.wherePurchased?.vendorID,
            "pricePaid"         : stock.pricePaid,
            "priceToResell"     : stock.priceToResell
        ]
        let sql = """
            UPDATE \(tableName) SET \(COLUMNS.QUANTITY) = \(COLUMNS.QUANTITY) + :quantity
            WHERE (\(tableName).\(COLUMNS.PRICE_PAID)        = :pricePaid)
            AND (\(tableName).\(COLUMNS.PRICE_TO_RESELL)     = :priceToResell)
            AND (\(tableName).\(COLUMNS.WHERE_PURCHASED)     = :wherePurchased)
            AND (\(tableName).\(COLUMNS.SUPPLY_LOCATION_ID)  = :supplyLocationId)
            AND (\(tableName).\(COLUMNS.REMOVED) = 0 OR \(tableName).\(COLUMNS.REMOVED) is NULL);
            """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,
                                     typeOfAction: .update, updatedId: UInt64(stock.pricePaid!),
                                     success: { [weak self] id in
                                        guard let self = self else { return }
                                        self.checkIfExists(stock: stock,
                                                           success: success,
                                                           failure: failure)
                                     },
                                     fail: failure)
    }
    
    func checkIfExists(stock: SupplyFinder,success: @escaping (_ isExists: Bool) -> (), failure: @escaping (_ error: Error)->()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        let arguments: StatementArguments = [
            "supplyLocationId"    : stock.supplyLocation?.supplyLocationID,
            "wherePurchased"    : stock.wherePurchased?.vendorID,
            "pricePaid"         : stock.pricePaid,
            "priceToResell"     : stock.priceToResell
        ]
        var sql = """
        SELECT 1 FROM main.\(tableName)
            WHERE (main.\(tableName).\(COLUMNS.PRICE_PAID)        = :pricePaid)
            AND (main.\(tableName).\(COLUMNS.PRICE_TO_RESELL)     = :priceToResell)
            AND (main.\(tableName).\(COLUMNS.WHERE_PURCHASED)     = :wherePurchased)
            AND (main.\(tableName).\(COLUMNS.SUPPLY_LOCATION_ID)    = :supplyLocationId)
            AND (main.\(tableName).\(COLUMNS.REMOVED) = 0 OR main.\(tableName).\(COLUMNS.REMOVED) is NULL);
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            let isExists = try queue.read({ (db) -> Bool in
                if let _ = try Row.fetchOne(db,
                                              sql: sql,
                                              arguments: arguments) {
                    return true
                }
                return false
            })
            success(isExists)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    func fetchStock(stockSupplyID: Int? = nil, showRemoved: Bool, offset: Int, success: @escaping(_ stocks: [SupplyFinder]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        var arguments: StatementArguments = []
        let searchable = ""
        let removedCondition = """
                WHERE (main.\(tableName).\(COLUMNS.REMOVED) = 0
                OR main.\(tableName).\(COLUMNS.REMOVED) is NULL)
            """
        
        let showRemovedCondition = """
                WHERE (main.\(tableName).\(RepositoryConstants.Columns.REMOVED) = 1)
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
        
//        var sql2 = """
//        SELECT * FROM main.\(tableName)
//        LEFT JOIN main.\(TABLES.VENDORS) ON main.\(tableName).\(COLUMNS.WHERE_PURCHASED) == main.\(TABLES.VENDORS).\(COLUMNS.VENDOR_ID)
//        LEFT JOIN main.\(TABLES.SUPPLY_LOCATIONS) ON main.\(tableName).\(COLUMNS.SUPPLY_LOCATION_ID) == main.\(TABLES.SUPPLY_LOCATIONS).\(COLUMNS.SUPPLY_LOCATION_ID)
//        WHERE (main.\(tableName).\(RepositoryConstants.Columns.REMOVED) = 0
//                OR main.\(tableName).\(RepositoryConstants.Columns.REMOVED) is NULL)
//        """
        
        var sql = """
        SELECT * FROM main.\(tableName)
        LEFT JOIN main.\(TABLES.VENDORS) ON main.\(tableName).\(COLUMNS.WHERE_PURCHASED) == main.\(TABLES.VENDORS).\(COLUMNS.VENDOR_ID)
        LEFT JOIN main.\(TABLES.SUPPLY_LOCATIONS) ON main.\(tableName).\(COLUMNS.SUPPLY_LOCATION_ID) == main.\(TABLES.SUPPLY_LOCATIONS).\(COLUMNS.SUPPLY_LOCATION_ID)
            \(condition)
        """
        
        
        if let stockSupplyID = stockSupplyID {
            arguments = [stockSupplyID]
            sql += " AND main.\(tableName).\(COLUMNS.SUPPLY_ID) = ?"
//            sql += " WHERE \(tableName).\(COLUMNS.SUPPLY_ID) = ?;"
            arguments += [stockSupplyID] // Only for using 'uniun' below
        }
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            let stocks = try queue.read({ (db) -> [SupplyFinder] in
                var stocks: [SupplyFinder] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: arguments)
                rows.forEach { (row) in
                    stocks.append(.init(row: row))
                }
                return stocks
            })
            success(stocks)
        }
        catch {
            failure(error)
            print(error)
        }
    }

}
