//
//  Attachment.swift
//  MyProHelper
//
//  Created by Samir on 11/4/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import GRDB

struct Attachment: RepositoryBaseModel {
    
    var attachmentId        : Int?
    var description         : String?
    var qouteId             : Int?
    var estimateId          : Int?
    var assetId             : Int?
    var expenseStatementId  : Int?
    var invoiceId           : Int?
    var partId              : Int?
    var purchaseOrderId     : Int?
    var receiptId           : Int?
    var scheduledJobId      : Int?
    var supplyId            : Int?
    var vendorId            : Int?
    var wageId              : Int?
    var paymentId           : Int?
    var workOrderId         : Int?
    var jobDetailId         : Int?
    var pathToAttachment    : String?
    var dateCreated         : String?
    var removed             : Bool?
    var removedDate         : String?
    
    var attachmentName      : String? {
        guard let path = pathToAttachment, let url = URL(string: path) else {
            return nil
        }
        return AppFileManager.getFileName(at: url)
    }
    
    init() {
        dateCreated = DateManager.getStandardDateString(date: Date())
    }
    
    init(path: String) {
        self.pathToAttachment = path
        dateCreated = DateManager.getStandardDateString(date: Date())
    }
    
    init(row: GRDB.Row) {
        attachmentId        = row[RepositoryConstants.Columns.ATTACHMENT_ID]
        description         = row[RepositoryConstants.Columns.DESCRIPTION]
        qouteId             = row[RepositoryConstants.Columns.QOUTE_ID]
        estimateId          = row[RepositoryConstants.Columns.ESTIMATE_ID]
        assetId             = row[RepositoryConstants.Columns.ASSET_ID]
        expenseStatementId  = row[RepositoryConstants.Columns.EXPENSE_STATEMENT_ID]
        invoiceId           = row[RepositoryConstants.Columns.INVOICE_ID]
        partId              = row[RepositoryConstants.Columns.PART_ID]
        purchaseOrderId     = row[RepositoryConstants.Columns.PURCHASE_ORDER_ID]
        receiptId           = row[RepositoryConstants.Columns.RECEIPT_ID]
        scheduledJobId      = row[RepositoryConstants.Columns.SCHEDULED_JOB_ID]
        supplyId            = row[RepositoryConstants.Columns.SUPPLY_ID]
        vendorId            = row[RepositoryConstants.Columns.VENDOR_ID]
        wageId              = row[RepositoryConstants.Columns.WAGE_ID]
        paymentId           = row[RepositoryConstants.Columns.PAYMENT_ID]
        workOrderId         = row[RepositoryConstants.Columns.WORK_ORDER_ID]
        jobDetailId               = row[RepositoryConstants.Columns.JOB_ID]
        pathToAttachment    = row[RepositoryConstants.Columns.PATH_TO_ATTACHMENT]
        dateCreated         = row[RepositoryConstants.Columns.DATE_CREATED]
        removed             = row[RepositoryConstants.Columns.REMOVED]
        removedDate         = row[RepositoryConstants.Columns.REMOVED_DATE]
    }
    
    func getDataArray() -> [Any] {
        return []
    }
}
