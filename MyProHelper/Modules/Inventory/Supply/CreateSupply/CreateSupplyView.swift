//
//  CreateSupplyView.swift
//  MyProHelper
//
//  Created by sismac010 on 10/03/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit
import SwiftDataTables

private enum SupplyCell: String {
    case SUPPLY_NAME            = "SUPPLY_NAME"
    case DESCRIPTION            = "DESCRIPTION"
    case SUPPLY_DETAILS         = "SUPPLY_DETAILS"
    case Attachments            = "Attachments"
}


class CreateSupplyView: BaseCreateWithAttachmentView<CreateSupplyViewModel>, Storyboarded {
    private let stockTableHeader = [
                                    "QUANTITY".localize,
                                    "LAST_PURCHASED".localize,
                                    "PRICE_PAID".localize,
                                    "PRICE_TO_RESELL".localize,
                                    "PURCHASED_FROM".localize,
                                    "SUPPLY_LOCATION".localize,
//                                    "REMOVED".localize
                                    ]
    
//    let viewModel = BaseCreateWithAttachmentView<CreateSupplyViewModel>()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCellsData()
        getVendors()
        getSupplyLocations()
        getSuppyStocks()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.addShowRemovedButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        super.hideShowRemovedButton()
    }

    override func reloadData() {
        getSuppyStocks()
    }

    private func setupCellsData() {
        cellData = [
            .init(title: SupplyCell.SUPPLY_NAME.rawValue.localize,
                  key: SupplyCell.SUPPLY_NAME.rawValue,
                  dataType: .Text,
                  isRequired: true,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateName(),
                  text: viewModel.getPartName()),
            
            .init(title: SupplyCell.DESCRIPTION.rawValue.localize,
                  key: SupplyCell.DESCRIPTION.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateDescription(),
                  text: viewModel.getPartDescription()),
            
            .init(title: SupplyCell.SUPPLY_DETAILS.rawValue.localize,
                  key: SupplyCell.SUPPLY_DETAILS.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: ""),
            
            .init(title: SupplyCell.Attachments.rawValue.localize,
                  key: SupplyCell.Attachments.rawValue,
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
    
    private func getSupplyLocations() {
        viewModel.getSupplyLocations { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    private func getSuppyStocks(isReload: Bool = true) {
        viewModel.getStocks(isReload: isReload, showRemoved: isShowingRemoved) { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    private func showAddStockView(stock: SupplyFinder? = nil, isEditingEnabled: Bool = true) {
        let createStockView = CreateSupplyStockView.instantiate(storyboard: .SUPPLY)
        createStockView.isEditingEnabled = isEditingEnabled
        if let stock = stock {
            createStockView.viewModel.setStock(stock: stock)
        }
        createStockView.delegate = self
        navigationController?.pushViewController(createStockView, animated: true)
    }
    
    override func getCell(at indexPath: IndexPath) -> BaseFormCell {
        guard let cellType = SupplyCell(rawValue:  cellData[indexPath.row].key) else {
            return BaseFormCell()
        }
        if cellType == .Attachments {
            return instantiateAttachmentCell()
        }
        else if let cellType = SupplyCell(rawValue:  cellData[indexPath.row].key), cellType == .SUPPLY_DETAILS {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DataTableViewCell.ID) as? DataTableViewCell else {
                return BaseFormCell()
            }
            cell.setAddButtonTitle(title: "ADD_STOCK".localize)
            cell.bindData(stockData: viewModel.getStocks(), fields: stockTableHeader, canAddValue: isEditingEnabled, data: .init(key: SupplyCell.SUPPLY_DETAILS.rawValue))
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
        viewModel.addSupply { (error, isValidData) in
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

extension CreateSupplyView: TextFieldCellDelegate {
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        guard let cell = SupplyCell(rawValue: data.key) else {
            return
        }
        switch cell {
        case .SUPPLY_NAME:
            viewModel.setSupplyName(name: text)
            
        case .DESCRIPTION:
            viewModel.setSupplyDescription(description: text)
            
        case .SUPPLY_DETAILS, .Attachments:
            break
        }
    }
}

extension CreateSupplyView: DataTableViewCellDelegate {
    func willAddItem(data: DataTableData) {
        showAddStockView()
    }
    
    func didTapOnItem(at indexPath: IndexPath,dataTable: SwiftDataTable, data: DataTableData) {
        if !isEditingEnabled {
            return
        }
        guard let stock = viewModel.getStock(at: indexPath.section) else { return }
        let isItemRemoved = stock.removed ?? false
        let removeTitle = isItemRemoved ? "UNDELETE".localize : "DELETE".localize
        let actionSheet = GlobalFunction.showListActionSheet(deleteTitle:removeTitle) { [weak self] (_) in
            guard let self = self else { return }
            self.showAddStockView(stock: stock,isEditingEnabled: false)
            
        } editHandler: { [weak self] (_) in
            guard let self = self else { return }
            self.showAddStockView(stock: stock)
            
        } deleteHandler: { [weak self] (_) in
            guard let self = self else { return }
            if let _ = stock.supplyFinderId {
                if isItemRemoved{
                    self.viewModel.undeleteStock(stock: stock) { error in
                        if let error = error {
                            DispatchQueue.main.async { [unowned self] in
                                GlobalFunction.showMessageAlert(fromView: self, title: self.title ?? "", message: error)
                            }
                        }
                        else {
                            DispatchQueue.main.async { [unowned self] in
                                self.getSuppyStocks()
                            }
                        }
                    }
                }
                else{
                    self.viewModel.deleteStock(stock: stock) { error in
                        if let error = error {
                            DispatchQueue.main.async { [unowned self] in
                                GlobalFunction.showMessageAlert(fromView: self, title: self.title ?? "", message: error)
                            }
                        }
                        else {
                            DispatchQueue.main.async { [unowned self] in
                                self.getSuppyStocks()
                            }
                        }
                    }
                }
                
            }
            else{
//                var stock = stock
//                stock.removed = !isItemRemoved
//                self.viewModel.setRemoveStock(stock: stock)
                self.viewModel.removeStock(stock: stock)
            }
            
            
            self.tableView.reloadData()
        }
        if let cell = dataTable.collectionView.cellForItem(at: indexPath) {
            presentAlert(alert: actionSheet, sourceView: cell)
        }
    }
    
    func fetchMoreData(data: DataTableData) {
        getSuppyStocks(isReload: false)
    }
}

extension CreateSupplyView: StockViewDelegate {
    func didCreateStock(stock: PartFinder) {
        
    }
    
    func didUpdateStock(stock: PartFinder) {
        
    }
    
    func didCreateStock(stock: SupplyFinder) {
        DispatchQueue.main.async { [unowned self] in
            self.viewModel.addStock(stock: stock)
            self.tableView.reloadData()
        }
    }
    
    func didUpdateStock(stock: SupplyFinder) {
        DispatchQueue.main.async { [unowned self] in
            self.viewModel.updateStock(stock: stock)
            self.tableView.reloadData()
        }
    }
}
