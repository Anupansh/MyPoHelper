//
//  ReceiptListView.swift
//  MyProHelper
//
//  Created by Deep on 2/15/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit
import SwiftDataTables

enum ReceiptListField: String {
    case CUSTOMER_NAME          = "CUSTOMER_NAME"
    case INVOICE_DESCRIPTION    = "DESCRIPTION"
    case AMOUNT                 = "AMOUNT"
    case FULL_PAID              = "FULL_PAID"
    case PARTIAL_PAYMENT        = "PARTIAL_PAYMENT"
    case PAYMENT_NOTE           = "PAYMENT_NOTE"
    case ATTACHMENTS            = "ATTACHMENTS"
    case CREATED_DATE           = "CREATED_DATE"
}

class ReceiptListView:  BaseDataTableView<Receipt, ReceiptListField>, Storyboarded {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Receipt List"
        viewModel = ReceiptListViewModel(delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.addShowRemovedButton()
        super.removeLeftBarItems()
    }
    
    override func setDataTableFields() {
        dataTableFields = [
            .CUSTOMER_NAME,
            .INVOICE_DESCRIPTION,
            .AMOUNT,
            .FULL_PAID,
            .PARTIAL_PAYMENT,
            .PAYMENT_NOTE,
            .ATTACHMENTS,
            .CREATED_DATE
        ]
    }
    
    override func getHeader(for columnIndex: NSInteger) -> String {
        return dataTableFields[columnIndex].rawValue.localize
    }
    
    override func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let viewAction  = UIAlertAction(title: "View".localize, style: .default) { [unowned self] (action) in
            self.showReceipt(at: indexPath)
        }
        alert.addAction(viewAction)
        if let cell = dataTable.collectionView.cellForItem(at: indexPath) {
            presentAlert(alert: alert, sourceView: cell.contentView)
        }
    }

    func showReceipt(at indexPath: IndexPath) {
        let viewReceiptView = ViewReceiptView.instantiate(storyboard: .RECEIPT)
        let receipt = viewModel.getItem(at: indexPath.section)
        viewReceiptView.viewModel = ViewReceiptViewModel(attachmentSource: .RECEIPT)
        viewReceiptView.setViewMode(isEditingEnabled: false)
        viewReceiptView.viewModel.setReceipt(receipt: receipt)
        navigationController?.pushViewController(viewReceiptView, animated: true)
    }
}
