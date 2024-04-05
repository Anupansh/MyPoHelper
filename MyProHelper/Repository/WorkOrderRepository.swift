//
//  WorkOrderRepository.swift
//  MyProHelper
//
//  Created by sismac010 on 06/04/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import GRDB

class WorkOrderRepository: BaseRepository {
    
    init() {
        super.init(table: .WORK_ORDER)
    }
    
    override func setIdKey() -> String {
        return COLUMNS.WORK_ORDER_ID
    }
    
    func insertWorkOrder(workOrder: WorkOrder, success: @escaping(_ purchaseOrderID: Int64) -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "workerId"              : workOrder.workerId,
            "customerId"            : workOrder.customerId,
            "description"           : workOrder.description,
            "status"                : workOrder.status ?? "R",
            "remarks"               : workOrder.remarks ?? "",
            "dateCreated"           : DateManager.getStandardDateString(date: workOrder.dateCreated),
            "dateApproved"          : DateManager.getStandardDateString(date: workOrder.dateApproved),
            "approvedBy"            : workOrder.approvedBy ?? 0,
            "dateModified"          : DateManager.getStandardDateString(date: workOrder.dateModified),
            "sampleWorkOrder"       : workOrder.sampleWorkOrder ?? 0,
            "removed"               : workOrder.removed ?? 0,
            "removedDate"           : DateManager.getStandardDateString(date: workOrder.removedDate),
            "numberOfAttachments"   : workOrder.numberOfAttachments
            
        ]
        let sql = """
            INSERT INTO chg.\(tableName) (
                \(COLUMNS.WORKER_ID),
                \(COLUMNS.CUSTOMER_ID),
                \(COLUMNS.DESCRIPTION),
                \(COLUMNS.STATUS),
                \(COLUMNS.REMARKS),
                \(COLUMNS.DATE_CREATED),
                \(COLUMNS.DATE_APPROVED),
                \(COLUMNS.APPROVED_BY),
                \(COLUMNS.DATE_MODIFIED),
                \(COLUMNS.SAMPLE_WORK_ORDER),
                \(COLUMNS.REMOVED),
                \(COLUMNS.REMOVED_DATE),
                \(COLUMNS.NUMBER_OF_ATTACHMENTS))

            VALUES (:workerId,
                    :customerId,
                    :description,
                    :status,
                    :remarks,
                    :dateCreated,
                    :dateApproved,
                    :approvedBy,
                    :dateModified,
                    :sampleWorkOrder,
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
    
    
    func update(workOrder: WorkOrder, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "id"                    : workOrder.workOrderId,
            "workerId"              : workOrder.workerId,
            "customerId"            : workOrder.customerId,
            "description"           : workOrder.description,
            "status"                : workOrder.status ?? "R",
            "remarks"               : workOrder.remarks ?? "",
            "dateCreated"           : DateManager.getStandardDateString(date: workOrder.dateCreated),
            "dateApproved"          : DateManager.getStandardDateString(date: workOrder.dateApproved),
            "approvedBy"            : workOrder.approvedBy ?? 0,
            "dateModified"          : DateManager.getStandardDateString(date: workOrder.dateModified),
            "sampleWorkOrder"       : workOrder.sampleWorkOrder ?? 0,
            "removed"               : workOrder.removed,
            "removedDate"           : DateManager.getStandardDateString(date: workOrder.removedDate),
            "numberOfAttachments"   : workOrder.numberOfAttachments
            
        ]
        let sql = """
            UPDATE \(tableName) SET
                \(COLUMNS.WORKER_ID)                = :workerId,
                \(COLUMNS.CUSTOMER_ID)              = :customerId,
                \(COLUMNS.DESCRIPTION)              = :description,
                \(COLUMNS.STATUS)                   = :status,
                \(COLUMNS.REMARKS)                  = :remarks,
                \(COLUMNS.DATE_CREATED)             = :dateCreated,
                \(COLUMNS.DATE_APPROVED)            = :dateApproved,
                \(COLUMNS.APPROVED_BY)              = :approvedBy,
                \(COLUMNS.DATE_MODIFIED)            = :dateModified,
                \(COLUMNS.SAMPLE_WORK_ORDER)        = :sampleWorkOrder,
                \(COLUMNS.REMOVED)                  = :removed,
                \(COLUMNS.REMOVED_DATE)             = :removedDate,
                \(COLUMNS.NUMBER_OF_ATTACHMENTS)    = :numberOfAttachments
            WHERE \(tableName).\(setIdKey()) = :id;
            """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,
                                     typeOfAction: .update, updatedId: UInt64(workOrder.workOrderId!),
                                     success: { _ in
                                        success()
                                     },
                                     fail: failure)
    }
    
    func Edit(workOrder: WorkOrder, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "id"                    : workOrder.workOrderId,
            "workerId"              : workOrder.workerId,
            "customerId"            : workOrder.customerId,
            "description"           : workOrder.description,
            "status"                : workOrder.status ?? "Requested",
            "remarks"               : workOrder.remarks ?? "",
            "dateCreated"           : DateManager.getStandardDateString(date: workOrder.dateCreated),
            "dateApproved"          : DateManager.getStandardDateString(date: workOrder.dateApproved),
            "approvedBy"            : workOrder.approvedBy,
            "dateModified"          : DateManager.getStandardDateString(date: workOrder.dateModified),
            "sampleWorkOrder"       : workOrder.sampleWorkOrder ?? 0,
            "removed"               : workOrder.removed,
            "removedDate"           : DateManager.getStandardDateString(date: workOrder.removedDate),
            "numberOfAttachments"   : workOrder.numberOfAttachments
            
        ]
        let sql = """
            UPDATE \(tableName) SET
                \(COLUMNS.WORKER_ID)                = :workerId,
                \(COLUMNS.CUSTOMER_ID)              = :customerId,
                \(COLUMNS.DESCRIPTION)              = :description,
                \(COLUMNS.STATUS)                   = :status,
                \(COLUMNS.Remarks)                  = :remarks,
                \(COLUMNS.DATE_CREATED)             = :dateCreated,
                \(COLUMNS.DATE_APPROVED)            = :dateApproved,
                \(COLUMNS.APPROVED_BY)              = :approvedBy,
                \(COLUMNS.DATE_MODIFIED)            = :dateModified,
                \(COLUMNS.SAMPLE_WORK_ORDER)        = :sampleWorkOrder,
                \(COLUMNS.REMOVED)                  = :removed,
                \(COLUMNS.REMOVED_DATE)             = :removedDate,
                \(COLUMNS.NUMBER_OF_ATTACHMENTS)    = :numberOfAttachments
            WHERE \(tableName).\(setIdKey()) = :id;
            """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,
                                      typeOfAction: .update,updatedId: UInt64(workOrder.workOrderId!),
                                     success: { _ in
                                        success()
                                     },
                                     fail: failure)
    }
    
    func fetchWorkOrders(showRemoved: Bool, with key: String? = nil, sortBy: WorkOrderField? = nil , sortType: SortType? = nil ,offset: Int,success: @escaping(_ supplies: [WorkOrder]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        
        let sortable = makeSortableItems(sortBy: sortBy, sortType: sortType)
        let searchable = makeSearchableItems(key: key)
        
        let removedCondition = """
                WHERE (main.\(tableName).\(COLUMNS.REMOVED) = 0
                OR main.\(tableName).\(COLUMNS.REMOVED) is NULL)
                AND (main.\(TABLES.WORK_ORDERS_Used).\(COLUMNS.REMOVED) = 0
                OR main.\(TABLES.WORK_ORDERS_Used).\(COLUMNS.REMOVED) is NULL)
                """
        
        let showRemovedCondition = """
                WHERE (main.\(tableName).\(COLUMNS.REMOVED) = 1)
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
        SELECT main.\(tableName).\(COLUMNS.DESCRIPTION),main.\(tableName).\(COLUMNS.WORK_ORDER_ID),main.\(tableName).\(COLUMNS.WORKER_ID),
        CASE WHEN main.\(tableName).\(COLUMNS.WORKER_ID) > 0 THEN main.\(TABLES.WORKERS).\(COLUMNS.FIRST_NAME) || ' ' || main.\(TABLES.WORKERS).\(COLUMNS.LAST_NAME) ELSE '' END AS \(COLUMNS.WORKER_NAME),main.\(TABLES.WORKERS).\(COLUMNS.EMAIL),
        CASE WHEN main.\(tableName).\(COLUMNS.APPROVED_BY) > 0 THEN A.\(COLUMNS.FIRST_NAME) || ' ' || A.\(COLUMNS.LAST_NAME) ELSE '' END AS \(COLUMNS.APPROVER_NAME),main.\(TABLES.CUSTOMERS).\(COLUMNS.CUSTOMER_NAME),
        CASE WHEN main.\(TABLES.WORK_ORDERS_Used).\(COLUMNS.PART_ID) > 0 THEN main.\(TABLES.PARTS).\(COLUMNS.PART_NAME) ELSE '' END AS \(COLUMNS.PART_NAME),
        CASE WHEN main.\(TABLES.WORK_ORDERS_Used).\(COLUMNS.SUPPLY_ID) > 0 THEN main.\(TABLES.SUPPLIES).\(COLUMNS.SUPPLY_NAME) ELSE '' END AS \(COLUMNS.SUPPLY_NAME),
        SUM(main.\(TABLES.WORK_ORDERS_Used).\(COLUMNS.AMOUNT_OF_LINE_ITEM)) AS \(COLUMNS.AMOUNT_OF_LINE_ITEM),
        main.\(tableName).\(COLUMNS.REMOVED) as \(COLUMNS.REMOVED),
        ROW_NUMBER() OVER (ORDER BY main.\(tableName).\(COLUMNS.WORK_ORDER_ID)) AS RowNum
        FROM main.\(tableName)

