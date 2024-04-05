//
//  JobHistoryViewModel.swift
//  MyProHelper
//
//  Created by Deep on 1/18/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

class JobHistoryViewModel: BaseDataTableViewModel<JobHistory, JobHistoryField>  {
    
    let service = JobHistoryService()
    
    override func reloadData() {
        hasMoreData = true
        FetchJobHistory(reloadData: true)
    }
    
    override func fetchMoreData() {
        FetchJobHistory(reloadData: false)
    }
    
    private func FetchJobHistory(reloadData: Bool) {
        guard hasMoreData else { return }
        let offset = (reloadData == false) ? data.count : 0
        service.fetchJobs(showRemoved: isShowingRemoved, key: searchKey, sortBy: sortWith?.sortBy, sortType: sortWith?.sortType, offset: offset) { [weak self] (result) in
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
