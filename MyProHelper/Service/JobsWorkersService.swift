//
//  JobsWorkersService.swift
//  MyProHelper
//
//  Created by Samir on 12/23/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

class JobsWorkersService {
    private let repository = JobsWorkersRepository()
    
    func fetchJobsWorker(for workersId: [Int],date: String, completion: @escaping (Result<[JobsWorkers], ErrorResult>) -> ()) {
        repository.fetchJobsWorkers(for: workersId, date: date) { (jobsWorkers) in
            completion(.success(jobsWorkers))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func createJobsWorker(jobsWorkers: JobsWorkers, completion: @escaping (Result<Int64, ErrorResult>) -> ()) {
        repository.insertJobsWorkers(jobsWorkers: jobsWorkers) { (jobsWorkerId) in
            completion(.success(jobsWorkerId))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
}
