//
//  ExpenseStatementView.swift
//  MyProHelper
//
//  Created by sismac010 on 12/05/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

enum ExpenseStatementField: String {
    case WORKER_NAME            = "WORKER_NAME"
    case CUSTOMER_NAME          = "CUSTOMER_NAME"
    case SALE_TAX               = "SALE_TAX"
    case SHIPPING               = "SHIPPING"
    case TOTAL_AMOUNT           = "TOTAL_AMOUNT"
    case DESCRIPTION            = "DESCRIPTION"
    case STATUS                 = "STATUS"
    case REMARKS                = "REMARKS"
    case ATTACHMENTS            = "ATTACHMENTS"
    case APPROVED_BY            = "APPROVED_BY"
    case APPROVED_DATE          = "APPROVED_DATE"
}

class ExpenseStatementView: BaseDataTableView<ExpenseStatements, ExpenseStatementField>, Storyboarded {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hasDecimalAlignRightSide = true
        viewModel = ExpenseStatementViewModel(delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "EXPENSE_STATEMENTS".localize
        super.addShowRemovedButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        super.hideShowRemovedButton()
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
        let createExpenseStatementView = CreateExpenseStatementView.instantiate(storyboard: .EXPENSE_STATEMENT)
        createExpenseStatementView.viewModel = CreateExpenseStatementViewModel(attachmentSource: .Expense_Statement)
        createExpenseStatementView.setViewMode(isEditingEnabled: true)
        navigationController?.pushViewController(createExpenseStatementView, animated: true)
    }

    override func showItem(at indexPath: IndexPath) {
        let createExpenseStatementView = CreateExpenseStatementView.instantiate(storyboard: .EXPENSE_STATEMENT)
        let expenseStatements = viewModel.getItem(at: indexPath.section)
        createExpenseStatementView.viewModel = CreateExpenseStatementViewModel(attachmentSource: .Expense_Statement)
        createExpenseStatementView.setViewMode(isEditingEnabled: false)
        createExpenseStatementView.viewModel.setExpenseStatement(expenseStatements: expenseStatements)
        navigationController?.pushViewController(createExpenseStatementView, animated: true)
    }
    
    override func editItem(at indexPath: IndexPath) {
        
        let createExpenseStatementView = CreateExpenseStatementView.instantiate(storyboard: .EXPENSE_STATEMENT)
        let expenseStatements = viewModel.getItem(at: indexPath.section)
        createExpenseStatementView.viewModel = CreateExpenseStatementViewModel(attachmentSource: .Expense_Statement)
        createExpenseStatementView.setViewMode(isEditingEnabled: true)
        createExpenseStatementView.viewModel.setExpenseStatement(expenseStatements: expenseStatements)
        navigationController?.pushViewController(createExpenseStatementView, animated: true)
    }
    
}
