//
//  SupplyLocationService.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 30/07/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

final class SupplyLocationService {
    
    private let dbService = SupplyLocationRepository()
    
    func fetchSupplyLocations(showRemoved: Bool = false, key: String? = nil, sortBy: SupplyLocationField? = nil,sortType: SortType? = nil ,offset: Int, completion:@escaping((Result<[SupplyLocation],ErrorResult>) -> Void)) {
        dbService.fetchSupplyLocations(showRemoved: showRemoved, with: key, sortBy: sortBy, sortType: sortType, offset: offset) { (locations) in
            completion(.success(locations))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    func createSupplyLocation(supplyLocation: SupplyLocation, completion: @escaping ((Result<SupplyLocation, ErrorResult>) -> Void)) {
        dbService.insertSupplyLocation(supplyLocation: supplyLocation, success: { locationID in
            var supplyLocation = supplyLocation
            supplyLocation.supplyLocationID = Int(locationID)
            completion(.success(supplyLocation))
        }) { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func updateSupplyLocation(supplyLocation: SupplyLocation, completion: @escaping ((Result<SupplyLocation, ErrorResult>) -> Void)) {
        dbService.update(supplyLocation: supplyLocation, success: {
            completion(.success(supplyLocation))
        }) { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func deleteSupplyLocation(supplyLocation: SupplyLocation, completion:@escaping((Result<String,ErrorResult>) -> Void)) {
        dbService.delete(supplyLocation: supplyLocation) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func restoreSupplyLocation(supplyLocation: SupplyLocation, completion:@escaping((Result<String,ErrorResult>) -> Void)) {
        dbService.restoreSupplyLocation(supplyLocation: supplyLocation) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
}
