//
//  PurchaseOrderUsedRepository.swift
//  MyProHelper
//
//  Created by sismac010 on 25/03/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import GRDB

class PurchaseOrderUsedRepository: BaseRepository {

    init() {
        super.init(table: .PURCHASE_ORDER_USED)
    }
    
    override func setIdKey() -> String {
        return COLUMNS.PURCHASE_ORDER_USED_ID
    }
    
    func addPurchaseOrderUsed(purchaseOrderUsed: PurchaseOrderUsed, success: @escaping (_ purchaseOrderUsedID: Int64)->(), failure: @escaping (_ error: Error)->()) {
        if let id = purchaseOrderUsed.purchaseOrderUsedId  {
            updatePurchaseOrderUsed(purchaseOrderUsed: purchaseOrderUsed) {
                success(Int64(id))
            } failure: { (error) in
                failure(error)
            }
            return
        }
        
        let arguments: StatementArguments = [
            "purchaseOrderId"       : purchaseOrderUsed.purchaseOrderId,
            "partId"                : purchaseOrderUsed.part?.partID ?? 0,
            "supplyId"              : purchaseOrderUsed.supply?.supplyId ?? 0,
            "nonStockable"          : purchaseOrderUsed.nonStockable,
            "vendorPartNumber"      : purchaseOrderUsed.vendorPartNumber,
            "quantity"              : purchaseOrderUsed.quantity,
            "pricePerItem"          : purchaseOrderUsed.pricePerItem,
            "amountOfLineItem"      : purchaseOrderUsed.amountOfLineItem,
            "samplePurchaseOrder"   : purchaseOrderUsed.samplePurchaseOrder,
            "dateReceived"          : DateManager.getStandardDateString(date: purchaseOrderUsed.dateReceived),
//            "salesTax"              : purchaseOrderUsed.salesTax,
//            "shipping"              : purchaseOrderUsed.shipping,
//            "orderedDate"           : DateManager.getStandardDateString(date: purchaseOrderUsed.orderedDate),
            "removed"               : purchaseOrderUsed.removed,
            "removedDate"           : DateManager.getStandardDateString(date: purchaseOrderUsed.removedDate),
            "numberOfAttachments"   : purchaseOrderUsed.numberOfAttachments
            
        ]
        let sql = """
            INSERT INTO chg.\(tableName) (
                \(COLUMNS.PURCHASE_ORDER_ID),
                \(COLUMNS.PART_ID),
                \(COLUMNS.SUPPLY_ID),
                \(COLUMNS.NON_STOCKABLE),
                \(COLUMNS.VENDOR_PART_NUMBER),
                \(COLUMNS.QUANTITY),
                \(COLUMNS.PRICE_PER_ITEM),
                \(COLUMNS.AMOUNT_OF_LINE_ITEM),
                \(COLUMNS.SAMPLE_PURCHASE_ORDER),
                \(COLUMNS.DATE_RECEIVED),
                \(COLUMNS.REMOVED),
                \(COLUMNS.REMOVED_DATE),
                \(COLUMNS.NUMBER_OF_ATTACHMENTS))

            VALUES (:purchaseOrderId,
                    :partId,
                    :supplyId,
                    :nonStockable,
                    :vendorPartNumber,
                    :quantity,
                    :pricePerItem,
                    :amountOfLineItem,
                    :samplePurchaseOrder,
                    :dateReceived,
                    :removed,
                    :removedDate,
                    :numberOfAttachments)
            """
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments
                                     ,typeOfAction: .insert, updatedId: nil,
                                     success: { id in
                                        success(id)
                                     },
                                     fail: failure)
    }
    
    func updatePurchaseOrderUsed(purchaseOrderUsed: PurchaseOrderUsed, success: @escaping ()->(), failure: @escaping (_ error: Error)->()) {
        let arguments: StatementArguments = [
            "id"                    : purchaseOrderUsed.purchaseOrderUsedId,
            "purchaseOrderId"       : purchaseOrderUsed.purchaseOrderId,
            "partId"                : purchaseOrderUsed.part?.partID ?? 0,
            "supplyId"              : purchaseOrderUsed.supply?.supplyId ?? 0,
            "nonStockable"          : purchaseOrderUsed.nonStockable,
            "vendorPartNumber"      : purchaseOrderUsed.vendorPartNumber,
            "quantity"              : purchaseOrderUsed.quantity,
            "pricePerItem"          : purchaseOrderUsed.pricePerItem,
            "amountOfLineItem"      : purchaseOrderUsed.amountOfLineItem,
            "samplePurchaseOrder"   : purchaseOrderUsed.samplePurchaseOrder,
            "dateReceived"          : DateManager.getStandardDateString(date: purchaseOrderUsed.dateReceived),
//            "salesTax"              : purchaseOrderUsed.salesTax,
//            "shipping"              : purchaseOrderUsed.shipping,
//            "orderedDate"           : DateManager.getStandardDateString(date: purchaseOrderUsed.orderedDate),
            "removed"               : purchaseOrderUsed.removed,
            "removedDate"           : DateManager.getStandardDateString(date: purchaseOrderUsed.removedDate),
            "numberOfAttachments"   : purchaseOrderUsed.numberOfAttachments
        ]
        let sql = """
            UPDATE \(tableName) SET
                \(COLUMNS.PURCHASE_ORDER_ID)    = :purchaseOrderId,
                \(COLUMNS.PART_ID)              = :partId,
                \(COLUMNS.SUPPLY_ID)            = :supplyId,
                \(COLUMNS.NON_STOCKABLE)        = :nonStockable,
                \(COLUMNS.VENDOR_PART_NUMBER)   = :vendorPartNumber,
                \(COLUMNS.QUANTITY)             = :quantity,
                \(COLUMNS.PRICE_PER_ITEM)       = :pricePerItem,
                \(COLUMNS.AMOUNT_OF_LINE_ITEM)  = :amountOfLineItem,
                \(COLUMNS.SAMPLE_PURCHASE_ORDER)= :samplePurchaseOrder,
                \(COLUMNS.DATE_RECEIVED)        = :dateReceived,
                \(COLUMNS.REMOVED)              = :removed,
                \(COLUMNS.REMOVED_DATE)         = :removedDate,
                \(COLUMNS.NUMBER_OF_ATTACHMENTS)= :numberOfAttachments
            WHERE \(tableName).\(setIdKey())    = :id;
            """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,
                                     typeOfAction: .update, updatedId: UInt64(purchaseOrderUsed.purchaseOrderUsedId ?? 0),
                                     success: { _ in
                                        success()
                                     },
                                     fail: failure)
    }
    
    func fetchPurchaseOrderUsed(purchaseOrderID: Int? = nil, showRemoved: Bool, offset: Int, success: @escaping(_ stocks: [PurchaseOrderUsed]) -> (), failure: @escaping(_ error: Error) -> ()) {
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
//        SELECT * FROM \(tableName)
//        LEFT JOIN \(TABLES.PARTS) ON \(tableName).\(COLUMNS.PART_ID) == \(TABLES.PARTS).\(COLUMNS.PART_ID)
//        LEFT JOIN \(TABLES.SUPPLIES) ON \(tableName).\(COLUMNS.SUPPLY_ID) == \(TABLES.SUPPLIES).\(COLUMNS.SUPPLY_ID)
//        WHERE (\(tableName).\(RepositoryConstants.Columns.REMOVED) = 0
//                OR \(tableName).\(RepositoryConstants.Columns.REMOVED) is NULL)
//        """
        
        var sql = """
        SELECT * FROM main.\(tableName)
        LEFT JOIN main.\(TABLES.PARTS) ON main.\(tableName).\(COLUMNS.PART_ID) == main.\(TABLES.PARTS).\(COLUMNS.PART_ID)
        LEFT JOIN main.\(TABLES.SUPPLIES) ON main.\(tableName).\(COLUMNS.SUPPLY_ID) == main.\(TABLES.SUPPLIES).\(COLUMNS.SUPPLY_ID)
            \(condition)
        """
        if let purchaseOrderID = purchaseOrderID {
            arguments = [purchaseOrderID]
            sql += " AND main.\(tableName).\(COLUMNS.PURCHASE_ORDER_ID) = ?"
            arguments += [purchaseOrderID] // Only for using 'uniun' below
        }
        
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        
        
        do {
            let lineItems = try queue.read({ (db) -> [PurchaseOrderUsed] in
                var lineItems: [PurchaseOrderUsed] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: arguments)
                rows.forEach { (row) in
                    lineItems.append(.init(row: row))
                }
                return lineItems
            })
            success(lineItems)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    func fetchMaxPurchaseOrderUsedID(_ success: @escaping(_ ID: Int) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        let sql = """
        SELECT max(\(COLUMNS.PURCHASE_ORDER_USED_ID)) AS LineItemID FROM \(tableName)
        """
        do {
            let lineItem = try queue.read({ (db) -> PurchaseOrderUsed? in
                var lineItem: PurchaseOrderUsed?
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    lineItem = .init(row: row)
                }
                return lineItem
            })
            success(lineItem?.lineItemId ?? 0)
        }
        catch {
            failure(error)
            print(error)
        }
    }

    func deletePurchaseOrderUsed(purchaseOrderUsed: PurchaseOrderUsed, success: @escaping ()->(), failure: @escaping (_ error: Error)->()) {
        guard let id = purchaseOrderUsed.purchaseOrderUsedId else { return }
        softDelete(atId: id, success: success, fail: failure)
    }
    
    func undeletePurchaseOrderUsed(purchaseOrderUsed: PurchaseOrderUsed, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = purchaseOrderUsed.purchaseOrderUsedId else {return}
        restoreItem(atId: id, success: success, fail: failure)
    }
    
}

