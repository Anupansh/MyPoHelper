//
//  ExpenseStatements.swift
//  MyProHelper
//
//  Created by sismac010 on 12/05/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB
struct ExpenseStatements: RepositoryBaseModel {
    
    var expenseStatementsId     : Int?
    var workerId                : Int?
    var workerName              : String?
    var worker                  : Worker?
    var customerId              : Int?
    var customerName            : String?
    var customer                : Customer?
    var salesTax                : Double?
    var shipping                : Double?
    var description             : String?
    var status                  : String?
    var remarks                 : String?
    var dateCreated             : Date?
    var dateApproved            : Date?
    var approvedBy              : Int?
    
    var datePaid                : Date?
    var dateModified            : Date?
    var sampleExpenseStatement  : Int?
    var removed                 : Bool?
    var removedDate             : Date?
    var numberOfAttachments     : Int?
    
    var amountToReimburse       :Double?

    init() { }
    
    init(row: GRDB.Row) {
        let column = RepositoryConstants.Columns.self
        expenseStatementsId     = row[column.EXPENSE_STATEMENT_ID]
        workerId                = row[column.WORKER_ID]
        workerName              = row[column.WORKER_NAME]
        worker                  = Worker(row: row)
        customerId              = row[column.CUSTOMER_ID]
        customerName            = row[column.CUSTOMER_NAME]
        customer                = Customer(row: row)
        salesTax                = row[column.SALES_TAX]
        shipping                = row[column.SHIPPING]
        description             = row[column.DESCRIPTION]
        status                = row[column.STATUS]
        remarks                 = row[column.REMARKS]
        dateCreated             = DateManager.stringToDate(string: row[column.DATE_CREATED] ?? "")
        dateApproved            = DateManager.stringToDate(string: row[column.DATE_APPROVED] ?? "")
//        approvedBy              = row[column.APPROVED_BY]
        datePaid                = DateManager.stringToDate(string: row[column.DATE_PAID] ?? "")
        dateModified            = DateManager.stringToDate(string: row[column.DATE_MODIFIED] ?? "")
        sampleExpenseStatement  = row[column.SAMPLE_EXPENSE_STATEMENT]
        removed                 = row[column.REMOVED]
        removedDate             = createDate(with: column.REMOVED_DATE)
        numberOfAttachments     = row[column.NUMBER_OF_ATTACHMENTS]
        
        amountToReimburse        = row[column.AMOUNT_TO_REIMBURSE]

    }
    
    func getDataArray() -> [Any] {
        let formattedDateApproved = DateManager.dateToString(date: dateApproved)
        let amountToReimburse1 = amountToReimburse ?? 0
     return [
        getStringValue(value: workerName),
        getStringValue(value: customerName),
        getFormattedStringValue(value: salesTax),
        getFormattedStringValue(value: shipping),
        getFormattedStringValue(value: amountToReimburse1),
        getStringValue(value: description),
        getStringValue(value: status),
        getStringValue(value: remarks),
        getIntValue(value: numberOfAttachments),
        getStringValue(value: ""),
        getStringValue(value: formattedDateApproved),
        ]
    }
    
    func decimalAlignRightSideIndex() -> [Int] {
        return [4]
    }
    
    mutating func updateModifyDate() {
        dateModified = Date()
    }
}
