//
//  HolidayListView.swift
//  MyProHelper
//
//  Created by Deep on 1/13/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit
import SwiftDataTables

enum HolidayField: String {
    case HOLIDAY_NAME            = "HOLIDAY_NAME"
    case YEAR                    = "YEAR"
    case ACTUAL_DATE             = "ACTUAL_DATE"
    case DATE_CELEBRATED         = "DATE_CELEBRATED"
}

class HolidayListView: BaseDataTableView<Holiday, HolidayField>,Storyboarded {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Holidays List"
        viewModel = HolidayListViewModel(delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.addShowRemovedButton()
    }

    override func setDataTableFields() {
        dataTableFields = [
            .HOLIDAY_NAME,
            .YEAR,
            .ACTUAL_DATE,
            .DATE_CELEBRATED
        ]
    }
    
    @objc override func handleAddItem() {
        let createHolidayView = CreateHolidayView.instantiate(storyboard: .HOLIDAYS)
        createHolidayView.setViewMode(isEditingEnabled: true)
        navigationController?.pushViewController(createHolidayView, animated: true)
    }
    
    override func getHeader(for columnIndex: NSInteger) -> String {
        return dataTableFields[columnIndex].rawValue.localize
    }
    
    override func showItem(at indexPath: IndexPath) {
        let createHolidayView = CreateHolidayView.instantiate(storyboard: .HOLIDAYS)
        let holiday = viewModel.getItem(at: indexPath.section)
        createHolidayView.setViewMode(isEditingEnabled: false)
        createHolidayView.viewModel.setHoliday(holiday: holiday)
        navigationController?.pushViewController(createHolidayView, animated: true)
    }
    
    override func editItem(at indexPath: IndexPath) {
        let createHolidayView = CreateHolidayView.instantiate(storyboard: .HOLIDAYS)
        let holiday = viewModel.getItem(at: indexPath.section)
        createHolidayView.setViewMode(isEditingEnabled: true)
        createHolidayView.viewModel.setHoliday(holiday: holiday)
        navigationController?.pushViewController(createHolidayView, animated: true)
    }
  
}

