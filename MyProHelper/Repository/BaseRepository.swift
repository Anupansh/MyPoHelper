//
//  BaseRepository.swift
//  MyProHelper
//
//  Created by Samir on 12/1/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import GRDB

enum Table {
    case ASSETS
    case ASSET_TYPES
    case SUPPLY_LOCATIONS
    case PART_LOCATIONS
    case SERVICE_TYPES
    case VENDORS
    case CUSTOMERS
    case WORKERS
    case ATTACHMENTS
    case SCHEDULED_JOBS
    case PART_FINDERS
    case PARTS
    case JOBS_WORKERS
    case WORKER_HOME_ADDRESS
    case WAGES
    case DEVICES
    case WorkerRoles
    case WorkerRolesGroups
    case HOLIDAYS
    case JOBS_HISTORY
    case QUOTES
    case ESTIMATES
    case INVOICES
    case PAYMENTS
    case SERVICES_USED
    case PARTS_USED
    case SUPPLIES_USED
    case SUPPLIES
    case JOB_DETAILS
    case RECEIPTS
    case APPROVALS
    case SUPPLY_FINDERS
    case PURCHASE_ORDER
    case PURCHASE_ORDER_USED
    case WORK_ORDER
    case WORK_ORDER_USED
    case EXPENSE_STATEMENTS
    case EXPENSE_STATEMENTS_USED
    case CURRENT_TIME_SHEETS
}

class BaseRepository {
    
    let COLUMNS = RepositoryConstants.Columns.self
    let TABLES  = RepositoryConstants.Tables.self
    
    let LIMIT = Constants.DATA_OFFSET
    let table: Table
    var tableName: String {
        return getTableName()
    }
    
    init(table: Table) {
        self.table = table
    }
    
    private func getTableName() -> String {
        switch table {
        case .ASSETS:
            return RepositoryConstants.Tables.ASSETS
        case .ASSET_TYPES:
            return RepositoryConstants.Tables.ASSET_TYPES
        case .SUPPLY_LOCATIONS:
            return RepositoryConstants.Tables.SUPPLY_LOCATIONS
        case .PART_LOCATIONS:
            return RepositoryConstants.Tables.PART_LOCATIONS
        case .SERVICE_TYPES:
            return RepositoryConstants.Tables.SERVICE_TYPES
        case .VENDORS:
            return RepositoryConstants.Tables.VENDORS
        case .CUSTOMERS:
            return RepositoryConstants.Tables.CUSTOMERS
        case .WORKERS:
            return RepositoryConstants.Tables.WORKERS
        case .ATTACHMENTS:
            return RepositoryConstants.Tables.ATTACHMENTS
        case .SCHEDULED_JOBS:
            return RepositoryConstants.Tables.SCHEDULED_JOBS
        case .PART_FINDERS:
            return RepositoryConstants.Tables.PART_FINDERS
        case .PARTS:
            return RepositoryConstants.Tables.PARTS
        case .JOBS_WORKERS:
            return RepositoryConstants.Tables.JOBS_WORKERS
        case .WORKER_HOME_ADDRESS:
            return RepositoryConstants.Tables.WORKER_HOME_ADDRESSES
        case .WAGES:
            return RepositoryConstants.Tables.WAGES
        case .DEVICES:
            return RepositoryConstants.Tables.DEVICES
        case .WorkerRoles:
            return RepositoryConstants.Tables.WORKER_ROLES
        case .WorkerRolesGroups:
            return RepositoryConstants.Tables.WORKER_ROLES_GROUPS
        case .HOLIDAYS:
            return RepositoryConstants.Tables.HOLIDAYS
        case .JOBS_HISTORY:
            return RepositoryConstants.Tables.JOB_HISTORY
        case .QUOTES:
            return RepositoryConstants.Tables.QOUTES
        case .ESTIMATES:
            return RepositoryConstants.Tables.ESTIMATES
        case .INVOICES:
            return RepositoryConstants.Tables.INVOICES
        case .PAYMENTS:
            return RepositoryConstants.Tables.PAYMENTS
        case .SERVICES_USED:
            return RepositoryConstants.Tables.SERVICES_USED
        case .PARTS_USED:
            return RepositoryConstants.Tables.PARTS_USED
        case .SUPPLIES_USED:
            return RepositoryConstants.Tables.SUPPLIES_USED
        case .SUPPLIES:
            return RepositoryConstants.Tables.SUPPLIES
        case .JOB_DETAILS:
            return RepositoryConstants.Tables.JOB_DETAILS
        case .RECEIPTS:
            return RepositoryConstants.Tables.RECEIPTS
        case .APPROVALS:
            return RepositoryConstants.Tables.APPROVAL
        case .SUPPLY_FINDERS:
            return RepositoryConstants.Tables.SUPPLY_FINDERS
        case .PURCHASE_ORDER:
            return RepositoryConstants.Tables.PURCHASE_ORDERS
        case .PURCHASE_ORDER_USED:
            return RepositoryConstants.Tables.PURCHASE_ORDERS_Used
        case .WORK_ORDER:
            return RepositoryConstants.Tables.WORK_ORDERS
        case .WORK_ORDER_USED:
            return RepositoryConstants.Tables.WORK_ORDERS_Used
        case .EXPENSE_STATEMENTS:
            return RepositoryConstants.Tables.EXPENSE_STATEMENTS
        case .EXPENSE_STATEMENTS_USED:
            return RepositoryConstants.Tables.EXPENSE_STATEMENTS_USED
        case .CURRENT_TIME_SHEETS:
            return RepositoryConstants.Tables.CURRENT_TIME_SHEETS
        }
    }
    
