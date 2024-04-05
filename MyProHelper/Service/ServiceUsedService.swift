//
//  ServiceUsedService.swift
//  MyProHelper
//
//  Created by Deep on 2/7/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

final class ServiceUsedService {
    let dbService = ServiceUsedRepository()
    
    func fetchServiceUsed(invoiceId: Int, offset: Int, completion: @escaping (Result<[ServiceUsed], ErrorResult>) -> ()) {
        dbService.fetchServiceUsed(invoiceSerivceId: invoiceId, offset: offset) { (servicesUsed) in
            completion(.success(servicesUsed))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func addServiceUsed(service: ServiceUsed, completion: @escaping (_ result: Result<Int64, ErrorResult>)->()) {
        
        dbService.addServiceUsed(service: service) { serviceUsedId in
            completion(.success(serviceUsedId))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func delete(service: ServiceUsed, completion: @escaping (Result<String, ErrorResult>) -> ()) {
        dbService.deleteServiceUsed(service: service) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func updateServiceUsed(service: ServiceUsed, completion: @escaping ((Result<ServiceUsed, ErrorResult>) -> Void)) {
        dbService.updateServiceUsed(service: service, success: {
            completion(.success(service))
        }) { error in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }

}
