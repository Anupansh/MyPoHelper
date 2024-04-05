//
//  AssetTypeListViewModel.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/26/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

class AssetTypeListViewModel: BaseDataTableViewModel<AssetType, AssetTypeField> {
    let service = AssetTypeService()
    
    override func reloadData() {
        hasMoreData = true
        fetchAssetType(reloadData: true)
    }
    
    override func fetchMoreData() {
        fetchAssetType(reloadData: false)
    }
    
    override func deleteItem(at row: Int) {
        let assetType = data[row]
        service.deleteAssetTypes(assetType: assetType) { [weak self] (result) in
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
        let assetType = data[row]
        service.restoreAssetTypes(assetType: assetType) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.reloadData()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
    
    private func fetchAssetType(reloadData: Bool) {
        guard hasMoreData else { return }
        let offset = (reloadData == false) ? data.count : 0
        service.fetchAssetType(showRemoved: isShowingRemoved, key: searchKey, sortBy: sortWith?.sortBy, sortType: sortWith?.sortType, offset: offset) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let assetType):
                self.hasMoreData = assetType.count == Constants.DATA_OFFSET
                if reloadData {
                    self.data = assetType
                }
                else {
                    self.data.append(contentsOf: assetType)
                }
                self.delegate.reloadView()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
}
