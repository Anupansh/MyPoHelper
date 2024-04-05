//
//  CreateVendorView.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/21/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit

private enum VendorCell: String {
    case VENDOR_NAME            = "VENDOR_NAME"
    case PHONE                  = "PHONE"
    case EMAIL                  = "EMAIL"
    case CONTACT_NAME           = "CONTACT_NAME"
    case ACCOUNT_NUMBER         = "ACCOUNT_NUMBER"
    case MOST_RECENT_CONTACT    = "MOST_RECENT_CONTACT"
    case ATTACHMENTS            = "Attachments"
}

class CreateVendorView: BaseCreateWithAttachmentView<CreateVendorViewModel>, Storyboarded {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCellsData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func getCell(at indexPath: IndexPath) -> BaseFormCell {
        if let cellType = VendorCell(rawValue:  cellData[indexPath.row].key), cellType == .ATTACHMENTS {
            return instantiateAttachmentCell()
        }
        
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
        viewModel.saveVendor { (error, isValidData) in
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
            .init(title: VendorCell.VENDOR_NAME.rawValue.localize,
                  key: VendorCell.VENDOR_NAME.rawValue,
                  dataType: .Text,
                  isRequired: true,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateVendorName(),
                  text: viewModel.getVendorName()),
            
            .init(title: VendorCell.PHONE.rawValue.localize,
                  key: VendorCell.PHONE.rawValue,
                  dataType: .Mobile,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  keyboardType: .asciiCapableNumberPad,
                  validation: viewModel.validateVendorPhone(),
                  text: viewModel.getVendorPhone()),
            
            .init(title: VendorCell.EMAIL.rawValue.localize,
                  key: VendorCell.EMAIL.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  keyboardType: .emailAddress,
                  validation: viewModel.validateVendorEmail(),
                  text: viewModel.getVendorEmail()),
            
            .init(title: VendorCell.CONTACT_NAME.rawValue.localize,
                  key: VendorCell.CONTACT_NAME.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateVendorContactName(),
                  text: viewModel.getVendorContactName()),
            
            .init(title: VendorCell.ACCOUNT_NUMBER.rawValue.localize,
                  key: VendorCell.ACCOUNT_NUMBER.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateVendorAccountNumber(),
                  text: viewModel.getAccountNumber()),
            
            .init(title: VendorCell.MOST_RECENT_CONTACT.rawValue.localize,
                  key:  VendorCell.MOST_RECENT_CONTACT.rawValue,
                  dataType: .Date,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: viewModel.getMostRecentContact()),
            
            .init(title: VendorCell.ATTACHMENTS.rawValue.localize,
                  key: VendorCell.ATTACHMENTS.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: "")
        ]
    }
}

extension CreateVendorView: TextFieldCellDelegate {
    
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        guard let cell = VendorCell(rawValue: data.key) else {
            return
        }
        
        switch cell {
        case .VENDOR_NAME:
            viewModel.setVendorName(name: text)
            
        case .PHONE:
            viewModel.setPhone(phone: text)
            
        case .EMAIL:
            viewModel.setEmail(email: text)
            
        case .CONTACT_NAME:
            viewModel.setContactName(name: text)
            
        case .ACCOUNT_NUMBER:
            viewModel.setAccountNumber(number: text)
            
        case .MOST_RECENT_CONTACT:
            viewModel.setMostRecentContact(date: text)
        case .ATTACHMENTS:
            break
        }
    }
}
