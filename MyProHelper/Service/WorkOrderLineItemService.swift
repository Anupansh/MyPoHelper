//
//  WorkOrderLineItemService.swift
//  MyProHelper
//
//  Created by sismac010 on 12/04/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

protocol WorkOrderLineItemServiceProtocol {
    func fetchLineItem(showRemoved: Bool, offset: Int, completion: @escaping (_ result: Result<[WorkOrderUsed], ErrorResult>)->())
    func fetchLineItem(lineItemID: Int, showRemoved: Bool, offset: Int, completion: @escaping (_ result: Result<[WorkOrderUsed], ErrorResult>)->())
    func addLineItem(lineItem: WorkOrderUsed, completion: @escaping (_ result: Result<Int64, ErrorResult>)->())
    func delete(lineItem: WorkOrderUsed, completion: @escaping (_ result: Result<String, ErrorResult>)->())
//    func updateQuantity(stock: SupplyFinder, quantity: Int, completion: @escaping (_ result: Result<Bool, ErrorResult>)->())
}


class WorkOrderLineItemService: WorkOrderLineItemServiceProtocol {

    private let repository = WorkOrderUsedRepository()
    
    func addLineItem(lineItem: WorkOrderUsed, completion: @escaping (_ result: Result<Int64, ErrorResult>)->()) {
        
        repository.addWorkOrderUsed(workOrderUsed: lineItem) { workOrderUsedID in
            completion(.success(workOrderUsedID))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchLineItem(showRemoved: Bool = false, offset: Int, completion: @escaping (Result<[WorkOrderUsed], ErrorResult>) -> ()) {
        repository.fetchWorkOrderUsed(showRemoved: showRemoved, offset: offset) { (lineItems) in
            completion(.success(lineItems))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchLineItem(lineItemID: Int, showRemoved: Bool = false, offset: Int, completion: @escaping (Result<[WorkOrderUsed], ErrorResult>) -> ()) {
        repository.fetchWorkOrderUsed(workOrderID: lineItemID, showRemoved: showRemoved, offset: offset) { (lineItems) in
            completion(.success(lineItems))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchMaxWorkOrderUsedID(completion: @escaping (Result<Int, ErrorResult>) -> ()) {
        repository.fetchMaxWorkOrderUsedID { (ID) in
            completion(.success(ID))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func delete(lineItem: WorkOrderUsed, completion: @escaping (Result<String, ErrorResult>) -> ()) {
        repository.deleteWorkOrderUsed(workOrderUsed: lineItem) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func undelete(lineItem: WorkOrderUsed, _ completion:@escaping((Result<String,ErrorResult>) -> Void)) {
        repository.undeleteWorkOrderUsed(workOrderUsed: lineItem) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
}
