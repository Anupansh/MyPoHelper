//
//  PartInventoryView.swift
//  MyProHelper
//
//  Created by Samir on 11/16/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit

private enum PartInventoryField: String {
    case ADD_QUANTITY           = "ADD_QUANTITY"
    case PRICE_PAID             = "PRICE_PAID"
    case PRICE_TO_RESELL        = "PRICE_TO_RESELL"
    case LAST_PURCHASED_DATE    = "LAST_PURCHASED_DATE"
    case PART_LOCATION          = "PART_LOCATION"
    case PART_LOCATION_TO       = "PART_LOCATION_TO"
    case PURCHASED_FROM         = "PURCHASED_FROM"
    case REMOVE_QUANTITY        = "REMOVE_QUANTITY"
    case TRANSFER_QUANTITY      = "TRANSFER_QUANTITY"
    case PART_LOCATION_FROM     = "PART_LOCATION_FROM"
}

class PartInventoryView: BaseCreateItemView, Storyboarded {
    
    private let viewModel = PartInventoryViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPartLocations()
        getVendors()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupCellsData() {
        guard let actionType = viewModel.getActionType() else { return }
        
        switch actionType {
        case .ADD_INVENTORY:
            setDateForAdd()
        case .REMOVE_INVENTORY:
            setDateForRemove()
        case .TRANSFER_INVENTORY:
            setDateForTransfer()
        }
    }
    
    private func setDateForAdd() {
        cellData = [
            .init(title: PartInventoryField.ADD_QUANTITY.rawValue.localize,
                  key: PartInventoryField.ADD_QUANTITY.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: true,
                  keyboardType: .asciiCapableNumberPad,
                  validation: viewModel.validateQuantity(),
                  text: viewModel.getQuantityString()),
            
            .init(title: PartInventoryField.PRICE_PAID.rawValue.localize,
                  key: PartInventoryField.PRICE_PAID.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: true,
                  keyboardType: .numberPad,
                  validation: viewModel.validatePricePaid(),
                  text: viewModel.getPricePaid()),
            
            .init(title: PartInventoryField.PRICE_TO_RESELL.rawValue.localize,
                  key: PartInventoryField.PRICE_TO_RESELL.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: true,
                  keyboardType: .decimalPad,
                  validation: viewModel.validatePriceToResell(),
                  text: viewModel.getPriceToResell()),
            
            .init(title: PartInventoryField.LAST_PURCHASED_DATE.rawValue.localize,
                  key: PartInventoryField.LAST_PURCHASED_DATE.rawValue,
                  dataType: .Date,
                  isRequired: false,
                  isActive: true,
                  keyboardType: .default,
                  validation: .Valid,
                  text: viewModel.getLastPurchasedDate()),
            
            .init(title: PartInventoryField.PART_LOCATION.rawValue.localize,
                  key: PartInventoryField.PART_LOCATION.rawValue,
                  dataType: .ListView,
                  isRequired: false,
                  isActive: true,
                  keyboardType: .default,
                  validation: .Valid,
                  text: viewModel.getLocationName(),
                  listData: viewModel.getPartLocations()),
            
            .init(title: PartInventoryField.PURCHASED_FROM.rawValue.localize,
                  key: PartInventoryField.PURCHASED_FROM.rawValue,
                  dataType: .ListView,
                  isRequired: false,
                  isActive: viewModel.canEditVendor(),
                  keyboardType: .default,
                  validation: .Valid,
                  text: viewModel.getVendorName(),
                  listData: viewModel.getVendors())
        ]
    }
    
    private func setDateForRemove() {
        cellData = [
            .init(title: PartInventoryField.REMOVE_QUANTITY.rawValue.localize,
                  key: PartInventoryField.REMOVE_QUANTITY.rawValue,
                  dataType: .Text, isRequired: false,
                  isActive: true,
                  keyboardType: .asciiCapableNumberPad,
                  validation: viewModel.validateQuantity(),
                  text: viewModel.getQuantityString())
            ]
    }
    
    private func setDateForTransfer() {
        
        cellData = [
            .init(title: PartInventoryField.TRANSFER_QUANTITY.rawValue.localize,
                  key: PartInventoryField.TRANSFER_QUANTITY.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: true,
                  keyboardType: .asciiCapableNumberPad,
                  validation: viewModel.validateQuantity(),
                  text: viewModel.getQuantityString()),
            
            .init(title: PartInventoryField.PART_LOCATION_FROM.rawValue.localize,
                  key: PartInventoryField.PART_LOCATION_FROM.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: false,
                  keyboardType: .default,
                  validation: .Valid,
                  text: viewModel.getFromLocationName()),
            
            .init(title: PartInventoryField.PART_LOCATION_TO.rawValue.localize,
                  key: PartInventoryField.PART_LOCATION_TO.rawValue,
                  dataType: .ListView,
                  isRequired: false,
                  isActive: true,
                  keyboardType: .default,
                  validation: .Valid,
                  text:viewModel.getLocationName(),
                  listData: viewModel.getPartLocations())
        ]
    }
    
