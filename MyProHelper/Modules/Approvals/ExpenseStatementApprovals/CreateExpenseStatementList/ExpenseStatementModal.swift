//
//  ExpenseStatementModal.swift
//  MyProHelper
//
//  Created by Sarvesh on 21/04/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation


class ExpenseStatementModal: BaseDataTableViewModel<ExpenseStatements, ExpenseStatementField> {

//    private let service = ExpenseOrderService()
    let service = ExpenseOrderService()
    
    override func reloadData() {
        hasMoreData = true
        fetchExpenseOrder(reloadData: true)
    }
    
    override func fetchMoreData() {
        fetchExpenseOrder(reloadData: false)
    }
    
    private func fetchExpenseOrder(reloadData: Bool){
        guard hasMoreData else { return }
        let offset = (reloadData == false) ? data.count : 0
        
        service.fetchExpenseOrder(showRemoved: isShowingRemoved, key: searchKey, offset: offset){ [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let ExpenseOrdersArray):
                self.hasMoreData = ExpenseOrdersArray.count == Constants.DATA_OFFSET
                if reloadData {
                    self.data = ExpenseOrdersArray
                }
                else {
                    self.data.append(contentsOf: ExpenseOrdersArray)
                }
                self.delegate.reloadView()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }

    }

}
 
    override func deleteItem(at row: Int) {
        let expenseOrder = data[row]
        service.deleteExpenseOrder(expenseStatements: expenseOrder)
       { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.reloadData()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
    
    override func undeleteItem(at row: Int) {
        let expenseOrder = data[row]
        service.undeleteExpenseOrder(expenseStatements: expenseOrder)
      { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.reloadData()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
    
    
}
