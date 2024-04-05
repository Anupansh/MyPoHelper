//
//  CreateQuoteAndEstimateView.swift
//  MyProHelper
//
//  Created by Deep on 2/1/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit

private enum QuoteEstimateCell: String {
    case TYPE                   = "TYPE"
    case CUSTOMER_NAME          = "CUSTOMER_NAME"
    case DESCRIPTION            = "DESCRIPTION"
    case PRICE_QUOTED           = "PRICE_QUOTED"
    case PRICE                  = "PRICE"
    case QUOTE_EXPIRATION       = "QUOTE_EXPIRATION"
    case ATTACHMENTS            = "Attachments"
}

private enum TypeCell: String {
    case QUOTE = "QUOTE"
    case ESTIMATE = "ESTIMATE"
    
    case PRICE_ESTIMATE = "PRICE_ESTIMATE"
    case FIXED_PRICE    = "FIXED_PRICE"
    
    func stringValue() -> String {
        return self.rawValue.localize
    }
}

class CreateQuoteEstimateView: BaseCreateWithAttachmentView<CreateQuoteEstimateViewModel>, Storyboarded {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCustomers()
        setupCellsData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func fetchCustomers() {
        viewModel.fetchCustomers { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    private func openCreateCustomer() {
        let createCustomerView = CreateCustomerView.instantiate(storyboard: .CUSTOMERS)
        createCustomerView.setViewMode(isEditingEnabled: true)
        createCustomerView.viewModel.customer.bind { [weak self] customer in
            guard let self = self else { return }
            self.viewModel.setCustomer(with: customer)
            self.tableView.reloadData()
        }
    }
    
    override func getCell(at indexPath: IndexPath) -> BaseFormCell {
        if let cellType = QuoteEstimateCell(rawValue:  cellData[indexPath.row].key), cellType == .ATTACHMENTS {
            return instantiateAttachmentCell()
        } else if let cellType = QuoteEstimateCell(rawValue:  cellData[indexPath.row].key), cellType == .TYPE {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: RadioButtonCell.ID) as? RadioButtonCell else {
                return RadioButtonCell()
            }
            cell.isSelectionEnabled = isEditingEnabled
            cell.setTitle(title: "Type")
            cell.bindCell(data: [.init(key: TypeCell.QUOTE.rawValue,
                                       title: TypeCell.QUOTE.stringValue(),
                                       value: viewModel.getIsQuote()),
                                 .init(key: TypeCell.ESTIMATE.rawValue,
                                       title: TypeCell.ESTIMATE.stringValue(),
                                       value: viewModel.getIsEsttimate())])
            cell.delegate = self
            return cell
        }  else if let cellType = QuoteEstimateCell(rawValue:  cellData[indexPath.row].key), cellType == .PRICE {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: RadioButtonCell.ID) as? RadioButtonCell else {
                return RadioButtonCell()
            }
            cell.isSelectionEnabled = isEditingEnabled
            cell.setTitle(title: "Price")
            cell.bindCell(data: [.init(key: TypeCell.PRICE_ESTIMATE.rawValue,
                                       title: "Estimate",
                                       value: viewModel.isPriceEstimate()),
                                 .init(key: TypeCell.FIXED_PRICE.rawValue,
                                       title: TypeCell.FIXED_PRICE.stringValue(),
                                       value: viewModel.isPriceFixed())])
            cell.delegate = self
            return cell
        } else if let cellType = QuoteEstimateCell(rawValue:  cellData[indexPath.row].key), cellType == .DESCRIPTION{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TextViewCell.ID) as? TextViewCell else {
                return BaseFormCell()
            }
            cell.bindTextView(data: cellData[indexPath.row])
            cell.delegate = self
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.ID) as? TextFieldCell else {
            return BaseFormCell()
        }
        cell.bindTextField(data: cellData[indexPath.row])
        cell.delegate = self
        cell.listDelegate = self
        return cell
    }
    
    override func handleAddItem() {
        super.handleAddItem()
        setupCellsData()
        viewModel.saveItem { (error, isValidData) in
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
            .init(title: QuoteEstimateCell.TYPE.rawValue.localize,
                  key: QuoteEstimateCell.TYPE.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: ""),
            
            .init(title: QuoteEstimateCell.CUSTOMER_NAME.rawValue.localize,
                  key: QuoteEstimateCell.CUSTOMER_NAME.rawValue,
                  dataType: .ListView,
                  isRequired: true,
                  isActive: isEditingEnabled,
                  keyboardType: .default,
                  validation: viewModel.validateCustomer(),
                  text: viewModel.getCustomerName(),
                  listData: viewModel.getCustomers()),
            
            .init(title: QuoteEstimateCell.DESCRIPTION.rawValue.localize,
                  key: QuoteEstimateCell.DESCRIPTION.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateDescription(),
                  text: viewModel.getDescription()),
            
            .init(title: QuoteEstimateCell.PRICE_QUOTED.rawValue.localize,
                  key: QuoteEstimateCell.PRICE_QUOTED.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  keyboardType: .asciiCapableNumberPad,
                  validation: viewModel.validatePriceQuoted(),
                  text: viewModel.getPriceQuoted()),
            
            .init(title: QuoteEstimateCell.PRICE.rawValue.localize,
                  key: QuoteEstimateCell.PRICE.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: ""),
            
            .init(title: QuoteEstimateCell.QUOTE_EXPIRATION.rawValue.localize,
                  key: QuoteEstimateCell.QUOTE_EXPIRATION.rawValue,
                  dataType: .Date,
                  isRequired: true,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: viewModel.getQuoteExpirationDate()),
            
            .init(title: QuoteEstimateCell.ATTACHMENTS.rawValue.localize,
                  key: QuoteEstimateCell.ATTACHMENTS.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: "")
        ]
    }
}

//MARK: - Text Field Delegate

extension CreateQuoteEstimateView: TextFieldCellDelegate {
    
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        guard let cell = QuoteEstimateCell(rawValue: data.key) else {
            return
        }
        switch cell {
        case .DESCRIPTION:
            viewModel.setDescription(description: text)
        case .PRICE_QUOTED:
            viewModel.setPriceQuoted(price: text)
        case .PRICE:
            break
        case .QUOTE_EXPIRATION:
            viewModel.setQuoteExpiration(date: text)
        default:
            break
        }
    }
}

//MARK: - Radio Buttom Cell Delegate

extension CreateQuoteEstimateView: RadioButtonCellDelegate {
    func didChooseButton(data: RadioButtonData) {
        
        guard let button = TypeCell(rawValue: data.key) else {
            return
            
        }
        switch button {
        case .QUOTE:
            viewModel.setIsQuote()
        case .ESTIMATE:
            viewModel.setIsEstimate()
        case .PRICE_ESTIMATE:
            viewModel.setPriceEstimate()
        case .FIXED_PRICE:
            viewModel.setFixedPrice()
        }
    }
}

//MARK: - Text Field List Delegate

extension CreateQuoteEstimateView: TextFieldListDelegate {
    
    func willAddItem(data: TextFieldCellData) {
        guard let field = QuoteEstimateCell(rawValue: data.key) else {
            return
        }
        switch field {
        case .CUSTOMER_NAME:
            openCreateCustomer()
        default:
            break
        }
    }
    
    func didChooseItem(at row: Int?, data: TextFieldCellData) {
        guard let row = row else { return }
        guard let field = QuoteEstimateCell(rawValue: data.key) else {
            return
        }
        switch field {
        case .CUSTOMER_NAME:
            viewModel.setCustomer(at: row)
            setupCellsData()
            tableView.reloadData()
        default:
            break
        }
    }
}
