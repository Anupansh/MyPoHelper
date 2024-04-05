//
//  ServiceTypeDBService.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 10/06/1942 Saka.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB

class ServiceTypeRepository: BaseRepository {
    
    
    init() {
        super.init(table: .SERVICE_TYPES)
        createSelectedLayoutTable()
    }
    
    override func setIdKey() -> String {
        return COLUMNS.SERICE_TYPE_ID
    }
    
    private func createSelectedLayoutTable() {
        let sql = """
         CREATE TABLE IF NOT EXISTS \(tableName)(
            \(COLUMNS.SERICE_TYPE_ID) INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL,
            \(COLUMNS.DESCRIPTION)          TEXT (1000),
            \(COLUMNS.PRICE_QUOTE)          REAL,
            \(COLUMNS.DATE_CREATED)         TEXT,
            \(COLUMNS.DATE_MODIFIED)        TEXT,
            \(COLUMNS.SAMPLE_SERVICE_TYPE)  INTEGER DEFAULT(0),
            \(COLUMNS.REMOVED)              INTEGER DEFAULT(0),
            \(COLUMNS.REMOVED_DATE)         TEXT
        )
        """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                      arguments: [],typeOfAction: .create, updatedId: nil) { (_) in

            print("TABLE SERVICE_TYPES IS CREATED SUCCESSFULLY")
        } fail: { (error) in
            print(error)
        }
    }
    
    func insertServiceType(serviceType: ServiceType, success: @escaping(_ id: Int64) -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "description"           : serviceType.description,
            "priceQoute"            : serviceType.priceQuote,
            "dateCreated"           : DateManager.getStandardDateString(date: serviceType.dateCreated),
            "dateModified"          : DateManager.getStandardDateString(date: serviceType.dateModified),
            "removed"               : serviceType.removed,
            "removedDate"           : DateManager.getStandardDateString(date: serviceType.removedDate)
        ]
        let sql = """
            INSERT INTO chg.\(tableName) (
                \(COLUMNS.DESCRIPTION),
                \(COLUMNS.PRICE_QUOTE),
                \(COLUMNS.DATE_CREATED),
                \(COLUMNS.DATE_MODIFIED),
                \(COLUMNS.REMOVED),
                \(COLUMNS.REMOVED_DATE))

            VALUES (:description,
                    :priceQoute,
                    :dateCreated,
                    :dateModified,
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
    
    func update(serviceType: ServiceType, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "id"                    : serviceType.serviceTypeID,
            "description"           : serviceType.description,
            "priceQoute"            : serviceType.priceQuote,
            "dateCreated"           : DateManager.getStandardDateString(date: serviceType.dateCreated),
            "dateModified"          : DateManager.getStandardDateString(date: serviceType.dateModified),
            "removed"               : serviceType.removed,
            "removedDate"           : DateManager.getStandardDateString(date: serviceType.removedDate)
        ]
        let sql = """
            UPDATE \(tableName) SET
                \(COLUMNS.DESCRIPTION)      = :description,
                \(COLUMNS.PRICE_QUOTE)      = :priceQoute,
                \(COLUMNS.DATE_CREATED)     = :dateCreated,
                \(COLUMNS.DATE_MODIFIED)    = :dateModified,
                \(COLUMNS.REMOVED)          = :removed,
                \(COLUMNS.REMOVED_DATE)     = :removedDate
            WHERE \(tableName).\(setIdKey()) = :id;
            """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                      arguments: arguments,
                                      typeOfAction: .update, updatedId: UInt64(serviceType.serviceTypeID!),
                                      success: { _ in
                                        success()
                                      },
                                      fail: failure)
    }
    
    func delete(serviceType: ServiceType, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = serviceType.serviceTypeID else { return }
        softDelete(atId: id, success: success, fail: failure)
    }
    
    func restoreServiceType(serviceType: ServiceType, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = serviceType.serviceTypeID else { return }
        restoreItem(atId: id, success: success, fail: failure)
    }
    
    func fetchService(showRemoved: Bool, with key: String? = nil, sortBy: ServiceField? = nil, sortType: SortType? = nil ,offset: Int,success: @escaping(_ service: [ServiceType]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        let sortable = makeSortableItems(sortBy: sortBy, sortType: sortType)
        let searchable = makeSearchableItems(key: key)
        let removedCondition = """
        WHERE (main.\(tableName).\(COLUMNS.REMOVED) = 0
        OR main.\(tableName).\(COLUMNS.REMOVED) is NULL)
        """
        let showRemovedCondition = """
                WHERE (main.\(tableName).\(COLUMNS.REMOVED) = 1)
                AND main.\(tableName).\(COLUMNS.DESCRIPTION) != '--SELECT--'
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
        \(condition)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        sql += """
                \(sortable)
        """
//        LIMIT \(LIMIT) OFFSET \(offset);
        
        
        do {
            let services = try queue.read({ (db) -> [ServiceType] in
                var services: [ServiceType] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    services.append(.init(row: row))
                }
                return services
            })
            success(services)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    private func makeSortableItems(sortBy: ServiceField?, sortType: SortType?) -> String {
        guard let sortBy = sortBy, let sortType = sortType else {
            return makeSortableCondition(key: COLUMNS.DESCRIPTION, sortType: .ASCENDING)
        }
        switch sortBy {
        case .DESCRIPTION:
            return makeSortableCondition(key: COLUMNS.DESCRIPTION, sortType: sortType)
        case .PRICE_QUOTE:
            return makeSortableCondition(key: COLUMNS.PRICE_QUOTE, sortType: sortType)
        case .CREATED_DATE:
            return makeSortableCondition(key: COLUMNS.DATE_CREATED, sortType: sortType)
        }
    }
    
    private func makeSearchableItems(key: String?) -> String {
        guard let key = key else { return "" }
        return  makeSearchableCondition(key: key,
                                        fields: [
                                            COLUMNS.DESCRIPTION,
                                            COLUMNS.PRICE_QUOTE,
                                            COLUMNS.DATE_CREATED])
    }
}
