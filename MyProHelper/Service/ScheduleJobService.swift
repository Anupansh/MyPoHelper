//
//  ScheduleJobService.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 05/04/1942 Saka.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

final class ScheduleJobService:RequestHandler {
    
    private let scheduleJobDBService = JobScheduleRepository()
    
    func fetchJobs(customerId:Int ,offset: Int, completion:@escaping((Result<[Job],ErrorResult>) -> Void)){
        scheduleJobDBService.fetchJob(customerId:customerId, offset: offset) { (jobs) in
            completion(.success(jobs))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    
    func fetchJobs(showRemoved:Bool, key: String?, sortBy: JobField?,sortType: SortType? ,offset: Int, completion:@escaping((Result<[Job],ErrorResult>) -> Void)){
        scheduleJobDBService.fetchJob(showRemoved: showRemoved, with: key, sortBy: sortBy, sortType: sortType, offset: offset) { (jobs) in
            completion(.success(jobs))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func createJob(_ job: Job, completion: @escaping ((Result<Int64, ErrorResult>) -> Void)) {
        scheduleJobDBService.insertJob(job: job, success: { jobID in 
            completion(.success(jobID))
        }) { error in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
        
    }
    
    func updateJob(job: Job, with time: String? = nil, completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        
        scheduleJobDBService.updateJob(job: job) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    
    func deleteJob(job: Job, completion: @escaping ((Result<Job, ErrorResult>) -> Void)) {
        scheduleJobDBService.deleteJob(with: job.jobID, success: {
            completion(.success(job))
        }) { error in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func restoreJob(_ job: Job, completion:@escaping((Result<String,ErrorResult>) -> Void)) {
        scheduleJobDBService.restoreJob(jobId: job.jobID) {
            completion(.success(""))
        } fail: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
}
