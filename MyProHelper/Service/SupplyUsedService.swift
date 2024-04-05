//
//  SupplyUsedService.swift
//  MyProHelper
//
//  Created by Deep on 2/17/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

final class SupplyUsedService {
    let dbService = SupplyUsedRepositorry()
    
    func fetchSupplyUsed(invoiceId: Int, offset: Int, completion: @escaping (Result<[SupplyUsed], ErrorResult>) -> ()) {
        dbService.fetchSuppliesUsed(invoiceId: invoiceId, offset: offset) { (supplyUsed) in
            completion(.success(supplyUsed))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchSupplyVendors(supplyId: Int, offset: Int, completion: @escaping (Result<[Vendor], ErrorResult>) -> ()) {
        dbService.fetchSupplyVendors(with: supplyId) { vendors in
            completion(.success(vendors))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchSupplyLocations(supplyId: Int, offset: Int, completion: @escaping (Result<[SupplyLocation], ErrorResult>) -> ()) {
        dbService.fetchSupplyLocations(with: supplyId) { supplyLocation in
            completion(.success(supplyLocation))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchSupplyFinder(supplyId: Int, offset: Int, completion: @escaping (Result<[SupplyFinder], ErrorResult>) -> ()) {
        dbService.fetchSupplyFinder(with: supplyId) { supplyFinder in
            completion(.success(supplyFinder))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchFinder(supply: SupplyFinder, completion: @escaping (Result<SupplyFinder?, ErrorResult>) -> ()) {
        dbService.fetchFinder(supply: supply) { supplyFinder in
            completion(.success(supplyFinder))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func addSupplyUsed(supplyUsed: SupplyUsed, completion: @escaping (_ result: Result<Int64, ErrorResult>)->()) {
        
        dbService.addSupplyUsed(supply: supplyUsed) { supplyUsedId in
            completion(.success(supplyUsedId))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func deleteSupplyUsed(supply: SupplyUsed, completion: @escaping (Result<String, ErrorResult>) -> ()) {
        dbService.deleteSupplyUsed(supply: supply) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func restoreSupplyUsed(supply: SupplyUsed, _ completion:@escaping((Result<String,ErrorResult>) -> Void)) {
        dbService.restoreSupplyUsed(supply: supply) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    
    func updatePartUsed(supply: SupplyUsed, completion: @escaping ((Result<SupplyUsed, ErrorResult>) -> Void)) {
        dbService.updateSupplyUsed(supply: supply, success: {
            completion(.success(supply))
        }) { error in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
}
