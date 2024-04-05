//
//  JobDetailService.swift
//  MyProHelper
//
//  Created by Deep on 2/22/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

final class JobDetailService {

    private let dbService = JobDetailRepository()
    
    func fetchJobDetail(showRemoved: Bool = false, key: String? = nil, sortBy: JobDetailListField? = nil,sortType: SortType? = nil ,offset: Int, completion:@escaping((Result<[JobDetail],ErrorResult>) -> Void)) {
        dbService.fetchJobDetail(showRemoved: showRemoved,
                                with: key,
                                sortBy: sortBy,
                                sortType: sortType,
                                offset: offset) { (jobArray) in
            completion(.success(jobArray))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func deleteJobDetail(jobDetail: JobDetail, _ completion:@escaping((Result<String,ErrorResult>) -> Void)) {
        dbService.removeJobDetail(jobDetail: jobDetail)  {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    func undeleteJobDetail(jobDetail: JobDetail, _ completion:@escaping((Result<String,ErrorResult>) -> Void)) {
        dbService.unremoveJobDetail(jobDetail: jobDetail)  {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    func updateJobDetail(jobDetail: JobDetail, completion: @escaping ((Result<JobDetail, ErrorResult>) -> Void)) {
        dbService.update(jobDetail: jobDetail, success: {
            completion(.success(jobDetail))
        }) { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func saveJobDetail(jobDetail: JobDetail, completion: @escaping ((Result<Int64, ErrorResult>) -> Void)) {
        dbService.insert(jobDetail: jobDetail, success: { jobID in
            completion(.success(jobID))
        }) { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    
    func fetchJobDetail(jobID: Int? = nil,
                        showRemoved: Bool = false,
                        key: String? = nil,
                        sortBy: JobDetailListField? = nil,
                        sortType: SortType? = nil ,
                        offset: Int,
                        completion:@escaping((Result<[JobDetailLineItem],ErrorResult>) -> Void)) {
        dbService.fetchJobDetail(jobID: jobID,
                                 showRemoved: showRemoved,
                                with: key,
                                sortBy: sortBy,
                                sortType: sortType,
                                offset: offset) { (jobArray) in
            completion(.success(jobArray))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }

}
