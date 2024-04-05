//
//  AssetListView.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/27/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit

enum AssetField: String {
    case ASSETS_NAME            = "ASSETS_NAME"
    case DESCRIPTION            = "DESCRIPTION"
    case MODEL_INFO             = "MODEL_INFO"
    case SERIAL_NUMBER          = "SERIAL_NUMBER"
    case ASSET_TYPE             = "ASSET_TYPE"
    case PURCHASE_PRICE         = "PURCHASE_PRICE"
    case MILEAGE                = "MILEAGE"
    case HOURS_USED             = "HOURS_USED"
    case ATTACHMENTS            = "ATTACHMENTS"
    case MAINTENANCE_DATE       = "MAINTENANCE_DATE"
    case PURCHASED_DATE         = "PURCHASED_DATE"
}

class AssetListView: BaseDataTableView<Asset, AssetField>, Storyboarded {

    override func viewDidLoad() {
        super.viewDidLoad()
        hasDecimalAlignRightSide = true
        title = "Asset List"
        viewModel = AssetListViewModel(delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.addShowRemovedButton()
    }
    
    @objc override func handleAddItem() {
        let createAssetView = CreateAssetView.instantiate(storyboard: .ASSET)
        createAssetView.viewModel = CreateAssetViewModel(attachmentSource: .ASSET)
        createAssetView.setViewMode(isEditingEnabled: true)
        navigationController?.pushViewController(createAssetView, animated: true)
    }
    
    override func setDataTableFields() {
        dataTableFields = [
            .ASSETS_NAME,
            .DESCRIPTION,
            .MODEL_INFO,
            .SERIAL_NUMBER,
            .ASSET_TYPE,
            .PURCHASE_PRICE,
            .MILEAGE,
            .HOURS_USED,
            .ATTACHMENTS,
            .MAINTENANCE_DATE,
            .PURCHASED_DATE
        ]
    }
    
    override func getHeader(for columnIndex: NSInteger) -> String {
        return dataTableFields[columnIndex].rawValue.localize
    }
    
    override func showItem(at indexPath: IndexPath) {
        let createAssetView = CreateAssetView.instantiate(storyboard: .ASSET)
        let asset = viewModel.getItem(at: indexPath.section)
        createAssetView.viewModel = CreateAssetViewModel(attachmentSource: .ASSET)
        createAssetView.setViewMode(isEditingEnabled: false)
        createAssetView.viewModel.setAsset(asset: asset)
        navigationController?.pushViewController(createAssetView, animated: true)
    }
    
    override func editItem(at indexPath: IndexPath) {
        let createAssetView = CreateAssetView.instantiate(storyboard: .ASSET)
        let asset = viewModel.getItem(at: indexPath.section)
        createAssetView.viewModel = CreateAssetViewModel(attachmentSource: .ASSET)
        createAssetView.setViewMode(isEditingEnabled: true)
        createAssetView.viewModel.setAsset(asset: asset)
        navigationController?.pushViewController(createAssetView, animated: true)
    }
}
