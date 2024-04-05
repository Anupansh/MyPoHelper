//
//  ViewReceiptViewModel.swift
//  MyProHelper
//
//  Created by Deep on 2/15/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

class ViewReceiptViewModel: BaseAttachmentViewModel {
    
    private var isUpdatingReceipt: Bool = false
    let receipt = Box(Receipt())
    
    func setReceipt(receipt: Receipt) {
        self.receipt.value = receipt
        self.sourceId = receipt.receiptId
    }
    
    //MARK: - Getterrs
    
    func getInvoice() -> String? {
        return receipt.value.invoice?.description
    }

    func getCustomerName() -> String? {
        return receipt.value.customer?.customerName
    }

    func getAmount() -> String? {
        guard let amount = receipt.value.amount  else { return nil }
        return String(amount)
    }

    func getPaid() -> String? {
        return "text"
    }
    
    func getPaymentNote() -> String? {
        return receipt.value.paymentNote
    }
    
    func getIsFull() -> Bool {
        guard let paidInFull = receipt.value.paidInFull else {
            return false
        }
        return paidInFull
    }
    
    func getIsPartial() -> Bool {
        guard let partialPayment = receipt.value.partialPayment else {
            return false
        }
        return partialPayment
    }
}
