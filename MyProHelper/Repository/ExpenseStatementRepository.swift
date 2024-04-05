//
//  ExpenseStatementRepository.swift
//  MyProHelper
//
//  Created by sismac010 on 14/05/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB

class ExpenseStatementRepository: BaseRepository {
    
    init() {
        super.init(table: .EXPENSE_STATEMENTS)
    }
    
    override func setIdKey() -> String {
        return COLUMNS.EXPENSE_STATEMENT_ID
    }
    
    func insertExpenseStatements(expenseStatements: ExpenseStatements, success: @escaping(_ expenseStatementsId: Int64) -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "workerId"              : expenseStatements.workerId,
            "customerId"            : expenseStatements.customerId,
            "description"           : expenseStatements.description,
            "salesTax"              : expenseStatements.salesTax,
            "shipping"              : expenseStatements.shipping,
            "dateCreated"           : DateManager.getStandardDateString(date: expenseStatements.dateCreated),
            "status"                : expenseStatements.status ?? "",
            "remarks"               : expenseStatements.remarks ?? "",
            "approvedBy"            : expenseStatements.approvedBy ?? 0,
            "datePaid"              : DateManager.getStandardDateString(date: expenseStatements.datePaid),
            "dateModified"          : DateManager.getStandardDateString(date: expenseStatements.dateModified),
            "sampleExpenseStatement": expenseStatements.sampleExpenseStatement ?? 0,
            "removed"               : expenseStatements.removed ?? 0,
            "removedDate"           : DateManager.getStandardDateString(date: expenseStatements.removedDate),
            "numberOfAttachments"   : expenseStatements.numberOfAttachments
            
        ]
        let sql = """
            INSERT INTO chg.\(tableName) (
                \(COLUMNS.WORKER_ID),
                \(COLUMNS.CUSTOMER_ID),
                \(COLUMNS.DESCRIPTION),
                \(COLUMNS.SALES_TAX),
                \(COLUMNS.SHIPPING),
                \(COLUMNS.DATE_CREATED),
                \(COLUMNS.STATUS),
                \(COLUMNS.REMARKS),
                \(COLUMNS.APPROVED_BY),
                \(COLUMNS.DATE_PAID),
                \(COLUMNS.DATE_MODIFIED),
                \(COLUMNS.SAMPLE_EXPENSE_STATEMENT),
                \(COLUMNS.REMOVED),
                \(COLUMNS.REMOVED_DATE),
                \(COLUMNS.NUMBER_OF_ATTACHMENTS))

            VALUES (:workerId,
                    :customerId,
                    :description,
                    :salesTax,
                    :shipping,
                    :dateCreated,
                    :status,
                    :remarks,
                    :approvedBy,
                    :datePaid,
                    :dateModified,
                    :sampleExpenseStatement,
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
    
    func update(expenseStatements: ExpenseStatements, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "id"                    : expenseStatements.expenseStatementsId,
            "workerId"              : expenseStatements.workerId,
            "customerId"            : expenseStatements.customerId,
            "description"           : expenseStatements.description,
            "salesTax"              : expenseStatements.salesTax,
            "shipping"              : expenseStatements.shipping,
            "dateCreated"           : DateManager.getStandardDateString(date: expenseStatements.dateCreated),
            "status"                : expenseStatements.status ?? "",
            "remarks"               : expenseStatements.remarks ?? "",
            "approvedBy"            : expenseStatements.approvedBy ?? 0,
            "datePaid"              : DateManager.getStandardDateString(date: expenseStatements.datePaid),
            "dateModified"          : DateManager.getStandardDateString(date: expenseStatements.dateModified),
            "sampleExpenseStatement": expenseStatements.sampleExpenseStatement ?? 0,
            "removed"               : expenseStatements.removed ?? 0,
            "removedDate"           : DateManager.getStandardDateString(date: expenseStatements.removedDate),
            "numberOfAttachments"   : expenseStatements.numberOfAttachments
            
        ]
        let sql = """
            UPDATE \(tableName) SET
                \(COLUMNS.WORKER_ID)                = :workerId,
                \(COLUMNS.CUSTOMER_ID)              = :customerId,
                \(COLUMNS.DESCRIPTION)              = :description,
                \(COLUMNS.SALES_TAX)                = :salesTax,
                \(COLUMNS.SHIPPING)                 = :shipping,
                \(COLUMNS.DATE_CREATED)             = :dateCreated,
                \(COLUMNS.STATUS)                   = :status,
                \(COLUMNS.REMARKS)                  = :remarks,
                \(COLUMNS.APPROVED_BY)              = :approvedBy,
                \(COLUMNS.DATE_PAID)                = :datePaid,
                \(COLUMNS.DATE_MODIFIED)            = :dateModified,
                \(COLUMNS.SAMPLE_EXPENSE_STATEMENT) = :sampleExpenseStatement,
                \(COLUMNS.REMOVED)                  = :removed,
                \(COLUMNS.REMOVED_DATE)             = :removedDate,
                \(COLUMNS.NUMBER_OF_ATTACHMENTS)    = :numberOfAttachments
            WHERE \(tableName).\(setIdKey()) = :id;
            """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,
                                     typeOfAction: .update, updatedId: UInt64(expenseStatements.expenseStatementsId!),
                                     success: { _ in
                                        success()
                                     },
                                     fail: failure)
    }
    
    
    func fetchExpenseStatements(showRemoved: Bool, with key: String? = nil, sortBy: ExpenseStatementField? = nil , sortType: SortType? = nil ,offset: Int,success: @escaping(_ supplies: [ExpenseStatements]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        
        let sortable = makeSortableItems(sortBy: sortBy, sortType: sortType)
        let searchable = makeSearchableItems(key: key)
        
        let removedCondition = """
                WHERE (ES.\(COLUMNS.REMOVED) = 0
                OR ES.\(COLUMNS.REMOVED) is NULL)
                AND (ESU.\(COLUMNS.REMOVED) = 0
                OR ESU.\(COLUMNS.REMOVED) is NULL)
                """
        
        let showRemovedCondition = """
                WHERE (ES.\(COLUMNS.REMOVED) = 1)
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
        SELECT ES.*,
        CASE WHEN ES.\(COLUMNS.WORKER_ID) > 0 THEN W.\(COLUMNS.FIRST_NAME) || ' ' || W.\(COLUMNS.LAST_NAME) ELSE '' END AS \(COLUMNS.WORKER_NAME),W.\(COLUMNS.EMAIL),
        CASE WHEN ES.\(COLUMNS.APPROVED_BY) > 0 THEN A.\(COLUMNS.FIRST_NAME) || ' ' || A.\(COLUMNS.LAST_NAME) ELSE '' END AS \(COLUMNS.APPROVER_NAME),C.\(COLUMNS.CUSTOMER_NAME),
        CASE WHEN P.\(COLUMNS.PART_ID) > 0 THEN P.\(COLUMNS.PART_NAME) ELSE '' END AS \(COLUMNS.PART_NAME),
        CASE WHEN S.\(COLUMNS.SUPPLY_ID) > 0 THEN S.\(COLUMNS.SUPPLY_NAME) ELSE '' END AS \(COLUMNS.SUPPLY_NAME),
        ESU.\(COLUMNS.PART_ID),
        ESU.\(COLUMNS.SUPPLY_ID),
        ESU.\(COLUMNS.VENDOR_PART_NUMBER),
        ESU.\(COLUMNS.QUANTITY),
        ESU.\(COLUMNS.PRICE_PER_ITEM),
        SUM(ESU.\(COLUMNS.AMOUNT_TO_REIMBURSE)) AS \(COLUMNS.AMOUNT_TO_REIMBURSE),
        ROW_NUMBER() OVER (ORDER BY ES.\(COLUMNS.EXPENSE_STATEMENT_ID)) AS RowNum
        FROM main.\(tableName) ES