    func setIdKey() -> String {
        return "id"
    }
    
    func makeSortableCondition(key: String, sortType: SortType) -> String {
        let type = (sortType == .ASCENDING) ? "ASC" : "DESC"
        return "ORDER BY \(key) \(type)"
    }
    
    func makeSearchableCondition(key: String?, fields: [String]) -> String {
        guard let key = key, !fields.isEmpty else { return "" }
        guard let lastField = fields.last else { return "" }
        var baseCondition = "("
        
        for fieldIndex in 0..<fields.count - 1  {
            baseCondition += "CAST(\(fields[fieldIndex]) AS varchar) LIKE '%\(key)%' OR "
        }
        
        baseCondition += "\(lastField) LIKE '%\(key)%')"
        return baseCondition
    }
    
    func getShowRemoveCondition(showRemoved: Bool, searchable: String) -> String {
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

    func createRange(from list: [Int]) -> String {
        var sql = "("
        for (index,item) in list.enumerated() {
            if index == list.count - 1 { break }
            sql.append("\(item),")
        }
        if let lastItem = list.last {
            sql.append("\(lastItem))")
        }
        else {
            sql.append(")")
        }
        return sql
    }

    func softDelete(atId: Int, success: @escaping () -> (), fail: @escaping (_ error: Error) -> ()) {
        let sql = """
            UPDATE \(tableName)
            SET
                \(RepositoryConstants.Columns.REMOVED) = 1,
                \(RepositoryConstants.Columns.REMOVED_DATE) = '\(DateManager.getStandardDateString(date: Date()))'
            WHERE \(tableName).\(setIdKey()) = :id;
        """
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: ["id": atId],
                                     typeOfAction: .update, updatedId: UInt64(atId),
                                     success: { _ in
                                        success()
                                     },
                                     fail: fail)
    }
    
    func restoreItem(atId: Int, success: @escaping () -> (), fail: @escaping (_ error: Error) -> ()) {
        let sql = """
            UPDATE \(tableName)
            SET \(RepositoryConstants.Columns.REMOVED) = 0
            WHERE \(tableName).\(setIdKey()) = :id;
        """
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: ["id": atId],
                                     typeOfAction: .update, updatedId: UInt64(atId),
                                     success: { _ in
                                        success()
                                     },
                                     fail: fail)
    }
    
    func deleteItem(atId: Int, success: @escaping () -> (), fail: @escaping (_ error: Error) -> ()) {
        let sql = """
            DELETE FROM \(tableName)
            WHERE \(tableName).\(setIdKey()) = :id;
        """
        AppDatabase.shared.executeSQL(sql: sql,
                                      arguments: ["id": atId],typeOfAction: .update, updatedId: UInt64(atId),
                                      success: { _ in
                                        success()
                                      },
                                      fail: { error in
                                        print(error)
                                        fail(error)
                                      })
    }
}
