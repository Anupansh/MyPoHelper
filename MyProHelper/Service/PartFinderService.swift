//
//  PartFinderService.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 11/8/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

protocol PartFinderServiceProtocol {
    func fetchStock(offset: Int, completion: @escaping (_ result: Result<[PartFinder], ErrorResult>)->())
    func fetchStock(partID: Int,offset: Int, completion: @escaping (_ result: Result<[PartFinder], ErrorResult>)->())
    func addStock(stock: PartFinder, completion: @escaping (_ result: Result<Int64, ErrorResult>)->())
    func delete(stock: PartFinder, completion: @escaping (_ result: Result<String, ErrorResult>)->())
    func updateQuantity(stock: PartFinder, quantity: Int, completion: @escaping (_ result: Result<Bool, ErrorResult>)->())
}

class PartFinderService: PartFinderServiceProtocol {
    
    private let repository = PartFinderRepository()
    
    func fetchStock(offset: Int, completion: @escaping (Result<[PartFinder], ErrorResult>) -> ()) {
        repository.fetchStock(offset: offset) { (stocks) in
            completion(.success(stocks))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    
    func fetchStock(partID: Int, offset: Int, completion: @escaping (Result<[PartFinder], ErrorResult>) -> ()) {
        repository.fetchStock(stockPartID: partID, offset: offset) { (stocks) in
            completion(.success(stocks))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func addStock(stock: PartFinder, completion: @escaping (_ result: Result<Int64, ErrorResult>)->()) {
        
        repository.addStock(stock: stock) { partID in
            completion(.success(partID))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func delete(stock: PartFinder, completion: @escaping (Result<String, ErrorResult>) -> ()) {
        repository.deleteStock(stock: stock) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func updateQuantity(stock: PartFinder, quantity: Int, completion: @escaping (_ result: Result<Bool, ErrorResult>)->()) {
        repository.updateQuantity(stock: stock,quantity: quantity) { (isUpdated) in
            completion(.success(isUpdated))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
}
