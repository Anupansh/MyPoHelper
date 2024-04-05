//
//  ExpenseOrderService.swift
//  MyProHelper
//
//  Created by Pooja Mishra on 10/04/1943 Saka.
//  Copyright © 1943 Benchmark Computing. All rights reserved.
//


import Foundation
protocol ExpenseOrderServiceProtocol:AnyObject {
    
    func fetchExpenseOrder(showRemoved: Bool, key: String?, offset: Int, completion:@escaping((Result<[ExpenseStatements],ErrorResult>) -> Void))
    func fetchExpenseOrder(showRemoved: Bool, key: String?, sortBy: PurchaseOrderField?,sortType: SortType? ,offset: Int, completion:@escaping((Result<[ExpenseStatements],ErrorResult>) -> Void))
    func createExpenseOrder(expenseStatements: ExpenseStatements, completion:@escaping((Result<Int64,ErrorResult>) -> Void))
    func updateExpenseOrder(expenseStatements: ExpenseStatements, completion:@escaping((Result<ExpenseStatements,ErrorResult>) -> Void))
    func editExpenseOrder(expenseStatements: ExpenseStatements, completion:@escaping((Result<ExpenseStatements,ErrorResult>) -> Void))
    func deleteExpenseOrder(expenseStatements: ExpenseStatements, _ completion:@escaping((Result<String,ErrorResult>) -> Void))
    func undeleteExpenseOrder(expenseStatements: ExpenseStatements, _ completion:@escaping((Result<String,ErrorResult>) -> Void))

}


final class ExpenseOrderService :RequestHandler, ExpenseOrderServiceProtocol
{
    var dbService =  ExpenseOrderRepository()
    
    
    func editExpenseOrder(expenseStatements: ExpenseStatements, completion: @escaping ((Result<ExpenseStatements, ErrorResult>) -> Void)) {
        dbService.Edit(expenseOrder: expenseStatements, success: {
            completion(.success(expenseStatements))
        }) { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    

    func updateExpenseOrder(expenseStatements: ExpenseStatements, completion: @escaping ((Result<ExpenseStatements, ErrorResult>) -> Void))  {
        dbService.update(expenseOrder: expenseStatements, success: {
            completion(.success(expenseStatements))
        }) { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    
    func deleteExpenseOrder(expenseStatements: ExpenseStatements, _ completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        dbService.removeExpenseOrder(expenseOrder: expenseStatements)
      {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }

    func undeleteExpenseOrder(expenseStatements: ExpenseStatements, _ completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        dbService.unremoveExpenseOrder(expenseOrder:expenseStatements ) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    
   
    func fetchExpenseOrder(showRemoved: Bool, key: String?, offset: Int, completion: @escaping ((Result<[ExpenseStatements], ErrorResult>) -> Void)) {
        dbService.fetchExpenseOrder(showRemoved: showRemoved, with: key, offset: offset) { (ExpenseStatements) in
            completion(.success(ExpenseStatements))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchExpenseOrder(showRemoved: Bool, key: String?, sortBy: PurchaseOrderField?, sortType: SortType?, offset: Int, completion: @escaping ((Result<[ExpenseStatements], ErrorResult>) -> Void)) {
        dbService.fetchExpenseOrder(showRemoved: showRemoved, with: key, sortType: sortType, offset: offset) { (ExpenseStatements) in
            completion(.success(ExpenseStatements))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    
    func createExpenseOrder(expenseStatements: ExpenseStatements, completion: @escaping ((Result<Int64, ErrorResult>) -> Void)) {

        dbService.insertExpenseOrder(expenseOrder: expenseStatements, success: { ExpenseStatementID in
            completion(.success(ExpenseStatementID))
        }) { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
       
    }

     
}
   

    

    
   
    

    