        JOIN main.\(TABLES.WORK_ORDERS_Used) ON main.\(tableName).\(COLUMNS.WORK_ORDER_ID) == main.\(TABLES.WORK_ORDERS_Used).\(COLUMNS.WORK_ORDER_ID)
        JOIN main.\(TABLES.PARTS) ON main.\(TABLES.WORK_ORDERS_Used).\(COLUMNS.PART_ID) == main.\(TABLES.PARTS).\(COLUMNS.PART_ID)
        JOIN main.\(TABLES.CUSTOMERS) ON main.\(tableName).\(COLUMNS.CUSTOMER_ID) == main.\(TABLES.CUSTOMERS).\(COLUMNS.CUSTOMER_ID) AND (main.\(TABLES.CUSTOMERS).\(COLUMNS.REMOVED) = 0 OR main.\(TABLES.CUSTOMERS).\(COLUMNS.REMOVED) is NULL)
        JOIN main.\(TABLES.SUPPLIES) ON main.\(TABLES.WORK_ORDERS_Used).\(COLUMNS.SUPPLY_ID) == main.\(TABLES.SUPPLIES).\(COLUMNS.SUPPLY_ID)
        JOIN main.\(TABLES.WORKERS) ON main.\(tableName).\(COLUMNS.WORKER_ID) == main.\(TABLES.WORKERS).\(COLUMNS.WORKER_ID)
        LEFT JOIN main.\(TABLES.WORKERS) A ON main.\(tableName).\(COLUMNS.APPROVED_BY) == A.\(COLUMNS.WORKER_ID)
        \(condition)
        GROUP BY main.\(TABLES.WORK_ORDERS_Used).\(COLUMNS.WORK_ORDER_ID)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        sql += """
                \(sortable.replaceMain())
                LIMIT \(LIMIT) OFFSET \(offset);
        """
        /*
        let sql2 = """
                SELECT * from \(tableName)
        """
         */
        /*
        let sql3 = """
                SELECT \(tableName).*,
                CASE WHEN \(tableName).\(COLUMNS.APPROVED_BY) > 0 THEN \(TABLES.WORKERS).\(COLUMNS.FIRST_NAME) || ' ' || \(TABLES.WORKERS).\(COLUMNS.LAST_NAME) ELSE '' END AS \(COLUMNS.APPROVER_NAME),\(TABLES.CUSTOMERS).\(COLUMNS.CUSTOMER_NAME)
                FROM \(tableName)
                JOIN \(TABLES.CUSTOMERS) ON \(tableName).\(COLUMNS.CUSTOMER_ID) == \(TABLES.CUSTOMERS).\(COLUMNS.CUSTOMER_ID) AND (\(TABLES.CUSTOMERS).\(COLUMNS.REMOVED) = 0 OR \(TABLES.CUSTOMERS).\(COLUMNS.REMOVED) is NULL)
                JOIN \(TABLES.WORKERS) ON \(tableName).\(COLUMNS.WORKER_ID) == \(TABLES.WORKERS).\(COLUMNS.WORKER_ID)
                
        """
         */
        do {
            let workOrders = try queue.read({ (db) -> [WorkOrder] in
                var workOrders: [WorkOrder] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    workOrders.append(.init(row: row))
                }
                return workOrders
            })
            success(workOrders)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    func removeWorkOrder(workOrder: WorkOrder, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = workOrder.workOrderId else {
                return
        }
        softDelete(atId: id, success: success, fail: failure)
    }
    
    func unremoveWorkOrder(workOrder: WorkOrder, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = workOrder.workOrderId else {
                return
        }
        restoreItem(atId: id, success: success, fail: failure)
    }
    
    
    private func makeSortableItems(sortBy: WorkOrderField?, sortType: SortType?) -> String {
        guard let sortBy = sortBy, let sortType = sortType else {
            return makeSortableCondition(key: COLUMNS.WORKER_NAME, sortType: .ASCENDING)
        }
        switch sortBy {
        case .CUSTOMER_NAME:
            return makeSortableCondition(key: COLUMNS.CUSTOMER_NAME, sortType: sortType)
        case .DESCRIPTION:
            return makeSortableCondition(key: COLUMNS.DESCRIPTION, sortType: sortType)
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
