//
//  QuoteService.swift
//  MyProHelper
//
//  Created by Deep on 1/25/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

final class QuoteService {
    private let dbService = QuoteRepository()
    
    func fetchQuotes(showRemoved: Bool = false, key: String? = nil, sortBy: QuotesListFields? = nil, sortType: SortType? = nil, offset: Int, completion: @escaping ((Result<[Quote], ErrorResult>) -> Void)) {
        dbService.fetchQuotes(showRemoved: showRemoved, with: key, sortBy: sortBy, sortType: sortType, offset: offset) { (quotes) in
            completion(.success(quotes))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchQuotes(showRemoved: Bool = false, key: String? = nil, sortBy: QuoteEstimateField? = nil, sortType: SortType? = nil, offset: Int, completion: @escaping ((Result<[QuoteEstimate], ErrorResult>) -> Void)) {
        dbService.fetchQuotes(showRemoved: showRemoved, with: key, sortBy: sortBy, sortType: sortType, offset: offset) { (quotes) in
            completion(.success(quotes))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func createQuote(quote: QuoteEstimate, completion: @escaping ((Result<Int64, ErrorResult>) -> Void)) {
        dbService.insertQuote(quote: quote, success: { quoteID in
            completion(.success(quoteID))
        }) { error in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func updateQuote(quote: QuoteEstimate, completion: @escaping ((Result<QuoteEstimate, ErrorResult>) -> Void)) {
        dbService.updateQuote(quote: quote, success: {
            completion(.success(quote))
        }) { error in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func deleteQuote(at quote: QuoteEstimate, completion: @escaping ((Result<String, ErrorResult>) -> Void))
    {
        dbService.deleteQuote(quote: quote) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func restoreQuote(at quote: QuoteEstimate, completion: @escaping ((Result<String, ErrorResult>) -> Void))
    {
        dbService.restoreQuote(quote: quote) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
}
