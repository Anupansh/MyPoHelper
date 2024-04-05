//
//  CreateWagesView.swift
//  MyProHelper
//
//  Created by sismac010 on 04/06/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import UIKit

private enum WageCheckboxField: String {
    case NEEDS_1099              = "NEEDS_1099"
    case IS_FIXED_CONTRACT_PRICE = "IS_FIXED_CONTRACT_PRICE"
    
    func stringValue() -> String {
        return self.rawValue.localize
    }
}

class CreateWagesView: BaseCreateWithAttachmentView<CreateWagesViewModel>, Storyboarded {
    private var fields: [WagesField] = [.WORKER_NAME,
                                        .SALARY_RATE,
//                                        .SALART_PER_TIME,
                                       .HOURLY_RATE,
                                       .W4WH,
                                       .W4EXEMPTIONS,
                                       .GARNISHMENTS,
                                       .GARNISHMENT_AMOUNT,
                                       .FED_TAX_WH,
                                       .STATE_TAX_WH,
                                       .START_EMPLOYMENT_DATE,
                                       .END_EMPLOYMENT_DATE,
                                       .CURRENT_VACATION_AMOUNT,
                                       .VACATION_ACCRUAL_RATE_IN_HOURS,
                                       .VACATION_HOURS_PER_YEAR,
                                       .CONTRACT_PRICE,
                                       .CHECKBOX,
                                       .ATTACHMENTS]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        getWorkers()
        setupCellsData()
        self.tableView.reloadData()
    }
    
    private func getWorkers() {
        viewModel.getWorkers { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    private func setupTableView() {
        let textFieldCell   = UINib(nibName: TextFieldCell.ID, bundle: nil)
        let checkboxCell    = UINib(nibName: CheckboxCell.ID, bundle: nil)
        let datePickerCell  = UINib(nibName: DatePickerCell.ID, bundle: nil)
        let dataPickerCell  = UINib(nibName: DataPickerCell.ID, bundle: nil)

//        wagesTableView.allowsSelection   = false
//        wagesTableView.dataSource        = self
//        wagesTableView.separatorStyle    = .none
//        wagesTableView.contentInset      = UIEdgeInsets(top: 20,
//                                                        left: 0,
//                                                        bottom: 20,
//                                                        right: 0)
        
        tableView.register(textFieldCell, forCellReuseIdentifier: TextFieldCell.ID)
        tableView.register(checkboxCell, forCellReuseIdentifier: CheckboxCell.ID)
        tableView.register(datePickerCell, forCellReuseIdentifier: DatePickerCell.ID)
        tableView.register(dataPickerCell, forCellReuseIdentifier: DataPickerCell.ID)
    }
    
    private func setupCellsData() {
        let workerName = ""//viewModel.getWorker() != nil ? viewModel.getWorker() : ((viewModel.getWorkers().count > 0) ? viewModel.getWorkers().first : "")
        
        cellData = [
            .init(title: WagesField2.WORKER_NAME.stringValue(),
                  key: WagesField2.WORKER_NAME.rawValue,
                  dataType: .ListView,
                  isRequired: isEditingEnabled,
                  isActive: isEditingEnabled ,
                  keyboardType: .default,
                  validation: viewModel.validateWorker(),
                  text: workerName,
                  listData: viewModel.getWorkers()),
            .init(title: WagesField.SALARY_RATE.stringValue(),
                   key: WagesField.SALARY_RATE.rawValue,
                   dataType: .Text,
                   isRequired: false,
                   isActive: isEditingEnabled,
                   keyboardType: .decimalPad,
                   validation: .Valid,
                   text: viewModel.getSalaryRate()),
//            .init(title: WagesField.SALART_PER_TIME.stringValue(),
//                   key: WagesField.SALART_PER_TIME.rawValue,
//                   dataType: .PickerView,
//                   isRequired: true,
//                   isActive: isEditingEnabled,
//                   validation: viewModel.validateSalaryPerTime(),
//                   text: viewModel.getSalaryPerTime(),
//                   listData: viewModel.getSalaryPerTimeList()),
            .init(title: WagesField.HOURLY_RATE.stringValue(),
                   key: WagesField.HOURLY_RATE.rawValue,
                   dataType: .Text,
                   isRequired: false,
                   isActive: isEditingEnabled,
                   keyboardType: .decimalPad,
                   validation: .Valid,
                   text: viewModel.getHourlyRate()),
            .init(title: WagesField.W4WH.stringValue(),
                   key: WagesField.W4WH.rawValue,
                   dataType: .Text,
                   isRequired: false,
                   isActive: isEditingEnabled,
                   keyboardType: .decimalPad,
                   validation: .Valid,
                   text: viewModel.getW4WH()),
            .init(title: WagesField.W4EXEMPTIONS.stringValue(),
                   key: WagesField.W4EXEMPTIONS.rawValue,
                   dataType: .Text,
                   isRequired: false,
                   isActive: isEditingEnabled,
                   keyboardType: .asciiCapableNumberPad,
                   validation: .Valid,
                   text: viewModel.getw4Exemptions()),
            .init(title: WagesField.GARNISHMENTS.stringValue(),
                   key: WagesField.GARNISHMENTS.rawValue,
                   dataType: .Text,
                   isRequired: false,
                   isActive: isEditingEnabled,
                   validation: .Valid,
                   text: viewModel.getGarnishments()),
            .init(title: WagesField.GARNISHMENT_AMOUNT.stringValue(),
                   key: WagesField.GARNISHMENT_AMOUNT.rawValue,
                   dataType: .Text,
                   isRequired: false,
                   isActive: isEditingEnabled,
                   keyboardType: .decimalPad,
                   validation: .Valid,
                   text: viewModel.getGarnishmentAmount()),
            .init(title: WagesField.FED_TAX_WH.stringValue(),
                   key: WagesField.FED_TAX_WH.rawValue,
                   dataType: .Text,
                   isRequired: false,
                   isActive: isEditingEnabled,
                   keyboardType: .decimalPad,
                   validation: .Valid,
                   text: viewModel.getfedTaxWH()),
            .init(title: WagesField.STATE_TAX_WH.stringValue(),
                   key: WagesField.STATE_TAX_WH.rawValue,
                   dataType: .Text,
                   isRequired: false,
                   isActive: isEditingEnabled,
                   keyboardType: .decimalPad,
                   validation: .Valid,
                   text: viewModel.getStateTaxWH()),
            .init(title: WagesField.START_EMPLOYMENT_DATE.stringValue(),
                   key: WagesField.START_EMPLOYMENT_DATE.rawValue,
                   dataType: .Date,
                   isRequired: false,
                   isActive: isEditingEnabled,
                   validation: .Valid,
                   text: viewModel.getStartEmploymentDate()),
            .init(title: WagesField.END_EMPLOYMENT_DATE.stringValue(),
                   key: WagesField.END_EMPLOYMENT_DATE.rawValue,
                   dataType: .Date,
                   isRequired: false,
                   isActive: isEditingEnabled,
                   validation: .Valid,
                   text: viewModel.getEndEmploymentDate()),
            .init(title: WagesField.CURRENT_VACATION_AMOUNT.stringValue(),
                   key: WagesField.CURRENT_VACATION_AMOUNT.rawValue,
                   dataType: .Text,
                   isRequired: false,
                   isActive: isEditingEnabled,
                   keyboardType: .decimalPad,
                   validation: .Valid,
                   text: viewModel.getCurrentVacationAmount()),
            .init(title: WagesField.VACATION_ACCRUAL_RATE_IN_HOURS.stringValue(),
                   key: WagesField.VACATION_ACCRUAL_RATE_IN_HOURS.rawValue,
                   dataType: .Text,
                   isRequired: false,
                   isActive: isEditingEnabled,
                   keyboardType: .decimalPad,
                   validation: .Valid,
                   text: viewModel.getVacationAccrualRateInHours()),
            .init(title: WagesField.VACATION_HOURS_PER_YEAR.stringValue(),
                   key: WagesField.VACATION_HOURS_PER_YEAR.rawValue,
                   dataType: .Text,
                   isRequired: false,
                   isActive: isEditingEnabled,
                   keyboardType: .decimalPad,
                   validation: .Valid,
                   text: viewModel.getVacationHoursPerYear()),
            .init(title: WagesField.CONTRACT_PRICE.stringValue(),
                  key: WagesField.CONTRACT_PRICE.rawValue,
                   dataType: .Text,
                   isRequired: false,
                   isActive: isEditingEnabled,
                   keyboardType: .decimalPad,
                   validation: .Valid,
                   text: viewModel.getContractPrice()),
            .init(title: WagesField.CONTRACT_PRICE.stringValue(),
                  key: WagesField.CONTRACT_PRICE.rawValue,
                   dataType: .Text,
                   isRequired: false,
                   isActive: isEditingEnabled,
                   keyboardType: .decimalPad,
                   validation: .Valid,
                   text: viewModel.getContractPrice()),
            .init(title: WagesField.Attachments.rawValue.localize,
                  key: WagesField.Attachments.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: "")
            ]

        updateSalaryPerTime(viewModel.getSalaryRateValue() > 0)
        
    }
    
    func updateSalaryPerTime(_ isAdd:Bool){
        if isAdd{
            if fields.contains(.SALART_PER_TIME){return}
            fields.insert(.SALART_PER_TIME, at: 2)
            cellData.insert(.init(title: WagesField.SALART_PER_TIME.stringValue(),
                              key: WagesField.SALART_PER_TIME.rawValue,
                              dataType: .PickerView,
                              isRequired: true,
                              isActive: isEditingEnabled,
                              validation: viewModel.validateSalaryPerTime(),
                              text: viewModel.getSalaryPerTime(),
                              listData: viewModel.getSalaryPerTimeList()),
                      at: 2)
        }
        else{
            let i = cellData.firstIndex(where: {$0.title == WagesField.SALART_PER_TIME.stringValue()}) ?? -1
            if i != -1{
                cellData.remove(at: i)
                
            }
            let j = fields.firstIndex(where: {$0 == .SALART_PER_TIME}) ?? -1
            if j != -1{
                fields.remove(at: j)
            }
        }
        tableView.reloadData()
    }
    
    override func getCell(at indexPath: IndexPath) -> BaseFormCell {
        
        switch fields[indexPath.row] {
        case .START_EMPLOYMENT_DATE, .END_EMPLOYMENT_DATE:
            return instantiateDateCell(cellForRowAt: indexPath)
        case .SALART_PER_TIME:
            return instantiateDataCell(cellForRowAt: indexPath)
        case .CHECKBOX:
            return initializeCheckboxCell()
        case .ATTACHMENTS:
            return instantiateAttachmentCell()
        default:
            return initializeTextFieldCell(cellForRowAt: indexPath)
        }
        
    }
    
    func initializeCheckboxCell() -> BaseFormCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CheckboxCell.ID) as? CheckboxCell else {
            return BaseFormCell()
        }
        cell.bindCell(data: [.init(key: WageCheckboxField.NEEDS_1099.rawValue,
                                   title: WageCheckboxField.NEEDS_1099.stringValue(),
                                   value: viewModel.isNeed1099()),
                             
                             .init(key: WageCheckboxField.IS_FIXED_CONTRACT_PRICE.rawValue,
                                   title: WageCheckboxField.IS_FIXED_CONTRACT_PRICE.stringValue(),
                                   value: viewModel.isFixedContractPrice())])
        cell.isSelectionEnabled = isEditingEnabled
        cell.delegate = self
        return cell
    }
    
    func instantiateDataCell(cellForRowAt indexPath: IndexPath) -> BaseFormCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DataPickerCell.ID) as? DataPickerCell else {
            return TextFieldCell()
        }
        let field = fields[indexPath.row]
        cell.showValidation = true//viewModel.didPerformAdd(for: .WAGES)
        cell.delegate = self
        cell.bindCell(data: .init(title: field.stringValue(),
                                       key: field.rawValue,
                                       dataType: .PickerView,
                                       isRequired: true,
                                       isActive: isEditingEnabled,
                                       validation: viewModel.validateSalaryPerTime(),
                                       text: viewModel.getSalaryPerTime(),
                                       listData: viewModel.getSalaryPerTimeList()))

        return cell
    }
    
    func instantiateDateCell(cellForRowAt indexPath: IndexPath) -> BaseFormCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DatePickerCell.ID) as? DatePickerCell else {
            return TextFieldCell()
        }

        let field = fields[indexPath.row]
        switch field {
        case .START_EMPLOYMENT_DATE:
            cell.bindCell(data: .init(title: field.stringValue(),
                                           key: field.rawValue,
                                           dataType: .Date,
                                           isRequired: false,
                                           isActive: isEditingEnabled,
                                           validation: .Valid,
                                           text: viewModel.getStartEmploymentDate()))
        case .END_EMPLOYMENT_DATE:
            cell.bindCell(data: .init(title: field.stringValue(),
                                           key: field.rawValue,
                                           dataType: .Date,
                                           isRequired: false,
                                           isActive: isEditingEnabled,
                                           validation: .Valid,
                                           text: viewModel.getEndEmploymentDate()))
        default:
            break
        }
        cell.delegate = self
        return cell
    }
     
    func initializeTextFieldCell(cellForRowAt indexPath: IndexPath) -> BaseFormCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.ID) as? TextFieldCell else {
            return TextFieldCell()
        }
        let field = fields[indexPath.row]
        
        switch field {
        case .WORKER_NAME:
//            let workerName = ""
            cell.bindTextField(data: .init(title: field.stringValue(),
                                           key: field.rawValue,
                                           dataType: .ListView,
                                           isRequired: true,
                                           isActive: isEditingEnabled,
                                           keyboardType: .asciiCapableNumberPad,
                                           validation: viewModel.validateWorker(),
                                           text: viewModel.getWorker(),
                                           listData: viewModel.getWorkers()))
            cell.listDelegate = self
        case .SALARY_RATE:
            cell.bindTextField(data: .init(title: field.stringValue(),
                                           key: field.rawValue,
                                           dataType: .Text,
                                           isRequired: false,
                                           isActive: isEditingEnabled,
                                           keyboardType: .decimalPad,
                                           validation: .Valid,
                                           text: viewModel.getSalaryRate()))
        case .HOURLY_RATE:
            cell.bindTextField(data: .init(title: field.stringValue(),
                                           key: field.rawValue,
                                           dataType: .Text,
                                           isRequired: false,
                                           isActive: isEditingEnabled,
                                           keyboardType: .decimalPad,
                                           validation: .Valid,
                                           text: viewModel.getHourlyRate()))
        case .W4WH:
            cell.bindTextField(data: .init(title: field.stringValue(),
                                           key: field.rawValue,
                                           dataType: .Text,
                                           isRequired: false,
                                           isActive: isEditingEnabled,
                                           keyboardType: .decimalPad,
                                           validation: .Valid,
                                           text: viewModel.getW4WH()))
        case .W4EXEMPTIONS:
            cell.bindTextField(data: .init(title: field.stringValue(),
                                           key: field.rawValue,
                                           dataType: .Text,
                                           isRequired: false,
                                           isActive: isEditingEnabled,
                                           keyboardType: .asciiCapableNumberPad,
                                           validation: .Valid,
                                           text: viewModel.getw4Exemptions()))
        case .GARNISHMENTS:
            cell.bindTextField(data: .init(title: field.stringValue(),
                                           key: field.rawValue,
                                           dataType: .Text,
                                           isRequired: false,
                                           isActive: isEditingEnabled,
                                           validation: .Valid,
                                           text: viewModel.getGarnishments()))
        case .GARNISHMENT_AMOUNT:
            cell.bindTextField(data: .init(title: field.stringValue(),
                                           key: field.rawValue,
                                           dataType: .Text,
                                           isRequired: false,
                                           isActive: isEditingEnabled,
                                           keyboardType: .decimalPad,
                                           validation: .Valid,
                                           text: viewModel.getGarnishmentAmount()))
        case .FED_TAX_WH:
            cell.bindTextField(data: .init(title: field.stringValue(),
                                           key: field.rawValue,
                                           dataType: .Text,
                                           isRequired: false,
                                           isActive: isEditingEnabled,
                                           keyboardType: .decimalPad,
                                           validation: .Valid,
                                           text: viewModel.getfedTaxWH()))
        case .STATE_TAX_WH:
            cell.bindTextField(data: .init(title: field.stringValue(),
                                           key: field.rawValue,
                                           dataType: .Text,
                                           isRequired: false,
                                           isActive: isEditingEnabled,
                                           keyboardType: .decimalPad,
                                           validation: .Valid,
                                           text: viewModel.getStateTaxWH()))

        case .CURRENT_VACATION_AMOUNT:
            cell.bindTextField(data: .init(title: field.stringValue(),
                                           key: field.rawValue,
                                           dataType: .Text,
                                           isRequired: false,
                                           isActive: isEditingEnabled,
                                           keyboardType: .decimalPad,
                                           validation: .Valid,
                                           text: viewModel.getCurrentVacationAmount()))
        case .VACATION_ACCRUAL_RATE_IN_HOURS:
            cell.bindTextField(data: .init(title: field.stringValue(),
                                           key: field.rawValue,
                                           dataType: .Text,
                                           isRequired: false,
                                           isActive: isEditingEnabled,
                                           keyboardType: .decimalPad,
                                           validation: .Valid,
                                           text: viewModel.getVacationAccrualRateInHours()))
        case .VACATION_HOURS_PER_YEAR:
            cell.bindTextField(data: .init(title: field.stringValue(),
                                           key: field.rawValue,
                                           dataType: .Text,
                                           isRequired: false,
                                           isActive: isEditingEnabled,
                                           keyboardType: .decimalPad,
                                           validation: .Valid,
                                           text: viewModel.getVacationHoursPerYear()))
        case .CONTRACT_PRICE:
            cell.bindTextField(data: .init(title: field.stringValue(),
                                           key: field.rawValue,
                                           dataType: .Text,
                                           isRequired: false,
                                           isActive: isEditingEnabled,
                                           keyboardType: .decimalPad,
                                           validation: .Valid,
                                           text: viewModel.getContractPrice()))
         
        default:
            break

        }
        cell.showValidation = true//viewModel.didPerformAdd(for: .WAGES)
        cell.delegate       = self
