//
//  RolesCell.swift
//  MyProHelper
//
//  Created by Samir on 12/30/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit

enum RoleOption: String {
    case ADMIN                              = "ADMIN"
    case OWNER                              = "OWNER"
    case TECH_SUPPORT                       = "TECH_SUPPORT"
    case CAN_DO_COMPANY_SETUP               = "CAN_DO_COMPANY_SETUP"
    case CAN_ADD_WORKERS                    = "CAN_ADD_WORKERS"
    case CAN_ADD_CUSTOMERS                  = "CAN_ADD_CUSTOMERS"
    case CAN_RUN_PAYROLL                    = "CAN_RUN_PAYROLL"
    case CAN_SEE_WAGES                      = "CAN_SEE_WAGES"
//    case CAN_SCHEDULE                       = "CAN_SCHEDULE"
    case CAN_DO_INVENTORY                   = "CAN_DO_INVENTORY"
    case CAN_RUN_REPORT                     = "CAN_RUN_REPORT"
    case CAN_ADD_REMOVE_INVENTORY_ITEMS     = "CAN_ADD_REMOVE_INVENTORY_ITEMS"
    case CAN_EDIT_TIME_ALREADY_ENTERED      = "CAN_EDIT_TIME_ALREADY_ENTERED"
    case CAN_REQUEST_VACATION               = "CAN_REQUEST_VACATION"
    case CAN_REQUEST_SICK                   = "CAN_REQUEST_SICK"
    case CAN_REQUEST_PERSONAL_TIME          = "CAN_REQUEST_PERSONAL_TIME"
    case CAN_APPROVE_TIMEOFF                = "CAN_APPROVE_TIMEOFF"
    case CAN_APPROVE_PAYROLL                = "CAN_APPROVE_PAYROLL"
    case CAN_EDIT_JOB_HISTORY               = "CAN_EDIT_JOB_HISTORY"
    case CAN_SCHEDULE_JOBS                  = "CAN_SCHEDULE_JOBS"
    case CAN_APPROVE_PURCHASE_ORDERS        = "CAN_APPROVE_PURCHASE_ORDERS"
    case CAN_APPROVE_WORK_ORDERS            = "CAN_APPROVE_WORK_ORDERS"
    case CAN_APPROVE_INVOICES               = "CAN_APPROVE_INVOICES"
    case RECEIVE_EMAIL_FOR_REJECTED_JOBS    = "RECEIVE_EMAIL_FOR_REJECTED_JOBS"
    
    func stringValue() -> String {
        return self.rawValue.localize
    }
}

class RolesCell: UICollectionViewCell {

    static let ID = String(describing: RolesCell.self)
    
    @IBOutlet weak private var rolesGroupLabel      : UILabel!
    @IBOutlet weak private var rolesGroupTextField  : UITextField!
    @IBOutlet weak private var rolesTableView       : UITableView!
    
    private let rolesPickerView = UIPickerView()
    private let roles: [RoleOption] = [.ADMIN,
                                       .CAN_DO_COMPANY_SETUP,
                                       .CAN_ADD_WORKERS,
                                       .CAN_ADD_CUSTOMERS,
                                       .CAN_RUN_PAYROLL,
                                       .CAN_SEE_WAGES,
//                                       .CAN_SCHEDULE,
                                       .CAN_DO_INVENTORY,
                                       .CAN_RUN_REPORT,
                                       .CAN_ADD_REMOVE_INVENTORY_ITEMS,
                                       .CAN_EDIT_TIME_ALREADY_ENTERED,
                                       .CAN_REQUEST_VACATION,
                                       .CAN_REQUEST_SICK,
                                       .CAN_REQUEST_PERSONAL_TIME,
                                       .CAN_EDIT_JOB_HISTORY,
                                       .CAN_SCHEDULE_JOBS,
                                       .CAN_APPROVE_PURCHASE_ORDERS,
                                       .CAN_APPROVE_WORK_ORDERS,
                                       .CAN_APPROVE_INVOICES,
                                       .RECEIVE_EMAIL_FOR_REJECTED_JOBS]

    var isEditingEnabled = true {
        didSet {
            rolesGroupTextField.isEnabled = isEditingEnabled

        }
    }
    var viewModel: CreateWorkerViewModel? {
        didSet {
            fetchRolesGroup()
            bindTextField()
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        setupTableView()
        setupTextField()
        setupRolesPickerView()
    }
    
    private func setupTableView() {
        let roleCell = UINib(nibName: RoleItemCell.ID, bundle: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleClosePicker))
        
        rolesTableView.allowsSelection   = false
        rolesTableView.dataSource        = self
        rolesTableView.separatorStyle    = .none
        rolesTableView.contentInset.top  = 20
        
        rolesTableView.addGestureRecognizer(tapGesture)
        rolesTableView.register(roleCell, forCellReuseIdentifier: RoleItemCell.ID)
    }
    
    private func setupTextField() {
        rolesGroupTextField.inputView   = rolesPickerView
        rolesGroupTextField.tintColor   = .clear
    }
    
    private func setupRolesPickerView() {
        rolesPickerView.delegate    = self
        rolesPickerView.dataSource  = self
    }
    
    @objc private func handleClosePicker() {
        rolesGroupTextField.resignFirstResponder()
    }
    
    private func bindTextField() {
        rolesGroupTextField.text = viewModel?.getSelectedRolesGroup() ?? "SELECT_ITEM_MESSAGE".localize
    }
    
    private func fetchRolesGroup() {
        guard let viewModel = viewModel else { return }
        viewModel.fetchRolesGroup(completion: { [weak self] in
            guard let self = self else { return }
            self.rolesPickerView.reloadAllComponents()
        })
    }
}

extension RolesCell: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RoleItemCell.ID) as? RoleItemCell else {
            return UITableViewCell()
        }
        guard let viewModel = viewModel else { return UITableViewCell() }
        let role = roles[indexPath.row]
        cell.isSelectionEnabled = isEditingEnabled
        cell.bindData(title: role.stringValue(),
                      isOn: viewModel.isRoleOpen(for: role) ?? false)
        cell.didSetRole =  { (isOpen) in
            viewModel.changeRoleState(for: role, value: isOpen)
        }
        return cell
    }
}

//MARK:  - CONFORM TO PICKER VIEW DELEGATE
extension RolesCell: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let viewModel = viewModel else { return }
        rolesGroupTextField.text = viewModel.getRolesGroup(at: row)
        viewModel.selectRolesGroup(at: row)
        rolesTableView.reloadData()
    }
}

//MARK:  - CONFORM TO PICKER VIEW DATA SOURCE
extension RolesCell: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel?.countRolesGroup() ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel?.getRolesGroup(at: row)
    }
}
