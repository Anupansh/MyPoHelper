//
//  ExpenseStatementsUsedRepository.swift
//  MyProHelper
//
//  Created by sismac010 on 18/05/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB

class ExpenseStatementsUsedRepository: BaseRepository {

    init() {
        super.init(table: .EXPENSE_STATEMENTS_USED)
    }
    
    override func setIdKey() -> String {
        return COLUMNS.EXPENSE_STATEMENT_USED_ID
    }
    
    func addExpenseStatementsUsed(expenseStatementsUsed: ExpenseStatementsUsed, success: @escaping (_ expenseStatementsUsedID: Int64)->(), failure: @escaping (_ error: Error)->()) {
        if let id = expenseStatementsUsed.expenseStatementsUsedId  {
            updateExpenseStatementsUsed(expenseStatementsUsed: expenseStatementsUsed) {
                success(Int64(id))
            } failure: { (error) in
                failure(error)
            }
            return
        }
        
        let arguments: StatementArguments = [
            "expenseStatementsId"   : expenseStatementsUsed.expenseStatementsId,
            "partId"                : expenseStatementsUsed.part?.partID ?? 0,
            "supplyId"              : expenseStatementsUsed.supply?.supplyId ?? 0,
            "description"           : expenseStatementsUsed.description,
            "vendorPartNumber"      : expenseStatementsUsed.vendorPartNumber,
            "quantity"              : expenseStatementsUsed.quantity,
            "pricePerItem"          : expenseStatementsUsed.pricePerItem,
            "amountToReimburse"     : expenseStatementsUsed.amountToReimburse,
            "dateCreated"           : DateManager.getStandardDateString(date: expenseStatementsUsed.dateCreated),
            "dateModified"          : DateManager.getStandardDateString(date: expenseStatementsUsed.dateModified),
            "removed"               : expenseStatementsUsed.removed ?? 0,
            "removedDate"           : DateManager.getStandardDateString(date: expenseStatementsUsed.removedDate)
        ]
        let sql = """
            INSERT INTO chg.\(tableName) (
                \(COLUMNS.EXPENSE_STATEMENT_ID),
                \(COLUMNS.PART_ID),
                \(COLUMNS.SUPPLY_ID),
                \(COLUMNS.DESCRIPTION),
                \(COLUMNS.VENDOR_PART_NUMBER),
                \(COLUMNS.QUANTITY),
                \(COLUMNS.PRICE_PER_ITEM),
                \(COLUMNS.AMOUNT_TO_REIMBURSE),
                \(COLUMNS.DATE_CREATED),
                \(COLUMNS.DATE_MODIFIED),
                \(COLUMNS.REMOVED),
                \(COLUMNS.REMOVED_DATE))

            VALUES (:expenseStatementsId,
                    :partId,
                    :supplyId,
                    :description,
                    :vendorPartNumber,
                    :quantity,
                    :pricePerItem,
                    :amountToReimburse,
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
    
    func updateExpenseStatementsUsed(expenseStatementsUsed: ExpenseStatementsUsed, success: @escaping ()->(), failure: @escaping (_ error: Error)->()) {
        let arguments: StatementArguments = [
            "id"                    : expenseStatementsUsed.expenseStatementsUsedId,
            "expenseStatementsId"   : expenseStatementsUsed.expenseStatementsId,
            "partId"                : expenseStatementsUsed.part?.partID ?? 0,
            "supplyId"              : expenseStatementsUsed.supply?.supplyId ?? 0,
            "description"           : expenseStatementsUsed.description,
            "vendorPartNumber"      : expenseStatementsUsed.vendorPartNumber,
            "quantity"              : expenseStatementsUsed.quantity,
            "pricePerItem"          : expenseStatementsUsed.pricePerItem,
            "amountToReimburse"     : expenseStatementsUsed.amountToReimburse,
            "dateCreated"           : DateManager.getStandardDateString(date: expenseStatementsUsed.dateCreated),
            "dateModified"          : DateManager.getStandardDateString(date: expenseStatementsUsed.dateModified),
            "removed"               : expenseStatementsUsed.removed,
            "removedDate"           : DateManager.getStandardDateString(date: expenseStatementsUsed.removedDate),
        ]
        let sql = """
            UPDATE \(tableName) SET
                \(COLUMNS.EXPENSE_STATEMENT_ID) = :expenseStatementsId,
                \(COLUMNS.PART_ID)              = :partId,
                \(COLUMNS.SUPPLY_ID)            = :supplyId,
                \(COLUMNS.DESCRIPTION)          = :description,
                \(COLUMNS.VENDOR_PART_NUMBER)   = :vendorPartNumber,
                \(COLUMNS.QUANTITY)             = :quantity,
                \(COLUMNS.PRICE_PER_ITEM)       = :pricePerItem,
                \(COLUMNS.AMOUNT_TO_REIMBURSE)  = :amountToReimburse,
                \(COLUMNS.DATE_CREATED)         = :dateCreated,
                \(COLUMNS.DATE_MODIFIED)        = :dateModified,
                \(COLUMNS.REMOVED)              = :removed,
                \(COLUMNS.REMOVED_DATE)         = :removedDate
                WHERE \(tableName).\(setIdKey())    = :id;
            """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,
                                     typeOfAction: .update, updatedId: UInt64(expenseStatementsUsed.expenseStatementsUsedId!),
                                     success: { _ in
                                        success()
                                     },
                                     fail: failure)
    }
    
    func fetchExpenseStatementsUsed(expenseStatementsID: Int? = nil, showRemoved: Bool, offset: Int, success: @escaping(_ stocks: [ExpenseStatementsUsed]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        var arguments: StatementArguments = []
        let searchable = ""
        let removedCondition = """
                WHERE (ESU.\(RepositoryConstants.Columns.REMOVED) = 0
                OR ESU.\(RepositoryConstants.Columns.REMOVED) is NULL)

            """
        
        let showRemovedCondition = """
                WHERE (ESU.\(RepositoryConstants.Columns.REMOVED) = 1)
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
//        SELECT ESU.*,
//        CASE WHEN ESU.\(COLUMNS.PART_ID) > 0 THEN P.\(COLUMNS.PART_NAME) ELSE '' END AS \(COLUMNS.PART_NAME),
//        CASE WHEN ESU.\(COLUMNS.SUPPLY_ID) > 0 THEN S.\(COLUMNS.SUPPLY_NAME) ELSE '' END AS \(COLUMNS.SUPPLY_NAME)
//        FROM \(tableName) ESU
//        JOIN \(TABLES.PARTS) P ON ESU.\(COLUMNS.PART_ID) == P.\(COLUMNS.PART_ID)
//        JOIN \(TABLES.SUPPLIES) S ON ESU.\(COLUMNS.SUPPLY_ID) == S.\(COLUMNS.SUPPLY_ID)
//
//        WHERE (ESU.\(RepositoryConstants.Columns.REMOVED) = 0
//                OR ESU.\(RepositoryConstants.Columns.REMOVED) is NULL)
//        """
        
        var sql = """
        SELECT ESU.*,
        CASE WHEN ESU.\(COLUMNS.PART_ID) > 0 THEN P.\(COLUMNS.PART_NAME) ELSE '' END AS \(COLUMNS.PART_NAME),
        CASE WHEN ESU.\(COLUMNS.SUPPLY_ID) > 0 THEN S.\(COLUMNS.SUPPLY_NAME) ELSE '' END AS \(COLUMNS.SUPPLY_NAME)
        FROM main.\(tableName) ESU
        JOIN main.\(TABLES.PARTS) P ON ESU.\(COLUMNS.PART_ID) == P.\(COLUMNS.PART_ID)
        JOIN main.\(TABLES.SUPPLIES) S ON ESU.\(COLUMNS.SUPPLY_ID) == S.\(COLUMNS.SUPPLY_ID)
            \(condition)
        """

        
        if let expenseStatementsID = expenseStatementsID {
            arguments = [expenseStatementsID]
            sql += " AND ESU.\(COLUMNS.EXPENSE_STATEMENT_ID) = ?"
            arguments += [expenseStatementsID] // Only for using 'uniun' below
            
        }
        
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        
        do {
            let lineItems = try queue.read({ (db) -> [ExpenseStatementsUsed] in
                var lineItems: [ExpenseStatementsUsed] = []
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

    func fetchMaxExpenseStatementsUsedID(_ success: @escaping(_ ID: Int) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        var sql = """
        SELECT max(\(COLUMNS.EXPENSE_STATEMENT_USED_ID)) AS LineItemID FROM main.\(tableName)
        """
        
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            let lineItem = try queue.read({ (db) -> ExpenseStatementsUsed? in
                var lineItem: ExpenseStatementsUsed?
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
    
    func deleteExpenseStatementsUsed(expenseStatementsUsed: ExpenseStatementsUsed, success: @escaping ()->(), failure: @escaping (_ error: Error)->()) {
        guard let id = expenseStatementsUsed.expenseStatementsUsedId else { return }
        softDelete(atId: id, success: success, fail: failure)
    }
    
    func undeleteExpenseStatementsUsed(expenseStatementsUsed: ExpenseStatementsUsed, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = expenseStatementsUsed.expenseStatementsUsedId else {return}
        restoreItem(atId: id, success: success, fail: failure)
    }
}
