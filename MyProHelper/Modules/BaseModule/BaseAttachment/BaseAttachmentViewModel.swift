//
//  BaseAttachmentViewModel.swift
//  MyProHelper
//
//  Created by Samir on 11/5/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

class BaseAttachmentViewModel {
    
    private let attachmentService = AttachmentService()
    private let attachmentSource: AttachmentSource
    private var attachments: [Attachment] = []
    
    var sourceId: Int?
    var numberOfAttachment: Int {
        get {
            return attachments.count
        }
    }
    
    init(attachmentSource: AttachmentSource) {
        self.attachmentSource = attachmentSource
    }
    
    func getAttachments() -> [Attachment] {
        return attachments
    }
    
    func getAttchmentURL(at index: Int) -> URL? {
        let attachment = attachments[index]
        if let path = attachment.pathToAttachment {
            return URL(fileURLWithPath: path)
        }
        else {
            return nil
        }
    }
    
    func getAttachmentName(at index: Int) -> String? {
        let attachment = attachments[index]
        guard let path = attachment.pathToAttachment, let url = URL(string: path) else {
            return nil
        }
        return AppFileManager.getFileName(at: url)
    }
    
    func editAttachment(at index: Int, with description: String?) {
        guard index < attachments.count else { return }
        attachments[index].description = description
    }
    
    func addAttachment(with url: URL, completion: @escaping ()->()) {
        guard let savedURL = AppFileManager.saveFile(from: url) else { return }
        if attachments.first(where: { $0.pathToAttachment == savedURL.path}) == nil {
            var attachment = Attachment(path: savedURL.path)
            switch attachmentSource {
            case .QOUTE:
                attachment.qouteId = sourceId
            case .ESTIMATE:
                attachment.estimateId = sourceId
            case .ASSET:
                attachment.assetId = sourceId
            case .Expense_Statement:
                attachment.expenseStatementId = sourceId
            case .INVOICE:
                attachment.invoiceId = sourceId
            case .PART:
                attachment.partId = sourceId
            case .PURCHASE_ORDER:
                attachment.purchaseOrderId = sourceId
            case .RECEIPT:
                attachment.receiptId = sourceId
            case .SCHEDULED_JOB:
                attachment.scheduledJobId = sourceId
            case .SUPPLY:
                attachment.supplyId = sourceId
            case .VENDOR:
                attachment.vendorId = sourceId
            case .WAGE:
                attachment.wageId = sourceId
            case .PAYMENT:
                attachment.paymentId = sourceId
            case .WORK_ORDER:
                attachment.workOrderId = sourceId
            case .JOB_HISTORY:
                attachment.jobDetailId = sourceId
            case .JOB_DETAIL:
                attachment.jobDetailId = sourceId
            }
            attachments.append(attachment)
            completion()
        }
    }
    
    func deleteAttahment(at index: Int, completion: @escaping (_ error: String?) -> ()) {
        let attachment = attachments[index]
        attachmentService.deleteAttachment(attachment: attachment) { (result) in
            switch result {
            case .success(_):
                self.attachments.remove(at: index) // remove attachment if not added to DB yet
                completion(nil)
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    func fetchAttachments(completion: @escaping()->()) {
        guard let id = sourceId else {
            print("source ID did not set yet!!!!")
            completion()
            return
        }
        
        attachmentService.fetchAttachment(with: id, source: attachmentSource) { [unowned self] (result) in
            switch result {
            case .success(let attachments):
                self.attachments = attachments
                completion()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func saveAttachment(id: Int) {
        for var attachment in attachments {
            switch attachmentSource {
            case .QOUTE:
                attachment.qouteId = id
            case .ESTIMATE:
                attachment.estimateId = id
            case .ASSET:
                attachment.assetId = id
            case .Expense_Statement:
                attachment.expenseStatementId = id
            case .INVOICE:
                attachment.invoiceId = id
            case .PART:
                attachment.partId = id
            case .PURCHASE_ORDER:
                attachment.purchaseOrderId = id
            case .RECEIPT:
                attachment.receiptId = id
            case .SCHEDULED_JOB:
                attachment.scheduledJobId = id
            case .SUPPLY:
                attachment.supplyId = id
            case .VENDOR:
                attachment.vendorId = id
            case .WAGE:
                attachment.wageId = id
            case .PAYMENT:
                attachment.paymentId = id
            case .WORK_ORDER:
                attachment.workOrderId = id
            case .JOB_HISTORY:
                attachment.jobDetailId = id
            case .JOB_DETAIL:
                attachment.jobDetailId = id
            }
            attachmentService.addAttachment(attachment: attachment) { (result) in
                switch result {
                case .success(_):
                    print("add")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func getFormattedStringValue(value: Double?) -> String{
        let result = value as Double? ?? 0.0
        return String(format:"%.2f ", result)
    }
}
