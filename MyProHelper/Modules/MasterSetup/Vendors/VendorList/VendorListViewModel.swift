//
//  VendorListViewModel.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/20/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

class VendorListViewModel: BaseDataTableViewModel<Vendor,VendorField> {
    
    private let service = VendorService()
    
    override func reloadData() {
        hasMoreData = true
        fetchVendors(reloadData: true)
    }
    
    override func fetchMoreData() {
        fetchVendors(reloadData: false)
    }
    
    override func deleteItem(at row: Int) {
        let vendor = data[row]
        service.deleteVendor(at: vendor) { [weak self] (result) in
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
        let vendor = data[row]
        service.restoreVendor(at: vendor) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.reloadData()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
    
    private func fetchVendors(reloadData: Bool) {
        guard hasMoreData else { return }
        let offset = (reloadData == false) ? data.count : 0
        
        service.fetchVendors(showRemoved: isShowingRemoved, key: searchKey, sortBy: sortWith?.sortBy, sortType: sortWith?.sortType, offset: offset) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let vendors):
                self.hasMoreData = vendors.count == Constants.DATA_OFFSET
                if reloadData {
                    self.data = vendors
                }
                else {
                    self.data.append(contentsOf: vendors)
                }
                self.delegate.reloadView()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
        
    }
}
