//
//  CreatePartView.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/25/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit
import SwiftDataTables

private enum PartCell: String {
    case PART_NAME              = "PART_NAME"
    case DESCRIPTION            = "DESCRIPTION"
    case PART_DETAILS           = "PART_DETAILS"
    case Attachments            = "Attachments"
}

class CreatePartView: BaseCreateWithAttachmentView<CreatePartViewModel>, Storyboarded {
    
    private let stockTableHeader = [
                                    "QUANTITY".localize,
                                    "LAST_PURCHASED".localize,
                                    "PRICE_PAID".localize,
                                    "PRICE_TO_RESELL".localize,
                                    "PURCHASED_FROM".localize,
                                    "PART_LOCATION".localize]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCellsData()
        getVendors()
        getPartLocations()
        getPartStocks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupCellsData() {
        cellData = [
            .init(title: PartCell.PART_NAME.rawValue.localize,
                  key: PartCell.PART_NAME.rawValue,
                  dataType: .Text,
                  isRequired: true,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateName(),
                  text: viewModel.getPartName()),
            
            .init(title: PartCell.DESCRIPTION.rawValue.localize,
                  key: PartCell.DESCRIPTION.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateDescription(),
                  text: viewModel.getPartDescription()),
            
            .init(title: PartCell.PART_DETAILS.rawValue.localize,
                  key: PartCell.PART_DETAILS.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: ""),
            
            .init(title: PartCell.Attachments.rawValue.localize,
                  key: PartCell.Attachments.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: "")
        ]
    }
    
    private func getVendors() {
        viewModel.getVendors { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    private func getPartLocations() {
        viewModel.getPartLocations { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    private func getPartStocks(isReload: Bool = true) {
        viewModel.getStocks(isReload: isReload) { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    private func showAddStockView(stock: PartFinder? = nil, isEditingEnabled: Bool = true) {
        let createStockView = CreatePartStockView.instantiate(storyboard: .PART)
        createStockView.isEditingEnabled = isEditingEnabled
        if let stock = stock {
            createStockView.viewModel.setStock(stock: stock)
        }
        createStockView.delegate = self
        navigationController?.pushViewController(createStockView, animated: true)
    }
    
    override func getCell(at indexPath: IndexPath) -> BaseFormCell {
        guard let cellType = PartCell(rawValue:  cellData[indexPath.row].key) else {
            return BaseFormCell()
        }
        if cellType == .Attachments {
            return instantiateAttachmentCell()
        }
        else if let cellType = PartCell(rawValue:  cellData[indexPath.row].key), cellType == .PART_DETAILS {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DataTableViewCell.ID) as? DataTableViewCell else {
                return BaseFormCell()
            }
            cell.setAddButtonTitle(title: "ADD_STOCK".localize)
            cell.bindData(stockData: viewModel.getStocks(), fields: stockTableHeader, canAddValue: isEditingEnabled, data: .init(key: PartCell.PART_DETAILS.rawValue))
            cell.setGearIcon(isAailable: isEditingEnabled)
            cell.delegate = self
            return cell
        }
        else if cellType == .DESCRIPTION {
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
         return cell
    }
    
    override func handleAddItem() {
        super.handleAddItem()
        setupCellsData()
        viewModel.addPart { (error, isValidData) in
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

extension CreatePartView: TextFieldCellDelegate {
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        guard let cell = PartCell(rawValue: data.key) else {
            return
        }
        switch cell {
        case .PART_NAME:
            viewModel.setPartName(name: text)            
            
        case .DESCRIPTION:
            viewModel.setPartDescription(description: text)
            
        case .PART_DETAILS, .Attachments:
            break
        }
    }
}

extension CreatePartView: DataTableViewCellDelegate {
    func willAddItem(data: DataTableData) {
        showAddStockView()
    }
    
    func didTapOnItem(at indexPath: IndexPath,dataTable: SwiftDataTable, data: DataTableData) {
        if !isEditingEnabled {
            return
        }
        guard let stock = viewModel.getStock(at: indexPath.section) else { return }
        let actionSheet = GlobalFunction.showListActionSheet() { [weak self] (_) in
            guard let self = self else { return }
            self.showAddStockView(stock: stock,isEditingEnabled: false)
            
        } editHandler: { [weak self] (_) in
            guard let self = self else { return }
            self.showAddStockView(stock: stock)
            
        } deleteHandler: { [weak self] (_) in
            guard let self = self else { return }
            self.viewModel.deleteStock(stock: stock) { error in
                if let error = error {
                    DispatchQueue.main.async { [unowned self] in
                        GlobalFunction.showMessageAlert(fromView: self, title: self.title ?? "", message: error)
                    }
                }
                else {
                    DispatchQueue.main.async { [unowned self] in
                        self.getPartStocks()
                    }
                }
            }
        }
        if let cell = dataTable.collectionView.cellForItem(at: indexPath) {
            presentAlert(alert: actionSheet, sourceView: cell)
        }
    }
    
    func fetchMoreData(data: DataTableData) {
        getPartStocks(isReload: false)
    }
}

extension CreatePartView: StockViewDelegate {
    func didCreateStock(stock: PartFinder) {
        DispatchQueue.main.async { [unowned self] in
            self.viewModel.addStock(stock: stock)
            self.tableView.reloadData()
        }
    }
    
    func didUpdateStock(stock: PartFinder) {
        DispatchQueue.main.async { [unowned self] in
            self.viewModel.updateStock(stock: stock)
            self.tableView.reloadData()
        }
    }
    
    func didCreateStock(stock: SupplyFinder) {
        
    }
    
    func didUpdateStock(stock: SupplyFinder) {
        
    }
}
