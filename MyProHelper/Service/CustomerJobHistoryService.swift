//
//  CustomerJobHistoryService.swift
//  MyProHelper
//
//  Created by Deep on 1/25/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

class CustomerJobHistoryService {
    
    private let dbService = CustomerJobHistoryRepository()
    
    func fetchJobs(for job: JobHistory,showRemoved:Bool, key: String?, sortBy: CustomerJobHistoryField?,sortType: SortType? ,offset: Int, completion:@escaping((Result<[CustomerJobHistory],ErrorResult>) -> Void)){
        dbService.fetchJob(for: job,showRemoved: showRemoved, with: key, sortBy: sortBy, sortType: sortType, offset: offset) { (jobsHistory) in
            completion(.success(jobsHistory))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func updateJobHistory(jobHistory: CustomerJobHistory, completion: @escaping ((Result<CustomerJobHistory, ErrorResult>) -> Void)) {
        dbService.update(jobHistory: jobHistory, success: {
            completion(.success(jobHistory))
        }) { error in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
}
