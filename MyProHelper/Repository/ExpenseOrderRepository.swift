//
//  ExpenseOrderRepository  .swift
//  MyProHelper
//
//  Created by Pooja Mishra on 08/04/1943 Saka.
//  Copyright © 1943 Benchmark Computing. All rights reserved.
//
import Foundation
import GRDB


class ExpenseOrderRepository: BaseRepository {

    init() {
        super.init(table: .EXPENSE_STATEMENTS)
    }


    override func setIdKey() -> String {
        return COLUMNS.EXPENSE_STATEMENT_ID
    }

  func insertExpenseOrder(expenseOrder: ExpenseStatements, success: @escaping(_ : Int64) -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments :  StatementArguments = [
            "workerId"              : expenseOrder.workerId,
            "customerId"            : expenseOrder.customerId,
            "salesTax"               : expenseOrder.salesTax,
            "shipping"               : expenseOrder.shipping,
            "description"           : expenseOrder.description,
            "status"                : expenseOrder.status ?? "Requested",
            "remarks"               : expenseOrder.remarks ?? "",
            "dateCreated"           : DateManager.getStandardDateString(date: expenseOrder.dateCreated),
            "dateApproved"          : DateManager.getStandardDateString(date: expenseOrder.dateApproved),
            "approvedBy"            : expenseOrder.approvedBy ?? 0 ,
            "dateModified"          : DateManager.getStandardDateString(date: expenseOrder.dateModified),
            "sampleExpenseOrder"    : expenseOrder.sampleExpenseStatement ?? 0,
            "removed"               : expenseOrder.removed ?? 0,
            "removedDate"           : DateManager.getStandardDateString(date: expenseOrder.removedDate),
            "numberOfAttachments"   : expenseOrder.numberOfAttachments

        ]
        let sql = """
            INSERT INTO chg.\(tableName) (
                      \(COLUMNS.WORKER_ID),
                      \(COLUMNS.CUSTOMER_ID),
                      \(COLUMNS.DESCRIPTION),
                      \(COLUMNS.STATUS),
                      \(COLUMNS.Remarks),
                      \(COLUMNS.SALES_TAX),
                      \(COLUMNS.SHIPPING),
                      \(COLUMNS.DATE_CREATED),
                      \(COLUMNS.DATE_APPROVED),
                      \(COLUMNS.APPROVED_BY),
                      \(COLUMNS.DATE_MODIFIED),
                      \(COLUMNS.REMOVED),
                      \(COLUMNS.REMOVED_DATE),
                      \(COLUMNS.NUMBER_OF_ATTACHMENTS))

            VALUES (:workerId,
                    :customerId,
                    :description,
                    :status,
                    :remarks,
                    :salesTax,
                    :shipping,
                    :dateCreated,
                    :dateApproved,
                    :approvedBy,
                    :dateModified,
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
    func update(expenseOrder: ExpenseStatements, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        let argument : StatementArguments = [
            "id"                    : expenseOrder.expenseStatementsId,
            "workerId"              : expenseOrder.workerId,
            "customerId"            : expenseOrder.customerId,
            "salesTax"               : expenseOrder.salesTax,
            "shipping"               : expenseOrder.shipping,
            "description"           : expenseOrder.description,
            "status"                : expenseOrder.status,
            "remarks"               : expenseOrder.remarks ?? "",
            "dateCreated"           : DateManager.getStandardDateString(date: expenseOrder.dateCreated),
            "dateApproved"          : DateManager.getStandardDateString(date: expenseOrder.dateApproved),
            "approvedBy"            :  1,
            "dateModified"          : DateManager.getStandardDateString(date: expenseOrder.dateModified),
            "sampleExpenseOrder"       : expenseOrder.sampleExpenseStatement ?? 0,
            "removed"               : expenseOrder.removed ?? 0,
            "removedDate"           : DateManager.getStandardDateString(date: expenseOrder.removedDate),
            "numberOfAttachments"   : expenseOrder.numberOfAttachments

        ]

        let sql = """
            UPDATE \(tableName) SET
                                    \(COLUMNS.WORKER_ID)        =:workerId,
                                    \(COLUMNS.CUSTOMER_ID)      =:customerId,
                                    \(COLUMNS.DESCRIPTION)      =:description,
                                    \(COLUMNS.STATUS)           =:status ,
                                    \(COLUMNS.Remarks)          =:remarks,
                                    \(COLUMNS.SALES_TAX)        =:salesTax,
                                    \(COLUMNS.SHIPPING)          =:shipping,
                                    \(COLUMNS.DATE_CREATED)      =:dateCreated,
                                    \(COLUMNS.DATE_APPROVED)      =:dateApproved,
                                    \(COLUMNS.APPROVED_BY)        =:approvedBy,
                                    \(COLUMNS.DATE_MODIFIED)       =:dateModified,
                                    \(COLUMNS.REMOVED)              =:removed,
                                    \(COLUMNS.REMOVED_DATE)        = :removedDate,
                                    \(COLUMNS.NUMBER_OF_ATTACHMENTS) =:numberOfAttachments

            WHERE \(tableName).\(setIdKey()) = :id
            """

        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: argument,
                                      typeOfAction: .update, updatedId: UInt64(expenseOrder.expenseStatementsId!),
                                     success: { _ in
                                        success()
                                     },
                                     fail: failure)
    }
    
    func Edit(expenseOrder: ExpenseStatements, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        let argument : StatementArguments = [
            "id"                    : expenseOrder.expenseStatementsId,
            "workerId"              : expenseOrder.workerId,
            "customerId"            : expenseOrder.customerId,
            "salesTax"               : expenseOrder.salesTax,
            "shipping"               : expenseOrder.shipping,
            "description"           : expenseOrder.description,
            "status"                : expenseOrder.status,
            "remarks"               : expenseOrder.remarks ?? "",
            "dateCreated"           : DateManager.getStandardDateString(date: expenseOrder.dateCreated),
            "dateApproved"          : DateManager.getStandardDateString(date: expenseOrder.dateApproved),
            "approvedBy"            : expenseOrder.approvedBy,
            "dateModified"          : DateManager.getStandardDateString(date: expenseOrder.dateModified),
            "sampleExpenseOrder"    : expenseOrder.sampleExpenseStatement ?? 0,
            "removed"               : expenseOrder.removed ?? 0,
            "removedDate"           : DateManager.getStandardDateString(date: expenseOrder.removedDate),
            "numberOfAttachments"   : expenseOrder.numberOfAttachments

        ]

        let sql = """
            UPDATE \(tableName) SET
                                    \(COLUMNS.WORKER_ID)          =:workerId,
                                    \(COLUMNS.CUSTOMER_ID)        =:customerId,
                                    \(COLUMNS.DESCRIPTION)        =:description,
                                    \(COLUMNS.STATUS)             =:status ,
                                    \(COLUMNS.Remarks)            =:remarks,
                                    \(COLUMNS.SALES_TAX)          =:salesTax,
                                    \(COLUMNS.SHIPPING)           =:shipping,
                                    \(COLUMNS.DATE_CREATED)       =:dateCreated,
                                    \(COLUMNS.DATE_APPROVED)      =:dateApproved,
                                    \(COLUMNS.APPROVED_BY)        =:approvedBy,
                                    \(COLUMNS.DATE_MODIFIED)      =:dateModified,
                                    \(COLUMNS.REMOVED)            =:removed,
                                    \(COLUMNS.REMOVED_DATE)     = :removedDate,
                                    \(COLUMNS.NUMBER_OF_ATTACHMENTS) =:numberOfAttachments

            WHERE \(tableName).\(setIdKey()) = :id
            """

        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: argument,
                                    typeOfAction: .update, updatedId: UInt64(expenseOrder.expenseStatementsId!),
                                     success: { _ in
                                        success()
                                     },
                                     fail: failure)
    }

    func removeExpenseOrder(expenseOrder: ExpenseStatements, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = expenseOrder.expenseStatementsId else {
                return
        }
        softDelete(atId: id, success: success, fail: failure)
    }

    func unremoveExpenseOrder(expenseOrder: ExpenseStatements, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = expenseOrder.expenseStatementsId else {
                return
        }
        restoreItem(atId: id, success: success, fail: failure)
    }

    func fetchExpenseOrder(showRemoved: Bool, with key: String? = nil, sortBy: ExpenseStatementField? = nil , sortType: SortType? = nil ,offset: Int,success: @escaping(_ supplies: [ExpenseStatements]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        
        let sortable = makeSortableItems(sortBy: sortBy, sortType: sortType)
        let searchable = makeSearchableItems(key: key)
        let removedCondition = """
                WHERE (main.\(tableName).\(COLUMNS.REMOVED) = 0
                OR main.\(tableName).\(COLUMNS.REMOVED) is NULL)
                AND (main.\(TABLES.EXPENSE_STATEMENTS_USED).\(COLUMNS.REMOVED) = 0
                OR main.\(TABLES.EXPENSE_STATEMENTS_USED).\(COLUMNS.REMOVED) is NULL)
                """

        let showRemovedCondition = """
                WHERE (main.\(tableName).\(COLUMNS.REMOVED) = 1)
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
        
        
        var sql = """
        SELECT main.\(tableName).\(COLUMNS.EXPENSE_STATEMENT_ID),main.\(tableName).\(COLUMNS.WORKER_ID),main.\(TABLES.WORKERS).\(COLUMNS.FIRST_NAME),
        CASE WHEN main.\(tableName).\(COLUMNS.WORKER_ID) > 0 THEN main.\(TABLES.WORKERS).\(COLUMNS.FIRST_NAME) || ' ' || main.\(TABLES.WORKERS).\(COLUMNS.LAST_NAME) ELSE '' END AS \(COLUMNS.WORKER_NAME),main.\(TABLES.WORKERS).\(COLUMNS.EMAIL),
        CASE WHEN main.\(tableName).\(COLUMNS.APPROVED_BY) > 0 THEN A.\(COLUMNS.FIRST_NAME) || ' ' || A.\(COLUMNS.LAST_NAME) ELSE '' END AS \(COLUMNS.APPROVER_NAME),main.\(TABLES.CUSTOMERS).\(COLUMNS.CUSTOMER_NAME),
        CASE WHEN main.\(TABLES.EXPENSE_STATEMENTS_USED).\(COLUMNS.PART_ID) > 0 THEN main.\(TABLES.PARTS).\(COLUMNS.PART_NAME) ELSE '' END AS \(COLUMNS.PART_NAME),
        CASE WHEN main.\(TABLES.EXPENSE_STATEMENTS_USED).\(COLUMNS.SUPPLY_ID) > 0 THEN main.\(TABLES.SUPPLIES).\(COLUMNS.SUPPLY_NAME) ELSE '' END AS \(COLUMNS.SUPPLY_NAME),
        SUM(main.\(TABLES.EXPENSE_STATEMENTS_USED).\(COLUMNS.AMOUNT_TO_REIMBURSE)) AS \(COLUMNS.AMOUNT_TO_REIMBURSE),
        main.\(tableName).\(COLUMNS.REMOVED) as \(COLUMNS.REMOVED),
        ROW_NUMBER() OVER (ORDER BY main.\(tableName).\(COLUMNS.EXPENSE_STATEMENT_ID)) AS RowNum
        FROM main.\(tableName)

        JOIN main.\(TABLES.EXPENSE_STATEMENTS_USED) ON main.\(tableName).\(COLUMNS.EXPENSE_STATEMENT_ID) == main.\(TABLES.EXPENSE_STATEMENTS_USED).\(COLUMNS.EXPENSE_STATEMENT_ID)
        JOIN main.\(TABLES.PARTS) ON main.\(TABLES.EXPENSE_STATEMENTS_USED).\(COLUMNS.PART_ID) == main.\(TABLES.PARTS).\(COLUMNS.PART_ID)
        JOIN main.\(TABLES.CUSTOMERS) ON main.\(tableName).\(COLUMNS.CUSTOMER_ID) == main.\(TABLES.CUSTOMERS).\(COLUMNS.CUSTOMER_ID) AND (main.\(TABLES.CUSTOMERS).\(COLUMNS.REMOVED) = 0 OR main.\(TABLES.CUSTOMERS).\(COLUMNS.REMOVED) is NULL)
        JOIN main.\(TABLES.SUPPLIES) ON main.\(TABLES.EXPENSE_STATEMENTS_USED).\(COLUMNS.SUPPLY_ID) == main.\(TABLES.SUPPLIES).\(COLUMNS.SUPPLY_ID)
        JOIN main.\(TABLES.WORKERS) ON main.\(tableName).\(COLUMNS.WORKER_ID) == main.\(TABLES.WORKERS).\(COLUMNS.WORKER_ID)
        LEFT JOIN main.\(TABLES.WORKERS) A ON main.\(tableName).\(COLUMNS.APPROVED_BY) == A.\(COLUMNS.WORKER_ID)
        \(condition)
        GROUP BY main.\(TABLES.EXPENSE_STATEMENTS_USED).\(COLUMNS.EXPENSE_STATEMENT_ID)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        sql += """
                \(sortable)
        """
        do {
            let ExpenseStatements = try queue.read({ (db) -> [ExpenseStatements] in
                var ExpenseStatements: [ExpenseStatements] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    ExpenseStatements.append(.init(row: row))
                }
                return ExpenseStatements
            })
            success(ExpenseStatements)
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
        case .CUSTOMER_NAME:
            return makeSortableCondition(key: COLUMNS.CUSTOMER_NAME, sortType: sortType)
        case .DESCRIPTION:
            return makeSortableCondition(key: COLUMNS.DESCRIPTION, sortType: sortType)
        case .SALE_TAX:
            return makeSortableCondition(key: COLUMNS.SALES_TAX, sortType: sortType)
        case .SHIPPING:
            return makeSortableCondition(key: COLUMNS.SHIPPING, sortType: sortType)
        case .TOTAL_AMOUNT:
            return makeSortableCondition(key: COLUMNS.TOTAL_AMOUNT, sortType: sortType)
        case .STATUS:
            return makeSortableCondition(key: COLUMNS.STATUS, sortType: sortType)
        case .REMARKS:
            return makeSortableCondition(key: COLUMNS.Remarks, sortType: sortType)
        case .ATTACHMENTS:
            return makeSortableCondition(key: COLUMNS.ATTACHMENTS_date, sortType: sortType)
        case .APPROVED_BY:
            return makeSortableCondition(key: COLUMNS.APPROVED_BY, sortType: sortType)
        case .APPROVED_DATE:
            return makeSortableCondition(key: COLUMNS.APPROVED_DATE, sortType: sortType)
        case .WORKER_NAME:
            return makeSortableCondition(key: COLUMNS.WORKER_NAME, sortType: sortType)
        }
    }
    
    
    
    private func makeSearchableItems(key: String?) -> String {
        guard let key = key else { return "" }
        return makeSearchableCondition(key: key,
                                       fields: [
                                        COLUMNS.WORKER_NAME,
                                        COLUMNS.CUSTOMER_NAME,
                                       ])
    }
   
}



