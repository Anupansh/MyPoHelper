//
//  CreatePartStockView.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 11/8/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit

private enum StockCell: String {
    case QUANTITY               = "QUANTITY"
    case PRICE_PAID             = "PRICE_PAID"
    case PRICE_TO_RESELL        = "PRICE_TO_RESELL"
    case LAST_PURCHASED_DATE    = "LAST_PURCHASED_DATE"
    case WHERE_PURCHASED        = "WHERE_PURCHASED"
    case PART_LOCATION          = "PART_LOCATION"
}

class CreatePartStockView: BaseCreateItemView, Storyboarded {
    
    let viewModel = CreatePartStockViewModel()
    var delegate: StockViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getVendors()
        getPartLocations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupCellsData() {
        cellData = [
            .init(title: StockCell.QUANTITY.rawValue.localize,
                  key: StockCell.QUANTITY.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  keyboardType: .asciiCapableNumberPad,
                  validation: viewModel.validateQuantity(),
                  text: viewModel.getQuantity()),
            
            .init(title: StockCell.PRICE_PAID.rawValue.localize,
                  key: StockCell.PRICE_PAID.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  keyboardType: .decimalPad,
                  validation: viewModel.validatePricePaid(),
                  text: viewModel.getPricePaid()),
            
            .init(title: StockCell.PRICE_TO_RESELL.rawValue.localize,
                  key: StockCell.PRICE_TO_RESELL.rawValue,
                  dataType: .Text, isRequired: false,
                  isActive: isEditingEnabled,
                  keyboardType: .decimalPad,
                  validation: viewModel.validatePriceToResell(),
                  text: viewModel.getPriceToResell()),
            
            .init(title: StockCell.LAST_PURCHASED_DATE.rawValue.localize,
                  key: StockCell.LAST_PURCHASED_DATE.rawValue,
                  dataType: .Date,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  keyboardType: .default,
                  validation: .Valid,
                  text: viewModel.getLastPurchasedDate()),
            
            .init(title: StockCell.WHERE_PURCHASED.rawValue.localize,
                  key: StockCell.WHERE_PURCHASED.rawValue,
                  dataType: .ListView,
                  isRequired: false,
                  isActive: isEditingEnabled && viewModel.canEditVendor(),
                  keyboardType: .default,
                  validation: .Valid,
                  text: viewModel.getVendor(),
                  listData: viewModel.getVendors()),
            
            .init(title: StockCell.PART_LOCATION.rawValue.localize,
                  key: StockCell.PART_LOCATION.rawValue,
                  dataType: .ListView,
                  isRequired: true,
                  isActive: isEditingEnabled && viewModel.canEditPartLocation(),
                  keyboardType: .default,
                  validation: viewModel.validatePartLocation(),
                  text: viewModel.getPartLocation(),
                  listData: viewModel.getPartLocations())
            
        ]
    }
    
    private func getVendors() {
        viewModel.fetchVendors {
            DispatchQueue.main.async { [unowned self] in
                self.setupCellsData()
                self.tableView.reloadData()
            }
        }
    }
    
    private func getPartLocations() {
        viewModel.fetchPartLocations {
            DispatchQueue.main.async { [unowned self] in
                self.setupCellsData()
                self.tableView.reloadData()
            }
        }
    }
    
    private func openCreatePartLocation() {
        let createPartLocationView = CreatePartLocationView.instantiate(storyboard: .PART_LOCATION)
        createPartLocationView.setViewMode(isEditingEnabled: true)
        createPartLocationView.viewModel.partLocation.bind { [unowned self] partLocation in
            self.viewModel.setPartLocation(partLocation: partLocation)
            self.getPartLocations()
        }
        navigationController?.pushViewController(createPartLocationView, animated: false)
    }
    
    private func openCreateVendor() {
        let createVendorView = CreateVendorView.instantiate(storyboard: .VENDORS)
        createVendorView.viewModel = CreateVendorViewModel(attachmentSource: .VENDOR)
        createVendorView.setViewMode(isEditingEnabled: true)
        createVendorView.viewModel.vendor.bind { vendor in
            self.viewModel.setVendor(vendor: vendor)
            self.getVendors()
        }
        navigationController?.pushViewController(createVendorView, animated: false)
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
        super.handleAddItem()
        setupCellsData()
        if viewModel.isValidData() {
            if viewModel.isUpdateStock() {
                delegate?.didUpdateStock(stock: viewModel.getStock())
            }
            else {
                delegate?.didCreateStock(stock: viewModel.getStock())
            }
            navigationController?.popViewController(animated: true)
        }
        else {
            tableView.reloadData()
        }
    }
}

extension CreatePartStockView: TextFieldCellDelegate {
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        guard let cell = StockCell(rawValue: data.key) else {
            return
        }
        switch cell {
        
        case .QUANTITY:
            viewModel.setQuantity(quantity: text)
        case .PRICE_PAID:
            viewModel.setPricePaid(price: text)
            
        case .PRICE_TO_RESELL:
            viewModel.setPriceToResell(price: text)
            
        case .LAST_PURCHASED_DATE:
            viewModel.setLastPurchasedDate(date: text)
        default:
            break
        }
    }
}

extension CreatePartStockView: TextFieldListDelegate {
    
    func willAddItem(data: TextFieldCellData) {
        guard let cell = StockCell(rawValue: data.key) else {
            return
        }
        switch cell {
        case .PART_LOCATION:
            openCreatePartLocation()
        case .WHERE_PURCHASED:
            openCreateVendor()
        default:
            break
        }
    }
    
    func didChooseItem(at row: Int?, data: TextFieldCellData) {
        guard let cell = StockCell(rawValue: data.key) else {
            return
        }
        switch cell {
        case .PART_LOCATION:
            DispatchQueue.main.async { [unowned self] in
                self.viewModel.setPartLocation(at: row)
                data.text = viewModel.getPartLocation()
                self.tableView.reloadData()
            }
            
        case .WHERE_PURCHASED:
            DispatchQueue.main.async { [unowned self] in
                self.viewModel.setVendor(at: row)
                data.text = viewModel.getVendor()
                self.tableView.reloadData()
            }
        default:
            break
        }
    }
}
