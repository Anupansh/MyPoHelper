//
//  PurchaseOrder.swift
//  MyProHelper
//
//  Created by sismac010 on 22/03/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import GRDB

struct PurchaseOrder: RepositoryBaseModel {
 
    var purchaseOrderId             : Int?
    var salesTax                    : Double?
    var shipping                    : Double?
    var enteredDate                 : Date?
    var orderedDate                 : Date?
    var status                      : String?
    var vendorId                    : Int?
    var purchasedFrom               : Vendor?
    var expectedDate                : Date?
    var approvedBy                  : Int?
    var dateApproved                : Date?
    var samplePurchaseOrder         : Int?
    var dateReceived                : Date?
    var removed                     : Bool?
    var removedDate                 : Date?
    var numberOfAttachments         : Int?
    var amountOfLineItem            :Double?
    var remarks                     :String?
    var rejectConfirm               :Bool?
    
    init() { }
    
    init(row: GRDB.Row) {
        let column = RepositoryConstants.Columns.self
        
        purchaseOrderId         = row[column.PURCHASE_ORDER_ID]
        salesTax                = row[column.SALES_TAX]
        shipping                = row[column.SHIPPING]
        enteredDate             = DateManager.stringToDate(string: row[column.ENTERED_DATE] ?? "")
        orderedDate             = DateManager.stringToDate(string: row[column.ORDERED_DATE] ?? "")
//        status                  = row[column.STATUS]
        vendorId                = row[column.VENDOR_ID]
        expectedDate            = DateManager.stringToDate(string: row[column.EXPECTED_DATE] ?? "")
        approvedBy              = row[column.APPROVED_BY]
        dateApproved            = DateManager.stringToDate(string: row[column.DATE_APPROVED] ?? "")
        samplePurchaseOrder     = row[column.SAMPLE_PURCHASE_ORDER]
        dateReceived            = DateManager.stringToDate(string: row[column.DATE_RECEIVED] ?? "")
        removed                 = row[column.REMOVED]
        removedDate             = createDate(with: column.REMOVED_DATE)
        numberOfAttachments     = row[column.NUMBER_OF_ATTACHMENTS]
        purchasedFrom           = Vendor(row: row)  // + " " +
        amountOfLineItem        = row[column.AMOUNT_OF_LINE_ITEM]
        
        remarks                 = row[column.Remarks]
        
        rejectConfirm           = false
        
    }
    func getDataArray() -> [Any] {
        let salesTax1 = salesTax ?? 0
        let shipping1 = shipping ?? 0
        let amountOfLineItem1 = amountOfLineItem ?? 0
        let totalAmount = Double(amountOfLineItem1 + salesTax1 + shipping1)
        var formattedOrderedDate = DateManager.dateToString(date: orderedDate)
        var formattedExpectedDate = DateManager.dateToString(date: expectedDate)
        let formattedApprovedDate = DateManager.dateToString(date: dateApproved)
        if status == "Rejected" {
            formattedOrderedDate = ""
            formattedExpectedDate = ""
        }
        if formattedOrderedDate.contains("1900-01-01") {
            formattedOrderedDate = ""
        }
        if formattedExpectedDate.contains("1900-01-01") {
            formattedExpectedDate = ""
        }
        var approverName = ""
        if approvedBy != 0 && approvedBy != nil {
            DBHelper.getWorker(workerId: approvedBy) { worker in
                approverName = (worker?.fullName)!
            }
        }
        return [
            getStringValue(value: purchasedFrom?.vendorName),
            getFormattedStringValue(value: salesTax),
            getFormattedStringValue(value: shipping),
            getFormattedStringValue(value: totalAmount),
            getStringValue(value: status),
            getStringValue(value: remarks),
            getIntValue(value: numberOfAttachments),
            getStringValue(value: approverName),
            getDateString(date: DateManager.stringToDate(string: formattedApprovedDate)),
            getDateString(date: DateManager.stringToDate(string: formattedOrderedDate)),
            getDateString(date: DateManager.stringToDate(string: formattedExpectedDate))
        ]
    }
    
    func decimalAlignRightSideIndex() -> [Int] {
        return [3]
    }
    
    mutating func updateModifyDate() {
//        dateModified = Date()
    }
    
}
