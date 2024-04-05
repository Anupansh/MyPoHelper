//
//  SupplyFinderService.swift
//  MyProHelper
//
//  Created by sismac010 on 10/03/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

protocol SupplyFinderServiceProtocol {
    func fetchStock(showRemoved: Bool, offset: Int, completion: @escaping (_ result: Result<[SupplyFinder], ErrorResult>)->())
    func fetchStock(supplyID: Int, showRemoved: Bool, offset: Int, completion: @escaping (_ result: Result<[SupplyFinder], ErrorResult>)->())
    func addStock(stock: SupplyFinder, completion: @escaping (_ result: Result<Int64, ErrorResult>)->())
    func delete(stock: SupplyFinder, completion: @escaping (_ result: Result<String, ErrorResult>)->())
    func updateQuantity(stock: SupplyFinder, quantity: Int, completion: @escaping (_ result: Result<Bool, ErrorResult>)->())
}


class SupplyFinderService: SupplyFinderServiceProtocol {

    private let repository = SupplyFinderRepository()
    
    func fetchStock(showRemoved: Bool, offset: Int, completion: @escaping (Result<[SupplyFinder], ErrorResult>) -> ()) {
        repository.fetchStock(showRemoved: showRemoved, offset: offset) { (stocks) in
            completion(.success(stocks))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    
    func fetchStock(supplyID: Int, showRemoved: Bool = false, offset: Int, completion: @escaping (Result<[SupplyFinder], ErrorResult>) -> ()) {
        repository.fetchStock(stockSupplyID: supplyID, showRemoved: showRemoved, offset: offset) { (stocks) in
            completion(.success(stocks))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func addStock(stock: SupplyFinder, completion: @escaping (_ result: Result<Int64, ErrorResult>)->()) {
        
        repository.addStock(stock: stock) { supplyID in
            completion(.success(supplyID))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }

    func delete(stock: SupplyFinder, completion: @escaping (Result<String, ErrorResult>) -> ()) {
        repository.deleteStock(stock: stock) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func undeleteStock(stock: SupplyFinder, _ completion:@escaping((Result<String,ErrorResult>) -> Void)) {
        repository.undeleteStock(stock: stock) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    
    
    func updateQuantity(stock: SupplyFinder, quantity: Int, completion: @escaping (_ result: Result<Bool, ErrorResult>)->()) {
        repository.updateQuantity(stock: stock,quantity: quantity) { (isUpdated) in
            completion(.success(isUpdated))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
}
