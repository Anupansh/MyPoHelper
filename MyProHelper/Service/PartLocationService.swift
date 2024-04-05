//
//  PartLocationService.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 29/07/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//



final class PartLocationService {
    
    private let repository = PartLocationRepository()
    
    func fetchPartLocations(showRemoved: Bool = false, key: String? = nil, sortBy: PartLocationField? = nil, sortType: SortType? = nil, offset: Int, completion: @escaping ((Result<[PartLocation], ErrorResult>) -> Void)) {
        repository.fetchPartLocation(showRemoved: showRemoved, with: key, sortBy: sortBy, sortType: sortType, offset: offset) { (partLocationArray) in
            completion(.success(partLocationArray))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }

    func createPartLocations(partLocation: PartLocation, _ completion: @escaping ((Result<Int64, ErrorResult>) -> Void)) {
        repository.insertPartLocation(partLocation: partLocation) { locationID in
            completion(.success(locationID))
        } fail: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func updatePartLocations(partLocation: PartLocation, _ completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        repository.updatePartLocation(partLocation: partLocation) {
            completion(.success(""))
        } fail: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func deletePartLocations(partLocation: PartLocation, _ completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        repository.deletePartLocation(partLocation: partLocation) {
            completion(.success(""))
        } fail: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func restorePartLocation(partLocation: PartLocation, _ completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        repository.restorePartLocation(partLocation: partLocation) {
            completion(.success(""))
        } fail: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
}
