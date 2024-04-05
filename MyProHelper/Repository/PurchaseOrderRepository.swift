//
//  PurchaseOrderRepository.swift
//  MyProHelper
//
//  Created by sismac010 on 22/03/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import GRDB

class PurchaseOrderRepository: BaseRepository {
    
    init() {
        super.init(table: .PURCHASE_ORDER)
    }
    
    
    override func setIdKey() -> String {
        return COLUMNS.PURCHASE_ORDER_ID
    }
    
    func insertPurchaseOrder(purchaseOrder: PurchaseOrder, success: @escaping(_ purchaseOrderID: Int64) -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "enteredDate"            : DateManager.getStandardDateString(date: purchaseOrder.enteredDate),
            "orderedDate"           : DateManager.getStandardDateString(date: purchaseOrder.orderedDate),
            "vendorID"               : purchaseOrder.vendorId,
            "salesTax"               : purchaseOrder.salesTax,
            "shipping"               : purchaseOrder.shipping,
            "expectedDate"           : DateManager.getStandardDateString(date: purchaseOrder.expectedDate),
            "removed"               : purchaseOrder.removed,
            "removedDate"           : DateManager.getStandardDateString(date: purchaseOrder.removedDate),
            "numberOfAttachments"   : purchaseOrder.numberOfAttachments
            
        ]
        let sql = """
            INSERT INTO chg.\(tableName) (
                \(COLUMNS.ENTERED_DATE),
                \(COLUMNS.ORDERED_DATE),
                \(COLUMNS.VENDOR_ID),
                \(COLUMNS.SALES_TAX),
                \(COLUMNS.SHIPPING),
                \(COLUMNS.EXPECTED_DATE),
                \(COLUMNS.REMOVED),
                \(COLUMNS.REMOVED_DATE),
                \(COLUMNS.NUMBER_OF_ATTACHMENTS))

            VALUES (:enteredDate,
                    :orderedDate,
                    :vendorID,
                    :salesTax,
                    :shipping,
                    :expectedDate,
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
    
    func update(purchaseOrder: PurchaseOrder, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "id"                    : purchaseOrder.purchaseOrderId,
            "enteredDate"           : DateManager.getStandardDateString(date: purchaseOrder.enteredDate),
            "orderedDate"           : DateManager.getStandardDateString(date: purchaseOrder.orderedDate),
            "vendorID"              : purchaseOrder.vendorId,
            "salesTax"              : purchaseOrder.salesTax,
            "shipping"              : purchaseOrder.shipping,
            "expectedDate"          : DateManager.getStandardDateString(date: purchaseOrder.expectedDate),
            "removed"               : purchaseOrder.removed,
            "removedDate"           : DateManager.getStandardDateString(date: purchaseOrder.removedDate),
            "numberOfAttachments"   : purchaseOrder.numberOfAttachments,
            "status"                : purchaseOrder.status,
            "approvedBy"            : purchaseOrder.approvedBy,
            "approvedDate"          : DateManager.getStandardDateString(date: purchaseOrder.dateApproved)
        ]
        let sql = """
            UPDATE \(tableName) SET
                \(COLUMNS.ENTERED_DATE)             = :enteredDate,
                \(COLUMNS.ORDERED_DATE)             = :orderedDate,
                \(COLUMNS.VENDOR_ID)                = :vendorID,
                \(COLUMNS.SALES_TAX)                = :salesTax,
                \(COLUMNS.SHIPPING)                 = :shipping,
                \(COLUMNS.EXPECTED_DATE)            = :expectedDate,
                \(COLUMNS.REMOVED)                  = :removed,
                \(COLUMNS.REMOVED_DATE)             = :removedDate,
                \(COLUMNS.NUMBER_OF_ATTACHMENTS)    = :numberOfAttachments,
                \(COLUMNS.STATUS)                   = :status,
                \(COLUMNS.APPROVED_BY)              = :approvedBy,
                \(COLUMNS.APPROVED_DATE)            = :approvedDate
            WHERE \(tableName).\(setIdKey()) = :id;
            """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,
                                     typeOfAction: .update, updatedId: UInt64(purchaseOrder.purchaseOrderId!),
                                     success: { _ in
                                        success()
                                     },
                                     fail: failure)
    }
    
    func Edit(purchaseOrder: PurchaseOrder, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "id"                    : purchaseOrder.purchaseOrderId,
            "salesTax"              : purchaseOrder.salesTax,
            "shipping"              : purchaseOrder.shipping,
            "enteredDate"           : DateManager.getStandardDateString(date: purchaseOrder.enteredDate),
            "orderedDate"           : purchaseOrder.orderedDate,
            "status"                : purchaseOrder.status,
            "vendorID"              : purchaseOrder.vendorId,
            "approveBy"              :purchaseOrder.approvedBy,
            "approveDate"            :DateManager.getStandardDateString(date: purchaseOrder.expectedDate),
            "samplePurchaseOrder" :purchaseOrder.samplePurchaseOrder,
            "expectedDate"          : purchaseOrder.expectedDate,
            "dateRecived"          : purchaseOrder.dateReceived,
            "removed"               : purchaseOrder.removed,
            "removedDate"           :purchaseOrder.removedDate,
            "numberOfAttachments"   : purchaseOrder.numberOfAttachments
            
        ]
        let sql = """
            UPDATE \(tableName) SET
               \(COLUMNS.SALES_TAX)                 = :salesTax,
               \(COLUMNS.SHIPPING)                  = :shipping,
                \(COLUMNS.ENTERED_DATE)             = :enteredDate,
                \(COLUMNS.ORDERED_DATE)             = :orderedDate,
                \(COLUMNS.STATUS)                   = :status,
                \(COLUMNS.VENDOR_ID)                = :vendorID,
                \(COLUMNS.APPROVED_BY)              = :approveBy,
                \(COLUMNS.DATE_APPROVED)              = :approveDate,
                \(COLUMNS.SAMPLE_PURCHASE_ORDER)    = :samplePurchaseOrder,
                \(COLUMNS.EXPECTED_DATE)            = :expectedDate,
                \(COLUMNS.DATE_RECEIVED)            = :dateRecived,
                \(COLUMNS.REMOVED)                  = :removed,
                \(COLUMNS.REMOVED_DATE)             = :removedDate,
                \(COLUMNS.NUMBER_OF_ATTACHMENTS)    = :numberOfAttachments
            WHERE \(tableName).\(setIdKey()) = :id
            """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,
                                    typeOfAction: .update, updatedId: UInt64(purchaseOrder.purchaseOrderId!),
                                     success: { _ in
                                        success()
                                     },
                                     fail: failure)
    }
    
    func removePurchaseOrder(purchaseOrder: PurchaseOrder, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = purchaseOrder.purchaseOrderId else {
                return
        }
        softDelete(atId: id, success: success, fail: failure)
    }
    
    func unremovePurchaseOrder(purchaseOrder: PurchaseOrder, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = purchaseOrder.purchaseOrderId else {
                return
        }
        restoreItem(atId: id, success: success, fail: failure)
    }
    
    func fetchPurchaseOrders(showRemoved: Bool, with key: String? = nil, sortBy: PurchaseOrderField? = nil , sortType: SortType? = nil ,offset: Int,success: @escaping(_ supplies: [PurchaseOrder]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
//        let sortable = ""//makeSortableItems(sortBy: sortBy, sortType: sortType)
        let sortable = ""//makeSortableItems(sortBy: sortBy, sortType: sortType)
        let searchable = makeSearchableItems(key: key)
        
        let removedCondition = """
                WHERE (main.\(tableName).\(COLUMNS.REMOVED) = 0
                OR main.\(tableName).\(COLUMNS.REMOVED) is NULL)
                AND (main.\(TABLES.PURCHASE_ORDERS_Used).\(COLUMNS.REMOVED) = 0
                OR main.\(TABLES.PURCHASE_ORDERS_Used).\(COLUMNS.REMOVED) is NULL)
                """
        let showRemovedCondition = """
                WHERE (\(tableName).\(COLUMNS.REMOVED) = 1)
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
        JOIN main.\(TABLES.PURCHASE_ORDERS_Used) ON main.\(tableName).\(COLUMNS.PURCHASE_ORDER_ID) == main.\(TABLES.PURCHASE_ORDERS_Used).\(COLUMNS.PURCHASE_ORDER_ID)
        JOIN main.\(TABLES.PARTS) ON main.\(TABLES.PURCHASE_ORDERS_Used).\(COLUMNS.PART_ID) == main.\(TABLES.PARTS).\(COLUMNS.PART_ID)
        JOIN main.\(TABLES.SUPPLIES) ON main.\(TABLES.PURCHASE_ORDERS_Used).\(COLUMNS.SUPPLY_ID) == main.\(TABLES.SUPPLIES).\(COLUMNS.SUPPLY_ID)
        JOIN main.\(TABLES.VENDORS) ON main.\(TABLES.PURCHASE_ORDERS).\(COLUMNS.VENDOR_ID) == main.\(TABLES.VENDORS).\(COLUMNS.VENDOR_ID)
        \(condition)
        GROUP BY main."\(TABLES.PURCHASE_ORDERS_Used)"."\(COLUMNS.PURCHASE_ORDER_ID)"
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        sql += """
                \(sortable.replaceMain())
        """
        do {
            let purchaseOrders = try queue.read({ (db) -> [PurchaseOrder] in
                var purchaseOrders: [PurchaseOrder] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    purchaseOrders.append(.init(row: row))
                }
    
                return purchaseOrders
            })
            success(purchaseOrders)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    private func makeSortableItems(sortBy: PurchaseOrderField?, sortType: SortType?) -> String {
        guard let sortBy = sortBy, let sortType = sortType else {
            return makeSortableCondition(key: COLUMNS.VENDOR_NAME, sortType: .ASCENDING)
        }
        switch sortBy {
        case .VENDOR_NAME:
            return makeSortableCondition(key: COLUMNS.VENDOR_NAME, sortType: sortType)
        case .SALE_TAX:
            return makeSortableCondition(key: COLUMNS.SALES_TAX, sortType: sortType)
        case .SHIPPING:
            return makeSortableCondition(key: COLUMNS.SHIPPING, sortType: sortType)
        case .TOTAL_AMOUNT:
            return makeSortableCondition(key: COLUMNS.AMOUNT_OF_LINE_ITEM, sortType: sortType)
        case .ATTACHMENTS:
            return makeSortableCondition(key: COLUMNS.NUMBER_OF_ATTACHMENTS, sortType: sortType)
        case .EXPECTED_DATE:
            return makeSortableCondition(key: COLUMNS.EXPECTED_DATE, sortType: sortType)
        case .ORDERED_DATE:
            return makeSortableCondition(key: COLUMNS.ORDERED_DATE, sortType: sortType)
        }
    }
    
    private func makeSearchableItems(key: String?) -> String {
        guard let key = key else { return "" }
        return makeSearchableCondition(key: key,
                                       fields: [
                                        COLUMNS.VENDOR_NAME,
                                        "main.\(tableName).\(COLUMNS.SALES_TAX)",
                                        "main.\(tableName).\(COLUMNS.SHIPPING)",
                                        COLUMNS.AMOUNT_OF_LINE_ITEM,
                                        "main.\(tableName).\(COLUMNS.NUMBER_OF_ATTACHMENTS)",
                                        COLUMNS.EXPECTED_DATE,
                                        "main.\(tableName).\(COLUMNS.ORDERED_DATE)"])
    }
    
    
}

