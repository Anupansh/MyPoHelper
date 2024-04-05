//
//  CreateRoleGroup.swift
//  MyProHelper
//
//  Created by sismac010 on 02/08/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

private enum CreateRoleGroupFields: String {
    case GROUP_NAME         = "GROUP_NAME"
    func stringValue() -> String {
        return self.rawValue.localize
    }
}

enum CreateRoleGroupFields2: String {
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

class CreateRoleGroup: BaseCreateItemView, Storyboarded {
    
    private let roles: [CreateRoleGroupFields2] = [.ADMIN,
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
    
    var viewModel: CreateRoleGroupModel = CreateRoleGroupModel()

    //MARK:- View controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCellsData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "ROLES_GROUP".localize
    }
    
    
    override func handleAddItem() {
        super.handleAddItem()
        setupCellsData()
        saveRoles()
    
    }
    
    private func saveRoles() {
        viewModel.saveRoles { (error, isValidData) in
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
            .init(title: CreateRoleGroupFields.GROUP_NAME.stringValue(),
                  key: CreateRoleGroupFields.GROUP_NAME.rawValue,
                  dataType: .Text,
                  isRequired: isEditingEnabled,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateGroupName(),
                  text:viewModel.getRolesGroupName()),
            ]
        
        for option in roles {
            cellData.append(
                .init(title: option.stringValue(),
                      key: option.rawValue,
                      dataType: .Text,
                      isRequired: false,
                      isActive: false,
                      validation: .Valid,
                      text: "")
            )
        }
        
    }
    
    override func getCell(at indexPath: IndexPath) -> BaseFormCell {
        if let _ = CreateRoleGroupFields2(rawValue:  cellData[indexPath.row].key) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: RoleItemCell.ID) as? RoleItemCell else {
                return RoleItemCell()
            }
            let role = roles[indexPath.row-1]
            cell.isSelectionEnabled = isEditingEnabled
            cell.bindData(title: role.stringValue(),
                          isOn: viewModel.isRoleOpen(for: role) ?? false)
            cell.didSetRole =  { (isOpen) in
                self.viewModel.changeRoleState(for: role, value: isOpen)
            }
            
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.ID) as? TextFieldCell else {
             return BaseFormCell()
        }
        
        
         cell.bindTextField(data: cellData[indexPath.row])
         cell.delegate = self
         return cell
    }
    
}


extension CreateRoleGroup: TextFieldCellDelegate {
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        guard let field = CreateRoleGroupFields(rawValue: data.key) else {
            return
        }
        
        switch field {
        
        case .GROUP_NAME:
            viewModel.setRolesGroupName(name: text)
            break
        }
    }
    
}