    private func getPartLocations() {
        viewModel.getPartLocations {
            DispatchQueue.main.async { [unowned self] in
                self.setupCellsData()
                self.tableView.reloadData()
            }
        }
    }
    
    private func getVendors() {
        viewModel.getVendors {
            DispatchQueue.main.async { [unowned self] in
                self.setupCellsData()
                self.tableView.reloadData()
            }
        }
    }
    private func showError(message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            GlobalFunction.showMessageAlert(fromView: self, title: self.title ?? "", message: message)
        }
    }
    
    private func createPartLocation() {
        let createPartLocationView = CreatePartLocationView.instantiate(storyboard: .PART_LOCATION)
        createPartLocationView.setViewMode(isEditingEnabled: true)
        createPartLocationView.viewModel.partLocation.bind { [unowned self] partLocation in
            self.viewModel.setPartLocation(partLocation: partLocation)
            self.getPartLocations()
        }
        navigationController?.pushViewController(createPartLocationView, animated: false)
    }
    
    private func createVendor() {
        let createVendorView = CreateVendorView.instantiate(storyboard: .VENDORS)
        createVendorView.viewModel = CreateVendorViewModel(attachmentSource: .VENDOR)
        createVendorView.setViewMode(isEditingEnabled: true)
        createVendorView.viewModel.vendor.bind { [unowned self] vendor in
            self.viewModel.setVendor(vendor: vendor)
            self.getVendors()
        }
        navigationController?.pushViewController(createVendorView, animated: false)
    }
    
    func bindData(stock: PartFinder, action: InventoryAction) {
        viewModel.setStock(stock: stock, for: action)
        setupCellsData()
    }
    
    override func getCell(at indexPath: IndexPath) -> BaseFormCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.ID) as? TextFieldCell else {
             return BaseFormCell()
         }
        cell.bindTextField(data: cellData[indexPath.row])
        cell.delegate = self
        cell.listDelegate = self
        return cell
    }
    
    override func handleAddItem() {
        
        guard let actionType = viewModel.getActionType() else { return }
        
        switch actionType {
        case .ADD_INVENTORY:
            viewModel.addStockQuantity { (error) in
                if let error = error {
                    self.showError(message: error)
                }
                else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
        case .REMOVE_INVENTORY:
            viewModel.removeStockQuantity { [weak self] (isValid, error) in
                guard let self = self else { return }
                if let error = error {
                    self.showError(message: error)
                }
                else {
                    if !isValid {
                        let message = "REMOVE_INVENTORY_ERROR".localize
                        self.showError(message: message)
                    }
                    else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            
        case .TRANSFER_INVENTORY:
            viewModel.transferStockQuantity { [weak self] (isValid, error) in
                guard let self = self else { return }
                if let error = error {
                    self.showError(message: error)
                }
                else {
                    if !isValid {
                        let message = "REMOVE_INVENTORY_ERROR".localize
                        self.showError(message: message)
                    }
                    else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
}

extension PartInventoryView: TextFieldCellDelegate {
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        guard let field = PartInventoryField(rawValue: data.key) else {
            return
        }
        switch field {
        case .ADD_QUANTITY:
            viewModel.setQuanityt(value: text)
            
        case .PRICE_PAID:
            viewModel.setPricePaid(price: text)
            
        case .PRICE_TO_RESELL:
            viewModel.setPriceToResell(price: text)
            
        case .LAST_PURCHASED_DATE:
            viewModel.setLastPurchased(date: text)
        case .REMOVE_QUANTITY:
            viewModel.setQuanityt(value: text)
            
        case .TRANSFER_QUANTITY:
            viewModel.setQuanityt(value: text)
            
        default:
            break
        }
    }
}

extension PartInventoryView: TextFieldListDelegate {
    
    func willAddItem(data: TextFieldCellData) {
        guard let field = PartInventoryField(rawValue: data.key) else {
            return
        }
        if field == .PART_LOCATION || field == .PART_LOCATION_TO {
            createPartLocation()
        }
        else if field == .PURCHASED_FROM {
            createVendor()
        }
    }
    
    func didChooseItem(at row: Int?, data: TextFieldCellData) {
        guard let field = PartInventoryField(rawValue: data.key) else {
            return
        }
        guard let row = row else { return }
        if field == .PART_LOCATION || field == .PART_LOCATION_TO {
            viewModel.setPartLocation(at: row)
            setupCellsData()
            tableView.reloadData()
        }
        else if field == .PURCHASED_FROM {
            viewModel.setVendor(at: row)
            setupCellsData()
            tableView.reloadData()
        }
    }
}
