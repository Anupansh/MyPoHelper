//
//  JobDetailListViewModel.swift
//  MyProHelper
//
//  Created by Deep on 2/22/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

class JobDetailListViewModel: BaseDataTableViewModel<JobDetail, JobDetailListField> {

    private let service = JobDetailService()

    override func reloadData() {
        hasMoreData = true
        fetchService(reloadData: true)
    }

    override func fetchMoreData() {
        fetchService(reloadData: false)
    }

    private func fetchService(reloadData: Bool) {
        guard hasMoreData else { return }
        let offset = (reloadData == false) ? data.count : 0
        service.fetchJobDetail(showRemoved: isShowingRemoved,
                             key: searchKey,
                             sortBy: sortWith?.sortBy,
                             sortType: sortWith?.sortType,
                             offset: offset) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let JobDetails):
                self.hasMoreData = JobDetails.count == Constants.DATA_OFFSET
                if reloadData {
                    self.data = JobDetails
                }
                else {
                    self.data.append(contentsOf: JobDetails)
                }
                self.delegate.reloadView()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
    
    override func deleteItem(at row: Int) {
        let jobDetail = data[row]
        service.deleteJobDetail(jobDetail: jobDetail) { [weak self] (result) in
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
        let jobDetail = data[row]
        service.undeleteJobDetail(jobDetail: jobDetail) { [weak self] (result) in
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

