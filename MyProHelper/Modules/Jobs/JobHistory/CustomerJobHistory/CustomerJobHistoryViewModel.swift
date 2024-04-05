//
//  JobHistoryDetailsViewModel.swift
//  MyProHelper
//
//  Created by Deep on 1/25/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation


class CustomerJobHistoryViewModel : BaseDataTableViewModel<CustomerJobHistory, CustomerJobHistoryField> {
    
    let service = CustomerJobHistoryService()
    
    var customerJobHistory : JobHistory?
    
    func setCustomerJobHistory(jobHistory: JobHistory) {
        self.customerJobHistory = jobHistory
    }
    
    override func reloadData() {
        hasMoreData = true
        FetchJobHistory(reloadData: true)
    }
    
    override func fetchMoreData() {
        FetchJobHistory(reloadData: false)
    }
    
    private func FetchJobHistory(reloadData: Bool) {
        guard hasMoreData else { return }
        guard let job = customerJobHistory else {
            return
        }
        let offset = (reloadData == false) ? data.count : 0
        service.fetchJobs(for: job, showRemoved: isShowingRemoved, key: searchKey, sortBy: sortWith?.sortBy, sortType: sortWith?.sortType, offset: offset) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let jobs):
                self.hasMoreData = jobs.count == Constants.DATA_OFFSET
                if reloadData {
                    self.data = jobs
                }
                else {
                    self.data.append(contentsOf: jobs)
                }
                self.delegate.reloadView()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
}
