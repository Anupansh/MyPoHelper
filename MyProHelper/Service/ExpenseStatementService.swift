//
//  ExpenseStatementService.swift
//  MyProHelper
//
//  Created by sismac010 on 14/05/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
protocol ExpenseStatementServiceProtocol:AnyObject {
    func fetchExpenseStatements(showRemoved: Bool, offset: Int, completion:@escaping((Result<[ExpenseStatements],ErrorResult>) -> Void))
    func fetchExpenseStatements(showRemoved: Bool, key: String?, sortBy: ExpenseStatementField?,sortType: SortType? ,offset: Int, completion:@escaping((Result<[ExpenseStatements],ErrorResult>) -> Void))
//    func createExpenseStatements(expenseStatements: ExpenseStatements, completion:@escaping((Result<Int64,ErrorResult>) -> Void))
    func updateExpenseStatements(expenseStatements: ExpenseStatements, completion:@escaping((Result<ExpenseStatements,ErrorResult>) -> Void))
//    func deleteExpenseStatements(expenseStatements: ExpenseStatements, _ completion:@escaping((Result<String,ErrorResult>) -> Void))
//    func undeleteExpenseStatements(expenseStatements: ExpenseStatements, _ completion:@escaping((Result<String,ErrorResult>) -> Void))
    
}




final class ExpenseStatementService:RequestHandler, ExpenseStatementServiceProtocol{

//    var dbService2 = WorkOrderRepository()
    var dbService = ExpenseStatementRepository()
    
    func fetchExpenseStatements(showRemoved: Bool, offset: Int, completion:@escaping((Result<[ExpenseStatements],ErrorResult>) -> Void)) {
        dbService.fetchExpenseStatements(showRemoved: showRemoved, offset: offset) { (expenseStatements) in
            completion(.success(expenseStatements))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchExpenseStatements(showRemoved: Bool = false,
                       key: String?,
                       sortBy: ExpenseStatementField?,
                       sortType: SortType? ,
                       offset: Int,
                       completion:@escaping((Result<[ExpenseStatements],ErrorResult>) -> Void)) {
        dbService.fetchExpenseStatements(showRemoved: showRemoved, with: key, sortBy: sortBy, sortType: sortType, offset: offset) { (expenseStatements) in
            completion(.success(expenseStatements))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    
    func createExpenseStatements(expenseStatements: ExpenseStatements, completion: @escaping ((Result<Int64, ErrorResult>) -> Void)) {
        dbService.insertExpenseStatements(expenseStatements: expenseStatements, success: { expenseStatementsId in
            completion(.success(expenseStatementsId))
        }) { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func updateExpenseStatements(expenseStatements: ExpenseStatements, completion: @escaping ((Result<ExpenseStatements, ErrorResult>) -> Void)) {
        dbService.update(expenseStatements: expenseStatements, success: {
            completion(.success(expenseStatements))
        }) { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
}
