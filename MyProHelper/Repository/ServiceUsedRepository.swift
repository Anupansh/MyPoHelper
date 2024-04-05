//
//  ServiceUsedRepository.swift
//  MyProHelper
//
//  Created by Deep on 2/7/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import GRDB

class ServiceUsedRepository: BaseRepository {
    
    init() {
        super.init(table: .SERVICES_USED)
     // createSelectedLayoutTable()
    }
 
    override func setIdKey() -> String {
        return COLUMNS.SERVICE_USED_ID
    }
    
    func fetchServiceUsed(invoiceSerivceId: Int? = nil, offset: Int, success: @escaping(_ services: [ServiceUsed]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        guard let invoiceId = invoiceSerivceId else { return }
        
        let arguments: StatementArguments = []
        
        var sql = """
        SELECT * FROM main.\(tableName)
        LEFT JOIN main.\(TABLES.SERVICE_TYPES) ON main.\(tableName).\(COLUMNS.SERICE_TYPE_ID) ==  main.\(TABLES.SERVICE_TYPES).\(COLUMNS.SERICE_TYPE_ID)
        WHERE main.\(tableName).\(COLUMNS.INVOICE_ID) == \(invoiceId)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            let services = try queue.read({ (db) -> [ServiceUsed] in
                var services: [ServiceUsed] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: arguments)
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
    
    func addServiceUsed(service: ServiceUsed, success: @escaping (_ serviceUsedId: Int64)->(), failure: @escaping (_ error: Error)->()) {

        let arguments: StatementArguments = [
            "serviceTypeId"         : service.serviceTypeId,
            "invoiceId"             : service.invoiceId,
            "priceToResell"         : service.priceToResell,
            "quantity"              : service.quantity,
            "dateAdded"             : DateManager.getStandardDateString(date: service.dateAdded),
            "dateModified"          : DateManager.getStandardDateString(date: service.dateModified),
            "removed"               : service.removed,
            "removedDate"           : DateManager.getStandardDateString(date: service.removedDate)
        ]
        let sql = """
            INSERT INTO chg.\(tableName) (
                \(COLUMNS.SERICE_TYPE_ID),
                \(COLUMNS.INVOICE_ID),
                \(COLUMNS.PRICE_TO_RESELL),
                \(COLUMNS.QUANTITY),
                \(COLUMNS.DATE_ADDED),
                \(COLUMNS.DATE_MODIFIED),
                \(COLUMNS.REMOVED),
                \(COLUMNS.REMOVED_DATE))

            VALUES (:serviceTypeId,
                    :invoiceId,
                    :priceToResell,
                    :quantity,
                    :dateAdded,
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
    
    func updateServiceUsed(service: ServiceUsed, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "serviceUsedId"         : service.serviceUsedId,
            "serviceTypeId"         : service.serviceTypeId,
            "invoiceId"             : service.invoiceId,
            "priceToResell"         : service.priceToResell,
            "quantity"              : service.quantity,
            "dateAdded"             : DateManager.getStandardDateString(date: service.dateAdded),
            "dateModified"          : DateManager.getStandardDateString(date: service.dateModified),
            "removed"               : service.removed,
            "removedDate"           : DateManager.getStandardDateString(date: service.removedDate)
        ]
        let sql = """
            UPDATE \(tableName) SET
            
                \(COLUMNS.SERICE_TYPE_ID)           =:serviceTypeId,
                \(COLUMNS.INVOICE_ID)               =:invoiceId,
                \(COLUMNS.PRICE_TO_RESELL)          =:priceToResell,
                \(COLUMNS.QUANTITY)                 =:quantity,
                \(COLUMNS.DATE_ADDED)               =:dateAdded,
                \(COLUMNS.DATE_MODIFIED)            =:dateModified,
                \(COLUMNS.REMOVED)                  =:removed,
                \(COLUMNS.REMOVED_DATE)             =:removedDate,

            WHERE \(tableName).\(setIdKey()) = :serviceUsedId;
            """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,
                                     typeOfAction: .update, updatedId: UInt64(service.serviceUsedId!),
                                     success: { _ in
                                        success()
                                     },
                                     fail: failure)
    }
    
    func deleteServiceUsed(service: ServiceUsed, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = service.serviceUsedId else { return }
        softDelete(atId: id, success: success, fail: failure)
    }
    
    func restoreServiceUsed(service: ServiceUsed, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = service.serviceUsedId else { return }
        restoreItem(atId: id, success: success, fail: failure)
    }
    
}
