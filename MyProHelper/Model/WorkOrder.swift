//
//  WorkOrder.swift
//  MyProHelper
//
//  Created by sismac010 on 06/04/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB
struct WorkOrder: RepositoryBaseModel {
    
    var workOrderId             : Int?
    var workerId                : Int?
    var workerName              : String?
    var worker                  : Worker?
    var customerId              : Int?
    var customerName            : String?
    var customer                : Customer?
    
    var description             : String?
    var status                  : String?
    var remarks                 : String?
    var dateCreated             : Date?
    var dateApproved            : Date?
    var approvedBy              : Int?
    var dateReceived            : Date?
    var dateModified            : Date?
    var sampleWorkOrder         : Int?
    var removed                 : Bool?
    var removedDate             : Date?
    var numberOfAttachments     : Int?
    
    var amountOfLineItem            :Double?
 
    init() { }
    
    init(row: GRDB.Row) {
        let column = RepositoryConstants.Columns.self
        workOrderId             = row[column.WORK_ORDER_ID]
        workerId                = row[column.WORKER_ID]
        workerName              = row[column.WORKER_NAME]
        worker                  = Worker(row: row)
        customerId              = row[column.CUSTOMER_ID]
        customerName            = row[column.CUSTOMER_NAME]
        customer              = Customer(row: row)
        description             = row[column.DESCRIPTION]
//        status                = row[column.STATUS]
        remarks                 = row[column.REMARKS]
        dateCreated             = DateManager.stringToDate(string: row[column.DATE_CREATED] ?? "")
        dateApproved            = DateManager.stringToDate(string: row[column.DATE_APPROVED] ?? "")
//        approvedBy              = row[column.APPROVED_BY]
        dateReceived            = DateManager.stringToDate(string: row[column.DATE_RECEIVED] ?? "")
        dateModified            = DateManager.stringToDate(string: row[column.DATE_MODIFIED] ?? "")
        sampleWorkOrder         = row[column.SAMPLE_WORK_ORDER]
        removed                 = row[column.REMOVED]
        removedDate             = createDate(with: column.REMOVED_DATE)
        numberOfAttachments     = row[column.NUMBER_OF_ATTACHMENTS]
        amountOfLineItem        = row[column.AMOUNT_OF_LINE_ITEM]
    }
    
    func getDataArray() -> [Any] {
        let formattedDateApproved = DateManager.dateToString(date: dateApproved)
        let amountOfLineItem1 = amountOfLineItem ?? 0
     return [
        getStringValue(value: workerName),
        getStringValue(value: customerName),
        getStringValue(value: description),
        getFormattedStringValue(value: amountOfLineItem1),
        getStringValue(value: ""),
        getStringValue(value: ""),
        getStringValue(value: ""),
        getStringValue(value: formattedDateApproved),
        getIntValue(value: numberOfAttachments),
        
     ]
    }
    
    mutating func updateModifyDate() {
        dateModified = Date()
    }
    
}
