//
//  EstimateListViewModel.swift
//  MyProHelper
//
//  Created by Deep on 1/31/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

class EstimateListViewModel: BaseDataTableViewModel<QuoteEstimate,QuoteEstimateField> {
    
    private let service = EstimateService()
    
    override func reloadData() {
        hasMoreData = true
        fetchEstimates(reloadData: true)
    }
    
    override func fetchMoreData() {
        fetchEstimates(reloadData: false)
    }
    
    private func fetchEstimates(reloadData: Bool) {
        guard hasMoreData else { return }
        let offset = (reloadData == false) ? data.count : 0
        
        service.fetchEstimates(showRemoved: isShowingRemoved, key: searchKey, sortBy: sortWith?.sortBy, sortType: sortWith?.sortType, offset: offset) { [weak self] (result) in
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
    
    override func deleteItem(at row: Int) {
        let estimate = data[row]
        service.deleteEstimate(at: estimate) { [weak self] (result) in
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
        let estimate = data[row]
        service.restorEstimate(at: estimate) { [weak self] (result) in
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
