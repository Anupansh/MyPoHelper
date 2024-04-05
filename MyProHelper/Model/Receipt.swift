//
//  Receipt.swift
//  MyProHelper
//
//  Created by Deep on 2/15/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB

struct Receipt: RepositoryBaseModel {
    var receiptId               : Int?
    var customerId              : Int?
    var paymentId               : Int?
    var invoiceId               : Int?
    var amount                  : Float?
    var dateCreated             : Date?
    var dateModified            : Date?
    var paidInFull              : Bool?
    var partialPayment          : Bool?
    var removed                 : Bool?
    var removedDate             : Date?
    var paymentNote             : String?
    var numberOfAttachment      : Int?
    var customer                : Customer?
    var invoice                 : Invoice?
    var payment                 : Payment?
    
    init() {
        dateCreated  = Date()
        customer     = Customer()
        invoice      = Invoice()
        payment      = Payment()
    }

    init(row: Row) {
        let column = RepositoryConstants.Columns.self
        
        receiptId           = row[column.RECEIPT_ID]
        customerId          = row[column.CUSTOMER_ID]
        paymentId           = row[column.PAYMENT_ID]
        invoiceId           = row[column.INVOICE_ID]
        amount              = row[column.AMOUNT]
        dateCreated         = createDate(with: row[column.DATE_CREATED])
        dateModified        = createDate(with: row[column.DATE_MODIFIED])
        paidInFull          = row[column.PAID_IN_FULL]
        partialPayment      = row[column.PARTIAL_PAYMENT]
        removed             = row[column.REMOVED]
        removedDate         = createDate(with: row[column.REMOVED_DATE])
        paymentNote         = row[column.PAYMENT_NOTE]
        numberOfAttachment  = row[column.NUMBER_OF_ATTACHMENTS]
        customer            = Customer(row: row)
        invoice             = Invoice(row: row)
        payment             = Payment(row: row)

    }
    
    func getDataArray() -> [Any] {
        return [
            getStringValue(value: customer?.customerName),
            getStringValue(value: invoice?.description),
            getFloatValue(value: amount),
            getYesNo(value: paidInFull),
            getYesNo(value: partialPayment),
            getStringValue(value: paymentNote),
            getIntValue(value: numberOfAttachment),
            getDateString(date: dateCreated)
        ]
    }
    
    mutating func updateModifyDate() {
        dateModified = Date()
    }
}

