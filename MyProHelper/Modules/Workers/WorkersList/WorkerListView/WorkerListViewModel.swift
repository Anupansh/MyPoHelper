//
//  WorkerListViewModel.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/28/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

class WorkerListViewModel: BaseDataTableViewModel<Worker, WorkerField> {
    
    let service = WorkersService()
    
    override func reloadData() {
        hasMoreData = true
        fetchWorker(reloadData: true)
    }
    
    override func fetchMoreData() {
        fetchWorker(reloadData: false)
    }
    
    override func deleteItem(at row: Int) {
        let worker = data[row]
        service.deleteWorker(worker) { [weak self] (result) in
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
        let worker = data[row]
        service.restoreWorker(worker) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.reloadData()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
    
    private func fetchWorker(reloadData: Bool) {
        guard hasMoreData else { return }
        let offset = (reloadData == false) ? data.count : 0
        
        service.fetchWorkers(showRemoved: isShowingRemoved, key: searchKey, sortBy: sortWith?.sortBy, sortType: sortWith?.sortType, offset: offset) { [weak self] (result) in
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
}
