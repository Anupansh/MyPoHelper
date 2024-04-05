//
//  WagesService.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 30/07/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

final class WagesService {
    
    private let repository = WageRepository()
    
    func createWage(_ wage: Wage, completion: @escaping ((Result<Int64, ErrorResult>) -> Void)) {
        repository.createWage(wage: wage) { (wageId) in
            completion(.success(wageId))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    
    func fetchWages(showRemoved: Bool = false,
                       key: String?,
                       sortBy: WagesField?,
                       sortType: SortType? ,
                       offset: Int,
                       completion:@escaping((Result<[Wage],ErrorResult>) -> Void)) {
        repository.fetchWages(showRemoved: showRemoved, with: key, sortBy: sortBy, sortType: sortType, offset: offset) { (wages) in
            completion(.success(wages))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    
    func updateWage(_ wage: Wage, completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        repository.updateWage(wage: wage) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    
    func deleteWage(wage: Wage, _ completion:@escaping((Result<String,ErrorResult>) -> Void)) {
        repository.deleteWage(wage: wage)  {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func undeleteWage(wage: Wage, _ completion:@escaping((Result<String,ErrorResult>) -> Void)) {
        repository.restoreWage(wage: wage) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }

}
