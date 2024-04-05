//
//  InvoiceRepository.swift
//  MyProHelper
//
//  Created by Deep on 2/4/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB

class InvoiceRepository: BaseRepository{
    
    init() {
        super.init(table: .INVOICES)
        createSelectedLayoutTable()
    }
    
    override func setIdKey() -> String {
        return COLUMNS.INVOICE_ID
    }

    private func createSelectedLayoutTable() {
        let sql = """
         CREATE TABLE IF NOT EXISTS \(tableName)(
                \(COLUMNS.INVOICE_ID)   INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL,
                \(COLUMNS.CUSTOMER_ID)  INTEGER REFERENCES \(TABLES.CUSTOMERS) (\(COLUMNS.CUSTOMER_ID)) NOT NULL,
                \(COLUMNS.JOB_ID)       INTEGER NOT NULL,
                \(COLUMNS.DESCRIPTION)              TEXT,
                \(COLUMNS.PRICE_QUOTED)             REAL,
                \(COLUMNS.PRICE_ESTIMATE)           INTEGER         DEFAULT (1),
                \(COLUMNS.PRICE_FIXED_PRICE)        INTEGER         DEFAULT (0),
                \(COLUMNS.INVOICE_ADJUSTEMENT)      REAL,
                \(COLUMNS.PERCENT_DISCOUNT)         REAL,
                \(COLUMNS.TOTAL_INVOICE_AMOUNT)     REAL,
                \(COLUMNS.DATE_COMPLETED)           TEXT,
                \(COLUMNS.DATE_CREATED)             TEXT,
                \(COLUMNS.DATE_MODIFIED)            TEXT,
                \(COLUMNS.STATUS)                   TEXT,
                \(COLUMNS.PRICE_EXPIRES)            TEXT,
                \(COLUMNS.IS_INVOICE_CREATED)       INTEGER DEFAULT(0),
                \(COLUMNS.IS_INVOICE_FINAL)         INTEGER DEFAULT(0),
                \(COLUMNS.DATE_APPROVED)            TEXT,
                \(COLUMNS.APPROVED_BY)              INTEGER  REFERENCES Workers(WorkerID),
                \(COLUMNS.SAMPLE_INVOICE)           INTEGER DEFAULT(0),
                \(COLUMNS.REMOVED)                  INTEGER DEFAULT(0),
                \(COLUMNS.REMOVED_DATE)             TEXT,
                \(COLUMNS.NUMBER_OF_ATTACHMENTS)    INTEGER DEFAULT(0)
        )
        """

        AppDatabase.shared.executeSQL(sql: sql,
                                      arguments: [],typeOfAction: .create, updatedId: nil) { (_) in
            print("TABLE INVOICES IS CREATED SUCCESSFULLY")
        } fail: { (error) in
            print(error)
        }
    }

    func insertInvoice(invoice: Invoice, success: @escaping(_ id: Int64) -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "customerId"            : invoice.customer?.customerID,
            "JobId"                 : invoice.jobID,
            "description"           : invoice.description,
            "priceQuoted"           : invoice.priceQuoted,
            "priceEstimate"         : invoice.priceEstimate,
            "priceFixedPrice"       : invoice.priceFixedPrice,
            "invoiceAdjustment"     : invoice.invoiceAdjustement,
            "percentDiscount"       : invoice.percentDiscount,
            "totalInvoiceAmount"    : invoice.totalInvoiceAmount,
            "dateCompleted"         : invoice.dateCompleted,
            "dateCreated"           : invoice.dateCreated,
            "dateModified"          : invoice.dateModified,
            "status"                : invoice.status,
            "priceExpires"          : invoice.priceExpires,
            "isInvoiceCreated"      : invoice.isInvoiceCreated,
            "isInvoiceFinal"        : invoice.isInvoiceFinal,
            "dateApproved"          : DateManager.getStandardDateString(date: invoice.dateApproved),
            "approvedBy"            : invoice.ApprovedBy,
            "removed"               : invoice.removed,
            "removedDate"           : DateManager.getStandardDateString(date: invoice.removedDate),
            "numberOfAttachment"    : invoice.numberOfAttachments
        ]

