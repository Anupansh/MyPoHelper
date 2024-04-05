//
//  WorkerHomeAddressesService.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 30/07/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation


final class WorkerHomeAddressesService {

    private let repository = WorkerHomeAddressRepository()
    
    func createWorkerAddress(_ workerAddress: WorkerHomeAddress, completion: @escaping ((Result<Int64, ErrorResult>) -> Void)) {
        
        repository.createAddress(workerAddress: workerAddress) { (addressId) in
            completion(.success(addressId))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    func updateWorkerAddress(_ workerAddress: WorkerHomeAddress, completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        repository.updateAddress(workerAddress: workerAddress) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    
    func deleteWorkerAddress(_ workerAddress: WorkerHomeAddress, completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        repository.deleteAddress(workerAddress: workerAddress) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func restoreAddress(_ workerAddress: WorkerHomeAddress, completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        repository.restoreAddress(workerAddress: workerAddress) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
}
