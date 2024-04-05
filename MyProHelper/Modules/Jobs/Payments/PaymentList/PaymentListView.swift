//
//  PaymentListView.swift
//  MyProHelper
//
//  Created by Samir on 07/02/2021.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit

enum PaymentListField: String {
    case CUSTOMER_NAME  = "CUSTOMER_NAME"
    case DESCRIPTION    = "DESCRIPTION"
    case INVOICE_AMOUNT = "INVOICE_AMOUNT"
    case AMOUNT_PAID    = "AMOUNT_PAID"
    case NOTE           = "NOTE"
    case ATTACHMENTS    = "ATTACHMENTS"
    case CREATED_DATE   = "CREATED_DATE"
}

class PaymentListView: BaseDataTableView<Payment, PaymentListField>, Storyboarded {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Payment List"
        viewModel = PaymentListViewModel(delegate: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.addShowRemovedButton()
    }

    @objc override func handleAddItem() {
        let createPaymentView = CreatePaymentView.instantiate(storyboard: .PAYMENT)
        createPaymentView.viewModel = CreatePaymentViewModel(attachmentSource: .PAYMENT)
        createPaymentView.setViewMode(isEditingEnabled: true)
        navigationController?.pushViewController(createPaymentView,animated: true)
    }

    override func setDataTableFields() {
        dataTableFields = [
            .CUSTOMER_NAME,
            .DESCRIPTION,
            .INVOICE_AMOUNT,
            .AMOUNT_PAID,
            .NOTE,
            .ATTACHMENTS,
            .CREATED_DATE
        ]
    }

    override func getHeader(for columnIndex: NSInteger) -> String {
        return dataTableFields[columnIndex].rawValue.localize
    }

    override func showItem(at indexPath: IndexPath) {
        let payment = viewModel.getItem(at: indexPath.section)
        instantiateShowEditView(isEditingEnabled: false, payment: payment)
    }

    override func editItem(at indexPath: IndexPath) {
        let payment = viewModel.getItem(at: indexPath.section)
        instantiateShowEditView(isEditingEnabled: true, payment: payment)
    }

    private func instantiateShowEditView(isEditingEnabled: Bool, payment: Payment) {
        let createPaymentView = CreatePaymentView.instantiate(storyboard: .PAYMENT)
        createPaymentView.viewModel = CreatePaymentViewModel(attachmentSource: .PAYMENT)
        createPaymentView.setViewMode(isEditingEnabled: isEditingEnabled)
        createPaymentView.viewModel.setPayment(payment: payment)
        navigationController?.pushViewController(createPaymentView,animated: true)
    }
}
