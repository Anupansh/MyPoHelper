//
//  PersonalInfoCell.swift
//  MyProHelper
//
//  Created by Samir on 12/30/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit

private enum PersonalInfoFields: String {
    case FIRST_NAME         = "FIRST_NAME"
    case MIDDLE_NAME        = "MIDDLE_NAME"
    case LAST_NAME          = "LAST_NAME"
    case NICKNAME           = "NICKNAME"
    case CELL_NUMBER        = "CELL_NUMBER"
    case EMAIL              = "EMAIL"
    case THEME              = "THEME"
    case FONT_COLOR         = "FONT_COLOR"
    case BACKGROUND_COLOR   = "BACKGROUND_COLOR"
    case HOUR_SALARY_WORKER = "HOUR_SALARY_WORKER"
    case CONTRACTOR         = "CONTRACTOR"
    
    func stringValue() -> String {
        return self.rawValue.localize
    }
}

private enum HourSalaryField: String {
    case SALARY = "SALARY"
    case HOURLY = "HOURLY"
    
    func stringValue() -> String {
        return self.rawValue.localize
    }
}

class PersonalInfoCell: UICollectionViewCell {

    static let ID = String(describing: PersonalInfoCell.self)
    
    @IBOutlet weak private var personalInfoTableView: UITableView!
    
    private let fields: [PersonalInfoFields] = [.FIRST_NAME,
                                                .MIDDLE_NAME,
                                                .LAST_NAME,
                                                .NICKNAME,
                                                .CELL_NUMBER,
                                                .EMAIL,
                                                .THEME,
                                                .FONT_COLOR,
                                                .BACKGROUND_COLOR,
                                                .HOUR_SALARY_WORKER,
                                                .CONTRACTOR]
    var isEditingEnabled = true
    var showViewDelegate: ShowViewDelegate?
    var viewModel: CreateWorkerViewModel!
    
    override func prepareForReuse() {
        personalInfoTableView.reloadData()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTableView()
    }
    
    private func setupTableView() {
        let textFieldCell   = UINib(nibName: TextFieldCell.ID, bundle: nil)
        let colorPickerCell = UINib(nibName: ColorPickerCell.ID, bundle: nil)
        let radioButtonCell = UINib(nibName: RadioButtonCell.ID, bundle: nil)
        let checkboxCell    = UINib(nibName: CheckboxCell.ID, bundle: nil)
        let dataPickerCell  = UINib(nibName: DataPickerCell.ID, bundle: nil)

        personalInfoTableView.allowsSelection   = false
        personalInfoTableView.dataSource        = self
        personalInfoTableView.separatorStyle    = .none
        personalInfoTableView.contentInset.top  = 20
        
        personalInfoTableView.register(textFieldCell, forCellReuseIdentifier: TextFieldCell.ID)
        personalInfoTableView.register(colorPickerCell, forCellReuseIdentifier: ColorPickerCell.ID)
        personalInfoTableView.register(radioButtonCell, forCellReuseIdentifier: RadioButtonCell.ID)
        personalInfoTableView.register(checkboxCell, forCellReuseIdentifier: CheckboxCell.ID)
        personalInfoTableView.register(dataPickerCell, forCellReuseIdentifier: DataPickerCell.ID)
    }
}

