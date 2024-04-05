//
//  PurchaseOrderLineItemService.swift
//  MyProHelper
//
//  Created by sismac010 on 25/03/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

protocol PurchaseOrderLineItemServiceProtocol {
    func fetchLineItem(showRemoved: Bool, offset: Int, completion: @escaping (_ result: Result<[PurchaseOrderUsed], ErrorResult>)->())
    func fetchLineItem(lineItemID: Int,showRemoved: Bool, offset: Int, completion: @escaping (_ result: Result<[PurchaseOrderUsed], ErrorResult>)->())
    func addLineItem(lineItem: PurchaseOrderUsed, completion: @escaping (_ result: Result<Int64, ErrorResult>)->())
    func delete(lineItem: PurchaseOrderUsed, completion: @escaping (_ result: Result<String, ErrorResult>)->())
//    func updateQuantity(stock: SupplyFinder, quantity: Int, completion: @escaping (_ result: Result<Bool, ErrorResult>)->())
}


class PurchaseOrderLineItemService: PurchaseOrderLineItemServiceProtocol {
    
    
    private let repository = PurchaseOrderUsedRepository()
    
    func addLineItem(lineItem: PurchaseOrderUsed, completion: @escaping (_ result: Result<Int64, ErrorResult>)->()) {
        
        repository.addPurchaseOrderUsed(purchaseOrderUsed: lineItem) { purchaseOrderUsedID in
            completion(.success(purchaseOrderUsedID))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchLineItem(lineItemID: Int, showRemoved: Bool = false, offset: Int, completion: @escaping (Result<[PurchaseOrderUsed], ErrorResult>) -> ()) {
        repository.fetchPurchaseOrderUsed(purchaseOrderID: lineItemID, showRemoved: showRemoved, offset: offset) { (lineItems) in
            completion(.success(lineItems))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchMaxPurchaseOrderUsedID(completion: @escaping (Result<Int, ErrorResult>) -> ()) {
        repository.fetchMaxPurchaseOrderUsedID { (ID) in
            completion(.success(ID))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchLineItem(showRemoved: Bool = false, offset: Int, completion: @escaping (Result<[PurchaseOrderUsed], ErrorResult>) -> ()) {
        repository.fetchPurchaseOrderUsed(showRemoved: showRemoved, offset: offset) { (lineItems) in
            completion(.success(lineItems))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }

    func delete(lineItem: PurchaseOrderUsed, completion: @escaping (Result<String, ErrorResult>) -> ()) {
        repository.deletePurchaseOrderUsed(purchaseOrderUsed: lineItem) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func undelete(lineItem: PurchaseOrderUsed, _ completion:@escaping((Result<String,ErrorResult>) -> Void)) {
        repository.undeletePurchaseOrderUsed(purchaseOrderUsed: lineItem) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    
}
