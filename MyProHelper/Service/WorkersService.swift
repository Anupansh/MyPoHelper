//
//  WorkersService.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 16/07/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

final class WorkersService {
    
    private let dbService = WorkerRepository()
    
    func fetchWorkers(showSelect: Bool = false, offset: Int, completion: @escaping ((Result<[Worker], ErrorResult>) -> Void)) {
        dbService.fetchWorkers(showSelect: showSelect, offset: offset) { (workers) in
            completion(.success(workers))
        }
        failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchWorkers(showRemoved: Bool = false , key: String? = nil, sortBy: WorkerField? = nil, sortType: SortType? = nil , offset: Int, completion:@escaping((Result<[Worker],ErrorResult>) -> Void)) {
        dbService.fetchWorkers(showRemoved: showRemoved, with: key, sortBy: sortBy, sortType: sortType, offset: offset) { (workers) in
            completion(.success(workers))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    
    func createWorker(_ worker: Worker, completion: @escaping ((Result<Int64, ErrorResult>) -> Void)) {
        dbService.createWorker(worker: worker, success: { workerId in
            completion(.success(workerId))
        }) { error in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func updateWorker(_ worker: Worker, completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        dbService.updateWorker(worker: worker, success: {
            completion(.success(""))
        }) { error in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func deleteWorker(_ worker: Worker, completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        dbService.deleteWorker(worker: worker) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func restoreWorker(_ worker: Worker, completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        dbService.restoreWorker(worker: worker) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchWorkerCanEditTimeAlreadyEntered(workerID:String, completion: @escaping ((Result<Bool, ErrorResult>) -> Void)) {
        dbService.fetchWorkerCanEditTimeAlreadyEntered(workerID:workerID) { (value) in
            completion(.success(value))
        }
        failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchWorkerCanRunPayroll(workerID:String, completion: @escaping ((Result<Bool, ErrorResult>) -> Void)) {
        dbService.fetchWorkerCanRunPayroll(workerID:workerID) { (value) in
            completion(.success(value))
        }
        failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }

}
