//
//  ExpenseStatementApprovals.swift
//  MyProHelper
//
//  Created by Sarvesh on 21/04/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//zDone

import Foundation
import UIKit


class ExpenseStatementApprovals: BaseDataTableView<ExpenseStatements, ExpenseStatementField>, Storyboarded, ClassBDelegate, RDelegate, BDelegate{
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
        viewModel = ExpenseStatementModal(delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.addShowRemovedButton()
        title = "Expense Approvals"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        super.hideShowRemovedButton()
        self.isShowingTitle = true
    }

    override func setDataTableFields() {
        dataTableFields = [
            .WORKER_NAME,
            .CUSTOMER_NAME,
            .SALE_TAX,
            .SHIPPING,
            .TOTAL_AMOUNT,
            .DESCRIPTION,
            .STATUS,
            .REMARKS,
            .ATTACHMENTS,
            .APPROVED_BY,
            .APPROVED_DATE,
        ]
    }

    override func getHeader(for columnIndex: NSInteger) -> String {
        return dataTableFields[columnIndex].rawValue.localize
    }
    
    @objc override func handleAddItem() {
        let createExpenseStatementView = CreateExpenseStatementView.instantiate(storyboard: .EXPENSESTATEMENTAPPROVALS)
        createExpenseStatementView.viewModel = CreateExpenseStatementViewModel(attachmentSource: .Expense_Statement)
        createExpenseStatementView.setViewMode(isEditingEnabled: true)
        navigationController?.pushViewController(createExpenseStatementView, animated: true)
    }

    override func showItem(at indexPath: IndexPath) {
        let createExpenseStatementView = CreateExpenseStatementView.instantiate(storyboard: .EXPENSESTATEMENTAPPROVALS)
        let expenseStatement = viewModel.getItem(at: indexPath.section)
        createExpenseStatementView.viewModel = CreateExpenseStatementViewModel(attachmentSource: .Expense_Statement)
               createExpenseStatementView.setViewMode(isEditingEnabled: false)
        createExpenseStatementView.viewModel.setExpenseStatement(ExpenseStatement: expenseStatement)
        navigationController?.pushViewController(createExpenseStatementView, animated: true)
    }
    
    override func editItem(at indexPath: IndexPath) {

        let createExpenseStatementView = CreateExpenseStatementView.instantiate(storyboard: .EXPENSESTATEMENTAPPROVALS)
        let expenseStatement = viewModel.getItem(at: indexPath.section)
        createExpenseStatementView.viewModel = CreateExpenseStatementViewModel(attachmentSource: .Expense_Statement)
               createExpenseStatementView.setViewMode(isEditingEnabled: true)
        createExpenseStatementView.viewModel.setExpenseStatement(ExpenseStatement: expenseStatement)
        navigationController?.pushViewController(createExpenseStatementView, animated: true)
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
        let expenseStatement = ApproveView.instantiate(storyboard: .APPROVEVIEW)
        let expense = viewModel.getItem(at:index)
       print("awsthi",expense)
     
        expenseStatement.codedelegate = self
        expenseStatement.isFromBtnAction = "ExpenseStatementApprovals"
        expenseStatement.expenseOrder = expense
        self.present(expenseStatement, animated: true, completion: nil)
        
        
    }
    private func RejectionAction(for index: Int, with action: ShowApprovelAction) {
        let createExpenseStatement = rejectView.instantiate(storyboard: .REJECTVIEW)
        let expenseOrders = viewModel.getItem(at:index)
        print("awsthi",expenseOrders)

        createExpenseStatement.rejectdelegate = self
        createExpenseStatement.isFrom = "ExpenseStatementApprovals"
        createExpenseStatement.expenseOrder = expenseOrders
        self.present(createExpenseStatement, animated: true, completion: nil)
        
        
    }
    
}

