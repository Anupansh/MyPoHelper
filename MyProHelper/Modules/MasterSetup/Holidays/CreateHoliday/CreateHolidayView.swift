//
//  CreateHolidayView.swift
//  MyProHelper
//
//  Created by Deep on 1/14/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit

private enum HolidayCell: String {
    case HOLIDAY_NAME         = "HOLIDAY_NAME"
    case YEAR                 = "YEAR"
    case ACTUAL_DATE          = "ACTUAL_DATE"
    case DATE_CELEBRATED      = "DATE_CELEBRATED"
}

class CreateHolidayView: BaseCreateItemView, Storyboarded {
    
    let viewModel = CreateHolidayViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCellsData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func getCell(at indexPath: IndexPath) -> BaseFormCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.ID) as? TextFieldCell else {
             return BaseFormCell()
         }
         cell.bindTextField(data: cellData[indexPath.row])
         cell.delegate = self
         return cell
    }
    
    override func handleAddItem() {
        super.handleAddItem()
        setupCellsData()
        viewModel.saveHoliday{ (error, isValidData) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let title = self.title ?? ""
                if let error = error {
                    GlobalFunction.showMessageAlert(fromView: self, title: title, message: error)
                }
                else if isValidData {
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func setupCellsData() {
        cellData = [
            .init(title: HolidayCell.HOLIDAY_NAME.rawValue.localize,
                  key: HolidayCell.HOLIDAY_NAME.rawValue,
                  dataType: .Text,
                  isRequired: true,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateHolidayName(),
                  text: viewModel.getHolidayName()),
            
            .init(title: HolidayCell.YEAR.rawValue.localize,
                  key: HolidayCell.YEAR.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  keyboardType: .asciiCapableNumberPad,
                  validation: .Valid,
                  text: viewModel.getYear()),
            
            .init(title: HolidayCell.ACTUAL_DATE.rawValue.localize,
                  key: HolidayCell.ACTUAL_DATE.rawValue,
                  dataType: .Date,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: viewModel.getHolidayActualDate()),
            
            .init(title: HolidayCell.DATE_CELEBRATED.rawValue.localize,
                  key: HolidayCell.DATE_CELEBRATED.rawValue,
                  dataType: .Date,
                  isRequired: false,
                  isActive: viewModel.checkWeekend(),
                  validation: .Valid,
                  text: viewModel.getHolidayActualDate()),
        ]
    }
}

extension CreateHolidayView: TextFieldCellDelegate {
    
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        guard let cell = HolidayCell(rawValue: data.key) else {
            return
        }
        switch cell {
        case .HOLIDAY_NAME:
            viewModel.setHolidayName(holidayName: text)
        case .YEAR:
            viewModel.setYear(year: text)
        case .ACTUAL_DATE:
            viewModel.setActualDate(actualDate: text)
            setupCellsData()
            let actualDateIndex = IndexPath(row: 3, section: 0)
            tableView.reloadRows(at: [actualDateIndex], with: .automatic)
        case .DATE_CELEBRATED:
            viewModel.setDateCelebrated(dateCelebrated: text)
        }
    }
}
