//
//  AssetListViewModel.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/27/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

class AssetListViewModel: BaseDataTableViewModel<Asset,AssetField> {
    let service = AssetService()
    
    override func reloadData() {
        hasMoreData = true
        fetchAsset(reloadData: true)
    }
    
    override func fetchMoreData() {
        fetchAsset(reloadData: false)
    }
    
    override func deleteItem(at row: Int) {
        let asset = data[row]
        service.deleteAsset(asset: asset) { [weak self] (result) in
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
        let asset = data[row]
        service.restoreAsset(asset: asset) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.reloadData()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
    
    private func fetchAsset(reloadData: Bool) {
        guard hasMoreData else { return }
        let offset = (reloadData == false) ? data.count : 0
        service.fetchAsset(showRemoved: isShowingRemoved, key: searchKey, sortBy: sortWith?.sortBy, sortType: sortWith?.sortType, offset: offset) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let assets):
                self.hasMoreData = assets.count == Constants.DATA_OFFSET
                if reloadData {
                    self.data = assets
                }
                else {
                    self.data.append(contentsOf: assets)
                }
                self.delegate.reloadView()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
}
