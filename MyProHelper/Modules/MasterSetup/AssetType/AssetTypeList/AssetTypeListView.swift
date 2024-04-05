//
//  AssetTypeListView.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/26/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit

enum AssetTypeField: String {
    case TYPE_OF_ASSET          = "TYPE_OF_ASSET"
    case CREATED_DATE           = "CREATED_DATE"
}

class AssetTypeListView: BaseDataTableView<AssetType, AssetTypeField>, Storyboarded {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Asset Type"
        viewModel = AssetTypeListViewModel(delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.addShowRemovedButton()
    }
    
    @objc override func handleAddItem() {
        let createAssetTypeView = CreateAssetTypeView.instantiate(storyboard: .ASSET_TYPE)
        createAssetTypeView.setViewMode(isEditingEnabled: true)
        navigationController?.pushViewController(createAssetTypeView, animated: true)
    }
    
    override func setDataTableFields() {
        dataTableFields = [
            .TYPE_OF_ASSET,
            .CREATED_DATE
        ]
    }
    
    override func getHeader(for columnIndex: NSInteger) -> String {
        return dataTableFields[columnIndex].rawValue.localize
    }
    
    override func showItem(at indexPath: IndexPath) {
        let createAssetTypeView = CreateAssetTypeView.instantiate(storyboard: .ASSET_TYPE)
        let assetType = viewModel.getItem(at: indexPath.section)
        createAssetTypeView.setViewMode(isEditingEnabled: false)
        createAssetTypeView.viewModel.setAssetType(assetType: assetType)
        navigationController?.pushViewController(createAssetTypeView, animated: true)
    }
    
    override func editItem(at indexPath: IndexPath) {
        let createAssetTypeView = CreateAssetTypeView.instantiate(storyboard: .ASSET_TYPE)
        let assetType = viewModel.getItem(at: indexPath.section)
        createAssetTypeView.setViewMode(isEditingEnabled: true)
        createAssetTypeView.viewModel.setAssetType(assetType: assetType)
        navigationController?.pushViewController(createAssetTypeView, animated: true)
    }
}
