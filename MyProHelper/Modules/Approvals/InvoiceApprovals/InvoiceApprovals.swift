//
//  InvoiceApprovals.swift
//  MyProHelper
//
//  Created by Sarvesh on 13/04/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit

class InvoiceApprovals:  BaseDataTableView<Invoice, InvoiceField>, Storyboarded,  ClassBDelegate, RDelegate, BDelegate {
    
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
        viewModel = InvoiceListViewModel(delegate: self)
        viewModel.isApprovals = true
        viewModel.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.addShowRemovedButton()
        self.showNavTitle()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isShowingTitle = true
    }
    
    func showNavTitle() {
        isshowNavTitle = UIBarButtonItem(image: nil,
                                         style: .plain,
                                         target: nil,
                                         action: nil)
        navigationItem.leftBarButtonItems?.append(isshowNavTitle!)
        title = "Invoice Approvals"
//        setupShowButtonTitle()
    }
    
    private func setupShowButtonTitle() {
        if isShowingTitle {
            isshowNavTitle?.title = ""
        }
        else {
            isshowNavTitle?.title = "Invoice Approvals"
        }
    }
    
    
    override func setDataTableFields() {
        dataTableFields = [
            .CUSTOMER_NAME,
            .DESCRIPTION,
            .TOTAL_AMOUNT,
            .PRICE_QUOTED,
            .ADJUSTMENT_AMOUNT,
            .PRICE_ESTIMATE,
            .STATUS,
            .REMARKS,
            .FIXED_PRICE,
            .ATTACHMENTS,
            .APPROVED_BY,
            .APPROVED_DATE,
            .QUOTE_EXPIRATION,
            .COMPLETED_DATE
        ]
    }
    
    override func getHeader(for columnIndex: NSInteger) -> String {
        return dataTableFields[columnIndex].rawValue.localize
    }
    
    @objc override func handleAddItem() {
        let createInvoiceView = CreateInvoiceView.instantiate(storyboard: .INVOICE)
        createInvoiceView.viewModel = CreateInvoiceViewModel(attachmentSource: .INVOICE)
        createInvoiceView.setViewMode(isEditingEnabled: true)
        navigationController?.pushViewController(createInvoiceView, animated: true)
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
        let createInvoiceView = ApproveView.instantiate(storyboard: .APPROVEVIEW)
        let InvoiceView = viewModel.getItem(at:index)
        createInvoiceView.codedelegate = self
        createInvoiceView.isFromBtnAction = "InvoiceListApprovals"
        createInvoiceView.invoice = InvoiceView
        self.present(createInvoiceView, animated: true, completion: nil)
    }
    private func RejectionAction(for index: Int, with action: ShowApprovelAction) {
        let createInvoiceView = rejectView.instantiate(storyboard: .REJECTVIEW)
        let InvoiceView = viewModel.getItem(at:index)
        createInvoiceView.rejectdelegate = self
        createInvoiceView.isFrom = "InvoiceListApprovals"
        createInvoiceView.invoice = InvoiceView
        self.present(createInvoiceView, animated: true, completion: nil)
        
        
    }
    override func showItem(at indexPath: IndexPath) {
        let createInvoiceView = CreateInvoiceView.instantiate(storyboard: .INVOICE)
        let invoice = viewModel.getItem(at: indexPath.section)
        createInvoiceView.viewModel = CreateInvoiceViewModel(attachmentSource: .INVOICE)
        createInvoiceView.setViewMode(isEditingEnabled: false)
        createInvoiceView.viewModel.setInvoice(invoice: invoice)
        navigationController?.pushViewController(createInvoiceView, animated: true)
    }

    override func editItem(at indexPath: IndexPath) {
        let createInvoiceView = CreateInvoiceView.instantiate(storyboard: .INVOICE)
        let invoice = viewModel.getItem(at: indexPath.section)
        createInvoiceView.viewModel = CreateInvoiceViewModel(attachmentSource: .INVOICE)
        createInvoiceView.setViewMode(isEditingEnabled: true)
        createInvoiceView.viewModel.setInvoice(invoice: invoice)
        navigationController?.pushViewController(createInvoiceView, animated: true)
    }
}
