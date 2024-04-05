//
//  PartLocationViewModel.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/21/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

class PartLocationViewModel: BaseDataTableViewModel<PartLocation,PartLocationField> {
    
    private let service = PartLocationService()
    
    override func reloadData() {
        hasMoreData = true
        fetchPartLocation(reloadData: true)
    }
    
    override func fetchMoreData() {
        fetchPartLocation(reloadData: false)
    }
    
    override func deleteItem(at row: Int) {
        let location = data[row]
        service.deletePartLocations(partLocation: location) { [weak self] (result) in
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
        let location = data[row]
        service.restorePartLocation(partLocation: location) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.reloadData()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
    
    private func fetchPartLocation(reloadData: Bool) {
        guard hasMoreData else { return }
        let offset = (reloadData == false) ? data.count : 0
        service.fetchPartLocations(showRemoved: isShowingRemoved, key: searchKey, sortBy: sortWith?.sortBy, sortType: sortWith?.sortType, offset: offset) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let partLocations):
                self.hasMoreData = partLocations.count == Constants.DATA_OFFSET
                if reloadData {
                    self.data = partLocations
                }
                else {
                    self.data.append(contentsOf: partLocations)
                }
                self.delegate.reloadView()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
}
