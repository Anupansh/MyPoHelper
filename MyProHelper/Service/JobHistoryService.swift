//
//  JobHistoryService.swift
//  MyProHelper
//
//  Created by Deep on 1/18/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

class JobHistoryService {
    
    private let JobHistoryDBService = JobHistoryRepository()
    
    func fetchJobs(showRemoved:Bool, key: String?, sortBy: JobHistoryField?,sortType: SortType? ,offset: Int, completion:@escaping((Result<[JobHistory],ErrorResult>) -> Void)){
        JobHistoryDBService.fetchJob(showRemoved: showRemoved, with: key, sortBy: sortBy, sortType: sortType, offset: offset) { (jobsHistory) in
            completion(.success(jobsHistory))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
}
