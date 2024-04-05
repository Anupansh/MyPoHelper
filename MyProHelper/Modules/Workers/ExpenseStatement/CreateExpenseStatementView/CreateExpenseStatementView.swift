//
//  CreateExpenseStatementView.swift
//  MyProHelper
//
//  Created by sismac010 on 12/05/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import SwiftDataTables

private enum ExpenseStatementCell: String {
    case DESCRIPTION            = "DESCRIPTION"
    case LINE_ITEM              = "LINE_ITEM"
    case SALE_TAX               = "SALE_TAX"
    case SHIPPING               = "SHIPPING"
    case TOTAL                  = "TOTAL"
    case Attachments            = "Attachments"
}

private enum ExpenseStatementCell2: String {
    case CUSTOMER_NAME          = "CUSTOMER_NAME"
    case WORKER_NAME            = "WORKER_NAME"
}



class CreateExpenseStatementView: BaseCreateWithAttachmentView<CreateExpenseStatementViewModel>, Storyboarded {
    private let stockTableHeader = [
                                    "LINE_ITEM".localize,
                                    "PART_NAME".localize,
                                    "SUPPLY_NAME".localize,
                                    "NON_STOCKABLE_ITEM".localize,
                                    "PART_NUMBER".localize,
                                    "QUANTITY".localize,
                                    "PRICE_PER_ITEM".localize,
                                    "AMOUNT_TO_REIMBURSE".localize]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCustomers()
        getWorkers()
        getCanEditTimeAlreadyEntered()
        setupCellsData()
        getExpenseStatementsLineItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        super.addShowRemovedButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        super.hideShowRemovedButton()
    }
    
    override func reloadData() {
        getExpenseStatementsLineItems()
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
    
    private func setupCellsData() {
        cellData = [
            .init(title: ExpenseStatementCell2.CUSTOMER_NAME.rawValue.localize,
                  key: ExpenseStatementCell2.CUSTOMER_NAME.rawValue,
                  dataType: isEditingEnabled ? .ListView : .Text,
                  isRequired: false/*isEditingEnabled*/,
                  isActive: isEditingEnabled ,
                  keyboardType: .default,
                  validation: viewModel.validateCustomer(),
                  text: viewModel.getCustomer() != nil ? viewModel.getCustomer() : ((viewModel.getCustomers().count > 0) ? viewModel.getCustomers().first : ""),
                  listData: viewModel.getCustomers()),
            
            .init(title: ExpenseStatementCell2.WORKER_NAME.rawValue.localize,
                  key: ExpenseStatementCell2.WORKER_NAME.rawValue,
                  dataType: isEditingEnabled ? .ListView : .Text,
                  isRequired: isEditingEnabled,
                  isActive: isEditingEnabled && viewModel.canEditWorker(),
                  keyboardType: .default,
                  validation: viewModel.validateWorker(),
                  text: viewModel.getWorker() != nil ? viewModel.getWorker() : ((viewModel.getWorkers().count > 0) ? viewModel.getWorkers().first : ""),
                  listData: viewModel.getWorkers()),
            
            .init(title: ExpenseStatementCell.DESCRIPTION.rawValue.localize,
                  key: ExpenseStatementCell.DESCRIPTION.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateDescription(),
                  text: viewModel.getDescription()),
            
            .init(title: ExpenseStatementCell.LINE_ITEM.rawValue.localize,
                  key: ExpenseStatementCell.LINE_ITEM.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: ""),

            .init(title: ExpenseStatementCell.SALE_TAX.rawValue.localize,
                  key: ExpenseStatementCell.SALE_TAX.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  keyboardType: .decimalPad,
                  validation: viewModel.validateSalesTax(),
                  text: viewModel.getSalesTax()),
            
            .init(title: ExpenseStatementCell.SHIPPING.rawValue.localize,
                  key: ExpenseStatementCell.SHIPPING.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  keyboardType: .decimalPad,
                  validation: viewModel.validateShipping(),
                  text: viewModel.getShipping()),
            
            .init(title: ExpenseStatementCell.TOTAL.rawValue.localize,
                  key: ExpenseStatementCell.TOTAL.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: false,
                  keyboardType: .decimalPad,
                  validation: .Valid,
                  text: viewModel.getTotal()),
            
            .init(title: ExpenseStatementCell.Attachments.rawValue.localize,
                  key: ExpenseStatementCell.Attachments.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: "")
        ]
    }
    
    private func updateTotalCell(){
        
        let cell = TextFieldCellData.init(title: ExpenseStatementCell.TOTAL.rawValue.localize,
                                          key: ExpenseStatementCell.TOTAL.rawValue,
                                          dataType: .Text,
                                          isRequired: false,
                                          isActive: false,
                                          keyboardType: .decimalPad,
                                          validation: .Valid,
                                          text: viewModel.getTotal())
                                    
        cellData[cellData.count - 2] = cell
        
        DispatchQueue.main.async { [unowned self] in
            self.tableView.reloadData()
        }
    }
    
    private func updateWorkerCell(){
        
        let cell = TextFieldCellData.init(title: ExpenseStatementCell2.WORKER_NAME.rawValue.localize,
                                          key: ExpenseStatementCell2.WORKER_NAME.rawValue,
                                          dataType: isEditingEnabled ? .ListView : .Text,
                                          isRequired: isEditingEnabled,
                                          isActive: isEditingEnabled && viewModel.canEditWorker(),
                                          keyboardType: .default,
                                          validation: viewModel.validateWorker(),
                                          text: viewModel.getWorker() != nil ? viewModel.getWorker() : ((viewModel.getWorkers().count > 0) ? viewModel.getWorkers().first : ""),
                                          listData: viewModel.getWorkers())
                                    
        cellData[1] = cell
        
        DispatchQueue.main.async { [unowned self] in
            self.tableView.reloadData()
        }
    }
    
    
    private func getExpenseStatementsLineItems(isReload: Bool = true) {
        viewModel.getExpenseStatementsLineItems(isReload: isReload, showRemoved: isShowingRemoved) { [weak self] in
            guard let self = self else { return }
            self.viewModel.setTotal()
            self.updateTotalCell()
            self.tableView.reloadData()
        }
    }
    
    override func getCell(at indexPath: IndexPath) -> BaseFormCell {
        if let cellType = ExpenseStatementCell2(rawValue:  cellData[indexPath.row].key) , cellType == .CUSTOMER_NAME || cellType == .WORKER_NAME {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.ID) as? TextFieldCell else {
                 return BaseFormCell()
            }
            cell.bindTextField(data: cellData[indexPath.row])
            cell.hideListAddButton()
            cell.delegate = self
            cell.listDelegate = self
            return cell
        }
        
        guard let cellType = ExpenseStatementCell(rawValue:  cellData[indexPath.row].key) else {
            return BaseFormCell()
        }
        if cellType == .Attachments {
            return instantiateAttachmentCell()
        }
        else if let cellType = ExpenseStatementCell(rawValue:  cellData[indexPath.row].key), cellType == .LINE_ITEM {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DataTableViewCell.ID) as? DataTableViewCell else {
                return BaseFormCell()
            }
            cell.setAddButtonTitle(title: "ADD".localize)
            cell.bindData(stockData: viewModel.getLineItems(), fields: stockTableHeader, canAddValue: isEditingEnabled, data: .init(key: ExpenseStatementCell.LINE_ITEM.rawValue))
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
        if let cellType = ExpenseStatementCell(rawValue:  cellData[indexPath.row].key), cellType == .TOTAL {
            cell.setbackgroundColor(#colorLiteral(red: 0.848439455, green: 0.8582248092, blue: 0.8794361949, alpha: 1))
        }
        else{
            cell.setbackgroundColor(.clear)
        }
        
        cell.bindTextField(data: cellData[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    private func showAddLineItem(item: ExpenseStatementsUsed? = nil, isEditingEnabled: Bool = true) {
        let createExpenseStatementLineItem = CreateExpenseStatementLineItem.instantiate(storyboard: .EXPENSE_STATEMENT)
        createExpenseStatementLineItem.isEditingEnabled = isEditingEnabled
        if let item = item {
            createExpenseStatementLineItem.viewModel.setLineItem(lineItem: item)
        }
        createExpenseStatementLineItem.delegate = self
        navigationController?.pushViewController(createExpenseStatementLineItem, animated: true)
    }
    
    override func handleAddItem() {
        super.handleAddItem()
        setupCellsData()
        viewModel.addExpenseStatements { (error, isValidData) in
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

extension CreateExpenseStatementView: TextFieldCellDelegate {
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        guard let cell = ExpenseStatementCell(rawValue: data.key) else {
            return
        }
        switch cell {

        case .DESCRIPTION:
            viewModel.setDescription(description: text)
            break
        case .LINE_ITEM, .Attachments:
            break
        case .SALE_TAX:
            viewModel.setSalesTax(price: text)
            viewModel.setTotal()
            updateTotalCell()
        case .SHIPPING:
            viewModel.setShipping(price: text)
            viewModel.setTotal()
            updateTotalCell()
            break
        case .TOTAL:break
        }
    }
}


extension CreateExpenseStatementView: TextFieldListDelegate {
    
    func willAddItem(data: TextFieldCellData) {
        guard let cell = ExpenseStatementCell2(rawValue: data.key) else {
            return
        }
        switch cell {
        case .CUSTOMER_NAME:break
//            openCreateVendor()
        case .WORKER_NAME:break
        }
    }
    
    func didChooseItem(at row: Int?, data: TextFieldCellData) {
        guard let cell = ExpenseStatementCell2(rawValue: data.key) else {
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

extension CreateExpenseStatementView: DataTableViewCellDelegate {
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
            
            if let _ = lineItem.expenseStatementsUsedId {
                if isItemRemoved{
                    
                    self.viewModel.undeleteLineItem(lineItem: lineItem) { error in
                        if let error = error {
                            DispatchQueue.main.async { [unowned self] in
                                GlobalFunction.showMessageAlert(fromView: self, title: self.title ?? "", message: error)
                            }
                        }
                        else {
                            DispatchQueue.main.async { [unowned self] in
                                self.getExpenseStatementsLineItems()
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
                                self.getExpenseStatementsLineItems()

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
        getExpenseStatementsLineItems(isReload: false)
    }
}

extension CreateExpenseStatementView: LineItemDelegate {
    
    func didCreateLineItem(lineItem: WorkOrderUsed) {
    }
    func didUpdateLineItem(lineItem: WorkOrderUsed) {
    }
    
    func didCreateLineItem(lineItem: ExpenseStatementsUsed) {
        var lineItem = lineItem
        DispatchQueue.main.async { [unowned self] in
            if lineItem.expenseStatementsUsedId == nil , lineItem.lineItemId == nil{
                self.viewModel.getMaxLineItemId { (ID) in
                    if let ID = ID{
                        let maxID = viewModel.getLineItems().map { $0.lineItemId ?? 0 }.max() ?? 0
                        let ID = max(ID,maxID)
                        lineItem.lineItemId = ID+1
                    }
                    self.viewModel.addLineItem(lineItem: lineItem)
                    self.viewModel.setTotal()
                    self.updateTotalCell()
                    self.tableView.reloadData()
                }
            }
            else{
                lineItem.dateCreated = Date()
                self.viewModel.addLineItem(lineItem: lineItem)
                self.viewModel.setTotal()
                self.updateTotalCell()
                self.tableView.reloadData()
                
            }
            
        }
        
    }
    
    func didUpdateLineItem(lineItem: ExpenseStatementsUsed) {
        DispatchQueue.main.async { [unowned self] in
            self.viewModel.updateLineItem(lineItem: lineItem)
            self.viewModel.setTotal()
            self.updateTotalCell()
            self.tableView.reloadData()
        }
    }
    
    func didUpdateLineItem(lineItem: PurchaseOrderUsed) {
        
    }
    
    func didCreateLineItem(lineItem: PurchaseOrderUsed) {
        
    }
}
