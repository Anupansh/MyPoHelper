//
//  QuotesListViewModel.swift
//  MyProHelper
//
//  Created by Deep on 1/24/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

class QuotesListViewModel: BaseDataTableViewModel<QuoteEstimate,QuoteEstimateField> {
    
    private let service = QuoteService()
    
    override func reloadData() {
        hasMoreData = true
        fetchQuotes(reloadData: true)
    }
    
    override func fetchMoreData() {
        fetchQuotes(reloadData: false)
    }
    
    private func fetchQuotes(reloadData: Bool) {
        guard hasMoreData else { return }
        let offset = (reloadData == false) ? data.count : 0
        
        service.fetchQuotes(showRemoved: isShowingRemoved, key: searchKey, sortBy: sortWith?.sortBy, sortType: sortWith?.sortType, offset: offset) { [weak self] (result) in
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
    
    override func deleteItem(at row: Int) {
        let quote = data[row]
        service.deleteQuote(at: quote) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.reloadData()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
    
    override func undeleteItem(at row: Int) {
        let quote = data[row]
        service.restoreQuote(at: quote) { [weak self] (result) in
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
