//
//  SupplyInventoryView.swift
//  MyProHelper
//
//  Created by sismac010 on 16/03/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

private enum SupplyInventoryField: String {
    case ADD_QUANTITY           = "ADD_QUANTITY"
    case PRICE_PAID             = "PRICE_PAID"
    case PRICE_TO_RESELL        = "PRICE_TO_RESELL"
    case LAST_PURCHASED_DATE    = "LAST_PURCHASED_DATE"
    case SUPPLY_LOCATION        = "SUPPLY_LOCATION"
    case SUPPLY_LOCATION_TO     = "SUPPLY_LOCATION_TO"
    case PURCHASED_FROM         = "PURCHASED_FROM"
    case REMOVE_QUANTITY        = "REMOVE_QUANTITY"
    case TRANSFER_QUANTITY      = "TRANSFER_QUANTITY"
    case SUPPLY_LOCATION_FROM   = "SUPPLY_LOCATION_FROM"
}


class SupplyInventoryView: BaseCreateItemView, Storyboarded {

    private let viewModel = SupplyInventoryViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSupplyLocations()
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
            .init(title: SupplyInventoryField.ADD_QUANTITY.rawValue.localize,
                  key: SupplyInventoryField.ADD_QUANTITY.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: true,
                  keyboardType: .asciiCapableNumberPad,
                  validation: viewModel.validateQuantity(),
                  text: viewModel.getQuantityString()),
            
            .init(title: SupplyInventoryField.PRICE_PAID.rawValue.localize,
                  key: SupplyInventoryField.PRICE_PAID.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: true,
                  keyboardType: .numberPad,
                  validation: viewModel.validatePricePaid(),
                  text: viewModel.getPricePaid()),
            
            .init(title: SupplyInventoryField.PRICE_TO_RESELL.rawValue.localize,
                  key: SupplyInventoryField.PRICE_TO_RESELL.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: true,
                  keyboardType: .decimalPad,
                  validation: viewModel.validatePriceToResell(),
                  text: viewModel.getPriceToResell()),
            
            .init(title: SupplyInventoryField.LAST_PURCHASED_DATE.rawValue.localize,
                  key: SupplyInventoryField.LAST_PURCHASED_DATE.rawValue,
                  dataType: .Date,
                  isRequired: false,
                  isActive: true,
                  keyboardType: .default,
                  validation: .Valid,
                  text: viewModel.getLastPurchasedDate()),
            
            .init(title: SupplyInventoryField.SUPPLY_LOCATION.rawValue.localize,
                  key: SupplyInventoryField.SUPPLY_LOCATION.rawValue,
                  dataType: .ListView,
                  isRequired: false,
                  isActive: true,
                  keyboardType: .default,
                  validation: .Valid,
                  text: viewModel.getLocationName(),
                  listData: viewModel.getSupplyLocations()),
            
            .init(title: SupplyInventoryField.PURCHASED_FROM.rawValue.localize,
                  key: SupplyInventoryField.PURCHASED_FROM.rawValue,
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
            .init(title: SupplyInventoryField.REMOVE_QUANTITY.rawValue.localize,
                  key: SupplyInventoryField.REMOVE_QUANTITY.rawValue,
                  dataType: .Text, isRequired: false,
                  isActive: true,
                  keyboardType: .asciiCapableNumberPad,
                  validation: viewModel.validateQuantity(),
                  text: viewModel.getQuantityString())
            ]
    }
    
    private func setDateForTransfer() {
        
        cellData = [
            .init(title: SupplyInventoryField.TRANSFER_QUANTITY.rawValue.localize,
                  key: SupplyInventoryField.TRANSFER_QUANTITY.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: true,
                  keyboardType: .asciiCapableNumberPad,
                  validation: viewModel.validateQuantity(),
                  text: viewModel.getQuantityString()),
            
            .init(title: SupplyInventoryField.SUPPLY_LOCATION_FROM.rawValue.localize,
                  key: SupplyInventoryField.SUPPLY_LOCATION_FROM.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: false,
                  keyboardType: .default,
                  validation: .Valid,
                  text: viewModel.getFromLocationName()),
            
            .init(title: SupplyInventoryField.SUPPLY_LOCATION_TO.rawValue.localize,
                  key: SupplyInventoryField.SUPPLY_LOCATION_TO.rawValue,
                  dataType: .ListView,
                  isRequired: false,
                  isActive: true,
                  keyboardType: .default,
                  validation: .Valid,
                  text:viewModel.getLocationName(),
                  listData: viewModel.getSupplyLocations())
        ]
    }
    
    private func getSupplyLocations() {
        viewModel.getSupplyLocations {
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

    private func createSupplyLocation() {
        let createSupplyLocationView = CreateSupplyLocationView.instantiate(storyboard: .SUPPLY_LOCATION)
        createSupplyLocationView.setViewMode(isEditingEnabled: true)
        createSupplyLocationView.viewModel.supplyLocation.bind { [unowned self] supplyLocation in
            self.viewModel.setSupplyLocation(supplyLocation: supplyLocation)
            self.getSupplyLocations()
        }
        navigationController?.pushViewController(createSupplyLocationView, animated: false)
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
    
    func bindData(stock: SupplyFinder, action: InventoryAction) {
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

extension SupplyInventoryView: TextFieldCellDelegate {
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        guard let field = SupplyInventoryField(rawValue: data.key) else {
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

extension SupplyInventoryView: TextFieldListDelegate {
    
    func willAddItem(data: TextFieldCellData) {
        guard let field = SupplyInventoryField(rawValue: data.key) else {
            return
        }
        if field == .SUPPLY_LOCATION || field == .SUPPLY_LOCATION_TO {
            createSupplyLocation()
        }
        else if field == .PURCHASED_FROM {
            createVendor()
        }
    }
    
    func didChooseItem(at row: Int?, data: TextFieldCellData) {
        guard let field = SupplyInventoryField(rawValue: data.key) else {
            return
        }
        guard let row = row else { return }
        if field == .SUPPLY_LOCATION || field == .SUPPLY_LOCATION_TO {
            viewModel.setSupplyLocation(at: row)
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
