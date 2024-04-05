//
//  WorkerRolesService.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 30/07/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

final class WorkerRolesService {
    
    private let repository = WorkerRolesRepository()
    
    func fetchWorkerRoles(for worker: Worker, completion: @escaping ((Result<WorkerRoles?, ErrorResult>) -> Void)) {
        guard let id = worker.workerID else {
            print("can not parse worker id")
            return
        }
        repository.fetchWorkerRoles(id: id) { (roles) in
            completion(.success(roles))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func addWorkerRoles(role: WorkerRoles,completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        repository.createWorkerRole(workerRole: role) { () in
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func updateWorkerRoles(role: WorkerRoles,completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        repository.updateWorkerRole(workerRole: role) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func deleteWorkerRole(role: WorkerRoles,completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        repository.deleteWorkerRole(workerRole: role) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
}
