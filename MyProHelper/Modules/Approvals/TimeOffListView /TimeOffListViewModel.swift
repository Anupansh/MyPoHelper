//
//  TimeOffListViewModel.swift
//  MyProHelper
//
//  Created by Macbook pro on 16/03/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//
//aaaa
import UIKit

class TimeOffListViewModel: BaseDataTableViewModel<Approval, TimeOffApprovalField> {
    let service = TimeOffApprovalService()
    override func reloadData() {
        hasMoreData = true
        fetchApproval(reloadData: true)
    }
    override func fetchMoreData() {
        fetchApproval(reloadData: false)
      
    }
    override func deleteItem(at row: Int) {
        let Approval = data[row]
        service.deleteApproval(Approval) { [weak self] (result) in
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
        let Approval = data[row]
        service.restoreApproval(Approval) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.reloadData()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }

    private func fetchApproval(reloadData: Bool) {
        guard hasMoreData else { return }
        let offset = (reloadData == false) ? data.count : 0
        service.fetchApproval(showRemoved: isShowingRemoved, key: searchKey, sortBy: sortWith?.sortBy, sortType: sortWith?.sortType, offset: offset) { [weak self] (result) in
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
