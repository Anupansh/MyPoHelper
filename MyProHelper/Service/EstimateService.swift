//
//  EstimateService.swift
//  MyProHelper
//
//  Created by Deep on 1/31/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

final class EstimateService {
    private let dbService = EstimateRepository()
    
    func fetchEstimates(showRemoved: Bool = false, key: String? = nil, sortBy: EstimatesListFields? = nil, sortType: SortType? = nil, offset: Int, completion: @escaping ((Result<[Estimate], ErrorResult>) -> Void)) {
        dbService.fetchEstimates(showRemoved: showRemoved, with: key, sortBy: sortBy, sortType: sortType, offset: offset) { (estimates) in
            completion(.success(estimates))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchEstimates(showRemoved: Bool = false, key: String? = nil, sortBy: QuoteEstimateField? = nil, sortType: SortType? = nil, offset: Int, completion: @escaping ((Result<[QuoteEstimate], ErrorResult>) -> Void)) {
        dbService.fetchEstimates(showRemoved: showRemoved, with: key, sortBy: sortBy, sortType: sortType, offset: offset) { (estimates) in
            completion(.success(estimates))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func createEstimate(estimate: QuoteEstimate, completion: @escaping ((Result<Int64, ErrorResult>) -> Void)) {
        dbService.insertEstimate(estimate: estimate, success: { estimateID in
            completion(.success(estimateID))
        }) { error in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func updateEstimate(estimate: QuoteEstimate, completion: @escaping ((Result<QuoteEstimate, ErrorResult>) -> Void)) {
        dbService.updateEstimate(estimate: estimate, success: {
            completion(.success(estimate))
        }) { error in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func deleteEstimate(at estimate: QuoteEstimate, completion: @escaping ((Result<String, ErrorResult>) -> Void))
    {
        dbService.deleteEstimate(estimate: estimate) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func restorEstimate(at estimate: QuoteEstimate, completion: @escaping ((Result<String, ErrorResult>) -> Void))
    {
        dbService.restoreEstimate(estimate: estimate) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
}
