//
//  PaymentRepository.swift
//  MyProHelper
//
//  Created by Samir on 07/02/2021.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB

class PaymentRepository: BaseRepository {

    init() {
        super.init(table: .PAYMENTS)
    }

    override func setIdKey() -> String {
        return COLUMNS.PAYMENT_ID
    }

    private func createSelectedLayoutTable() {
        let sql = """
         CREATE TABLE IF NOT EXISTS \(tableName)(
                \(COLUMNS.PAYMENT_ID)   INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL,
                \(COLUMNS.CUSTOMER_ID)  INTEGER REFERENCES \(TABLES.CUSTOMERS) (\(COLUMNS.CUSTOMER_ID)) NOT NULL,
                \(COLUMNS.INVOICE_ID)   INTEGER REFERENCES \(TABLES.INVOICES) (\(COLUMNS.INVOICE_ID)) NOT NULL,
                \(COLUMNS.DESCRIPTION)              TEXT,
                \(COLUMNS.TOTAL_INVOICE_AMOUNT)     REAL,
                \(COLUMNS.DATE_CREATED)             TEXT,
                \(COLUMNS.DATE_MODIFIED)            TEXT,
                \(COLUMNS.AMOUNT_PAID)              REAL,
                \(COLUMNS.TRANSACTION_ID)           TEXT,
                \(COLUMNS.STATUS)                   TEXT,
                \(COLUMNS.PAYMENT_TYPE)             TEXT,
                \(COLUMNS.NOTE_ABOUT_PAYMENT)       TEXT,
                \(COLUMNS.SAMPLE_PAYMENT)           INTEGER DEFAULT(0),
                \(COLUMNS.REMOVED)                  INTEGER DEFAULT(0),
                \(COLUMNS.REMOVED_DATE)             TEXT,
                \(COLUMNS.NUMBER_OF_ATTACHMENTS)    INTEGER DEFAULT(0)
        )
        """

        AppDatabase.shared.executeSQL(sql: sql,
                                      arguments: [],typeOfAction: .create, updatedId: nil) { (_) in
            print("TABLE PAYMENTS IS CREATED SUCCESSFULLY")
        } fail: { (error) in
            print(error)
        }
    }

    func insertPayment(payment: Payment, success: @escaping(_ id: Int64) -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "customerID"            : payment.customer?.customerID,
            "invoiceID"             : payment.invoice?.invoiceID,
            "description"           : payment.description,
            "totalInvoiceAmount"    : payment.totalInvoiceAmount,
            "dateCreated"           : DateManager.getStandardDateString(date: payment.dateCreated),
            "dateModified"          : DateManager.getStandardDateString(date: payment.dateModified),
            "amountPaid"            : payment.amountPaid,
            "transactionID"         : payment.transactionId,
            "status"                : payment.status?.rawValue,
            "paymentType"           : payment.paymentType?.rawValue,
            "noteAboutPayment"      : payment.noteAboutPayment,
            "removed"               : payment.removed,
            "removedDate"           : DateManager.getStandardDateString(date: payment.removedDate),
            "numberOfAttachments"   : payment.numberOfAttachment
        ]

