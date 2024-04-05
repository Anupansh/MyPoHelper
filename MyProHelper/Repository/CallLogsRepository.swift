//
//  CallLogsRepository.swift
//  MyProHelper
//
//  Created by sismac010 on 02/11/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB

class  CallLogsRepository: BaseRepository {
    
    init() {
        super.init(table: .ESTIMATES)
    }
    
    override func setIdKey() -> String {
        return COLUMNS.ESTIMATE_ID
    }
    
    func fetchCallLogs(showRemoved: Bool, with key: String? = nil, sortBy: CallLogFields? = nil, sortType: SortType? = nil ,offset: Int,success: @escaping(_ users: [CallLog]) -> (), failure: @escaping(_ error: Error) -> ()) {
        
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        let sortable = makeSortableItems(sortBy: sortBy, sortType: sortType)
//        let searchable = makeSearchableItems(key: key)
//        let condition = getShowRemoveCondition2(showRemoved: showRemoved, searchable: searchable)
        
//        var sql2 = """
//        SELECT \(COLUMNS.CONTACT_NAME) as \(COLUMNS.CONTACT_NAME),
//        \(COLUMNS.CONTACT_PHONE) as \(COLUMNS.CONTACT_PHONE),
//        \(COLUMNS.CUSTOMER_NAME) as \(COLUMNS.CUSTOMER_NAME),
//        C.\(COLUMNS.DATE_CREATED) as \(COLUMNS.DATE_CREATED),
//        TMP.\(COLUMNS.DESCRIPTION) as \(COLUMNS.DESCRIPTION)
//        FROM (SELECT * FROM \(TABLES.ESTIMATES) E, \(TABLES.QOUTES) Q
//         WHERE E.\(COLUMNS.DATE_CREATED) LIKE '2021-01-25%' OR Q.\(COLUMNS.DATE_CREATED) LIKE '2021-01-25%') TMP
//        JOIN \(TABLES.CUSTOMERS) C WHERE TMP.\(COLUMNS.CUSTOMER_ID) == C.\(COLUMNS.CUSTOMER_ID)
//        """
        
        var sql = """
        SELECT \(TABLES.CUSTOMERS).\(COLUMNS.CONTACT_NAME) as \(COLUMNS.CONTACT_NAME),
        \(TABLES.CUSTOMERS).\(COLUMNS.CONTACT_PHONE) as \(COLUMNS.CONTACT_PHONE),
        \(TABLES.CUSTOMERS).\(COLUMNS.CUSTOMER_NAME) as \(COLUMNS.CUSTOMER_NAME),
        OC.\(COLUMNS.DATE_CREATED) as \(COLUMNS.DATE_CREATED),
        TMP.\(COLUMNS.DESCRIPTION) as \(COLUMNS.DESCRIPTION)
        FROM (SELECT * FROM \(TABLES.ESTIMATES) JOIN main.\(TABLES.ESTIMATES) E,
        \(TABLES.QOUTES) JOIN main.\(TABLES.QOUTES) Q
        WHERE E.\(COLUMNS.DATE_CREATED) LIKE '2021-01-25%' OR Q.\(COLUMNS.DATE_CREATED) LIKE '2021-01-25%') TMP
        JOIN \(TABLES.CUSTOMERS)
        JOIN main.\(TABLES.CUSTOMERS) OC
        WHERE TMP.\(COLUMNS.CUSTOMER_ID) = \(TABLES.CUSTOMERS).\(COLUMNS.CUSTOMER_ID) AND
                OC.\(COLUMNS.CUSTOMER_ID) = \(TABLES.CUSTOMERS).\(COLUMNS.CUSTOMER_ID)
        """
//        let chgSql = " union \(sql.replaceMain())"
        sql = "\(sql.replaceMain())"
//        sql += chgSql
        sql += """
                \(sortable)
        """
//        LIMIT \(LIMIT) OFFSET \(offset);
        do {
            let callLog = try queue.read({ (db) -> [CallLog] in
                var callLog: [CallLog] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    callLog.append(.init(row: row))
                }
                return callLog
            })
            success(callLog)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    private func makeSortableItems(sortBy: CallLogFields?, sortType: SortType?) -> String {
        guard let sortBy = sortBy, let sortType = sortType else {
            return makeSortableCondition(key: COLUMNS.CONTACT_NAME, sortType: .ASCENDING)
        }
        switch sortBy {
            case .CUSTOMER_NAME:
                return makeSortableCondition(key: COLUMNS.CUSTOMER_NAME, sortType: sortType)
            case .CONTACT_PHONE:
                return makeSortableCondition(key: COLUMNS.CONTACT_PHONE, sortType: sortType)
//            case .DATE_CREATED:
//                return makeSortableCondition(key: COLUMNS.DATE_CREATED, sortType: sortType)
            case .CONTACT_NAME:
                return makeSortableCondition(key: COLUMNS.CONTACT_NAME, sortType: sortType)
            case .DESCRIPTION:
                return makeSortableCondition(key: COLUMNS.DESCRIPTION, sortType: sortType)
        }
    }
    
    private func makeSearchableItems(key: String?) -> String {
        guard let key = key else { return "" }
        return makeSearchableCondition(key: key,
                                       fields: [
                                        COLUMNS.CONTACT_NAME,
                                        COLUMNS.CUSTOMER_NAME,
                                        COLUMNS.CONTACT_PHONE,
                                        COLUMNS.DATE_CREATED])
    }
}
