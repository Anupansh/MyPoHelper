//
//  PurchaseOrderListView.swift
//  MyProHelper
//
//  Created by sismac010 on 19/03/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation


enum PurchaseOrderField: String {
    case VENDOR_NAME            = "VENDOR_NAME"
    case SALE_TAX               = "SALE_TAX"
    case SHIPPING               = "SHIPPING"
    case TOTAL_AMOUNT           = "TOTAL_AMOUNT"
    case ATTACHMENTS            = "ATTACHMENTS"
    case EXPECTED_DATE          = "EXPECTED_DATE"
    case ORDERED_DATE           = "ORDERED_DATE"
}


class PurchaseOrderListView: BaseDataTableView<PurchaseOrder, PurchaseOrderField>, Storyboarded {

    override func viewDidLoad() {
        super.viewDidLoad()
        hasDecimalAlignRightSide = true
        viewModel = PurchaseOrderListViewModel(delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "PURCHASE_ORDERS".localize
        super.addShowRemovedButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        super.hideShowRemovedButton()
    }

    override func setDataTableFields() {
        dataTableFields = [
            .VENDOR_NAME,
            .SALE_TAX,
            .SHIPPING,
            .TOTAL_AMOUNT,
            .ATTACHMENTS,
            .EXPECTED_DATE,
            .ORDERED_DATE
        ]
    }

    override func getHeader(for columnIndex: NSInteger) -> String {
        return dataTableFields[columnIndex].rawValue.localize
    }
    
    @objc override func handleAddItem() {
        let createPurchaseOrderView = CreatePurchaseOrderView.instantiate(storyboard: .PURCHASE_ORDER)
        createPurchaseOrderView.viewModel = CreatePurchaseOrderViewModel(attachmentSource: .PURCHASE_ORDER)
        createPurchaseOrderView.setViewMode(isEditingEnabled: true)
        navigationController?.pushViewController(createPurchaseOrderView, animated: true)
    }

    override func showItem(at indexPath: IndexPath) {
        let createPurchaseOrderView = CreatePurchaseOrderView.instantiate(storyboard: .PURCHASE_ORDER)
        let purchaseOrder = viewModel.getItem(at: indexPath.section)
        createPurchaseOrderView.viewModel = CreatePurchaseOrderViewModel(attachmentSource: .PURCHASE_ORDER)
        createPurchaseOrderView.setViewMode(isEditingEnabled: false)
        createPurchaseOrderView.viewModel.setPurchaseOrder(purchaseOrder: purchaseOrder)
        navigationController?.pushViewController(createPurchaseOrderView, animated: true)
    }
    
    override func editItem(at indexPath: IndexPath) {
        
        let createPurchaseOrderView = CreatePurchaseOrderView.instantiate(storyboard: .PURCHASE_ORDER)
        let purchaseOrder = viewModel.getItem(at: indexPath.section)
        createPurchaseOrderView.viewModel = CreatePurchaseOrderViewModel(attachmentSource: .PURCHASE_ORDER)
        createPurchaseOrderView.setViewMode(isEditingEnabled: true)
        createPurchaseOrderView.viewModel.setPurchaseOrder(purchaseOrder: purchaseOrder)
        navigationController?.pushViewController(createPurchaseOrderView, animated: true)
    }
    
    
}