        JOIN main.\(TABLES.WORKERS) W ON ES.\(COLUMNS.WORKER_ID) == W.\(COLUMNS.WORKER_ID)
        JOIN main.\(TABLES.EXPENSE_STATEMENTS_USED) ESU ON ESU.\(COLUMNS.EXPENSE_STATEMENT_ID) == ES.\(COLUMNS.EXPENSE_STATEMENT_ID)
        JOIN main.\(TABLES.CUSTOMERS) C ON C.\(COLUMNS.CUSTOMER_ID) == ES.\(COLUMNS.CUSTOMER_ID) AND (C.\(COLUMNS.REMOVED) = 0 OR C.\(COLUMNS.REMOVED) is NULL)
        JOIN main.\(TABLES.PARTS) P ON ESU.\(COLUMNS.PART_ID) == P.\(COLUMNS.PART_ID)
        JOIN main.\(TABLES.SUPPLIES) S ON ESU.\(COLUMNS.SUPPLY_ID) == S.\(COLUMNS.SUPPLY_ID)
        LEFT JOIN main.\(TABLES.WORKERS) A ON ES.\(COLUMNS.APPROVED_BY) == A.\(COLUMNS.WORKER_ID)
        \(condition)
        GROUP BY ES.\(COLUMNS.EXPENSE_STATEMENT_ID)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        sql += """
                \(sortable)
                LIMIT \(LIMIT) OFFSET \(offset);
        """
        
        
        do {
            let expenseStatements = try queue.read({ (db) -> [ExpenseStatements] in
                var expenseStatements: [ExpenseStatements] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    expenseStatements.append(.init(row: row))
                }
                return expenseStatements
            })
            success(expenseStatements)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    private func makeSortableItems(sortBy: ExpenseStatementField?, sortType: SortType?) -> String {
        guard let sortBy = sortBy, let sortType = sortType else {
            return makeSortableCondition(key: COLUMNS.WORKER_NAME, sortType: .ASCENDING)
        }
        switch sortBy {
        case .WORKER_NAME:
            return makeSortableCondition(key: COLUMNS.WORKER_NAME, sortType: sortType)
        case .SALE_TAX:
            return makeSortableCondition(key: COLUMNS.SALES_TAX, sortType: sortType)
        case .SHIPPING:
            return makeSortableCondition(key: COLUMNS.SHIPPING, sortType: sortType)
        case .TOTAL_AMOUNT:
            return makeSortableCondition(key: COLUMNS.AMOUNT_OF_LINE_ITEM, sortType: sortType)
        case .ATTACHMENTS:
            return makeSortableCondition(key: COLUMNS.NUMBER_OF_ATTACHMENTS, sortType: sortType)
        case .CUSTOMER_NAME:
            return makeSortableCondition(key: COLUMNS.CUSTOMER_NAME, sortType: sortType)
        case .DESCRIPTION:
            return makeSortableCondition(key: COLUMNS.DESCRIPTION, sortType: sortType)
        case .STATUS:
            return makeSortableCondition(key: COLUMNS.STATUS, sortType: sortType)
        case .REMARKS:
            return makeSortableCondition(key: COLUMNS.REMARKS, sortType: sortType)
        case .APPROVED_BY:
            return makeSortableCondition(key: COLUMNS.APPROVED_BY, sortType: sortType)
        case .APPROVED_DATE:
            return makeSortableCondition(key: COLUMNS.APPROVED_DATE, sortType: sortType)
        }
    }
    
    private func makeSearchableItems(key: String?) -> String {
        guard let key = key else { return "" }
        return makeSearchableCondition(key: key,
                                       fields: [
                                        COLUMNS.WORKER_NAME,
                                        COLUMNS.CUSTOMER_NAME,
                                        COLUMNS.SALES_TAX,
                                        COLUMNS.SHIPPING,
                                        //COLUMNS.TOTAL_AMOUNT,
                                        //COLUMNS.DESCRIPTION,
                                        COLUMNS.STATUS,
                                        COLUMNS.Remarks,
                                        //COLUMNS.NUMBER_OF_ATTACHMENTS,
                                        COLUMNS.APPROVED_BY,
                                        COLUMNS.APPROVED_DATE,
                                       ])
    }
    
}
