//
//  ExpenseStatementViewModel.swift
//  MyProHelper
//
//  Created by sismac010 on 12/05/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

class ExpenseStatementViewModel: BaseDataTableViewModel<ExpenseStatements, ExpenseStatementField> {
    
//    private let service2 = WorkOrderService()
    private let service = ExpenseStatementService()
    
    override func reloadData() {
        hasMoreData = true
        fetchExpenseStatement(reloadData: true)
    }
    
    override func fetchMoreData() {
        fetchExpenseStatement(reloadData: false)
    }

    private func fetchExpenseStatement(reloadData: Bool) {
        guard hasMoreData else { return }
        let offset = (reloadData == false) ? data.count : 0
        service.fetchExpenseStatements(showRemoved: isShowingRemoved,
                              key: searchKey,
                              sortBy: sortWith?.sortBy,
                              sortType: sortWith?.sortType,
                              offset: offset) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let expenseStatementsArray):
                self.hasMoreData = expenseStatementsArray.count == Constants.DATA_OFFSET
                if reloadData {
                    self.data = expenseStatementsArray
                }
                else {
                    self.data.append(contentsOf: expenseStatementsArray)
                }
                self.delegate.reloadView()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
    
    
}