//        cell.validateData()
        return cell
    }
    
    override func handleAddItem() {
        super.handleAddItem()
        setupCellsData()
        viewModel.addWage { (error, isValidData) in
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
    
}

extension CreateWagesView: TextFieldListDelegate {
    
    func willAddItem(data: TextFieldCellData) {
        guard let cell = WagesField2(rawValue: data.key) else {
            return
        }
        switch cell {
        case .WORKER_NAME:break
        }
    }
    
    func didChooseItem(at row: Int?, data: TextFieldCellData) {
        guard let cell = WagesField2(rawValue: data.key) else {
            return
        }
        switch cell {
        case .WORKER_NAME:
            DispatchQueue.main.async { [unowned self] in
                self.viewModel.setWorker(at: row)
                data.text = viewModel.getWorker()
                self.tableView.reloadData()
            }
            break
        }
    }
}

//MARK: - Conform to Color Picker Cell Delegate
extension CreateWagesView: TextFieldCellDelegate {
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        guard let field = WagesField(rawValue: data.key) else { return }
        switch field {
        case .SALARY_RATE:
            viewModel.setSalaryRate(rate: text)
            updateSalaryPerTime(viewModel.getSalaryRateValue() > 0)
        case .HOURLY_RATE:
            viewModel.setHourlyRate(rate: text)
        case .W4WH:
            viewModel.setW4WH(value: text)
        case .W4EXEMPTIONS:
            viewModel.setW4Exemptions(value: text)
        case .GARNISHMENTS:
            viewModel.setGarnishments(garnishment: text)
        case .GARNISHMENT_AMOUNT:
            viewModel.setGarnishmentAmount(amount: text)
        case .FED_TAX_WH:
            viewModel.setfedTaxWH(value: text)
        case .STATE_TAX_WH:
            viewModel.setStateTaxWH(value: text)
        case .CURRENT_VACATION_AMOUNT:
            viewModel.setCurrentVacationAmount(amount: text)
        case .VACATION_ACCRUAL_RATE_IN_HOURS:
            viewModel.setVacationAccrualRateInHours(rate: text)
        case .VACATION_HOURS_PER_YEAR:
            viewModel.setVacationHoursPerYear(vacation: text)
        case .CONTRACT_PRICE:
            viewModel.setContractPrice(price: text)
        default:
            break
        }
    }
}

