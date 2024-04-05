//
//  QuotesEstimatesViewModel.swift
//  MyProHelper
//
//  Created by Deep on 2/3/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

class QuotesEstimatesViewModel : BaseDataTableViewModel<QuoteEstimate,QuoteEstimateField> {
    
    private let quoteService = QuoteService()
    private let estimateService = EstimateService()
    
    private var isQuote: Bool = true
    private var isEstimate: Bool = false
    
    override func reloadData() {
        if isQuote {
            hasMoreData = true
            fetchQuotes(reloadData: true)
        }else {
            hasMoreData = true
            fetchEstimates(reloadData: true)
        }
    }
    
    override func fetchMoreData() {
        if isQuote{
            fetchQuotes(reloadData: false)
        }else{
            fetchEstimates(reloadData: false)
        }
    }
    
    func setIsQuote() {
        isQuote    = true
        isEstimate = false
        reloadData()
    }
    
    func setIsEstimate() {
        isQuote    = false
        isEstimate = true
        reloadData()
    }
    
    func getIsQuote() -> Bool {
        return isQuote
    }
    
    func getIsEstimate() -> Bool{
        return isEstimate
    }
    
    //MARK: - Fetching data
    
    private func fetchQuotes(reloadData: Bool) {
        guard hasMoreData else { return }
        let offset = (reloadData == false) ? data.count : 0
        
        quoteService.fetchQuotes(showRemoved: isShowingRemoved, key: searchKey, sortBy: sortWith?.sortBy, sortType: sortWith?.sortType, offset: offset) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let quotes):
                self.hasMoreData = quotes.count == Constants.DATA_OFFSET
                if reloadData {
                    self.data = quotes
                }
                else {
                    self.data.append(contentsOf: quotes)
                }
                self.delegate.reloadView()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
    
    private func fetchEstimates(reloadData: Bool) {
        guard hasMoreData else { return }
        let offset = (reloadData == false) ? data.count : 0
        estimateService.fetchEstimates(showRemoved: isShowingRemoved, key: searchKey, sortBy: sortWith?.sortBy, sortType: sortWith?.sortType, offset: offset) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let estimates):
                self.hasMoreData = estimates.count == Constants.DATA_OFFSET
                if reloadData {
                    self.data = estimates
                }
                else {
                    self.data.append(contentsOf: estimates)
                }
                self.delegate.reloadView()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
    
    
    //MARK: - Delete Item
    override func deleteItem(at row: Int) {
        if isQuote{
            deleteQuote(at: row)
        }else {
            deleteEstimate(at: row)
        }
    }
    
    private func deleteQuote(at row: Int) {
        let quote = data[row]
        print(quote)
        quoteService.deleteQuote(at: quote) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.reloadData()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
    
    private func deleteEstimate(at row: Int) {
        let estimate = data[row]
        estimateService.deleteEstimate(at: estimate) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.reloadData()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
    
    //MARK: - Undelete Item
    
    override func undeleteItem(at row: Int) {
        if isQuote{
            undeleteQuote(at: row)
        }else {
            undeleteEstimate(at: row)
        }
    }
    
    private func undeleteQuote(at row: Int){
        let quote = data[row]
        quoteService.restoreQuote(at: quote) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.reloadData()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
    
    private func undeleteEstimate(at row: Int){
        let estimate = data[row]
        estimateService.restorEstimate(at: estimate) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.reloadData()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
}
