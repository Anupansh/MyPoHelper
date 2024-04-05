//
//  CreatePurchaseOrderView.swift
//  MyProHelper
//
//  Created by sismac010 on 19/03/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import SwiftDataTables

private enum PurchaseOrderCell: String {
    case ORDER_DATE             = "ORDERED_DATE"
    case EXPECTED_DATE          = "EXPECTED_DATE"
    case LINE_ITEM              = "LINE_ITEM"
    case SALE_TAX               = "SALE_TAX"
    case SHIPPING               = "SHIPPING"
    case Attachments            = "Attachments"
}

private enum VenderCell: String {
    case VENDOR_NAME            = "VENDOR_NAME"
}



class CreatePurchaseOrderView: BaseCreateWithAttachmentView<CreatePurchaseOrderViewModel>, Storyboarded {
    private let stockTableHeader = [
                                    "LINE_ITEM".localize,
                                    "PART_NAME".localize,
                                    "SUPPLY_NAME".localize,
                                    "NON_STOCKABLE_ITEM".localize,
                                    "PART_NUMBER".localize,
                                    "QUANTITY".localize,
                                    "PRICE_PER_ITEM".localize,
                                    "AMOUNT".localize]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getVendors()
        setupCellsData()
        getPurchaseOrderLineItems()

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
        getPurchaseOrderLineItems()
    }

    
    private func setupCellsData() {
        cellData = [
            .init(title: VenderCell.VENDOR_NAME.rawValue.localize,
                  key: VenderCell.VENDOR_NAME.rawValue,
                  dataType: .ListView,
                  isRequired: true,
                  isActive: isEditingEnabled ,//&& viewModel.canEditVendor(),
                  keyboardType: .default,
                  validation: viewModel.validateVendor(),
                  text:  viewModel.getVendor() != nil ? viewModel.getVendor() : ((viewModel.getVendors().count > 0) ? viewModel.getVendors().first : ""),
                  listData: viewModel.getVendors()),
            
            .init(title: PurchaseOrderCell.ORDER_DATE.rawValue.localize,
                  key: PurchaseOrderCell.ORDER_DATE.rawValue,
                  dataType: .Date,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: /*isEditingEnabled ? "" : */viewModel.getOrderedDate()),
            
            .init(title: PurchaseOrderCell.EXPECTED_DATE.rawValue.localize,
                  key: PurchaseOrderCell.EXPECTED_DATE.rawValue,
                  dataType: .Date,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: /*isEditingEnabled ? "" : */viewModel.getExpectedDate()),
            
            .init(title: PurchaseOrderCell.LINE_ITEM.rawValue.localize,
                  key: PurchaseOrderCell.LINE_ITEM.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: ""),

            .init(title: PurchaseOrderCell.SALE_TAX.rawValue.localize,
                  key: PurchaseOrderCell.SALE_TAX.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  keyboardType: .decimalPad,
                  validation: viewModel.validateSalesTax(),
                  text: viewModel.getSalesTax()),
            
            .init(title: PurchaseOrderCell.SHIPPING.rawValue.localize,
                  key: PurchaseOrderCell.SHIPPING.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  keyboardType: .decimalPad,
                  validation: viewModel.validateShipping(),
                  text: viewModel.getShipping()),
            
            .init(title: PurchaseOrderCell.Attachments.rawValue.localize,
                  key: PurchaseOrderCell.Attachments.rawValue,
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
    
    private func getPurchaseOrderLineItems(isReload: Bool = true) {
        viewModel.getPurchaseOrderLineItems(isReload: isReload, showRemoved: isShowingRemoved) { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    override func getCell(at indexPath: IndexPath) -> BaseFormCell {
        if let cellType = VenderCell(rawValue:  cellData[indexPath.row].key) , cellType == .VENDOR_NAME {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.ID) as? TextFieldCell else {
                 return BaseFormCell()
            }
            cell.bindTextField(data: cellData[indexPath.row])
//            cell.hideListAddButton()
            cell.delegate = self
            cell.listDelegate = self
            return cell
        }
        
        guard let cellType = PurchaseOrderCell(rawValue:  cellData[indexPath.row].key) else {
            return BaseFormCell()
        }
        if cellType == .Attachments {
            return instantiateAttachmentCell()
        }
        else if let cellType = PurchaseOrderCell(rawValue:  cellData[indexPath.row].key), cellType == .LINE_ITEM {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DataTableViewCell.ID) as? DataTableViewCell else {
                return BaseFormCell()
            }
            cell.setAddButtonTitle(title: "ADD".localize)
            cell.bindData(stockData: viewModel.getLineItems(), fields: stockTableHeader, canAddValue: isEditingEnabled, data: .init(key: PurchaseOrderCell.LINE_ITEM.rawValue))
            cell.setGearIcon(isAailable: isEditingEnabled)
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
    
    private func showAddLineItem(item: PurchaseOrderUsed? = nil, isEditingEnabled: Bool = true) {
        let createPurchaseOrderLineItem = CreatePurchaseOrderLineItem.instantiate(storyboard: .PURCHASE_ORDER)
        createPurchaseOrderLineItem.isEditingEnabled = isEditingEnabled
        if let item = item {
            createPurchaseOrderLineItem.viewModel.setLineItem(lineItem: item)
        }
        createPurchaseOrderLineItem.delegate = self
        navigationController?.pushViewController(createPurchaseOrderLineItem, animated: true)
    }
    
    override func handleAddItem() {
        super.handleAddItem()
        setupCellsData()
        viewModel.addPurchaseOrder { (error, isValidData) in
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


extension CreatePurchaseOrderView: TextFieldCellDelegate {
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        guard let cell = PurchaseOrderCell(rawValue: data.key) else {
            return
        }
        switch cell {

        case .ORDER_DATE:
            viewModel.setOrderedDate(date: text)
            
        case .EXPECTED_DATE:
            viewModel.setExpectedDate(date: text)
            
        case .SALE_TAX:
            viewModel.setSalesTax(price: text)
        
        case .SHIPPING:
            viewModel.setShipping(price: text)
        
        case .LINE_ITEM, .Attachments:
            break
        }
    }
}

extension CreatePurchaseOrderView: TextFieldListDelegate {
    
    func willAddItem(data: TextFieldCellData) {
        guard let cell = VenderCell(rawValue: data.key) else {
            return
        }
        switch cell {
        case .VENDOR_NAME:
            openCreateVendor()
        }
    }
    
    func didChooseItem(at row: Int?, data: TextFieldCellData) {
        guard let cell = VenderCell(rawValue: data.key) else {
            return
        }
        switch cell {
        case .VENDOR_NAME:
            DispatchQueue.main.async { [unowned self] in
                self.viewModel.setVendor(at: row)
                data.text = viewModel.getVendor()
                self.tableView.reloadData()
            }
        }
    }
}

extension CreatePurchaseOrderView: DataTableViewCellDelegate {
    func willAddItem(data: DataTableData) {
        showAddLineItem()
    }
    
    func didTapOnItem(at indexPath: IndexPath,dataTable: SwiftDataTable, data: DataTableData) {
        if !isEditingEnabled {
            return
        }
        
        guard let lineItem = viewModel.getLineItem(at: indexPath.section) else { return }
        let isItemRemoved = lineItem.removed ?? false
        let removeTitle = isItemRemoved ? "UNDELETE".localize : "DELETE".localize
        let actionSheet = GlobalFunction.showListActionSheet(deleteTitle:removeTitle) { [weak self] (_) in
            guard let self = self else { return }
            self.showAddLineItem(item: lineItem, isEditingEnabled: false)
            
        } editHandler: { [weak self] (_) in
            guard let self = self else { return }
            self.showAddLineItem(item: lineItem)
            
            
        } deleteHandler: { [weak self] (_) in
            guard let self = self else { return }
            if let _ = lineItem.purchaseOrderUsedId {
                if isItemRemoved{
                    self.viewModel.undeleteLineItem(lineItem: lineItem) { error in
                        if let error = error {
                            DispatchQueue.main.async { [unowned self] in
                                GlobalFunction.showMessageAlert(fromView: self, title: self.title ?? "", message: error)
                            }
                        }
                        else {
                            DispatchQueue.main.async { [unowned self] in
                                self.getPurchaseOrderLineItems()
                            }
                        }
                    }
                }
                else{
                    self.viewModel.deleteLineItem(lineItem: lineItem) { error in
                        if let error = error {
                            DispatchQueue.main.async { [unowned self] in
                                GlobalFunction.showMessageAlert(fromView: self, title: self.title ?? "", message: error)
                            }
                        }
                        else {
                            DispatchQueue.main.async { [unowned self] in
                                self.getPurchaseOrderLineItems()
                                
                            }
                        }
                    }
                }
            }
            else{
//                var stock = stock
//                stock.removed = !isItemRemoved
//                self.viewModel.setRemoveStock(stock: stock)
                self.viewModel.removeLineItem(lineItem: lineItem)
            }
            self.tableView.reloadData()
             
        }
        if let cell = dataTable.collectionView.cellForItem(at: indexPath) {
            presentAlert(alert: actionSheet, sourceView: cell)
        }
    
    }
    
    func fetchMoreData(data: DataTableData) {
        getPurchaseOrderLineItems(isReload: false)
    }
}



extension CreatePurchaseOrderView: LineItemDelegate {
    
    func didCreateLineItem(lineItem: PurchaseOrderUsed) {
        var lineItem = lineItem
        DispatchQueue.main.async { [unowned self] in
            if lineItem.purchaseOrderUsedId == nil , lineItem.lineItemId == nil{
                self.viewModel.getMaxLineItemId { (ID) in
                    if let ID = ID{
                        let maxID = viewModel.getLineItems().map { $0.lineItemId ?? 0 }.max() ?? 0
                        let ID = max(ID,maxID)
                        lineItem.lineItemId = ID+1
                    }
                    self.viewModel.addLineItem(lineItem: lineItem)
                    self.tableView.reloadData()
                }
            }
            else{
                self.viewModel.addLineItem(lineItem: lineItem)
                self.tableView.reloadData()
                
            }
            
        }
        
    }
    
    func didUpdateLineItem(lineItem: PurchaseOrderUsed) {
        DispatchQueue.main.async { [unowned self] in
            self.viewModel.updateLineItem(lineItem: lineItem)
            self.tableView.reloadData()
        }
    }
    
    func didCreateLineItem(lineItem: WorkOrderUsed) {
        
    }
    
    func didUpdateLineItem(lineItem: WorkOrderUsed) {
        
    }
    
    func didCreateLineItem(lineItem: ExpenseStatementsUsed) {
        
    }
    
    func didUpdateLineItem(lineItem: ExpenseStatementsUsed) {
        
    }
}
