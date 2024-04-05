//
//  SupplyLocationList.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/25/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit

enum SupplyLocationField: String {
    case NAME                   = "NAME"
    case DESCRIPTION            = "DESCRIPTION"
    case CREATED_DATE           = "CREATED_DATE"
}


class SupplyLocationListView: BaseDataTableView<SupplyLocation, SupplyLocationField>, Storyboarded {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Supply Location"
        viewModel = SupplyLocationListViewModel(delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.addShowRemovedButton()
    }
    
    @objc override func handleAddItem() {
        let createSupplyLocation = CreateSupplyLocationView.instantiate(storyboard: .SUPPLY_LOCATION)
        createSupplyLocation.setViewMode(isEditingEnabled: true)
        navigationController?.pushViewController(createSupplyLocation, animated: true)
    }
    
    override func setDataTableFields() {
        dataTableFields = [
            .NAME,
            .DESCRIPTION,
            .CREATED_DATE
        ]
    }
    
    override func getHeader(for columnIndex: NSInteger) -> String {
        return dataTableFields[columnIndex].rawValue.localize
    }
    
    override func showItem(at indexPath: IndexPath) {
        let createSupplyLocation = CreateSupplyLocationView.instantiate(storyboard: .SUPPLY_LOCATION)
        let supplyLocation = viewModel.getItem(at: indexPath.section)
        createSupplyLocation.setViewMode(isEditingEnabled: false)
        createSupplyLocation.viewModel.setSupplyLocation(supplyLocation: supplyLocation)
        navigationController?.pushViewController(createSupplyLocation, animated: true)
    }
    
    override func editItem(at indexPath: IndexPath) {
        let createSupplyLocation = CreateSupplyLocationView.instantiate(storyboard: .SUPPLY_LOCATION)
        let supplyLocation = viewModel.getItem(at: indexPath.section)
        createSupplyLocation.setViewMode(isEditingEnabled: true)
        createSupplyLocation.viewModel.setSupplyLocation(supplyLocation: supplyLocation)
        navigationController?.pushViewController(createSupplyLocation, animated: true)
    }
}
