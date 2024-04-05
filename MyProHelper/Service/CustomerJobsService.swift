//
//  CustomerJobsService.swift
//  MyProHelper
//
//  Created by Deep on 2/9/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

class CustomerJobsService {
    private let dbService = CustomerJobsRepository()
    
    func fetchJobs(for customer: Customer, showRemoved:Bool = false , key: String? = nil, sortBy: JobField? = nil ,sortType: SortType? = nil  ,offset: Int, completion: @escaping((Result<[Job],ErrorResult>) -> Void)){
        dbService.fetchJobs(for: customer,showRemoved: showRemoved, with: key, sortBy: sortBy, sortType: sortType, offset: offset) { (jobs) in
            completion(.success(jobs))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
}
