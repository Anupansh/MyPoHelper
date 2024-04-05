//
//  PartService.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 10/07/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

protocol PartsServiceProtocol:class {
    func fetchParts(showRemoved: Bool, offset: Int, completion:@escaping((Result<[Part],ErrorResult>) -> Void))
    func fetchParts(showRemoved: Bool, key: String?, sortBy: PartField?,sortType: SortType? ,offset: Int, completion:@escaping((Result<[Part],ErrorResult>) -> Void))
    func createPart(part: Part, completion:@escaping((Result<Part,ErrorResult>) -> Void))
    func updatePart(part: Part, completion:@escaping((Result<Part,ErrorResult>) -> Void))
    func deletePart(part: Part, _ completion:@escaping((Result<String,ErrorResult>) -> Void))
    func undeletePart(part: Part, _ completion:@escaping((Result<String,ErrorResult>) -> Void))
}

final class PartsService: RequestHandler, PartsServiceProtocol {
    
    var dbService = PartRepository()
    
    func fetchStockedParts(showRemoved: Bool = false,isApproval: Bool, key: String? = nil, sortBy: StockedPartFields? = nil, sortType: SortType? = nil, offset: Int, completion: @escaping ((Result<[StockedPart], ErrorResult>) -> Void)) {
        dbService.fetchStockedParts(showRemoved: showRemoved, with: key, isApproval: isApproval, sortBy: sortBy, sortType: sortType, offset: offset) { (stockedPart) in
            completion(.success(stockedPart))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchParts(showSelect : Bool, offset: Int, completion:@escaping((Result<[Part],ErrorResult>) -> Void)) {
        dbService.fetchPart(showSelect: showSelect, offset: offset) { (parts) in
            completion(.success(parts))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchParts(showRemoved: Bool, offset: Int, completion:@escaping((Result<[Part],ErrorResult>) -> Void)) {
        dbService.fetchPart(showRemoved: showRemoved, offset: offset) { (parts) in
            completion(.success(parts))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchParts(showRemoved: Bool, key: String?, sortBy: PartField?,sortType: SortType? ,offset: Int, completion:@escaping((Result<[Part],ErrorResult>) -> Void)) {
        dbService.fetchPart(showRemoved: showRemoved, with: key, sortBy: sortBy, sortType: sortType, offset: offset) { (partArray) in
            completion(.success(partArray))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    
    func createPart(part: Part, completion: @escaping ((Result<Part, ErrorResult>) -> Void)) {
        dbService.insertPart(part: part, success: { partID in
            var part = part
            part.partID = Int(partID)
            completion(.success(part))
//            completion(.success(partID))
        }) { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func updatePart(part: Part, completion: @escaping ((Result<Part, ErrorResult>) -> Void)) {
        dbService.update(part: part, success: {
            completion(.success(part))
        }) { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func deletePart(part: Part, _ completion:@escaping((Result<String,ErrorResult>) -> Void)) {
        dbService.removePart(part: part) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func undeletePart(part: Part, _ completion:@escaping((Result<String,ErrorResult>) -> Void)) {
        dbService.unremovePart(part: part) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
}
