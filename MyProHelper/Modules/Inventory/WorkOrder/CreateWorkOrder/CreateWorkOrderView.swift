//
//  CreateWorkOrderView.swift
//  MyProHelper
//
//  Created by sismac010 on 08/04/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import SwiftDataTables

private enum WorkOrderCell: String {
    case DESCRIPTION            = "DESCRIPTION"
    case LINE_ITEM              = "LINE_ITEM"
    case Attachments            = "Attachments"
}

private enum WorkOrderCell2: String {
    case CUSTOMER_NAME          = "CUSTOMER_NAME"
    case WORKER_NAME            = "WORKER_NAME"
}



class CreateWorkOrderView: BaseCreateWithAttachmentView<CreateWorkOrderViewModel>, Storyboarded {
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
        getCustomers()
        getWorkers()
        getCanEditTimeAlreadyEntered()
        setupCellsData()
        getWorkOrderLineItems()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.addShowRemovedButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        super.hideShowRemovedButton()
    }
    
    private func getCustomers() {
        viewModel.getCustomers { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    private func getWorkers() {
        viewModel.getWorkers { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    private func getCanEditTimeAlreadyEntered(){
        guard let workerID = UserDefaults.standard.value(forKey: UserDefaultKeys.userId) as? String else{return}
        
        viewModel.getCanEditTimeAlreadyEntered(workerID:workerID) { [weak self] in
            guard let self = self else { return }
            self.setupCellsData()
            self.tableView.reloadData()
        }
    }
    
    override func reloadData() {
        getWorkOrderLineItems()
    }

    
    private func setupCellsData() {
        let customerName = viewModel.getCustomer() != nil ? viewModel.getCustomer() : ((viewModel.getCustomers().count > 0) ? viewModel.getCustomers().first : "")
        let workerName = viewModel.getWorker() != nil ? viewModel.getWorker() : ((viewModel.getWorkers().count > 0) ? viewModel.getWorkers().first : "")
        cellData = [
            .init(title: WorkOrderCell2.CUSTOMER_NAME.rawValue.localize,
                  key: WorkOrderCell2.CUSTOMER_NAME.rawValue,
                  dataType: .ListView,
                  isRequired: false/*isEditingEnabled*/,
                  isActive: isEditingEnabled ,//&& viewModel.canEditVendor(),
                  keyboardType: .default,
                  validation: viewModel.validateCustomer(),
                  text: customerName,
                  listData: viewModel.getCustomers()),
            
            .init(title: WorkOrderCell2.WORKER_NAME.rawValue.localize,
                  key: WorkOrderCell2.WORKER_NAME.rawValue,
                  dataType: .ListView,
                  isRequired: isEditingEnabled/*true*/,
                  isActive: isEditingEnabled  && viewModel.canEditWorker(),
                  keyboardType: .default,
                  validation: viewModel.validateWorker(),
                  text: workerName,
                  listData: viewModel.getWorkers()),
            
            .init(title: WorkOrderCell.DESCRIPTION.rawValue.localize,
                  key: WorkOrderCell.DESCRIPTION.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateDescription(),
                  text: viewModel.getDescription()),
            
            .init(title: WorkOrderCell.LINE_ITEM.rawValue.localize,
                  key: WorkOrderCell.LINE_ITEM.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: ""),

            .init(title: WorkOrderCell.Attachments.rawValue.localize,
                  key: WorkOrderCell.Attachments.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: "")
        ]
    }
    
    private func getWorkOrderLineItems(isReload: Bool = true) {
        viewModel.getWorkOrderLineItems(isReload: isReload, showRemoved: isShowingRemoved) { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }

    
    override func getCell(at indexPath: IndexPath) -> BaseFormCell {
        if let cellType = WorkOrderCell2(rawValue:  cellData[indexPath.row].key) , cellType == .CUSTOMER_NAME || cellType == .WORKER_NAME {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.ID) as? TextFieldCell else {
                 return BaseFormCell()
            }
            cell.bindTextField(data: cellData[indexPath.row])
            cell.hideListAddButton()
            cell.delegate = self
            cell.listDelegate = self
            return cell
        }
        
        guard let cellType = WorkOrderCell(rawValue:  cellData[indexPath.row].key) else {
            return BaseFormCell()
        }
        if cellType == .Attachments {
            return instantiateAttachmentCell()
        }
        else if let cellType = WorkOrderCell(rawValue:  cellData[indexPath.row].key), cellType == .LINE_ITEM {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DataTableViewCell.ID) as? DataTableViewCell else {
                return BaseFormCell()
            }
            cell.setAddButtonTitle(title: "ADD".localize)
            cell.bindData(stockData: viewModel.getLineItems(), fields: stockTableHeader, canAddValue: isEditingEnabled, data: .init(key: WorkOrderCell.LINE_ITEM.rawValue))
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
    
    private func showAddLineItem(item: WorkOrderUsed? = nil, isEditingEnabled: Bool = true) {
        let createWorkOrderLineItem = CreateWorkOrderLineItem.instantiate(storyboard: .WORK_ORDER)
        createWorkOrderLineItem.isEditingEnabled = isEditingEnabled
        if let item = item {
            createWorkOrderLineItem.viewModel.setLineItem(lineItem: item)
        }
        createWorkOrderLineItem.delegate = self
        navigationController?.pushViewController(createWorkOrderLineItem, animated: true)
    }
    
    override func handleAddItem() {
        super.handleAddItem()
        setupCellsData()
        viewModel.addWorkOrder { (error, isValidData) in
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

extension CreateWorkOrderView: TextFieldCellDelegate {
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        guard let cell = WorkOrderCell(rawValue: data.key) else {
            return
        }
        switch cell {

        case .DESCRIPTION:
            viewModel.setDescription(description: text)
            break
        case .LINE_ITEM, .Attachments:
            break
        }
    }
}

extension CreateWorkOrderView: TextFieldListDelegate {
    
    func willAddItem(data: TextFieldCellData) {
        guard let cell = WorkOrderCell2(rawValue: data.key) else {
            return
        }
        switch cell {
        case .CUSTOMER_NAME:break
//            openCreateVendor()
        case .WORKER_NAME:break
        }
    }
    
    func didChooseItem(at row: Int?, data: TextFieldCellData) {
        guard let cell = WorkOrderCell2(rawValue: data.key) else {
            return
        }
        switch cell {
        case .WORKER_NAME:
            DispatchQueue.main.async { [unowned self] in
                self.viewModel.setWorker(at: row)
                data.text = viewModel.getWorker()
                self.tableView.reloadData()
            }
            break
            
        case .CUSTOMER_NAME:
            DispatchQueue.main.async { [unowned self] in
                self.viewModel.setCustomer(at: row)
                data.text = viewModel.getCustomer()
                self.tableView.reloadData()
            }
            break
        }
    }
}


extension CreateWorkOrderView: DataTableViewCellDelegate {
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

            if let _ = lineItem.workOrderUsedId {
                if isItemRemoved{
                    self.viewModel.undeleteLineItem(lineItem: lineItem) { error in
                        if let error = error {
                            DispatchQueue.main.async { [unowned self] in
                                GlobalFunction.showMessageAlert(fromView: self, title: self.title ?? "", message: error)
                            }
                        }
                        else {
                            DispatchQueue.main.async { [unowned self] in
                                self.getWorkOrderLineItems()
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
                                self.getWorkOrderLineItems()
                                
                            }
                        }
                    }
                }
            }
            else{
                self.viewModel.removeLineItem(lineItem: lineItem)
            }
            self.tableView.reloadData()
            
        }
        if let cell = dataTable.collectionView.cellForItem(at: indexPath) {
            presentAlert(alert: actionSheet, sourceView: cell)
        }
    
    }
    
    func fetchMoreData(data: DataTableData) {
        getWorkOrderLineItems(isReload: false)
    }
}


extension CreateWorkOrderView: LineItemDelegate {
    
    func didCreateLineItem(lineItem: WorkOrderUsed) {
        var lineItem = lineItem
        DispatchQueue.main.async { [unowned self] in
            if lineItem.workOrderUsedId == nil , lineItem.lineItemId == nil{
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
                lineItem.dateCreated = Date()
                self.viewModel.addLineItem(lineItem: lineItem)
                self.tableView.reloadData()
                
            }
            
        }
        
    }
    
    func didUpdateLineItem(lineItem: WorkOrderUsed) {
        DispatchQueue.main.async { [unowned self] in
            self.viewModel.updateLineItem(lineItem: lineItem)
            self.tableView.reloadData()
        }
    }
    
    func didUpdateLineItem(lineItem: PurchaseOrderUsed) {
        
    }
    
    func didCreateLineItem(lineItem: PurchaseOrderUsed) {
        
    }
    
    func didCreateLineItem(lineItem: ExpenseStatementsUsed) {
        
    }
    
    func didUpdateLineItem(lineItem: ExpenseStatementsUsed) {
        
    }
}
