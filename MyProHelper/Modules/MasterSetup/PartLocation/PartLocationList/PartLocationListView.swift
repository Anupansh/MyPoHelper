//
//  PartLocationList.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/21/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit

enum PartLocationField: String {
    case NAME                   = "NAME"
    case DESCRIPTION            = "DESCRIPTION"
    case CREATED_DATE           = "CREATED_DATE"
}

class PartLocationListView: BaseDataTableView<PartLocation,PartLocationField>, Storyboarded {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Part Location"
        viewModel = PartLocationViewModel(delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.addShowRemovedButton()
    }
    
    @objc override func handleAddItem() {
        let createPartLocationView = CreatePartLocationView.instantiate(storyboard: .PART_LOCATION)
        createPartLocationView.setViewMode(isEditingEnabled: true)
        navigationController?.pushViewController(createPartLocationView, animated: true)
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
        let createPartLocationView = CreatePartLocationView.instantiate(storyboard: .PART_LOCATION)
        let partLocation = viewModel.getItem(at: indexPath.section)
        createPartLocationView.setViewMode(isEditingEnabled: false)
        createPartLocationView.viewModel.setPartLocation(partLocation: partLocation)
        navigationController?.pushViewController(createPartLocationView, animated: true)
    }
    
    override func editItem(at indexPath: IndexPath) {
        let createPartLocationView = CreatePartLocationView.instantiate(storyboard: .PART_LOCATION)
        let partLocation = viewModel.getItem(at: indexPath.section)
        createPartLocationView.setViewMode(isEditingEnabled: true)
        createPartLocationView.viewModel.setPartLocation(partLocation: partLocation)
        navigationController?.pushViewController(createPartLocationView, animated: true)
    }
}
