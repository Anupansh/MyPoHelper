//
//  WagesViewModel.swift
//  MyProHelper
//
//  Created by sismac010 on 04/06/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

class WagesViewModel: BaseDataTableViewModel<Wage, WagesField> {
    
    private let service = WagesService()
    
    override func reloadData() {
        hasMoreData = true
        fetchWages(reloadData: true)
    }
    
    override func fetchMoreData() {
        fetchWages(reloadData: false)
    }
    
    private func fetchWages(reloadData: Bool) {
        guard hasMoreData else { return }
        let offset = (reloadData == false) ? data.count : 0
        service.fetchWages(showRemoved: isShowingRemoved,
                              key: searchKey,
                              sortBy: sortWith?.sortBy,
                              sortType: sortWith?.sortType,
                              offset: offset) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let wagesArray):
                self.hasMoreData = wagesArray.count == Constants.DATA_OFFSET
                if reloadData {
                    self.data = wagesArray
                }
                else {
                    self.data.append(contentsOf: wagesArray)
                }
                self.delegate.reloadView()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
    
    override func deleteItem(at row: Int) {
        let wage = data[row]
        service.deleteWage(wage: wage) { [weak self] (result) in
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
        let wage = data[row]
        service.undeleteWage(wage: wage) { [weak self] (result) in
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
