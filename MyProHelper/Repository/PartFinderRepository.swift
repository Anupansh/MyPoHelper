//
//  PartFinderRepository.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 11/2/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import GRDB

class PartFinderRepository: BaseRepository {
    
    init() {
        super.init(table: .PART_FINDERS)
        createSelectedLayoutTable()
    }
 
    override func setIdKey() -> String {
        return COLUMNS.PART_FINDER_ID
    }
    
    private func createSelectedLayoutTable() {
        let sql = """
            CREATE TABLE IF NOT EXISTS \(tableName)(
                \(COLUMNS.PART_FINDER_ID) INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL,
                \(COLUMNS.PART_ID) INTEGER REFERENCES PARTS(PartID) NOT NULL,
                \(COLUMNS.PART_LOCATION_ID)     INTEGER REFERENCES PartLocations (PartLocationID) NOT NULL,
                \(COLUMNS.QUANTITY)             INTEGER,
                \(COLUMNS.WHERE_PURCHASED)      INTEGER REFERENCES Vendors(VendorID),
                \(COLUMNS.LAST_PURHCASED)       TEXT,
                \(COLUMNS.PRICE_PAID)           REAL,
                \(COLUMNS.PRICE_TO_RESELL)      REAL,
                \(COLUMNS.SAMPLE_PART_FINDER)   INTEGER DEFAULT(0),
                \(COLUMNS.REMOVED)              INTEGER DEFAULT(0),
                \(COLUMNS.REMOVED_DATE)         TEXT
            )
        """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                      arguments: [],typeOfAction: .create, updatedId: nil) { (_) in
            print("TABLE PART_FINDERS IS CREATED SUCCESSFULLY")
        } fail: { (error) in
            print(error)
        }
    }
    
    func addStock(stock: PartFinder, success: @escaping (_ stockID: Int64)->(), failure: @escaping (_ error: Error)->()) {
        if let id = stock.partFinderId  {
            updateStock(stock: stock) {
                success(Int64(id))
            } failure: { (error) in
                failure(error)
            }
            return
        }
        let arguments: StatementArguments = [
            "partId"            : stock.partID,
            "partLocationId"    : stock.partLocation?.partLocationID,
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
                \(COLUMNS.PART_ID),
                \(COLUMNS.PART_LOCATION_ID),
                \(COLUMNS.QUANTITY),
                \(COLUMNS.WHERE_PURCHASED),
                \(COLUMNS.LAST_PURHCASED),
                \(COLUMNS.PRICE_PAID),
                \(COLUMNS.PRICE_TO_RESELL),
                \(COLUMNS.REMOVED),
                \(COLUMNS.REMOVED_DATE))

            VALUES (:partId,
                    :partLocationId,
                    :quantity,
                    :wherePurchased,
                    :lastPurchased,
                    :pricePaid,
                    :priceToResell,
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
    
    func updateStock(stock: PartFinder, success: @escaping ()->(), failure: @escaping (_ error: Error)->()) {
        let arguments: StatementArguments = [
            "id"                : stock.partFinderId,
            "partId"            : stock.partID,
            "partLocationId"    : stock.partLocation?.partLocationID,
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
                \(COLUMNS.PART_ID)              = :partId,
                \(COLUMNS.PART_LOCATION_ID)     = :partLocationId,
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
                                     typeOfAction: .update, updatedId: UInt64(stock.partFinderId!),
                                     success: { _ in
                                        success()
                                     },
                                     fail: failure)
    }
    
    func deleteStock(stock: PartFinder, success: @escaping ()->(), failure: @escaping (_ error: Error)->()) {
        guard let id = stock.partFinderId else { return }
        softDelete(atId: id, success: success, fail: failure)
    }
    
    func updateQuantity(stock: PartFinder, quantity: Int, success: @escaping (_ isUpdated: Bool)->(), failure: @escaping (_ error: Error)->()) {
        let arguments: StatementArguments = [
            "partLocationId"    : stock.partLocation?.partLocationID,
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
            AND (\(tableName).\(COLUMNS.PART_LOCATION_ID)    = :partLocationId)
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
    
    func checkIfExists(stock: PartFinder,success: @escaping (_ isExists: Bool) -> (), failure: @escaping (_ error: Error)->()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        let arguments: StatementArguments = [
            "partLocationId"    : stock.partLocation?.partLocationID,
            "wherePurchased"    : stock.wherePurchased?.vendorID,
            "pricePaid"         : stock.pricePaid,
            "priceToResell"     : stock.priceToResell
        ]
        let sql = """
        SELECT 1 FROM \(tableName)
            WHERE (\(tableName).\(COLUMNS.PRICE_PAID)        = :pricePaid)
            AND (\(tableName).\(COLUMNS.PRICE_TO_RESELL)     = :priceToResell)
            AND (\(tableName).\(COLUMNS.WHERE_PURCHASED)     = :wherePurchased)
            AND (\(tableName).\(COLUMNS.PART_LOCATION_ID)    = :partLocationId)
            AND (\(tableName).\(COLUMNS.REMOVED) = 0 OR \(tableName).\(COLUMNS.REMOVED) is NULL);
        """
        
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
    
    func fetchStock(stockPartID: Int? = nil, offset: Int, success: @escaping(_ stocks: [PartFinder]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        var arguments: StatementArguments = []
        var sql = """
        SELECT * FROM main.\(tableName)
        LEFT JOIN main.\(TABLES.VENDORS) ON main.\(tableName).\(COLUMNS.WHERE_PURCHASED) == main.\(TABLES.VENDORS).\(COLUMNS.VENDOR_ID)
        LEFT JOIN main.\(TABLES.PART_LOCATIONS) ON main.\(tableName).\(COLUMNS.PART_LOCATION_ID) == main.\(TABLES.PART_LOCATIONS).\(COLUMNS.PART_LOCATION_ID)
        WHERE (main.\(tableName).\(RepositoryConstants.Columns.REMOVED) = 0
                OR main.\(tableName).\(RepositoryConstants.Columns.REMOVED) is NULL)
        """
        if let stockPartId = stockPartID {
            arguments = [stockPartId]
            sql += " AND main.\(tableName).\(COLUMNS.PART_ID) = ?"
            arguments += [stockPartId] // Only for using 'uniun' below
        }
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        
        do {
            let stocks = try queue.read({ (db) -> [PartFinder] in
                var stocks: [PartFinder] = []
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

