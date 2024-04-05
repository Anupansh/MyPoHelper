//
//  Payment.swift
//  MyProHelper
//
//  Created by Samir on 07/02/2021.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB

enum PaymentType: String {
    case cash       = "Cash"
    case cheque     = "Cheque"
    case creditCard = "Credit/Debit Card"
    case netbanking = "Net Banking"
}

enum PaymentStatus: String {
    case paidInFull       = "Paid In Full"
    case partialPayment   = "Partial payment"
}

struct Payment: RepositoryBaseModel {
    var paymentId           : Int?
    var description         : String?
    var totalInvoiceAmount  : Float?
    var dateCreated         : Date?
    var dateModified        : Date?
//    var amountPaid          : Int?
    var amountPaid          : Float?
    var amountLeft          : Float = 0.0
    var transactionId       : String?
    var status              : PaymentStatus?
    var paymentType         : PaymentType?
    var noteAboutPayment    : String?
    var removed             : Bool?
    var removedDate         : Date?
    var numberOfAttachment  : Int?
    var customer            : Customer?
    var invoice             : Invoice?

    init() {
        dateCreated = Date()
        customer = Customer()
        invoice = Invoice()
    }

    init(row: Row) {
        let column = RepositoryConstants.Columns.self

        paymentId           = row[column.PAYMENT_ID]
        description         = row[column.DESCRIPTION]
        totalInvoiceAmount  = row[column.TOTAL_INVOICE_AMOUNT]
        dateCreated         = createDate(with: row[column.DATE_CREATED])
        dateModified        = createDate(with: row[column.DATE_MODIFIED])
        amountPaid          = row[column.AMOUNT_PAID]
        transactionId       = row[column.TRANSACTION_ID]
        status              = PaymentStatus(rawValue: row[column.STATUS] ?? "")
        paymentType         = PaymentType(rawValue: row[column.PAYMENT_TYPE] ?? "")
        noteAboutPayment    = row[column.NOTE_ABOUT_PAYMENT]
        removed             = row[column.REMOVED]
        removedDate         = createDate(with: row[column.REMOVED_DATE])
        numberOfAttachment  = row[column.NUMBER_OF_ATTACHMENTS]
        customer            = Customer(row: row)
        invoice             = Invoice(row: row)

    }

    func getDataArray() -> [Any] {
        return [
            getStringValue(value: customer?.customerName),
            getStringValue(value: description),
            getFloatValue(value: invoice?.totalInvoiceAmount),
//            getFloatValue(value: amountPaid),
            getFloatValue(value: amountPaid),
            getStringValue(value: noteAboutPayment),
            getIntValue(value: numberOfAttachment),
            getDateString(date: dateCreated)
        ]
    }

    mutating func updateModifyDate() {
        dateModified = Date()
    }
}