extension PersonalInfoCell: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fields.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let field = fields[indexPath.row]
        
        if field == .FONT_COLOR {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ColorPickerCell.ID) as? ColorPickerCell else {
                return UITableViewCell()
            }
            cell.bindData(data: .init(title: field.stringValue(),
                                      Key: field.rawValue,
                                      value: viewModel.getFontColor(),
                                      backgroundColor: viewModel.getbackgroundColor(),
                                      foregroundColor: viewModel.getFontColor(), isActive: isEditingEnabled))
            cell.delegate = self
            return cell
        }
        else if field == .BACKGROUND_COLOR {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ColorPickerCell.ID) as? ColorPickerCell else {
                return UITableViewCell()
            }
            cell.bindData(data: .init(title: field.stringValue(),
                                      Key: field.rawValue,
                                      value: viewModel.getbackgroundColor(),
                                      backgroundColor: viewModel.getbackgroundColor(),
                                      foregroundColor: viewModel.getFontColor(), isActive: isEditingEnabled))
            cell.delegate = self
            return cell
        }
        else if field == .HOUR_SALARY_WORKER {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: RadioButtonCell.ID) as? RadioButtonCell else {
                return UITableViewCell()
            }
            cell.isSelectionEnabled = isEditingEnabled
            cell.setTitle(title: field.stringValue())
            cell.bindCell(data: [.init(key: HourSalaryField.HOURLY.rawValue,
                                       title: HourSalaryField.HOURLY.stringValue(),
                                       value: viewModel.isHourlyWorker()),
                                 .init(key: HourSalaryField.SALARY.rawValue,
                                       title: HourSalaryField.SALARY.stringValue(),
                                       value: viewModel.isSalaryWorker())])
            cell.delegate = self
            return cell
        }
        else if field == .THEME {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DataPickerCell.ID) as? DataPickerCell else {
                return UITableViewCell()
            }
            cell.bindCell(data: .init(title: field.stringValue(),
                                      key: field.rawValue,
                                      dataType: .PickerView,
                                      isRequired: false,
                                      isActive: isEditingEnabled,
                                      validation: .Valid,
                                      text: viewModel?.getWorkerTheme(),
                                      listData: viewModel.getThemes()))
            cell.delegate = self
            cell.validateData()
            return cell
        }
        else if field == .CONTRACTOR {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CheckboxCell.ID) as? CheckboxCell else {
                return UITableViewCell()
            }
            cell.isSelectionEnabled = isEditingEnabled
            cell.bindCell(data: [.init(key: field.rawValue, title: field.stringValue(),value: viewModel.isContractor())])
            cell.delegate = self
            return cell
        }
        else {
            return initializeTextFieldCell(tableView, cellForRowAt: indexPath)
        }
    }
    
    func initializeTextFieldCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.ID) as? TextFieldCell else {
            return TextFieldCell()
        }
        cell.showValidation = viewModel.didPerformAdd(for: .PERSONAL_INFO)
        let field = fields[indexPath.row]
        switch field {
        
        case .FIRST_NAME:
            cell.bindTextField(data: .init(title: field.stringValue(),
                                           key: field.rawValue,
                                           dataType: .Text,
                                           isRequired: true,
                                           isActive: isEditingEnabled,
                                           validation: viewModel.validateFirstName(),
                                           text: viewModel?.getFirstName()))
        case .MIDDLE_NAME:
            cell.bindTextField(data: .init(title: field.stringValue(),
                                           key: field.rawValue,
                                           dataType: .Text,
                                           isRequired: false,
                                           isActive: isEditingEnabled,
                                           validation: viewModel.validateMiddleName(),
                                           text: viewModel?.getMiddleName()))
        case .LAST_NAME:
            cell.bindTextField(data: .init(title: field.stringValue(),
                                           key: field.rawValue,
                                           dataType: .Text,
                                           isRequired: true,
                                           isActive: isEditingEnabled,
                                           validation: viewModel.validateLastName(),
                                           text: viewModel?.getLastName()))
        case .NICKNAME:
            cell.bindTextField(data: .init(title: field.stringValue(),
                                           key: field.rawValue,
                                           dataType: .Text,
                                           isRequired: false,
                                           isActive: isEditingEnabled,
                                           validation: viewModel.validateNickname(),
                                           text: viewModel?.getNickname()))
        case .CELL_NUMBER:
            cell.bindTextField(data: .init(title: field.stringValue(),
                                           key: field.rawValue,
                                           dataType: .Mobile,
                                           isRequired: false,
                                           isActive: isEditingEnabled,
                                           validation: viewModel.validateCellNumber(),
                                           text: viewModel?.getCellNumber()))
        case .EMAIL:
            cell.bindTextField(data: .init(title: field.stringValue(),
                                           key: field.rawValue,
                                           dataType: .Text,
                                           isRequired: true,
                                           isActive: isEditingEnabled,
                                           keyboardType: .emailAddress,
                                           validation: viewModel.validateEmail(),
                                           text: viewModel?.getEmail()))
           
        default:
            break
        }
        cell.delegate = self
        cell.validateData()
        return cell
        
    }
}

//MARK: - Conform to TextField Cell Delegate
extension PersonalInfoCell: TextFieldCellDelegate {
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        guard let field = PersonalInfoFields(rawValue: data.key) else { return }
        switch field {
        case .FIRST_NAME:
            viewModel.setFirstName(name: text)
        case .MIDDLE_NAME:
            viewModel.setMiddleName(name: text)
        case .LAST_NAME:
            viewModel.setLasttName(name: text)
        case .NICKNAME:
            viewModel.setNickname(name: text)
        case .CELL_NUMBER:
            viewModel.setCellNumber(number: text)
        case .EMAIL:
            viewModel.setEmail(email: text)
        default:
            break
        }
    }
}

//MARK: - Conform to Color Picker Cell Delegate
extension PersonalInfoCell: ColorPickerCellDelegate {
    func willChooseColor(colorPicker: UIViewController) {
        showViewDelegate?.presentView(view: colorPicker, completion: {})
    }
    
    func didChooseColor(color: String, key: String) {
        guard let field = PersonalInfoFields(rawValue: key) else { return }
        
        switch field {
        case .FONT_COLOR:
            viewModel.setFontColor(color: color)
            refreshColorPickerCells()
        case .BACKGROUND_COLOR:
            viewModel.setBackgroundColor(color: color)
            refreshColorPickerCells()
        default:
            break
        }
    }
    
    private func refreshColorPickerCells() {
        guard let fontCell = fields.firstIndex(of: .FONT_COLOR) else { return }
        guard let backgroundCell = fields.firstIndex(of: .BACKGROUND_COLOR) else { return }
        let rows: [IndexPath] = [.init(row: fontCell, section: 0),
                                 .init(row: backgroundCell, section: 0)]
        personalInfoTableView.reloadRows(at: rows, with: .automatic)
    }
}

//MARK: - Conform to Radio Button Cell Delegate
extension PersonalInfoCell: RadioButtonCellDelegate {
    func didChooseButton(data: RadioButtonData) {
        guard let button = HourSalaryField(rawValue: data.key) else { return }
        switch button {
        case .SALARY:
            viewModel.setSalaryWorker()
        case .HOURLY:
            viewModel.setHourlyWorker()
        }
    }
}

//MARK: - Conform to Checkbox Cell Delegate
extension PersonalInfoCell: CheckboxCellDelegate {
    func didChangeValue(with data: RadioButtonData, isSelected: Bool) {
        viewModel.setContractor(isContractor: isSelected)
    }
}

//MARK: - Conform to List Cell Delegate
extension PersonalInfoCell: PickerCellDelegate {

    func didPickItem(at index: Int, data: TextFieldCellData) {
        guard let field = PersonalInfoFields(rawValue: data.key) else { return }
        switch field {
        case .THEME:
            viewModel.setWorkerTheme(at: index)
        default:
            break
        }
    }
}
