//
//  PurchaseOrderApprovals.swift
//  MyProHelper
//
//  Created by Sarvesh on 21/04/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import UIKit

enum PurchaseOrderField1: String {
    case VENDOR_NAME            = "Vendor Name"
    case SALE_TAX               = "Sales Tax"
    case SHIPPING               = "Shipping"
    case TOTAL_AMOUNT           = "Total Amount"
    case Status                 = "STATUS"
    case Remarks                = "Remarks"
    case ATTACHMENTS            = "ATTACHMENTS"
    case APPROVED_BY            = "Approved By"
    case APPROVED_DATE            = "Approved Date"
    case EXPECTED_DATE          = "Expected Date"
    case Ordered_Date           = "Order Date"
}


class PurchaseOrderApprovals: BaseDataTableView<PurchaseOrder, PurchaseOrderField1>, Storyboarded,  ClassBDelegate, RDelegate, BDelegate {
    func rejectFunction(isConfirmed: Bool) {
        print("Ok")
    }
    
    
    private var isshowNavTitle: UIBarButtonItem?
    var isShowingTitle = false
    
    func dummyFunction() {
        viewModel.isShowingRemoved = true
        viewModel.reloadData()
    }
    

    func rejectFunction() {
        viewModel.isShowingRemoved = false
         viewModel.reloadData()
    }
    
    func approveFunction() {
        viewModel.isShowingRemoved = false
        viewModel.reloadData()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = PurchaseOrderModal(delegate: self)
        title = "Purchase Order Approvals"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.addShowRemovedButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        super.hideShowRemovedButton()
        self.isShowingTitle = true
    }

    override func setDataTableFields() {
        dataTableFields = [
            .VENDOR_NAME,
            .SALE_TAX,
            .SHIPPING,
            .TOTAL_AMOUNT,
            .Status,
            .Remarks,
            .ATTACHMENTS,
            .APPROVED_BY,
            .APPROVED_DATE,
            .Ordered_Date,
            .EXPECTED_DATE
        ]
    }

    override func getHeader(for columnIndex: NSInteger) -> String {
        return dataTableFields[columnIndex].rawValue.localize
    }
    
    @objc override func handleAddItem() {
        let createPurchaseOrderView = CreatedPurchaseOrderView.instantiate(storyboard: .PURCHAGEORDERAPPROVALS)
        createPurchaseOrderView.viewModel = CreatedPurchaseOrderViewModel(attachmentSource: .PURCHASE_ORDER)
        createPurchaseOrderView.setViewMode(isEditingEnabled: true)
        navigationController?.pushViewController(createPurchaseOrderView, animated: true)
    }

 
    override func setMoreAction(at indexPath: IndexPath) -> [UIAlertAction] {
        let addPurchaseAction      = UIAlertAction(title: "Approve", style: .default) { [unowned self] (action) in
            self.ApprovelAction(for: indexPath.section, with: .APPROVE)
        }
        let removePurchaseAction   = UIAlertAction(title: "Reject", style: .default) { [unowned self] (action) in
            self.RejectionAction(for: indexPath.section, with: .REJECT)
        }
       
        return [addPurchaseAction,removePurchaseAction]
    }
    
    
    private func ApprovelAction(for index: Int, with action: ShowApprovelAction) {
        let createPurchaseOrder = ApproveView.instantiate(storyboard: .APPROVEVIEW)
        let purchase = viewModel.getItem(at:index)
        print("awsthi",purchase)
     
        createPurchaseOrder.codedelegate = self
        createPurchaseOrder.isFromBtnAction = "PurchaseOrderApprovals"
        createPurchaseOrder.purchaseOrder = purchase
        self.present(createPurchaseOrder, animated: true, completion: nil)
        
        
    }
    private func RejectionAction(for index: Int, with action: ShowApprovelAction) {
        let createPurchaseOrder = rejectView.instantiate(storyboard: .REJECTVIEW)
        let purchase = viewModel.getItem(at:index)
        print("awsthi",purchase)

        createPurchaseOrder.rejectdelegate = self
        createPurchaseOrder.isFrom = "PurchaseOrderApprovals"
        createPurchaseOrder.purchaseOrder = purchase
        self.present(createPurchaseOrder, animated: true, completion: nil)
        
        
    }
    override func showItem(at indexPath: IndexPath) {
        let createPurchaseOrderView = CreatedPurchaseOrderView.instantiate(storyboard: .PURCHAGEORDERAPPROVALS)
        let purchaseOrder = viewModel.getItem(at: indexPath.section)
        createPurchaseOrderView.viewModel = CreatedPurchaseOrderViewModel(attachmentSource: .PURCHASE_ORDER)
        createPurchaseOrderView.setViewMode(isEditingEnabled: false)
        createPurchaseOrderView.viewModel.setPurchaseOrder(purchaseOrder: purchaseOrder)
        navigationController?.pushViewController(createPurchaseOrderView, animated: true)
    }
    override func editItem(at indexPath: IndexPath) {
        
        let createPurchaseOrderView = CreatedPurchaseOrderView.instantiate(storyboard: .PURCHAGEORDERAPPROVALS)
        let purchaseOrder = viewModel.getItem(at: indexPath.section)
        createPurchaseOrderView.viewModel = CreatedPurchaseOrderViewModel(attachmentSource: .PURCHASE_ORDER)
        createPurchaseOrderView.setViewMode(isEditingEnabled: true)
        createPurchaseOrderView.viewModel.setPurchaseOrder(purchaseOrder: purchaseOrder)
        navigationController?.pushViewController(createPurchaseOrderView, animated: true)
    }
    
    
}

