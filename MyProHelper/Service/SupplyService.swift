//
//  SupplyService.swift
//  MyProHelper
//
//  Created by Deep on 2/17/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

protocol SupplyServiceProtocol:class {
    func fetchSupplies(showRemoved: Bool, offset: Int, completion:@escaping((Result<[Supply],ErrorResult>) -> Void))
    func fetchSupplies(showRemoved: Bool, key: String?, sortBy: SupplyField?,sortType: SortType? ,offset: Int, completion:@escaping((Result<[Supply],ErrorResult>) -> Void))
    func createSupply(supply: Supply, completion:@escaping((Result<Supply,ErrorResult>) -> Void))
    func updateSupply(supply: Supply, completion:@escaping((Result<Supply,ErrorResult>) -> Void))
    func deleteSupply(supply: Supply, _ completion:@escaping((Result<String,ErrorResult>) -> Void))
    func undeleteSupply(supply: Supply, _ completion:@escaping((Result<String,ErrorResult>) -> Void))
}


final class SupplyService:RequestHandler, SupplyServiceProtocol{
    
    var dbService = SupplyRepository()
    
    func fetchSupplies(showSelect: Bool, offset: Int, completion:@escaping((Result<[Supply],ErrorResult>) -> Void)) {
        dbService.fetchSupplies(showSelect: showSelect, offset: offset) { (supplies) in
            completion(.success(supplies))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchSupplies(showRemoved: Bool, offset: Int, completion:@escaping((Result<[Supply],ErrorResult>) -> Void)) {
        dbService.fetchSupplies(showRemoved: showRemoved, offset: offset) { (supplies) in
            completion(.success(supplies))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchSupplies(showRemoved: Bool = false,
                       key: String?,
                       sortBy: SupplyField?,
                       sortType: SortType? ,
                       offset: Int,
                       completion:@escaping((Result<[Supply],ErrorResult>) -> Void)) {
        dbService.fetchSupplies(showRemoved: showRemoved, with: key, sortBy: sortBy, sortType: sortType, offset: offset) { (supplies) in
            completion(.success(supplies))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    
    func createSupply(supply: Supply, completion: @escaping ((Result<Supply, ErrorResult>) -> Void)) {
        dbService.insertSupply(supply: supply, success: { supplyID in
            var supply = supply
            supply.supplyId = Int(supplyID)
            completion(.success(supply))
//            completion(.success(supplyID))
        }) { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func updateSupply(supply: Supply, completion: @escaping ((Result<Supply, ErrorResult>) -> Void)) {
        dbService.update(supplies: supply, success: {
            completion(.success(supply))
        }) { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func deleteSupply(supply: Supply, _ completion:@escaping((Result<String,ErrorResult>) -> Void)) {
        dbService.removeSupply(supply: supply) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func undeleteSupply(supply: Supply, _ completion:@escaping((Result<String,ErrorResult>) -> Void)) {
        dbService.unremoveSupply(supply: supply) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    
}
