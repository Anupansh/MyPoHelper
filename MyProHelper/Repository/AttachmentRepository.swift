//
//  AttachmentRepository.swift
//  MyProHelper
//
//  Created by Samir on 11/4/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import GRDB

enum AttachmentSource {
    case QOUTE
    case ESTIMATE
    case ASSET
    case Expense_Statement
    case INVOICE
    case PART
    case PURCHASE_ORDER
    case RECEIPT
    case SCHEDULED_JOB
    case SUPPLY
    case VENDOR
    case WAGE
    case PAYMENT
    case WORK_ORDER
    case JOB_HISTORY
    case JOB_DETAIL
}

class AttachmentRepository: BaseRepository {
    
    init() {
        super.init(table: .ATTACHMENTS)
        createSelectedLayoutTable()
    }
    
    override func setIdKey() -> String {
        return RepositoryConstants.Columns.ATTACHMENT_ID
    }
    
    private func createSelectedLayoutTable() {
        let sql = """
            CREATE TABLE IF NOT EXISTS \(tableName)(
                \(RepositoryConstants.Columns.ATTACHMENT_ID)    INTEGER PRIMARY KEY  AUTOINCREMENT UNIQUE NOT NULL,

                \(RepositoryConstants.Columns.QOUTE_ID)             INTEGER REFERENCES
                                                                    \(RepositoryConstants.Tables.QOUTES)
                                                                    (\(RepositoryConstants.Columns.QOUTE_ID)),

                \(RepositoryConstants.Columns.ESTIMATE_ID)          INTEGER REFERENCES
                                                                    \(RepositoryConstants.Tables.ESTIMATES)
                                                                    (\(RepositoryConstants.Columns.ESTIMATE_ID)),

                \(RepositoryConstants.Columns.ASSET_ID)             INTEGER REFERENCES
                                                                    \(RepositoryConstants.Tables.ASSETS)
                                                                    (\(RepositoryConstants.Columns.ASSET_ID) ),

                \(RepositoryConstants.Columns.EXPENSE_STATEMENT_ID) INTEGER REFERENCES
                                                                    \(RepositoryConstants.Tables.EXPENSE_STATEMENTS)
                                                                    (\(RepositoryConstants.Columns.EXPENSE_STATEMENT_ID)),

                \(RepositoryConstants.Columns.INVOICE_ID)           INTEGER REFERENCES
                                                                    \(RepositoryConstants.Tables.INVOICES)
                                                                    (\(RepositoryConstants.Columns.INVOICE_ID)),

                \(RepositoryConstants.Columns.PART_ID)              INTEGER REFERENCES
                                                                    \(RepositoryConstants.Tables.PARTS)
                                                                    (\(RepositoryConstants.Columns.PART_ID)),

                \(RepositoryConstants.Columns.PURCHASE_ORDER_ID)    INTEGER REFERENCES
                                                                    \(RepositoryConstants.Tables.PURCHASE_ORDERS)
                                                                    (\(RepositoryConstants.Columns.PURCHASE_ORDER_ID)),

                \(RepositoryConstants.Columns.RECEIPT_ID)           INTEGER REFERENCES
                                                                    \(RepositoryConstants.Tables.RECEIPTS)
                                                                    (\(RepositoryConstants.Columns.RECEIPT_ID)),

                \(RepositoryConstants.Columns.SCHEDULED_JOB_ID)     INTEGER REFERENCES
                                                                    \(RepositoryConstants.Tables.SCHEDULED_JOBS)
                                                                    (\(RepositoryConstants.Columns.JOB_ID)),

                \(RepositoryConstants.Columns.SUPPLY_ID)            INTEGER REFERENCES
                                                                    \(RepositoryConstants.Tables.SUPPLIES)
                                                                    (\(RepositoryConstants.Columns.SUPPLY_ID)),

                \(RepositoryConstants.Columns.VENDOR_ID)            INTEGER REFERENCES
                                                                    \(RepositoryConstants.Tables.VENDORS)
                                                                    (\(RepositoryConstants.Columns.VENDOR_ID)),

                \(RepositoryConstants.Columns.WAGE_ID)              INTEGER REFERENCES
                                                                    \(RepositoryConstants.Tables.WAGES)
                                                                    (\(RepositoryConstants.Columns.WAGE_ID)),

                \(RepositoryConstants.Columns.PAYMENT_ID)           INTEGER REFERENCES
                                                                    \(RepositoryConstants.Tables.PAYMENTS)
                                                                    (\(RepositoryConstants.Columns.PAYMENT_ID)),

                \(RepositoryConstants.Columns.WORK_ORDER_ID)        INTEGER REFERENCES
                                                                    \(RepositoryConstants.Tables.WORK_ORDERS)
                                                                    (\(RepositoryConstants.Columns.WORK_ORDER_ID)),

                \(RepositoryConstants.Columns.JOB_DETAIL_ID)        INTEGER REFERENCES
                                                                    \(RepositoryConstants.Tables.JOB_HISTORY)
                                                                    (\(RepositoryConstants.Columns.JOB_ID)),

                \(RepositoryConstants.Columns.PATH_TO_ATTACHMENT)   TEXT,
                \(RepositoryConstants.Columns.DESCRIPTION)          TEXT,
                \(RepositoryConstants.Columns.DATE_CREATED)         TEXT,
                \(RepositoryConstants.Columns.SAMPLE_ATTACHMENT)    INTEGER DEFAULT (0),
                \(RepositoryConstants.Columns.REMOVED)              INTEGER DEFAULT (0),
                \(RepositoryConstants.Columns.REMOVED_DATE)         TEXT
            )
            """
        AppDatabase.shared.executeSQL(sql: sql,
                                      arguments: [],typeOfAction: .create, updatedId: nil) { (_) in
            print("TABLE ATTACHMENTS IS CREATED SUCCESSFULLY")
        } fail: { (error) in
            print(error)
        }

    }
    private func insertAttachment(attachment: Attachment, success: @escaping (_ id: Int64)->(), failure: @escaping (_ error: Error)-> ()) {
            
        let arguments: StatementArguments = [
            "QuoteID"               :    attachment.qouteId,
            "EstimateID"            :    attachment.estimateId,
            "AssetID"               :    attachment.assetId,
            "ExpenseStatementID"    :    attachment.expenseStatementId,
            "InvoiceID"             :    attachment.invoiceId ?? 0,
            "PartID"                :    attachment.partId,
            "PurchaseOrderID"       :    attachment.purchaseOrderId,
            "ReceiptID"             :    attachment.receiptId,
            "ScheduledJobID"        :    attachment.scheduledJobId,
            "SupplyID"              :    attachment.supplyId,
            "VendorID"              :    attachment.vendorId,
            "WageID"                :    attachment.wageId,
            "PaymentID"             :    attachment.paymentId,
            "WorkOrderID"           :    attachment.workOrderId,
            "JobDetailID"           :    attachment.jobDetailId,
            "PathToAttachment"      :    attachment.pathToAttachment,
            "DateCreated"           :    attachment.dateCreated,
            "Removed"               :    attachment.removed,
            "RemovedDate"           :    attachment.removedDate
        ]
        
        let sql = """
            INSERT INTO chg.\(tableName) (
                \(RepositoryConstants.Columns.QOUTE_ID),
                \(RepositoryConstants.Columns.ESTIMATE_ID),
                \(RepositoryConstants.Columns.ASSET_ID),
                \(RepositoryConstants.Columns.EXPENSE_STATEMENT_ID),
                \(RepositoryConstants.Columns.INVOICE_ID),
                \(RepositoryConstants.Columns.PART_ID),
                \(RepositoryConstants.Columns.PURCHASE_ORDER_ID),
                \(RepositoryConstants.Columns.RECEIPT_ID),
                \(RepositoryConstants.Columns.SCHEDULED_JOB_ID),
                \(RepositoryConstants.Columns.SUPPLY_ID),
                \(RepositoryConstants.Columns.VENDOR_ID),
                \(RepositoryConstants.Columns.WAGE_ID),
                \(RepositoryConstants.Columns.PAYMENT_ID),
                \(RepositoryConstants.Columns.WORK_ORDER_ID),
                \(RepositoryConstants.Columns.JOB_DETAIL_ID),
                \(RepositoryConstants.Columns.PATH_TO_ATTACHMENT),
                \(RepositoryConstants.Columns.DATE_CREATED),
                \(RepositoryConstants.Columns.REMOVED),
                \(RepositoryConstants.Columns.REMOVED_DATE))

            VALUES (:QuoteID,
                    :EstimateID,
                    :AssetID,
                    :ExpenseStatementID,
                    :InvoiceID,
                    :PartID,
                    :PurchaseOrderID,
                    :ReceiptID,
                    :ScheduledJobID,
                    :SupplyID,
                    :VendorID,
                    :WageID,
                    :PaymentID,
                    :WorkOrderID,
                    :JobDetailID,
                    :PathToAttachment,
                    :DateCreated,
                    :Removed,
                    :RemovedDate)
            """
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments
                                     ,typeOfAction: .insert, updatedId: nil,
                                     success: { id in
                                        success(id)
                                     },
                                     fail: failure)
    }
    
    func addAttachment(attachment: Attachment, success: @escaping (_ id: Int64)->(), failure: @escaping (_ error: Error)-> ()) {
        guard attachment.attachmentId == nil else {
            return
        }
        insertAttachment(attachment: attachment, success: success, failure: failure)
    }
    
    func editAttachment(attachment: Attachment, success: @escaping ()->(), failure: @escaping (_ error: Error)-> ()) {
        let arguments: StatementArguments = [
            "id"                    :    attachment.attachmentId,
            "QuoteID"               :    attachment.qouteId,
            "EstimateID"            :    attachment.estimateId,
            "AssetID"               :    attachment.assetId,
            "ExpenseStatementID"    :    attachment.expenseStatementId,
            "InvoiceID"             :    attachment.invoiceId,
            "PartID"                :    attachment.partId,
            "PurchaseOrderID"       :    attachment.purchaseOrderId,
            "ReceiptID"             :    attachment.receiptId,
            "ScheduledJobID"        :    attachment.scheduledJobId,
            "SupplyID"              :    attachment.supplyId,
            "VendorID"              :    attachment.vendorId,
            "WageID"                :    attachment.wageId,
            "PaymentID"             :    attachment.paymentId,
            "WorkOrderID"           :    attachment.workOrderId,
            "JobDetailID"           :    attachment.jobDetailId,
            "PathToAttachment"      :    attachment.pathToAttachment,
            "DateCreated"           :    attachment.dateCreated,
            "Removed"               :    attachment.removed,
            "RemovedDate"           :    attachment.removedDate
        ]
        let sql = """
            UPDATE \(tableName) SET
                \(RepositoryConstants.Columns.QOUTE_ID)             = :QuoteID,
                \(RepositoryConstants.Columns.ESTIMATE_ID)          = :EstimateID,
                \(RepositoryConstants.Columns.ASSET_ID)             = :AssetID,
                \(RepositoryConstants.Columns.EXPENSE_STATEMENT_ID) = :ExpenseStatementID,
                \(RepositoryConstants.Columns.INVOICE_ID)           = :InvoiceID,
                \(RepositoryConstants.Columns.PART_ID)              = :PartID,
                \(RepositoryConstants.Columns.PURCHASE_ORDER_ID)    = :PurchaseOrderID,
                \(RepositoryConstants.Columns.RECEIPT_ID)           = :ReceiptID,
                \(RepositoryConstants.Columns.SCHEDULED_JOB_ID)     = :ScheduledJobID,
                \(RepositoryConstants.Columns.SUPPLY_ID)            = :SupplyID,
                \(RepositoryConstants.Columns.VENDOR_ID)            = :VendorID,
                \(RepositoryConstants.Columns.WAGE_ID)              = :WageID,
                \(RepositoryConstants.Columns.PAYMENT_ID)           = :PaymentID,
                \(RepositoryConstants.Columns.WORK_ORDER_ID)        = :WorkOrderID,
                \(RepositoryConstants.Columns.JOB_DETAIL_ID)        =  :JobDetailID,
                \(RepositoryConstants.Columns.PATH_TO_ATTACHMENT)   = :PathToAttachment,
                \(RepositoryConstants.Columns.DATE_CREATED)         = :DateCreated,
                \(RepositoryConstants.Columns.REMOVED)              = :removed,
                \(RepositoryConstants.Columns.REMOVED_DATE)         = :removedDate
            WHERE \(tableName).\(setIdKey()) = :id;
            """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,
                                     typeOfAction: .update, updatedId: UInt64(attachment.attachmentId!),
                                     success: { _ in
                                        success()
                                     },
                                     fail: failure)
    }
    
    func deleteAttachment(attachment: Attachment, success: @escaping ()->(), failure: @escaping (_ error: Error)-> ()) {
        guard let id = attachment.attachmentId else {
            success()
            return
        }
        softDelete(atId: id, success: success, fail: failure)
    }
    
    func fetchAttachment(offset: Int, success: @escaping (_ attachments: [Attachment]) -> (), failure: @escaping (_ error: Error)->()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        var sql = """
        SELECT * FROM main.\(tableName)
        WHERE main.\(tableName).\(RepositoryConstants.Columns.REMOVED) = 0
                OR main.\(tableName).\(RepositoryConstants.Columns.REMOVED) is NULL)
        LIMIT \(LIMIT) OFFSET \(offset);
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            let attachments = try queue.read({ (db) -> [Attachment] in
                var attachments: [Attachment] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    attachments.append(.init(row: row))
                }
                return attachments
            })
            success(attachments)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    func fetchAttachment(with id: Int, source: AttachmentSource, success: @escaping (_ attachments: [Attachment]) -> (), failure: @escaping (_ error: Error)->()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        var sourceID: String
        switch source {
        case .QOUTE:
            sourceID = RepositoryConstants.Columns.QOUTE_ID
        case .ESTIMATE:
            sourceID = RepositoryConstants.Columns.ESTIMATE_ID
        case .ASSET:
            sourceID = RepositoryConstants.Columns.ASSET_ID
        case .Expense_Statement:
            sourceID = RepositoryConstants.Columns.EXPENSE_STATEMENT_ID
        case .INVOICE:
            sourceID = RepositoryConstants.Columns.INVOICE_ID
        case .PART:
            sourceID = RepositoryConstants.Columns.PART_ID
        case .PURCHASE_ORDER:
            sourceID = RepositoryConstants.Columns.PURCHASE_ORDER_ID
        case .RECEIPT:
            sourceID = RepositoryConstants.Columns.RECEIPT_ID
        case .SCHEDULED_JOB:
            sourceID = RepositoryConstants.Columns.SCHEDULED_JOB_ID
        case .SUPPLY:
            sourceID = RepositoryConstants.Columns.SUPPLY_ID
        case .VENDOR:
            sourceID = RepositoryConstants.Columns.VENDOR_ID
        case .WAGE:
            sourceID = RepositoryConstants.Columns.WAGE_ID
        case .PAYMENT:
            sourceID = RepositoryConstants.Columns.PAYMENT_ID
        case .WORK_ORDER:
            sourceID = RepositoryConstants.Columns.WORK_ORDER_ID
        case .JOB_HISTORY:
            sourceID = RepositoryConstants.Columns.JOB_DETAIL_ID
        case .JOB_DETAIL:
            sourceID = RepositoryConstants.Columns.JOB_DETAIL_ID
        }
        var sql = """
        SELECT * FROM main.\(tableName)
        WHERE (main.\(tableName).\(RepositoryConstants.Columns.REMOVED) = 0
                OR main.\(tableName).\(RepositoryConstants.Columns.REMOVED) is NULL)
        AND \(sourceID) = ?
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            let attachments = try queue.read({ (db) -> [Attachment] in
                var attachments: [Attachment] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [id,id])  // one additional'id' will add Only for using 'uniun' above
                rows.forEach { (row) in
                    attachments.append(.init(row: row))
                }
                return attachments
            })
            success(attachments)
        }
        catch {
            failure(error)
            print(error)
        }
    }
}