        let sql = """
            INSERT INTO chg.\(tableName) (
                \(COLUMNS.CUSTOMER_ID),
                \(COLUMNS.JOB_ID),
                \(COLUMNS.DESCRIPTION),
                \(COLUMNS.PRICE_QUOTED),
                \(COLUMNS.PRICE_ESTIMATE),
                \(COLUMNS.PRICE_FIXED_PRICE),
                \(COLUMNS.INVOICE_ADJUSTEMENT),
                \(COLUMNS.PERCENT_DISCOUNT),
                \(COLUMNS.TOTAL_INVOICE_AMOUNT),
                \(COLUMNS.DATE_COMPLETED),
                \(COLUMNS.DATE_CREATED),
                \(COLUMNS.DATE_MODIFIED),
                \(COLUMNS.STATUS),
                \(COLUMNS.PRICE_EXPIRES),
                \(COLUMNS.IS_INVOICE_CREATED),
                \(COLUMNS.IS_INVOICE_FINAL),
                \(COLUMNS.DATE_APPROVED),
                \(COLUMNS.APPROVED_BY),
                \(COLUMNS.REMOVED),
                \(COLUMNS.REMOVED_DATE),
                \(COLUMNS.NUMBER_OF_ATTACHMENTS))

            VALUES (
                :customerId,
                :JobId,
                :description,
                :priceQuoted,
                :priceEstimate,
                :priceFixedPrice,
                :invoiceAdjustment,
                :percentDiscount,
                :totalInvoiceAmount,
                :dateCompleted,
                :dateCreated,
                :dateModified,
                :status,
                :priceExpires,
                :isInvoiceCreated,
                :isInvoiceFinal,
                :dateApproved,
                :approvedBy,
                :removed,
                :removedDate,
                :numberOfAttachment)
            """
        AppDatabase.shared.executeSQL(sql: sql,
                                      arguments: arguments,typeOfAction: .insert, updatedId: nil,
                                      success: { id in
                                        success(id)
                                      },
                                      fail: failure)
    }

    func updateInvoice(invoice: Invoice, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "id"                    : invoice.invoiceID,
            "customerId"            : invoice.customerID,
            "JobId"                 : invoice.jobID,
            "description"           : invoice.description,
            "priceQuoted"           : invoice.priceQuoted,
            "priceEstimate"         : invoice.priceEstimate,
            "priceFixedPrice"       : invoice.priceFixedPrice,
            "invoiceAdjustment"     : invoice.invoiceAdjustement,
            "percentDiscount"       : invoice.percentDiscount,
            "totalInvoiceAmount"    : invoice.totalInvoiceAmount,
            "dateCompleted"         : invoice.dateCompleted,
            "dateCreated"           : invoice.dateCreated,
            "dateModified"          : invoice.dateModified,
            "status"                : invoice.status,
            "priceExpires"          : invoice.priceExpires,
            "isInvoiceCreated"      : invoice.isInvoiceCreated,
            "isInvoiceFinal"        : invoice.isInvoiceFinal,
            "dateApproved"          : DateManager.getStandardDateString(date: invoice.dateApproved),
            "approvedBy"            : invoice.ApprovedBy,
            "removed"               : invoice.removed,
            "removedDate"           : DateManager.getStandardDateString(date: invoice.removedDate),
            "numberOfAttachment"    : invoice.numberOfAttachments
        ]
        let sql = """
            UPDATE \(tableName) SET
                \(COLUMNS.CUSTOMER_ID)              = :customerId,
                \(COLUMNS.JOB_ID)                   = :JobId,
                \(COLUMNS.DESCRIPTION)              = :description,
                \(COLUMNS.PRICE_QUOTED)             = :priceQuoted,
                \(COLUMNS.PRICE_ESTIMATE)           = :priceEstimate,
                \(COLUMNS.PRICE_FIXED_PRICE)        = :priceFixedPrice,
                \(COLUMNS.INVOICE_ADJUSTEMENT)      = :invoiceAdjustment,
                \(COLUMNS.PERCENT_DISCOUNT)         = :percentDiscount,
                \(COLUMNS.TOTAL_INVOICE_AMOUNT)     = :totalInvoiceAmount,
                \(COLUMNS.DATE_COMPLETED)           = :dateCompleted,
                \(COLUMNS.DATE_CREATED)             = :dateCreated,
                \(COLUMNS.DATE_MODIFIED)            = :dateModified,
                \(COLUMNS.STATUS)                   = :status,
                \(COLUMNS.PRICE_EXPIRES)            = :priceExpires,
                \(COLUMNS.IS_INVOICE_CREATED)       = :isInvoiceCreated,
                \(COLUMNS.IS_INVOICE_FINAL)         = :isInvoiceFinal,
                \(COLUMNS.DATE_APPROVED)            = :dateApproved,
                \(COLUMNS.APPROVED_BY)              = :approvedBy,
                \(COLUMNS.REMOVED)                  = :removed,
                \(COLUMNS.REMOVED_DATE)             = :removedDate,
                \(COLUMNS.NUMBER_OF_ATTACHMENTS)    = :numberOfAttachment
            WHERE \(tableName).\(setIdKey()) = :id;
            """

        AppDatabase.shared.executeSQL(sql: sql,
                                      arguments: arguments,
                                      typeOfAction: .update, updatedId: UInt64(invoice.invoiceID!),
                                      success: { _ in
                                        success()
                                      },
                                      fail: failure)
    }

    func deleteInvoice(invoice: Invoice, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = invoice.invoiceID else { return }
        softDelete(atId: id, success: success, fail: failure)
    }

    func restoreInvoice(invoice: Invoice, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = invoice.invoiceID else { return }
        restoreItem(atId: id, success: success, fail: failure)
    }

    func fetchInvoices(showRemoved: Bool, with key: String? = nil,isApproval: Bool,sortBy: InvoiceField? = nil, sortType: SortType? = nil ,offset: Int,success: @escaping(_ users: [Invoice]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        
        let sortable = makeSortableItems(sortBy: sortBy, sortType: sortType)
        let searchable = makeSearchableItems(key: key)
        
        let condition = getShowRemoveCondition(showRemoved: showRemoved, searchable: searchable)
        
        var sql = """
        SELECT * FROM main.\(tableName)
        LEFT JOIN main.\(TABLES.CUSTOMERS) ON main.\(tableName).\(COLUMNS.CUSTOMER_ID) == main.\(TABLES.CUSTOMERS).\(COLUMNS.CUSTOMER_ID)
        LEFT JOIN main.\(TABLES.SCHEDULED_JOBS) ON main.\(tableName).\(COLUMNS.JOB_ID) == main.\(TABLES.SCHEDULED_JOBS).\(COLUMNS.JOB_ID)
        \(condition)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        sql += """
                \(sortable.replaceMain())
                LIMIT \(LIMIT) OFFSET \(offset);
        """
        
        do {
            let invoices = try queue.read({ (db) -> [Invoice] in
                var invoices: [Invoice] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    if isApproval {
                        var isInvoiceFinal : Bool?
                        isInvoiceFinal = row[RepositoryConstants.Columns.IS_INVOICE_FINAL]
                        if isInvoiceFinal == true && isInvoiceFinal != nil {
                            invoices.append(.init(row: row))
                        }
                    }
                    else {
                        invoices.append(.init(row: row))
                    }
                }
                return invoices
            })
            success(invoices)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    private func makeSortableItems(sortBy: InvoiceField?, sortType: SortType?) -> String {
        guard let sortBy = sortBy, let sortType = sortType else {
            return makeSortableCondition(key: COLUMNS.DESCRIPTION, sortType: .ASCENDING)
        }
        switch sortBy {
        case .CUSTOMER_NAME:
            return makeSortableCondition(key: COLUMNS.CUSTOMER_NAME, sortType: sortType)
        case .DESCRIPTION:
            return makeSortableCondition(key: COLUMNS.DESCRIPTION, sortType: sortType)
        case .TOTAL_AMOUNT:
            return makeSortableCondition(key: COLUMNS.TOTAL_INVOICE_AMOUNT, sortType: sortType)
        case .PRICE_QUOTED:
            return makeSortableCondition(key: COLUMNS.PRICE_QUOTED, sortType: sortType)
        case .ADJUSTMENT_AMOUNT:
            return makeSortableCondition(key: COLUMNS.INVOICE_ADJUSTEMENT, sortType: sortType)
        case .PRICE_ESTIMATE:
            return makeSortableCondition(key: COLUMNS.PRICE_ESTIMATE, sortType: sortType)
        case .STATUS:
            return makeSortableCondition(key: COLUMNS.STATUS, sortType: sortType)
        case .FIXED_PRICE:
            return makeSortableCondition(key: COLUMNS.PRICE_FIXED_PRICE, sortType: sortType)
        case .ATTACHMENTS:
            return makeSortableCondition(key: COLUMNS.NUMBER_OF_ATTACHMENTS, sortType: sortType)
        case .QUOTE_EXPIRATION:
            return makeSortableCondition(key: COLUMNS.PRICE_EXPIRES, sortType: sortType)
        case .COMPLETED_DATE:
            return makeSortableCondition(key: COLUMNS.DATE_COMPLETED, sortType: sortType)
        case .REMARKS:
            return makeSortableCondition(key: COLUMNS.Remarks, sortType: sortType)
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
                                        COLUMNS.CUSTOMER_NAME,
                                        COLUMNS.DESCRIPTION,
                                        COLUMNS.TOTAL_INVOICE_AMOUNT,
                                        COLUMNS.PRICE_QUOTED,
                                        COLUMNS.INVOICE_ADJUSTEMENT,
                                        COLUMNS.PRICE_ESTIMATE,
                                        COLUMNS.STATUS,
                                        COLUMNS.PRICE_FIXED_PRICE,
                                        "main.\(tableName).\(COLUMNS.NUMBER_OF_ATTACHMENTS)",
                                        COLUMNS.PRICE_EXPIRES,
                                        COLUMNS.DATE_COMPLETED
                                       ])
    }
}
