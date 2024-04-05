//
//  ServiceTypesService.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 30/07/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

final class ServiceTypeService {
    
    var dbService = ServiceTypeRepository()
    
    func fetchServiceTypes(showRemoved: Bool = false, key: String? = nil, sortBy: ServiceField? = nil,sortType: SortType? = nil ,offset: Int, completion:@escaping((Result<[ServiceType],ErrorResult>) -> Void)) {
        dbService.fetchService(showRemoved: showRemoved, with: key, sortBy: sortBy, sortType: sortType, offset: offset) { (services) in
            completion(.success(services))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    
    func createServiceType(serviceType: ServiceType, completion: @escaping ((Result<ServiceType, ErrorResult>) -> Void)) {
        dbService.insertServiceType(serviceType: serviceType, success: { serviceID in
            completion(.success(serviceType))
        })
        { error in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func updateServiceType(serviceType: ServiceType, completion: @escaping ((Result<ServiceType, ErrorResult>) -> Void)) {
        dbService.update(serviceType: serviceType, success: {
            completion(.success(serviceType))
        })
        { error in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func deleteServiceType(serviceType: ServiceType, _ completion:@escaping((Result<String,ErrorResult>) -> Void)) {
        dbService.delete(serviceType: serviceType) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func restoreServiceType(serviceType: ServiceType, _ completion:@escaping((Result<String,ErrorResult>) -> Void)) {
        dbService.restoreServiceType(serviceType: serviceType) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
}

