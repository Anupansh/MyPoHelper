//
//  CreateCustomerViewController.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 28/05/1942 Saka.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit
import DropDown // 1

private enum CustomerTextCell: String {
    case CUSTOMER_NAME          = "CUSTOMER_NAME"
    case CONTACT_NAME           = "CONTACT_NAME"
    case CONTACT_PHONE          = "CONTACT_PHONE"
    case CONTACT_EMAIL          = "CONTACT_EMAIL"
    case MOST_RECENT_CONTACT    = "MOST_RECENT_CONTACT"
    case BILLING_ADDRESS_ONE    = "BILLING_ADDRESS_ONE"
    case BILLING_ADDRESS_TWO    = "BILLING_ADDRESS_TWO"
    case BILLING_ADDRESS_CITY   = "BILLING_ADDRESS_CITY"
    case BILLING_ADDRESS_STATE  = "BILLING_ADDRESS_STATE"
    case BILLING_ADDRESS_ZIP    = "BILLING_ADDRESS_ZIP"
}

class CreateCustomerView: BaseCreateItemView, Storyboarded {
    
    let viewModel = CreateCustomerViewModel()
    var dropDown:DropDown = DropDown() //2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.setInitialMostRecentContact()
        setupCellsData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupCellsData() {
        cellData = [
            .init(title: CustomerTextCell.CUSTOMER_NAME.rawValue.localize,
                  key: CustomerTextCell.CUSTOMER_NAME.rawValue,
                  dataType: .Text,
                  isRequired: true,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateName(),
                  text: viewModel.getName()),
            
            .init(title: CustomerTextCell.CONTACT_NAME.rawValue.localize,
                  key: CustomerTextCell.CONTACT_NAME.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateContactName(),
                  text: viewModel.getContactName()),
            
            .init(title: CustomerTextCell.CONTACT_PHONE.rawValue.localize,
                  key: CustomerTextCell.CONTACT_PHONE.rawValue,
                  dataType: .Mobile,
                  isRequired: true,
                  isActive: isEditingEnabled,
                  keyboardType: .asciiCapableNumberPad,
                  validation: viewModel.validateContactPhone(),
                  text: viewModel.getContactPhone()),
            
            .init(title: CustomerTextCell.CONTACT_EMAIL.rawValue.localize,
                  key: CustomerTextCell.CONTACT_EMAIL.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  keyboardType: .emailAddress,
                  validation: viewModel.validateContactEmail(),
                  text: viewModel.getContactEmail()),
            
            .init(title: CustomerTextCell.MOST_RECENT_CONTACT.rawValue.localize,
                  key:  CustomerTextCell.MOST_RECENT_CONTACT.rawValue,
                  dataType: .Date,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: viewModel.getMostRecentContact()),
            
            .init(title: CustomerTextCell.BILLING_ADDRESS_ONE.rawValue.localize,
                  key: CustomerTextCell.BILLING_ADDRESS_ONE.rawValue,
                  dataType: .Text,
                  isRequired: true,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateBillingAddress(),
                  text: viewModel.getBillingAddress()),
            
            .init(title: CustomerTextCell.BILLING_ADDRESS_TWO.rawValue.localize,
                  key: CustomerTextCell.BILLING_ADDRESS_TWO.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateSecondBillingAddress(),
                  text: viewModel.getSecondBillingAddress()),
            
            .init(title: CustomerTextCell.BILLING_ADDRESS_CITY.rawValue.localize,
                   key: CustomerTextCell.BILLING_ADDRESS_CITY.rawValue,
                   dataType: .Text, isRequired: true,
                   isActive: isEditingEnabled,
                   validation: viewModel.validateBillingCity(),
                   text: viewModel.getBillingCity()),
            
            .init(title: CustomerTextCell.BILLING_ADDRESS_STATE.rawValue.localize,
                  key: CustomerTextCell.BILLING_ADDRESS_STATE.rawValue,
                  dataType: .Text,
                  isRequired: true,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateBillingState(),
                  text: viewModel.getBillingState()),
            
            .init(title: CustomerTextCell.BILLING_ADDRESS_ZIP.rawValue.localize,
                  key: CustomerTextCell.BILLING_ADDRESS_ZIP.rawValue,
                  dataType: .ZipCode,
                  isRequired: true,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateBillingZip(),
                  text: viewModel.getBillingZip())
        ]
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
        viewModel.saveCustomer { (error, isValidData) in
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

extension CreateCustomerView: TextFieldCellDelegate {
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        guard let cell = CustomerTextCell(rawValue: data.key) else {
            return
        }
        
        switch cell {
        case .CUSTOMER_NAME:
            viewModel.setName(name: text)
            
        case .CONTACT_NAME:
            viewModel.setContactName(name: text)
            
        case .CONTACT_PHONE:
            viewModel.setContactPhone(phone: text)
            
        case .CONTACT_EMAIL:
            viewModel.setContactEmail(email: text)

        case .MOST_RECENT_CONTACT:
            viewModel.setMostRecentContact(contact: text)
            
        case .BILLING_ADDRESS_ONE:
            viewModel.setBillingAddress(address: text)
            
        case .BILLING_ADDRESS_TWO:
            viewModel.setSecondBillingAddress(address: text)
            
        case .BILLING_ADDRESS_CITY:
            viewModel.setBillingCity(city: text)
            
        case .BILLING_ADDRESS_STATE:break
//            viewModel.setBillingState(state: text)
            
        case .BILLING_ADDRESS_ZIP:
            viewModel.setBillingZip(zip: text)
            
        }
    }
    
    func didChangeTextField(text: String?, data: TextFieldCellData) {
        guard let field = CustomerTextCell(rawValue: data.key) else {
            return
        }
        
        let finalText = text ?? ""
        print("Changed text:\(finalText)")
        
        switch field {
        case .BILLING_ADDRESS_STATE:
            
            let i = cellData.firstIndex(where: {CustomerTextCell.init(rawValue: $0.key) == .BILLING_ADDRESS_STATE}) ?? -1
            if i != -1{
                let indexPath = IndexPath(row: i, section: 0)
                if let cell = tableView.cellForRow(at: indexPath) as? TextFieldCell{
                    
                    let arrResult = arrStatesListGlobal
                        .filter { NSPredicate(format: "(StateNickName contains[c] %@)", finalText).evaluate(with: $0) }
                        
                    
                    let arr = arrResult.map({$0["StateNickName"] as! String}) // For Select Item from list
                    let arr2 = arrResult.map({"\($0["StateNickName"] as! String)" + " (\($0["FullStateName"] as! String))"})  // For Show list
                    
                    dropDown.anchorView = cell //5
                    dropDown.direction = .any
                    dropDown.width = cell.frame.width
                    dropDown.dataSource = arr2
                    dropDown.show()
                    dropDown.bottomOffset = CGPoint(x: 0, y: cell.frame.size.height)
                    
                    dropDown.selectionAction = { [weak self] (index: Int, item: String) in //8
                      guard let self = self else { return }
                        print("Selected Item:\(item)")
                        self.viewModel.setBillingState(state: arr[index])
                        data.text = arr[index]
                        self.setupCellsData()
                        self.tableView.reloadData()
                    }
                }
            }
            break
        default:break
        }
    }
}
