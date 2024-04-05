//
//  JobConfirmationService.swift
//  MyProHelper
//
//  Created by Deep on 1/20/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

class JobConfirmationService {
    
    private let jobConfirmationDBService = JobConfirmationRepository()
    
    func updateJob(job: Job, with time: String? = nil, completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        jobConfirmationDBService.updateJob(job: job) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchJobs(showRemoved:Bool, key: String?, sortBy: JobConfirmationField?,sortType: SortType? ,offset: Int, completion:@escaping((Result<[Job],ErrorResult>) -> Void)){
        jobConfirmationDBService.fetchJob(showRemoved: showRemoved, with: key, sortBy: sortBy, sortType: sortType, offset: offset) { (jobs) in
            completion(.success(jobs))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchJobs(showRemoved:Bool, key: String?, sortBy: JobsToRescheduleViewField?,sortType: SortType? ,offset: Int, completion:@escaping((Result<[Job],ErrorResult>) -> Void)){
        jobConfirmationDBService.fetchJob(showRemoved: showRemoved, with: key, sortBy: sortBy, sortType: sortType, offset: offset) { (jobs) in
            completion(.success(jobs))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
}
