//
//  EstimateRepository.swift
//  MyProHelper
//
//  Created by Deep on 1/31/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB

class  EstimateRepository: BaseRepository {
    
    init() {
        super.init(table: .ESTIMATES)
    }
    
    override func setIdKey() -> String {
        return COLUMNS.ESTIMATE_ID
    }
    
    func fetchEstimates(showRemoved: Bool, with key: String? = nil, sortBy: EstimatesListFields? = nil, sortType: SortType? = nil ,offset: Int,success: @escaping(_ users: [Estimate]) -> (), failure: @escaping(_ error: Error) -> ()) {
        
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        let sortable = makeSortableItems2(sortBy: sortBy, sortType: sortType)
        let searchable = makeSearchableItems(key: key)
        let condition = getShowRemoveCondition2(showRemoved: showRemoved, searchable: searchable)
        
        var sql = """
        SELECT C.\(COLUMNS.CUSTOMER_NAME),* FROM main.\(tableName) E
        JOIN main.\(TABLES.CUSTOMERS) C ON E.\(COLUMNS.CUSTOMER_ID) == C.\(COLUMNS.CUSTOMER_ID)
            \(condition)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        sql += """
                \(sortable)
        """
//        LIMIT \(LIMIT) OFFSET \(offset);
        do {
            let estimate = try queue.read({ (db) -> [Estimate] in
                var estimate: [Estimate] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    estimate.append(.init(row: row))
                }
                return estimate
            })
            success(estimate)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    func fetchEstimates(showRemoved: Bool, with key: String? = nil, sortBy: QuoteEstimateField? = nil, sortType: SortType? = nil ,offset: Int,success: @escaping(_ users: [QuoteEstimate]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        let sortable = makeSortableItems(sortBy: sortBy, sortType: sortType)
        let searchable = makeSearchableItems(key: key)
        let condition = getShowRemoveCondition(showRemoved: showRemoved, searchable: searchable)
    
        var sql = """
        SELECT * FROM main.\(tableName)
        LEFT JOIN main.\(TABLES.CUSTOMERS) ON main.\(tableName).\(COLUMNS.CUSTOMER_ID) == main.\(TABLES.CUSTOMERS).\(COLUMNS.CUSTOMER_ID)
            \(condition)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        sql += """
                \(sortable)
                LIMIT \(LIMIT) OFFSET \(offset);
        """
        do {
            let estimates = try queue.read({ (db) -> [QuoteEstimate] in
                var estimates: [QuoteEstimate] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    estimates.append(.init(row: row))
                }
                return estimates
            })
            print(estimates)
            success(estimates)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    func insertEstimate(estimate: QuoteEstimate, success: @escaping(_ estimateId: Int64) -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "customerID"            : estimate.customerID,
            "description"           : estimate.description,
            "priceQuoted"           : estimate.priceQuoted,
            "priceEstimate"         : estimate.priceEstimate,
            "priceFixedPrice"       : estimate.priceFixedPrice,
            "dateCreated"           : DateManager.getStandardDateString(date: estimate.dateCreated),
            "dateModified"          : DateManager.getStandardDateString(date: estimate.dateModified),
            "priceExpires"          : estimate.priceExpires,
            "sampleEstimate"        : estimate.sampleQuote,
            "removed"               : estimate.removed,
            "removedDate"           : DateManager.getStandardDateString(date: estimate.removedDate),
            "numberOfAttachments"   : estimate.numberOfAttachments
        ]
        let sql = """
            INSERT INTO chg.\(tableName) (
                \(COLUMNS.CUSTOMER_ID),
                \(COLUMNS.DESCRIPTION),
                \(COLUMNS.PRICE_QUOTED),
                \(COLUMNS.PRICE_ESTIMATE),
                \(COLUMNS.PRICE_FIXED_PRICE),
                \(COLUMNS.DATE_CREATED),
                \(COLUMNS.DATE_MODIFIED),
                \(COLUMNS.PRICE_EXPIRES),
                \(COLUMNS.SAMPLE_ESTIMATE),
                \(COLUMNS.REMOVED),
                \(COLUMNS.REMOVED_DATE),
                \(COLUMNS.NUMBER_OF_ATTACHMENTS)
            )

            VALUES (:customerID,
                    :description,
                    :priceQuoted,
                    :priceEstimate,
                    :priceFixedPrice,
                    :dateCreated,
                    :dateModified,
                    :priceExpires,
                    :sampleEstimate,
                    :removed,
                    :removedDate,
                    :numberOfAttachments
            )
            """
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,
                                     typeOfAction: .insert, updatedId: nil,
                                     success: { id in
                                        success(id)
                                     },
                                     fail: failure)
    }
    
    func updateEstimate(estimate: QuoteEstimate, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ())
    {
        let arguments: StatementArguments = [
            "id"                    : estimate.estimateId,
            "customerID"            : estimate.customerID,
            "description"           : estimate.description,
            "priceQuoted"           : estimate.priceQuoted,
            "priceEstimate"         : estimate.priceEstimate,
            "priceFixedPrice"       : estimate.priceFixedPrice,
            "dateCreated"           : DateManager.getStandardDateString(date: estimate.dateCreated),
            "dateModified"          : DateManager.getStandardDateString(date: estimate.dateModified),
            "priceExpires"          : estimate.priceExpires,
            "sampleEstimate"        : estimate.sampleQuote,
            "removed"               : estimate.removed,
            "removedDate"           : DateManager.getStandardDateString(date: estimate.removedDate),
            "numberOfAttachments"   : estimate.numberOfAttachments
        ]
        
        let sql = """
            UPDATE \(tableName) SET
                \(COLUMNS.CUSTOMER_ID)              = :customerID,
                \(COLUMNS.DESCRIPTION)              = :description,
                \(COLUMNS.PRICE_QUOTED)             = :priceQuoted,
                \(COLUMNS.PRICE_ESTIMATE)           = :priceEstimate,
                \(COLUMNS.PRICE_FIXED_PRICE)        = :priceFixedPrice,
                \(COLUMNS.DATE_CREATED)             = :dateCreated,
                \(COLUMNS.DATE_MODIFIED)            = :dateModified,
                \(COLUMNS.PRICE_EXPIRES)            = :priceExpires,
                \(COLUMNS.SAMPLE_ESTIMATE)          = :sampleEstimate,
                \(COLUMNS.REMOVED)                  = :removed,
                \(COLUMNS.REMOVED_DATE)             = :removedDate,
                \(COLUMNS.NUMBER_OF_ATTACHMENTS)    = :numberOfAttachments
            WHERE \(tableName).\(setIdKey()) = :id;
            """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,
                                     typeOfAction: .update, updatedId: UInt64(estimate.estimateId!),
                                     success: { _ in
                                        success()
                                     },
                                     fail: failure)
    }
    
    func deleteEstimate(estimate : QuoteEstimate, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = estimate.estimateId else { return }
        softDelete(atId: id, success: success, fail: failure)
    }
    
    func restoreEstimate(estimate: QuoteEstimate, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = estimate.estimateId else { return }
        restoreItem(atId: id, success: success, fail: failure)
    }
    
    private func makeSortableItems(sortBy: QuoteEstimateField?, sortType: SortType?) -> String {
        guard let sortBy = sortBy, let sortType = sortType else {
            return makeSortableCondition(key: COLUMNS.CUSTOMER_NAME, sortType: .ASCENDING)
        }
        switch sortBy {
            case .CUSOTMER_NAME:
                return makeSortableCondition(key: COLUMNS.CUSTOMER_NAME, sortType: sortType)
            case .DESCRIPTION:
                return makeSortableCondition(key: COLUMNS.DESCRIPTION, sortType: sortType)
            case .PRICE_QUOTED:
                return makeSortableCondition(key: COLUMNS.PRICE_QUOTED, sortType: sortType)
            case .PRICE_ESTIMATE:
                return makeSortableCondition(key: COLUMNS.PRICE_ESTIMATE, sortType: sortType)
            case .FIXED_PRICE:
                return makeSortableCondition(key: COLUMNS.PRICE_FIXED_PRICE, sortType: sortType)
            case .QUOTE_EXPIRATION:
                return makeSortableCondition(key: COLUMNS.PRICE_EXPIRES, sortType: sortType)
            case .ATTACHMENTS:
                return makeSortableCondition(key: COLUMNS.NUMBER_OF_ATTACHMENTS, sortType: sortType)
        }
    }
    
    private func makeSortableItems2(sortBy: EstimatesListFields?, sortType: SortType?) -> String {
        guard let sortBy = sortBy, let sortType = sortType else {
            return makeSortableCondition(key: COLUMNS.CUSTOMER_NAME, sortType: .ASCENDING)
        }
        switch sortBy {
            case .CUSTOMER_NAME:
                return makeSortableCondition(key: COLUMNS.CUSTOMER_NAME, sortType: sortType)
            case .DESCRIPTION:
                return makeSortableCondition(key: COLUMNS.DESCRIPTION, sortType: sortType)
            case .PRICE_QUOTED:
                return makeSortableCondition(key: COLUMNS.PRICE_QUOTED, sortType: sortType)
            case .PRICE_ESTIMATE:
                return makeSortableCondition(key: COLUMNS.PRICE_ESTIMATE, sortType: sortType)
            case .FIXED_PRICE:
                return makeSortableCondition(key: COLUMNS.PRICE_FIXED_PRICE, sortType: sortType)
            case .QUOTE_EXPIRATION:
                return makeSortableCondition(key: COLUMNS.PRICE_EXPIRES, sortType: sortType)
//            case .ATTACHMENTS:
//                return makeSortableCondition(key: COLUMNS.NUMBER_OF_ATTACHMENTS, sortType: sortType)
            case .NO_DOT:
                return makeSortableCondition(key: COLUMNS.ESTIMATE_ID, sortType: sortType)
        }
    }
    
    private func makeSearchableItems(key: String?) -> String {
        guard let key = key else { return "" }
        return makeSearchableCondition(key: key,
                                       fields: [
                                        COLUMNS.CUSTOMER_NAME,
                                        COLUMNS.DESCRIPTION,
                                        COLUMNS.PRICE_QUOTED,
                                        COLUMNS.PRICE_ESTIMATE,
                                        COLUMNS.PRICE_FIXED_PRICE,
                                        COLUMNS.PRICE_EXPIRES,
                                        COLUMNS.NUMBER_OF_ATTACHMENTS])
    }
    
    private func getShowRemoveCondition2(showRemoved: Bool, searchable: String) -> String {
        let removedCondition = """
        WHERE (E.\(COLUMNS.REMOVED) = 0
        OR E.\(COLUMNS.REMOVED) is NULL)
        """
        
        let removedItemsCondition = """
        WHERE (E.\(COLUMNS.REMOVED) = 1)
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
    
}