// MARK: - Conform to DatePickerCellDelegate
extension CreateWagesView: DatePickerCellDelegate {
    func didSelectDate(date: String?, date data: TextFieldCellData) {
        guard let field = WagesField(rawValue: data.key) else { return }
        switch field {
        case .START_EMPLOYMENT_DATE:
            viewModel.setStartEmploymentDate(date: date)
        case .END_EMPLOYMENT_DATE:
            viewModel.setEndEmploymentDate(date: date)
        default:
            break
        }
    }
}


// MARK: - Conform to PickerCellDelegate
extension CreateWagesView: PickerCellDelegate {
    func didPickItem(at index: Int, data: TextFieldCellData) {
        guard let field = WagesField(rawValue: data.key) else { return }
        switch field {
        case .SALART_PER_TIME:
            viewModel.setSalaryPerTime(at: index)
        default:
            break
        }
    }
}

//MARK: - Conform to Checkbox Cell Delegate
extension CreateWagesView: CheckboxCellDelegate {
    func didChangeValue(with data: RadioButtonData, isSelected: Bool) {
        guard let checkbox = WageCheckboxField(rawValue: data.key) else { return }
        switch checkbox {
        case .NEEDS_1099:
            viewModel.setNeed1099(isNeed: isSelected)
        case .IS_FIXED_CONTRACT_PRICE:
            viewModel.setFixedContractPrice(isFixed: isSelected)
        }
    }
}
