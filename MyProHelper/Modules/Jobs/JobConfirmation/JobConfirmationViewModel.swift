//
//  JobConfirmationViewModel.swift
//  MyProHelper
//
//  Created by Deep on 1/20/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

class JobConfirmationViewModel: BaseDataTableViewModel<Job, JobConfirmationField> {
    
    let service = JobConfirmationService()
    
    override func reloadData() {
        hasMoreData = true
        FetchJob(reloadData: true)
    }
    
    override func fetchMoreData() {
        FetchJob(reloadData: false)
    }
    
    private func FetchJob(reloadData: Bool) {
        guard hasMoreData else { return }
        let offset = (reloadData == false) ? data.count : 0
        service.fetchJobs(showRemoved: isShowingRemoved, key: searchKey, sortBy: sortWith?.sortBy, sortType: sortWith?.sortType, offset: offset) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let workers):
                self.hasMoreData = workers.count == Constants.DATA_OFFSET
                if reloadData {
                    self.data = workers
                }
                else {
                    self.data.append(contentsOf: workers)
                }
                self.delegate.reloadView()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
    
    func acceptJob(for index: Int){
        var modefiedJob = data[index]
        modefiedJob.jobStatus = "Scheduled"
        updateJob(job: modefiedJob) { (error) in
            self.reloadData()
        }
    }
    
    func declineJob(for index: Int, reason: String){
        var modefiedJob = data[index]
        modefiedJob.jobStatus = "Rejected"
        modefiedJob.rejectedReason = reason
        updateJob(job: modefiedJob) { (error) in
            self.reloadData()
        }
    }
    
    private func updateJob(job: Job , completion: @escaping (_ error: String?)->()) {
        service.updateJob(job: job) { (result) in
            switch result {
            case .success(_):
                completion(nil)
                
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
}

