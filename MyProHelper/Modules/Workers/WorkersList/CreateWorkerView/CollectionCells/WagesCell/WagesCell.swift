//
//  WagesCell.swift
//  MyProHelper
//
//  Created by Samir on 12/30/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit

private enum WageField: String {
    
    case SALARY_RATE                    = "SALARY_RATE"
    case SALART_PER_TIME                = "SALART_PER_TIME"
    case HOURLY_RATE                    = "HOURLY_RATE"
    case W4WH                           = "W4WH"
    case GARNISHMENTS                   = "GARNISHMENTS"
    case GARNISHMENT_AMOUNT             = "GARNISHMENT_AMOUNT"
    case FED_TAX_WH                     = "FED_TAX_WH"
    case STATE_TAX_WH                   = "STATE_TAX_WH"
    case START_EMPLOYMENT_DATE          = "START_EMPLOYMENT_DATE"
    case END_EMPLOYMENT_DATE            = "END_EMPLOYMENT_DATE"
    case CURRENT_VACATION_AMOUNT        = "CURRENT_VACATION_AMOUNT"
    case VACATION_ACCRUAL_RATE_IN_HOURS = "VACATION_ACCRUAL_RATE_IN_HOURS"
    case VACATION_HOURS_PER_YEAR        = "VACATION_HOURS_PER_YEAR"
    case CONTRACT_PRICE                 = "CONTRACT_PRICE"
    case CHECKBOX                       = "CHECKBOX"
    
    func stringValue() -> String {
        return self.rawValue.localize
    }
}

private enum WageCheckboxField: String {
    case NEEDS_1099              = "NEEDS_1099"
    case IS_FIXED_CONTRACT_PRICE = "IS_FIXED_CONTRACT_PRICE"
    
    func stringValue() -> String {
        return self.rawValue.localize
    }
}

class WagesCell: UICollectionViewCell {
    
    static let ID = String(describing: WagesCell.self)
    
    @IBOutlet weak private var wagesTableView: UITableView!
    
    private let fields: [WageField] = [.SALARY_RATE,
                                       .SALART_PER_TIME,
                                       .HOURLY_RATE,
                                       .W4WH,
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
                                       .CHECKBOX]
    
    var isEditingEnabled = true
    var showViewDelegate: ShowViewDelegate?
    var viewModel: CreateWorkerViewModel!

    override func prepareForReuse() {
        wagesTableView.reloadData()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTableView()
    }
    
    private func setupTableView() {
        let textFieldCell   = UINib(nibName: TextFieldCell.ID, bundle: nil)
        let checkboxCell    = UINib(nibName: CheckboxCell.ID, bundle: nil)
        let datePickerCell  = UINib(nibName: DatePickerCell.ID, bundle: nil)
        let dataPickerCell  = UINib(nibName: DataPickerCell.ID, bundle: nil)

        wagesTableView.allowsSelection   = false
        wagesTableView.dataSource        = self
        wagesTableView.separatorStyle    = .none
        wagesTableView.contentInset      = UIEdgeInsets(top: 20,
                                                        left: 0,
                                                        bottom: 20,
                                                        right: 0)
        
        wagesTableView.register(textFieldCell, forCellReuseIdentifier: TextFieldCell.ID)
        wagesTableView.register(checkboxCell, forCellReuseIdentifier: CheckboxCell.ID)
        wagesTableView.register(datePickerCell, forCellReuseIdentifier: DatePickerCell.ID)
        wagesTableView.register(dataPickerCell, forCellReuseIdentifier: DataPickerCell.ID)
    }
    
}

extension WagesCell: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch fields[indexPath.row] {
        case .START_EMPLOYMENT_DATE, .END_EMPLOYMENT_DATE:
            return instantiateDateCell(tableView, cellForRowAt: indexPath)
        case .SALART_PER_TIME:
            return instantiateDataCell(tableView, cellForRowAt: indexPath)
        case .CHECKBOX:
            return initializeCheckboxCell(tableView)
        default:
            return initializeTextFieldCell(tableView, cellForRowAt: indexPath)
        }
    }
    
    func initializeCheckboxCell(_ tableView: UITableView) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CheckboxCell.ID) as? CheckboxCell else {
            return UITableViewCell()
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

    func instantiateDataCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DataPickerCell.ID) as? DataPickerCell else {
            return TextFieldCell()
        }
        let field = fields[indexPath.row]
        
        cell.bindCell(data: .init(title: field.stringValue(),
                                       key: field.rawValue,
                                       dataType: .PickerView,
                                       isRequired: true,
                                       isActive: isEditingEnabled,
                                       validation: viewModel.validateSalaryPerTime(),
                                       text: viewModel.getSalaryPerTime(),
                                       listData: viewModel.getSalaryPerTimeList()))

        cell.showValidation = viewModel.didPerformAdd(for: .WAGES)
        cell.delegate = self
        cell.validateData()
        return cell
    }

    func instantiateDateCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        cell.showValidation = viewModel.didPerformAdd(for: .WAGES)
        cell.delegate = self
        cell.validateData()
        return cell
    }

    func initializeTextFieldCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.ID) as? TextFieldCell else {
            return TextFieldCell()
        }
        let field = fields[indexPath.row]
        
        switch field {
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
        cell.showValidation = viewModel.didPerformAdd(for: .WAGES)
        cell.delegate       = self
        cell.validateData()
        return cell
    }
}

//MARK: - Conform to Color Picker Cell Delegate
extension WagesCell: TextFieldCellDelegate {
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        guard let field = WageField(rawValue: data.key) else { return }
        switch field {
        case .SALARY_RATE:
            viewModel.setSalaryRate(rate: text)
        case .HOURLY_RATE:
            viewModel.setHourlyRate(rate: text)
        case .W4WH:
            viewModel.setW4WH(value: text)
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

//MARK: - Conform to Checkbox Cell Delegate
extension WagesCell: CheckboxCellDelegate {
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

// MARK: - Conform to DatePickerCellDelegate
extension WagesCell: DatePickerCellDelegate {
    func didSelectDate(date: String?, date data: TextFieldCellData) {
        guard let field = WageField(rawValue: data.key) else { return }
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
extension WagesCell: PickerCellDelegate {
    func didPickItem(at index: Int, data: TextFieldCellData) {
        guard let field = WageField(rawValue: data.key) else { return }
        switch field {
        case .SALART_PER_TIME:
            viewModel.setSalaryPerTime(at: index)
        default:
            break
        }
    }
}
