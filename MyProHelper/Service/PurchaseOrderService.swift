//
//  PurchaseOrderService.swift
//  MyProHelper
//
//  Created by sismac010 on 22/03/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
protocol PurchaseOrderServiceProtocol:AnyObject {
    
    func fetchPurchaseOrders(showRemoved: Bool, offset: Int,  key: String?, completion:@escaping((Result<[PurchaseOrder],ErrorResult>) -> Void))
    func fetchPurchaseOrders(showRemoved: Bool, key: String?, sortBy: PurchaseOrderField?,sortType: SortType? ,offset: Int, completion:@escaping((Result<[PurchaseOrder],ErrorResult>) -> Void))
    func createPurchaseOrder(purchaseOrder: PurchaseOrder, completion:@escaping((Result<Int64,ErrorResult>) -> Void))
    func updatePurchaseOrder(purchaseOrder: PurchaseOrder, completion:@escaping((Result<PurchaseOrder,ErrorResult>) -> Void))
    func deletePurchaseOrder(purchaseOrder: PurchaseOrder, _ completion:@escaping((Result<String,ErrorResult>) -> Void))
    func undeletePurchaseOrder(purchaseOrder: PurchaseOrder, _ completion:@escaping((Result<String,ErrorResult>) -> Void))

}


final class PurchaseOrderService:RequestHandler, PurchaseOrderServiceProtocol{

    var dbService = PurchaseOrderRepository()
    func fetchPurchaseOrders(showRemoved: Bool, offset: Int, key: String?, completion:@escaping((Result<[PurchaseOrder],ErrorResult>) -> Void)) {
        dbService.fetchPurchaseOrders(showRemoved: showRemoved, with: key, offset: offset) { (purchaseOrders) in
            completion(.success(purchaseOrders))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func editPurchaseOrder(purchaseOrder: PurchaseOrder, completion: @escaping ((Result<PurchaseOrder, ErrorResult>) -> Void)) {
        dbService.Edit(purchaseOrder: purchaseOrder, success: {
            completion(.success(purchaseOrder))
        }) { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }

    func fetchPurchaseOrders(showRemoved: Bool = false,
                       key: String?,
                       sortBy: PurchaseOrderField?,
                       sortType: SortType? ,
                       offset: Int,
                       completion:@escaping((Result<[PurchaseOrder],ErrorResult>) -> Void)) {
        dbService.fetchPurchaseOrders(showRemoved: showRemoved, with: key, sortBy: sortBy, sortType: sortType, offset: offset) { (purchaseOrders) in
            completion(.success(purchaseOrders))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }

    func createPurchaseOrder(purchaseOrder: PurchaseOrder, completion: @escaping ((Result<Int64, ErrorResult>) -> Void)) {
        dbService.insertPurchaseOrder(purchaseOrder: purchaseOrder, success: { purchaseOrderID in
            completion(.success(purchaseOrderID))
        }) { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func updatePurchaseOrder(purchaseOrder: PurchaseOrder, completion: @escaping ((Result<PurchaseOrder, ErrorResult>) -> Void)) {
        dbService.update(purchaseOrder: purchaseOrder, success: {
            completion(.success(purchaseOrder))
        }) { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func deletePurchaseOrder(purchaseOrder: PurchaseOrder, _ completion:@escaping((Result<String,ErrorResult>) -> Void)) {
        dbService.removePurchaseOrder(purchaseOrder: purchaseOrder)  {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func undeletePurchaseOrder(purchaseOrder: PurchaseOrder, _ completion:@escaping((Result<String,ErrorResult>) -> Void)) {
        dbService.unremovePurchaseOrder(purchaseOrder: purchaseOrder) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }

    
}
