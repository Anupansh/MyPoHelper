//
//  PartWaitingForInvoiceModel.swift
//  MyProHelper
//
//  Created by Anupansh on 02/08/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import GRDB

class PartWaitingForInvoice {
    
    var invoiceId: Int?
    var customerName: String?
    var partName: String?
    var countWaitingFor: Int?
    var jobID: Int?
    var contactPhone: String?
    var isPart = true
    var removed: Bool?
    
    init() {}
    
    init(row: GRDB.Row,isPart: Bool) {
        self.isPart = isPart
        let columns = RepositoryConstants.Columns.self
        invoiceId = row[columns.INVOICE_ID]
        customerName = row[columns.CUSTOMER_NAME]
        removed = row[columns.REMOVED]
        countWaitingFor = row[columns.COUNT_WAITING_FOR]
        jobID = row[columns.JOB_ID]
        contactPhone = row[columns.CONTACT_PHONE]
        if self.isPart {
            partName = row[columns.PART_NAME]
        }
        else {
            if let _ = row[columns.SUPPLY_NAME] {
                partName = row[columns.SUPPLY_NAME]
            }
            else {
                partName = DBHelper.getSupplyName(supplyId: row[columns.SUPPLY_ID])
            }
        }
    }
    
}
