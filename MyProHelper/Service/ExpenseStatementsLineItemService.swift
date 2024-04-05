//
//  ExpenseStatementsLineItemService.swift
//  MyProHelper
//
//  Created by sismac010 on 18/05/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

protocol ExpenseStatementsLineItemServiceProtocol {
    func fetchLineItem(showRemoved: Bool,offset: Int, completion: @escaping (_ result: Result<[ExpenseStatementsUsed], ErrorResult>)->())
    func fetchLineItem(lineItemID: Int, showRemoved: Bool,offset: Int, completion: @escaping (_ result: Result<[ExpenseStatementsUsed], ErrorResult>)->())
    func addLineItem(lineItem: ExpenseStatementsUsed, completion: @escaping (_ result: Result<Int64, ErrorResult>)->())
    func delete(lineItem: ExpenseStatementsUsed, completion: @escaping (_ result: Result<String, ErrorResult>)->())
//    func updateQuantity(stock: SupplyFinder, quantity: Int, completion: @escaping (_ result: Result<Bool, ErrorResult>)->())
}


class ExpenseStatementsLineItemService: ExpenseStatementsLineItemServiceProtocol {
    private let repository = ExpenseStatementsUsedRepository()
    private let repository2 = WorkOrderUsedRepository()
    
    func addLineItem(lineItem: ExpenseStatementsUsed, completion: @escaping (_ result: Result<Int64, ErrorResult>)->()) {
        
        repository.addExpenseStatementsUsed(expenseStatementsUsed: lineItem) { expenseStatementsUsedID in
            completion(.success(expenseStatementsUsedID))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchLineItem(showRemoved: Bool = false,offset: Int, completion: @escaping (Result<[ExpenseStatementsUsed], ErrorResult>) -> ()) {
        repository.fetchExpenseStatementsUsed(showRemoved: showRemoved, offset: offset) { (lineItems) in
            completion(.success(lineItems))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchLineItem(lineItemID: Int, showRemoved: Bool = false, offset: Int, completion: @escaping (Result<[ExpenseStatementsUsed], ErrorResult>) -> ()) {
        repository.fetchExpenseStatementsUsed(expenseStatementsID: lineItemID, showRemoved: showRemoved, offset: offset) { (lineItems) in
            completion(.success(lineItems))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchMaxExpenseStatementsUsedID(completion: @escaping (Result<Int, ErrorResult>) -> ()) {
        repository.fetchMaxExpenseStatementsUsedID { (ID) in
            completion(.success(ID))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func delete(lineItem: ExpenseStatementsUsed, completion: @escaping (Result<String, ErrorResult>) -> ()) {
        repository.deleteExpenseStatementsUsed(expenseStatementsUsed: lineItem) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func undelete(lineItem: ExpenseStatementsUsed, _ completion:@escaping((Result<String,ErrorResult>) -> Void)) {
        repository.undeleteExpenseStatementsUsed(expenseStatementsUsed: lineItem) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
}
