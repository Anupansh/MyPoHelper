//
//  SupplyLocationListViewModel.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/25/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

class SupplyLocationListViewModel:BaseDataTableViewModel<SupplyLocation,SupplyLocationField> {
    
    private let service = SupplyLocationService()
    
    override func reloadData() {
        hasMoreData = true
        fetchPartLocation(reloadData: true)
    }
    
    override func fetchMoreData() {
        fetchPartLocation(reloadData: false)
    }
    
    override func deleteItem(at row: Int) {
        let location = data[row]
        service.deleteSupplyLocation(supplyLocation: location) { [weak self] (result) in
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
        service.restoreSupplyLocation(supplyLocation: location) { [weak self] (result) in
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
        service.fetchSupplyLocations(showRemoved: isShowingRemoved, key: searchKey, sortBy: sortWith?.sortBy, sortType: sortWith?.sortType, offset: offset) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let supplyLocations):
                self.hasMoreData = supplyLocations.count == Constants.DATA_OFFSET
                if reloadData {
                    self.data = supplyLocations
                }
                else {
                    self.data.append(contentsOf: supplyLocations)
                }
                self.delegate.reloadView()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
}
