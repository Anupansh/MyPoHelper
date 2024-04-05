//
//  WorkOrderUsedRepository.swift
//  MyProHelper
//
//  Created by sismac010 on 12/04/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

import GRDB

class WorkOrderUsedRepository: BaseRepository {

    init() {
        super.init(table: .WORK_ORDER_USED)
    }
    
    override func setIdKey() -> String {
        return COLUMNS.WORK_ORDER_USED_ID
    }

    func addWorkOrderUsed(workOrderUsed: WorkOrderUsed, success: @escaping (_ workOrderUsedID: Int64)->(), failure: @escaping (_ error: Error)->()) {
        if let id = workOrderUsed.workOrderUsedId  {
            updateWorkOrderUsed(workOrderUsed: workOrderUsed) {
                success(Int64(id))
            } failure: { (error) in
                failure(error)
            }
            return
        }
        
        let arguments: StatementArguments = [
            "workOrderId"           : workOrderUsed.workOrderId,
            "partId"                : workOrderUsed.part?.partID ?? 0,
            "supplyId"              : workOrderUsed.supply?.supplyId ?? 0,
            "nonStockable"          : workOrderUsed.nonStockable,
            "vendorPartNumber"      : workOrderUsed.vendorPartNumber,
            "quantity"              : workOrderUsed.quantity,
            "pricePerItem"          : workOrderUsed.pricePerItem,
            "amountOfLineItem"      : workOrderUsed.amountOfLineItem,
            "dateCreated"           : DateManager.getStandardDateString(date: workOrderUsed.dateCreated),
            "dateModified"          : DateManager.getStandardDateString(date: workOrderUsed.dateModified),
            "removed"               : workOrderUsed.removed ?? 0,
            "removedDate"           : DateManager.getStandardDateString(date: workOrderUsed.removedDate)
        ]
        let sql = """
            INSERT INTO chg.\(tableName) (
                \(COLUMNS.WORK_ORDER_ID),
                \(COLUMNS.PART_ID),
                \(COLUMNS.SUPPLY_ID),
                \(COLUMNS.NON_STOCKABLE),
                \(COLUMNS.VENDOR_PART_NUMBER),
                \(COLUMNS.QUANTITY),
                \(COLUMNS.PRICE_PER_ITEM),
                \(COLUMNS.AMOUNT_OF_LINE_ITEM),
                \(COLUMNS.DATE_CREATED),
                \(COLUMNS.DATE_MODIFIED),
                \(COLUMNS.REMOVED),
                \(COLUMNS.REMOVED_DATE))

            VALUES (:workOrderId,
                    :partId,
                    :supplyId,
                    :nonStockable,
                    :vendorPartNumber,
                    :quantity,
                    :pricePerItem,
                    :amountOfLineItem,
                    :dateCreated,
                    :dateModified,
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
    
    func updateWorkOrderUsed(workOrderUsed: WorkOrderUsed, success: @escaping ()->(), failure: @escaping (_ error: Error)->()) {
        let arguments: StatementArguments = [
            "id"                    : workOrderUsed.workOrderUsedId,
            "workOrderId"           : workOrderUsed.workOrderId,
            "partId"                : workOrderUsed.part?.partID ?? 0,
            "supplyId"              : workOrderUsed.supply?.supplyId ?? 0,
            "nonStockable"          : workOrderUsed.nonStockable,
            "vendorPartNumber"      : workOrderUsed.vendorPartNumber,
            "quantity"              : workOrderUsed.quantity,
            "pricePerItem"          : workOrderUsed.pricePerItem,
            "amountOfLineItem"      : workOrderUsed.amountOfLineItem,
            "dateCreated"           : DateManager.getStandardDateString(date: workOrderUsed.dateCreated),
            "dateModified"          : DateManager.getStandardDateString(date: workOrderUsed.dateModified),
            "removed"               : workOrderUsed.removed,
            "removedDate"           : DateManager.getStandardDateString(date: workOrderUsed.removedDate),
        ]
        let sql = """
            UPDATE \(tableName) SET
                \(COLUMNS.WORK_ORDER_ID)        = :workOrderId,
                \(COLUMNS.PART_ID)              = :partId,
                \(COLUMNS.SUPPLY_ID)            = :supplyId,
                \(COLUMNS.NON_STOCKABLE)        = :nonStockable,
                \(COLUMNS.VENDOR_PART_NUMBER)   = :vendorPartNumber,
                \(COLUMNS.QUANTITY)             = :quantity,
                \(COLUMNS.PRICE_PER_ITEM)       = :pricePerItem,
                \(COLUMNS.AMOUNT_OF_LINE_ITEM)  = :amountOfLineItem,
                \(COLUMNS.DATE_CREATED)         = :dateCreated,
                \(COLUMNS.DATE_MODIFIED)        = :dateModified,
                \(COLUMNS.REMOVED)              = :removed,
                \(COLUMNS.REMOVED_DATE)         = :removedDate
                WHERE \(tableName).\(setIdKey())    = :id;
            """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,
                                     typeOfAction: .update, updatedId: UInt64(workOrderUsed.workOrderUsedId!),
                                     success: { _ in
                                        success()
                                     },
                                     fail: failure)
    }
    
    func fetchWorkOrderUsed(workOrderID: Int? = nil, showRemoved: Bool, offset: Int, success: @escaping(_ stocks: [WorkOrderUsed]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        var arguments: StatementArguments = []
        let searchable = ""
        let removedCondition = """
                WHERE (WOU.\(RepositoryConstants.Columns.REMOVED) = 0
                OR WOU.\(RepositoryConstants.Columns.REMOVED) is NULL)

            """
        
        let showRemovedCondition = """
                WHERE (WOU.\(RepositoryConstants.Columns.REMOVED) = 1)
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
//        SELECT WOU.*,
//        CASE WHEN WOU.\(COLUMNS.PART_ID) > 0 THEN P.\(COLUMNS.PART_NAME) ELSE '' END AS \(COLUMNS.PART_NAME),
//        CASE WHEN WOU.\(COLUMNS.SUPPLY_ID) > 0 THEN S.\(COLUMNS.SUPPLY_NAME) ELSE '' END AS \(COLUMNS.SUPPLY_NAME)
//        FROM main.\(tableName) WOU
//        JOIN main.\(TABLES.PARTS) P ON WOU.\(COLUMNS.PART_ID) == P.\(COLUMNS.PART_ID)
//        JOIN main.\(TABLES.SUPPLIES) S ON WOU.\(COLUMNS.SUPPLY_ID) == S.\(COLUMNS.SUPPLY_ID)
//        WHERE (WOU.\(RepositoryConstants.Columns.REMOVED) = 0
//                OR WOU.\(RepositoryConstants.Columns.REMOVED) is NULL)
//        """
        
        var sql = """
        SELECT WOU.*,
        CASE WHEN WOU.\(COLUMNS.PART_ID) > 0 THEN P.\(COLUMNS.PART_NAME) ELSE '' END AS \(COLUMNS.PART_NAME),
        CASE WHEN WOU.\(COLUMNS.SUPPLY_ID) > 0 THEN S.\(COLUMNS.SUPPLY_NAME) ELSE '' END AS \(COLUMNS.SUPPLY_NAME)
        FROM main.\(tableName) WOU
        JOIN main.\(TABLES.PARTS) P ON WOU.\(COLUMNS.PART_ID) == P.\(COLUMNS.PART_ID)
        JOIN main.\(TABLES.SUPPLIES) S ON WOU.\(COLUMNS.SUPPLY_ID) == S.\(COLUMNS.SUPPLY_ID)
            \(condition)
        """
        
        
        if let workOrderID = workOrderID {
            arguments = [workOrderID]
            sql += " AND WOU.\(COLUMNS.WORK_ORDER_ID) = ?;"
        }
        
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        
        do {
            let lineItems = try queue.read({ (db) -> [WorkOrderUsed] in
                var lineItems: [WorkOrderUsed] = []
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
    
    func fetchMaxWorkOrderUsedID(_ success: @escaping(_ ID: Int) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        var sql = """
        SELECT max(\(COLUMNS.WORK_ORDER_USED_ID)) AS LineItemID FROM main.\(tableName)
        """
        
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            let lineItem = try queue.read({ (db) -> WorkOrderUsed? in
                var lineItem: WorkOrderUsed?
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
    
    func deleteWorkOrderUsed(workOrderUsed: WorkOrderUsed, success: @escaping ()->(), failure: @escaping (_ error: Error)->()) {
        guard let id = workOrderUsed.workOrderUsedId else { return }
        softDelete(atId: id, success: success, fail: failure)
    }
    
    func undeleteWorkOrderUsed(workOrderUsed: WorkOrderUsed, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = workOrderUsed.workOrderUsedId else {return}
        restoreItem(atId: id, success: success, fail: failure)
    }
}
