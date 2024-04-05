//
//  PartsUsedService.swift
//  MyProHelper
//
//  Created by Deep on 2/10/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

final class PartsUsedService {
    let dbService = PartUsedRepository()
    
    func fetchPartUsed(invoiceId: Int, offset: Int, completion: @escaping (Result<[PartUsed], ErrorResult>) -> ()) {
        dbService.fetchPartsUsed(invoiceSerivceId: invoiceId, offset: offset) { (partsUsed) in
            completion(.success(partsUsed))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchPartVendors(partId: Int, offset: Int = 0, completion: @escaping (Result<[Vendor], ErrorResult>) -> ()) {
        dbService.fetchPartVendors(with: partId) { vendors in
            completion(.success(vendors))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchPartLocationList(partId: Int, offset: Int, completion: @escaping (Result<[PartLocation], ErrorResult>) -> ()) {
        dbService.fetchPartLocations(with: partId) { partLocation in
            completion(.success(partLocation))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchPartFinder(partId: Int, offset: Int, completion: @escaping (Result<[PartFinder], ErrorResult>) -> ()) {
        dbService.fetchPartFinder(with: partId) { partFinder in
            completion(.success(partFinder))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchFinder(part: PartFinder, completion: @escaping (Result<PartFinder?, ErrorResult>) -> ()) {
        dbService.fetchFinder(part: part) { partFinder in
            completion(.success(partFinder))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    
    func addPartUsed(part: PartUsed, completion: @escaping (_ result: Result<Int64, ErrorResult>)->()) {
        
        dbService.addPartUsed(part: part) { partUsedId in
            completion(.success(partUsedId))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func delete(part: PartUsed, completion: @escaping (Result<String, ErrorResult>) -> ()) {
        dbService.deletePartUsed(part: part) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func restorePartUsed(part: PartUsed, _ completion:@escaping((Result<String,ErrorResult>) -> Void)) {
        dbService.restorePartUsed(part: part) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    
    func updatePartUsed(part: PartUsed, completion: @escaping ((Result<PartUsed, ErrorResult>) -> Void)) {
        dbService.updatePartUsed(part: part, success: {
            completion(.success(part))
        }) { error in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
}