        let sql = """
            INSERT INTO chg.\(tableName) (
                \(COLUMNS.CUSTOMER_ID),
                \(COLUMNS.INVOICE_ID),
                \(COLUMNS.DESCRIPTION),
                \(COLUMNS.TOTAL_INVOICE_AMOUNT),
                \(COLUMNS.DATE_CREATED),
                \(COLUMNS.DATE_MODIFIED),
                \(COLUMNS.AMOUNT_PAID),
                \(COLUMNS.TRANSACTION_ID),
                \(COLUMNS.STATUS),
                \(COLUMNS.PAYMENT_TYPE),
                \(COLUMNS.NOTE_ABOUT_PAYMENT),
                \(COLUMNS.REMOVED),
                \(COLUMNS.REMOVED_DATE),
                \(COLUMNS.NUMBER_OF_ATTACHMENTS))

            VALUES (:customerID,
                    :invoiceID,
                    :description,
                    :totalInvoiceAmount,
                    :dateCreated,
                    :dateModified,
                    :amountPaid,
                    :transactionID,
                    :status,
                    :paymentType,
                    :noteAboutPayment,
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

    func updatePayment(payment: Payment, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "id"                    : payment.paymentId,
            "CustomerID"            : payment.customer?.customerID,
            "InvoiceID"             : payment.invoice?.invoiceID,
            "Description"           : payment.description,
            "TotalInvoiceAmount"    : payment.totalInvoiceAmount,
            "DateCreated"           : DateManager.getStandardDateString(date: payment.dateCreated),
            "DateModified"          : DateManager.getStandardDateString(date: payment.dateModified),
            "AmountPaid"            : payment.amountPaid,
            "TransactionID"         : payment.transactionId,
            "Status"                : payment.status?.rawValue,
            "PaymentType"           : payment.paymentType?.rawValue,
            "NoteAboutPayment"      : payment.noteAboutPayment,
            "Removed"               : payment.removed,
            "RemovedDate"           : DateManager.getStandardDateString(date: payment.removedDate),
            "NumberOfAttachments"   : payment.numberOfAttachment
        ]
        let sql = """
            UPDATE \(tableName) SET
                \(COLUMNS.CUSTOMER_ID)              = :CustomerID,
                \(COLUMNS.INVOICE_ID)               = :InvoiceID,
                \(COLUMNS.DESCRIPTION)              = :Description,
                \(COLUMNS.TOTAL_INVOICE_AMOUNT)     = :TotalInvoiceAmount,
                \(COLUMNS.DATE_CREATED)             = :DateCreated,
                \(COLUMNS.DATE_MODIFIED)            = :DateModified,
                \(COLUMNS.AMOUNT_PAID)              = :AmountPaid,
                \(COLUMNS.TRANSACTION_ID)           = :TransactionID,
                \(COLUMNS.STATUS)                   = :Status,
                \(COLUMNS.PAYMENT_TYPE)             = :PaymentType,
                \(COLUMNS.NOTE_ABOUT_PAYMENT)       = :NoteAboutPayment,
                \(COLUMNS.REMOVED)                  = :Removed,
                \(COLUMNS.REMOVED_DATE)             = :RemovedDate,
                \(COLUMNS.NUMBER_OF_ATTACHMENTS)    = :NumberOfAttachments
            WHERE \(tableName).\(setIdKey()) = :id;
            """

        AppDatabase.shared.executeSQL(sql: sql,
                                      arguments: arguments,
                                      typeOfAction: .update, updatedId: UInt64(payment.paymentId!),
                                      success: { _ in
                                        success()
                                      },
                                      fail: failure)
    }

    func delete(payment: Payment, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = payment.paymentId else { return }
        softDelete(atId: id, success: success, fail: failure)
    }

    func restorePayment(payment: Payment, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = payment.paymentId else { return }
        restoreItem(atId: id, success: success, fail: failure)
    }

    func fetchPayment(showRemoved: Bool, with key: String? = nil, sortBy: PaymentListField? = nil, sortType: SortType? = nil ,offset: Int,success: @escaping(_ service: [Payment]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        let sortable = makeSortableItems(sortBy: sortBy, sortType: sortType)
        let searchable = makeSearchableItems(key: key)
        let condition = getShowRemoveCondition(showRemoved: showRemoved, searchable: searchable)

        var sql = """
        SELECT * FROM main.\(tableName)
        JOIN main.\(TABLES.CUSTOMERS) ON main.\(tableName).\(COLUMNS.CUSTOMER_ID) = main.\(TABLES.CUSTOMERS).\(COLUMNS.CUSTOMER_ID)
        JOIN main.\(TABLES.INVOICES) ON main.\(tableName).\(COLUMNS.INVOICE_ID) = main.\(TABLES.INVOICES).\(COLUMNS.INVOICE_ID)
        JOIN main.\(TABLES.SCHEDULED_JOBS) ON main.\(TABLES.SCHEDULED_JOBS).\(COLUMNS.JOB_ID) = main.\(TABLES.INVOICES).\(COLUMNS.INVOICE_ID)
        \(condition)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        sql += """
                \(sortable.replaceMain())
                LIMIT \(LIMIT) OFFSET \(offset);
        """
        do {
            let payments = try queue.read({ (db) -> [Payment] in
                var payments: [Payment] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    payments.append(.init(row: row))
                }
                return payments
            })
            success(payments)
        }
        catch {
            failure(error)
            print(error)
        }
    }

    private func makeSortableItems(sortBy: PaymentListField?, sortType: SortType?) -> String {
        guard let sortBy = sortBy, let sortType = sortType else {
            return makeSortableCondition(key:"main.\(TABLES.CUSTOMERS).\(COLUMNS.CUSTOMER_NAME)",
                                         sortType: .ASCENDING)
        }
        switch sortBy {
        case .CUSTOMER_NAME:
            return makeSortableCondition(key:"main.\(TABLES.CUSTOMERS).\(COLUMNS.CUSTOMER_NAME)",
                                         sortType: sortType)
        case .DESCRIPTION:
            return makeSortableCondition(key: COLUMNS.DESCRIPTION,
                                         sortType: sortType)
        case .INVOICE_AMOUNT:
            return makeSortableCondition(key: COLUMNS.TOTAL_INVOICE_AMOUNT,
                                         sortType: sortType)
        case .AMOUNT_PAID:
            return makeSortableCondition(key: COLUMNS.AMOUNT_PAID,
                                         sortType: sortType)
        case .NOTE:
            return makeSortableCondition(key: COLUMNS.NOTE_ABOUT_PAYMENT,
                                         sortType: sortType)
        case .ATTACHMENTS:
            return makeSortableCondition(key: COLUMNS.NUMBER_OF_ATTACHMENTS,
                                         sortType: sortType)
        case .CREATED_DATE:
            return makeSortableCondition(key: COLUMNS.DATE_CREATED,
                                         sortType: sortType)
        }
    }

    private func makeSearchableItems(key: String?) -> String {
        guard let key = key else { return "" }
        return  makeSearchableCondition(key: key,
                                        fields: [
                                            "main.\(TABLES.CUSTOMERS).\(COLUMNS.CUSTOMER_NAME)",
                                            "main.\(tableName).\(COLUMNS.DESCRIPTION)",
                                            "main.\(tableName).\(COLUMNS.TOTAL_INVOICE_AMOUNT)",
                                            COLUMNS.AMOUNT_PAID,
                                            COLUMNS.NOTE_ABOUT_PAYMENT,
                                            "main.\(tableName).\(COLUMNS.NUMBER_OF_ATTACHMENTS)"])
    }
}
