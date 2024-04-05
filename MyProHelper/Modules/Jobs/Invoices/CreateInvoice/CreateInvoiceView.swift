//
//  CreateInvoiceView.swift
//  MyProHelper
//
//  Created by Deep on 2/4/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit
import SwiftDataTables
import GRDB

private enum InvoiceCell: String {
    case SCHEDULED_JOB            = "SCHEDULED_JOB"
    case CUSTOMER_NAME            = "CUSTOMER_NAME"
    case DESCRIPTION              = "DESCRIPTION"
    case PRICE_QUOTED             = "PRICE_QUOTED"
    case PRICE                    = "PRICE"
    case INVOICE_ADJUSTEMENT      = "INVOICE_ADJUSTEMENT"
    case QUOTE_EXPIRATION         = "QUOTE_EXPIRATION"
    case ATTACHMENTS              = "ATTACHMENT"
    case SERVICE_USED_ITEM        = "SERVICE_USED_ITEM"
    case SERVICE_TAX_PERCENTAGE   = "SERVICE_TAX_PERCENTAGE"
    case TAX_ON_SERVICE           = "TAX_ON_SERVICE"
    case PARTS_USED_ITEM          = "PARTS_USED_ITEM"
    case PART_TAX_PERCENTAGE      = "PART_TAX_PERCENTAGE"
    case TAX_ON_PARTS             = "TAX_ON_PARTS"
    case SUPPLIES_USED_ITEM       = "SUPPLIES_USED_ITEM"
    case SUPPLY_TAX_PERCENTAGE    = "SUPPLY_TAX_PERCENTAGE"
    case TAX_ON_SUPPLIES          = "TAX_ON_SUPPLIES"
    case DISCOUNT_PERCENTAGE      = "DISCOUNT_PERCENTAGE"
    case COMPLETED_DATE           = "COMPLETED_DATE"
    case TOTAL_INVOICE_AMOUNNT    = "TOTAL_INVOICE_AMOUNNT"
    case DATE_OF_SERVICE          = "DATE_OF_SERVICE"
}

private enum TypeCell: String {
    case ESTIMATE       = "ESTIMATE"
    case FIXED_PRICE    = "FIXED_PRICE"
    
    func stringValue() -> String {
        return self.rawValue.localize
    }
}

class CreateInvoiceView: BaseCreateWithAttachmentView<CreateInvoiceViewModel>, Storyboarded {
    
    private let serviceUsedHeader = [
        "SERVICE_NAME".localize,
        "QUANTITY".localize,
        "PRICE_TO_RESELL".localize
    ]
    
    private let partsUsedHeader = [
        "PART_NAME".localize,
        "PART_LOCATION".localize,
        "PURCHASED_FROM".localize,
        "QUANTITY".localize,
        "PRICE_TO_RESELL".localize
    ]
    
    private let suppliesUsedHeader = [
        "SUPPLY_NAME".localize,
        "SUPPLY_LOCATION".localize,
        "PURCHASED_FROM".localize,
        "QUANTITY".localize,
        "PRICE_TO_RESELL".localize
    ]
    var cameFromCurrentJobs = false
    var cameFromPayments = false
    var shareInvoiceClosure : (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCustomers()
        setupCellsData()
        getServiceItems()
        getPartItems()
        getSuppliesItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func setupNavigationBar() {
        if isEditingEnabled {
            if viewModel.getIsUpdatingInvoice() {
                let saveItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(handleAddItem))
                let finalizeItem = UIBarButtonItem(title: "Finalize", style: .done, target: self, action: #selector(finalizeInvoice))
                self.navigationItem.rightBarButtonItems = [saveItem,finalizeItem]
            }
            else {
                let saveItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(handleAddItem))
                self.navigationItem.rightBarButtonItem = saveItem
            }
        }
    }
    
    private func fetchCustomers() {
        viewModel.fetchCustomers { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    private func fetchJobs() {
        viewModel.fetchCustomerJobs {
            [weak self] in
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
    
    private func showAddServiceUsedView(service: ServiceUsed? = nil, isEditingEnabled: Bool = true ) {
        let createServiceUsedView = CreateServiceUsedView.instantiate(storyboard: .SERVICE)
        createServiceUsedView.isEditingEnabled = isEditingEnabled
        if let service = service {
            createServiceUsedView.viewModel.setService(service: service)
        }
        createServiceUsedView.delegate = self
        navigationController?.pushViewController(createServiceUsedView, animated: true)
    }
    
    private func showAddPartUsedView(part: PartUsed? = nil, isEditingEnabled: Bool = true ) {
        let createPartUsedView = CreatePartUsedView.instantiate(storyboard: .INVOICE)
        createPartUsedView.isEditingEnabled = isEditingEnabled
        if let part = part {
            createPartUsedView.viewModel.setPart(part: part)
        }
        createPartUsedView.delegate = self
        navigationController?.pushViewController(createPartUsedView, animated: true)
    }
    
    private func showAddSupplyUsedView(supply: SupplyUsed? = nil, isEditingEnabled: Bool = true ) {
        let createSupplyUsedView = CreateSupplyUsedView.instantiate(storyboard: .INVOICE)
        createSupplyUsedView.isEditingEnabled = isEditingEnabled
        if let supply = supply {
            createSupplyUsedView.viewModel.setSupply(supply: supply)
        }
        createSupplyUsedView.delegate = self
        navigationController?.pushViewController(createSupplyUsedView, animated: true)
    }
    
    override func getCell(at indexPath: IndexPath) -> BaseFormCell {
        let cellType = InvoiceCell(rawValue:  cellData[indexPath.row].key)
        
        switch cellType {
        case .ATTACHMENTS:
            return instantiateAttachmentCell()
        case .PRICE:
            return getRadioButtonCell()
        case .DESCRIPTION:
            return getDescriptionCell(at: indexPath.row)
        case .SERVICE_USED_ITEM:
            return getServiceUsed()
        case .PARTS_USED_ITEM:
            return getPartUsed()
        case .SUPPLIES_USED_ITEM:
            return getSupplyUsed()
        default:
            return getTextFieldCell(at: indexPath.row)
        }
    }
    
    func getPartUsed() -> BaseFormCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DataTableViewCell.ID) as? DataTableViewCell else {
            return BaseFormCell()
        }
        cell.setAddButtonTitle(title: "ADD_PART".localize)
        cell.bindData(stockData: viewModel.getPartUsedItems(), fields: partsUsedHeader, canAddValue: isEditingEnabled, data: .init(key: InvoiceCell.PARTS_USED_ITEM.rawValue))
        cell.setGearIcon(isAailable: isEditingEnabled)
        cell.delegate = self
        return cell
    }
    
    func getServiceUsed() -> BaseFormCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DataTableViewCell.ID) as? DataTableViewCell else {
            return BaseFormCell()
        }
        cell.setAddButtonTitle(title: "ADD_SERVICE_USED".localize)
        cell.bindData(stockData: viewModel.getServiceUsedItems(), fields: serviceUsedHeader, canAddValue: isEditingEnabled, data: .init(key: InvoiceCell.SERVICE_USED_ITEM.rawValue))
        cell.setGearIcon(isAailable: isEditingEnabled)
        cell.delegate = self
        return cell
    }
    
    func getSupplyUsed() -> BaseFormCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DataTableViewCell.ID) as? DataTableViewCell else {
            return BaseFormCell()
        }
        cell.setAddButtonTitle(title: "ADD_SUPPLY_USED".localize)
        cell.bindData(stockData: viewModel.getSupplyUsedItems(), fields: suppliesUsedHeader, canAddValue: isEditingEnabled, data: .init(key: InvoiceCell.SUPPLIES_USED_ITEM.rawValue))
        cell.setGearIcon(isAailable: isEditingEnabled)
        cell.delegate = self
        return cell
    }
    
    func getRadioButtonCell() -> BaseFormCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RadioButtonCell.ID) as? RadioButtonCell else {
            return RadioButtonCell()
        }
        cell.isSelectionEnabled = isEditingEnabled
        cell.setTitle(title: "Price")
        cell.bindCell(data: [.init(key: TypeCell.ESTIMATE.rawValue,
                                   title: TypeCell.ESTIMATE.stringValue(),
                                   value: viewModel.isPriceEstimate()),
                             .init(key: TypeCell.FIXED_PRICE.rawValue,
                                   title: TypeCell.FIXED_PRICE.stringValue(),
                                   value: viewModel.isPriceFixed())])
        cell.delegate = self
        return cell
    }
    
    func getTextFieldCell(at index: Int) -> BaseFormCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.ID) as? TextFieldCell else {
            return BaseFormCell()
        }
        cell.bindTextField(data: cellData[index])
        cell.delegate = self
        cell.listDelegate = self
        return cell
    }
    
    func getDescriptionCell(at index: Int) -> BaseFormCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TextViewCell.ID) as? TextViewCell else {
            return BaseFormCell()
        }
        cell.bindTextView(data: cellData[index])
        cell.delegate = self
        return cell
    }
    
    
    
    private func getServiceItems(isReload: Bool = true) {
        viewModel.getServiceUsedItem(isReload: isReload) { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    private func getPartItems(isReload: Bool = true) {
        viewModel.getServiceUsedItem(isReload: isReload) { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    private func getSuppliesItems(isReload: Bool = true) {
        viewModel.getSupplyUsedItem(isReload: isReload) { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    override func handleAddItem() {
        super.handleAddItem()
        setupCellsData()
        viewModel.saveItem { (error, isValidData) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                let title = self.title ?? ""
                if let error = error {
                    GlobalFunction.showMessageAlert(fromView: self, title: title, message: error)
                }
                else if isValidData {
                    if self.cameFromCurrentJobs {
                        for controller in self.navigationController!.viewControllers as Array {
                            if controller.isKind(of: DashboardViewController.self) {
                                self.navigationController?.popToViewController(controller, animated: true)
                            }
                        }
                    }
                    else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                else {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @objc func finalizeInvoice() {
        let arguments : StatementArguments = [
            "id" : viewModel.getInvoiceId(),
            "finalize" : true,
            "completedDate" : Date()
        ]
        let sql = """
            UPDATE \(RepositoryConstants.Tables.INVOICES) SET
                \(RepositoryConstants.Columns.IS_INVOICE_FINAL)                            =   :finalize,
                \(RepositoryConstants.Columns.DATE_COMPLETED)                            =   :completedDate
            WHERE \(RepositoryConstants.Tables.INVOICES).\(RepositoryConstants.Columns.INVOICE_ID)  =   :id
        """
        AppDatabase.shared.executeSQL(sql: sql, arguments: arguments,typeOfAction: .update, updatedId: UInt64(viewModel.getInvoiceId())) { (id) in
            if self.cameFromCurrentJobs {
                for controller in self.navigationController!.viewControllers as Array {
                    if controller.isKind(of: DashboardViewController.self) {
                        DBHelper.updateJobStatus(status: .invoiced, jobID: self.viewModel.invoice.value.jobID ?? 0) {}
                        self.navigationController?.popToViewController(controller, animated: true)
                    }
                }
            }
            else {
                self.navigationController?.popViewController(animated: true)
            }
        } fail: { (error) in
            print(error.localizedDescription)
        }
    }
    
    private func setupCellsData() {
        cellData = [
            .init(title: InvoiceCell.CUSTOMER_NAME.rawValue.localize,
                  key: InvoiceCell.CUSTOMER_NAME.rawValue,
                  dataType: .ListView,
                  isRequired: true,
                  isActive: cameFromCurrentJobs || cameFromPayments ?false:isEditingEnabled,
                  keyboardType: .default,
                  validation: viewModel.validateCustomer(),
                  text: viewModel.getCustomerName(),
                  listData: viewModel.getCustomers()),
            
            .init(title: InvoiceCell.SCHEDULED_JOB.rawValue.localize,
                  key: InvoiceCell.SCHEDULED_JOB.rawValue,
                  dataType: .ListView,
                  isRequired: true,
                  isActive: cameFromCurrentJobs ?false:isEditingEnabled,
                  keyboardType: .default,
                  validation: viewModel.validateJob(),
                  text: viewModel.getJobTitle(),
                  listData:viewModel.getJobs()),
            
            .init(title: InvoiceCell.DESCRIPTION.rawValue.localize,
                  key: InvoiceCell.DESCRIPTION.rawValue,
                  dataType: .Text,
                  isRequired: true,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateDescription(),
                  text: viewModel.getDescription()),
            
            .init(title: InvoiceCell.PRICE_QUOTED.rawValue.localize,
                  key: InvoiceCell.PRICE_QUOTED.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: viewModel.validatePriceQuoted(),
                  text: viewModel.getPriceQuoted()),
            
            .init(title: InvoiceCell.INVOICE_ADJUSTEMENT.rawValue.localize,
                  key: InvoiceCell.INVOICE_ADJUSTEMENT.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateInvoiceAdjustement(),
                  text: viewModel.getInvoiceAdjustement()),
            
            .init(title: InvoiceCell.QUOTE_EXPIRATION.rawValue.localize,
                  key: InvoiceCell.QUOTE_EXPIRATION.rawValue,
                  dataType: .Date,
                  isRequired: true,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateQuoteExpiration(),
                  text: viewModel.getQuoteExpirationDate()),
            
            .init(title: InvoiceCell.PRICE.rawValue.localize,
                  key: InvoiceCell.PRICE.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: ""),
            
            .init(title: InvoiceCell.ATTACHMENTS.rawValue.localize,
                  key: InvoiceCell.ATTACHMENTS.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: ""),
            
            .init(title: InvoiceCell.SERVICE_USED_ITEM.rawValue.localize,
                  key: InvoiceCell.SERVICE_USED_ITEM.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: ""),
            
            .init(title: InvoiceCell.SERVICE_TAX_PERCENTAGE.rawValue.localize,
                  key: InvoiceCell.SERVICE_TAX_PERCENTAGE.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: viewModel.getTaxPercentage()),
            
            .init(title: InvoiceCell.TAX_ON_SERVICE.rawValue.localize,
                  key: InvoiceCell.TAX_ON_SERVICE.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: false,
                  validation: .Valid,
                  text: viewModel.getTaxOnService()),
            
            .init(title: InvoiceCell.PARTS_USED_ITEM.rawValue.localize,
                  key: InvoiceCell.PARTS_USED_ITEM.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: ""),
            
            .init(title: InvoiceCell.PART_TAX_PERCENTAGE.rawValue.localize,
                  key: InvoiceCell.PART_TAX_PERCENTAGE.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: viewModel.getPartTaxPercentage()),
            
            .init(title: InvoiceCell.TAX_ON_PARTS.rawValue.localize,
                  key: InvoiceCell.TAX_ON_PARTS.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: false,
                  validation: .Valid,
                  text: viewModel.getTaxOnParts()),
            
            .init(title: InvoiceCell.SUPPLIES_USED_ITEM.rawValue.localize,
                  key: InvoiceCell.SUPPLIES_USED_ITEM.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: ""),
            
            .init(title: InvoiceCell.SUPPLY_TAX_PERCENTAGE.rawValue.localize,
                  key: InvoiceCell.SUPPLY_TAX_PERCENTAGE.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: viewModel.getSupplyTaxPercentage()),
            
            .init(title: InvoiceCell.TAX_ON_SUPPLIES.rawValue.localize,
                  key: InvoiceCell.TAX_ON_SUPPLIES.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: false,
                  validation: .Valid,
                  text: viewModel.getTaxOnSupplies()),
            
            .init(title: InvoiceCell.DISCOUNT_PERCENTAGE.rawValue.localize,
                  key: InvoiceCell.DISCOUNT_PERCENTAGE.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: viewModel.getDiscountPercentage()),
            
            .init(title: InvoiceCell.DATE_OF_SERVICE.rawValue.localize,
                  key: InvoiceCell.DATE_OF_SERVICE.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: true,
                  validation: .Valid,
                  text: viewModel.getServiceDates()),
            
            .init(title: InvoiceCell.COMPLETED_DATE.rawValue.localize,
                  key: InvoiceCell.COMPLETED_DATE.rawValue,
                  dataType: .Date,
                  isRequired: false,
                  isActive: false,
                  validation: .Valid,
                  text: viewModel.getInvoiceCompletedDate()),
            
            .init(title: InvoiceCell.TOTAL_INVOICE_AMOUNNT.rawValue.localize,
                  key: InvoiceCell.TOTAL_INVOICE_AMOUNNT.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: false,
                  validation: .Valid,
                  text: viewModel.getTotaInvoiceAmount()),
        ]
    }
    
    func reloadTableValues(indexPath: IndexPath) {
        viewModel.calculateTotalInvoiceAmount()
        setupCellsData()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

//MARK: - Text Field Delegate

extension CreateInvoiceView: TextFieldCellDelegate {
    
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        guard let cell = InvoiceCell(rawValue: data.key) else {
            return
        }
        switch cell {
        case .DESCRIPTION:
            viewModel.setDescription(description: text)
        case .PRICE_QUOTED:
            viewModel.setPriceQuoted(price: text)
        case .INVOICE_ADJUSTEMENT:
            viewModel.setInvoiceAdjustement(adjustement: text)
        case .QUOTE_EXPIRATION:
            viewModel.setQuoteExpiration(date: text)
        case .SERVICE_TAX_PERCENTAGE:
            viewModel.setServiceTaxPercentage(tax: text)
            reloadTableValues(indexPath: IndexPath(row: 10, section: 0))
        case .PART_TAX_PERCENTAGE:
            viewModel.setPartTaxPercentage(tax: text)
            reloadTableValues(indexPath: IndexPath(row: 13, section: 0))
        case .SUPPLY_TAX_PERCENTAGE:
            viewModel.setSupplyTaxPercentage(tax: text)
            reloadTableValues(indexPath: IndexPath(row: 16, section: 0))
        case .DISCOUNT_PERCENTAGE:
            viewModel.setDiscountPercentage(discount: text)
        case .COMPLETED_DATE:
            viewModel.setCompletedDate(date: text)
        default:
            break
        }
    }
}

//MARK: - Radio Buttom Cell Delegate

extension CreateInvoiceView: RadioButtonCellDelegate {
    func didChooseButton(data: RadioButtonData) {
        guard let button = TypeCell(rawValue: data.key) else { return }
        switch button {
        case .ESTIMATE:
            viewModel.setPriceEstimate()
        case .FIXED_PRICE:
            viewModel.setFixedPrice()
        }
    }
}

//MARK: - Text Field List Delegate

extension CreateInvoiceView: TextFieldListDelegate {
    
    func willAddItem(data: TextFieldCellData) {
        guard let field = InvoiceCell(rawValue: data.key) else { return }
        switch field {
        case .CUSTOMER_NAME:
            openCreateCustomer()
        case .SCHEDULED_JOB:
            break
        default:
            break
        }
    }
    
    func didChooseItem(at row: Int?, data: TextFieldCellData) {
        guard let row = row else { return }
        guard let field = InvoiceCell(rawValue: data.key) else {
            return
        }
        switch field {
        case .CUSTOMER_NAME:
            viewModel.setCustomer(at: row)
            tableView.reloadData()
            fetchJobs()
            reloadTableValues(indexPath: IndexPath(row: 1, section: 0))
        case .SCHEDULED_JOB:
            viewModel.setJob(at: row)
            tableView.reloadData()
        default:
            break
        }
    }
}

//MARK: - Add Data table view delegate

extension CreateInvoiceView: DataTableViewCellDelegate {
    func willAddItem(data: DataTableData) {
        guard let table = InvoiceCell(rawValue: data.key) else { return }
        switch table {
        case .SERVICE_USED_ITEM:
            showAddServiceUsedView()
        case .PARTS_USED_ITEM:
            showAddPartUsedView()
        case .SUPPLIES_USED_ITEM:
            showAddSupplyUsedView()
        default:
            break
        }
    }
    
    func didTapOnItem(at indexPath: IndexPath, dataTable: SwiftDataTable, data: DataTableData) {
        guard let table = InvoiceCell(rawValue: data.key) else { return }
        
        switch table {
        case .SERVICE_USED_ITEM:
            serviceUsedActions(indexPath: indexPath, dataTable: dataTable)
        case .PARTS_USED_ITEM:
            partUsedActions(indexPath: indexPath, dataTable: dataTable)
        case .SUPPLIES_USED_ITEM:
            supplyUsedActions(indexPath: indexPath, dataTable: dataTable)
        default:
            break
        }
    }
    
    func fetchMoreData(data: DataTableData) {
        guard let table = InvoiceCell(rawValue: data.key) else { return }
        switch table {
        case .SERVICE_USED_ITEM:
            getServiceItems(isReload: false)
        case .PARTS_USED_ITEM:
            getPartItems(isReload: false)
        case .SUPPLIES_USED_ITEM:
            getSuppliesItems(isReload: false)
        default:
            break
        }
    }
    
    func serviceUsedActions(indexPath: IndexPath,dataTable: SwiftDataTable ) {
        if !isEditingEnabled {
            return
        }
        guard let serviceItem = viewModel.getServiceItem(at: indexPath.section) else { return }
        let actionSheet = GlobalFunction.showListActionSheet() { [weak self] (_) in
            guard let self = self else { return }
            self.showAddServiceUsedView(service: serviceItem,isEditingEnabled: false)
            
        }
        editHandler: { [weak self] (_) in
            guard let self = self else { return }
            self.showAddServiceUsedView(service: serviceItem)
            
        }

        deleteHandler: { [weak self] (_) in
            guard let self = self else { return }
            self.viewModel.deleteServiceUsed(service: serviceItem) { error in
                if let error = error {
                    DispatchQueue.main.async { [unowned self] in
                        GlobalFunction.showMessageAlert(fromView: self, title: self.title ?? "", message: error)
                    }
                }
                else {
                    self.viewModel.removeServiceUsedItemFromArray(service: serviceItem, index: indexPath.section)
                    self.tableView.reloadData()
                    DispatchQueue.main.async { [unowned self] in
                        self.getPartItems()
                    }
                }
            }
        }
        
        if let cell = dataTable.collectionView.cellForItem(at: indexPath) {
            presentAlert(alert: actionSheet, sourceView: cell)
        }
    }
    
    func partUsedActions(indexPath: IndexPath,dataTable: SwiftDataTable) {
        if !isEditingEnabled {
            return
        }
        guard let partItem = viewModel.getPartItem(at: indexPath.section) else { return }
        let actionSheet = GlobalFunction.showListActionSheet() { [weak self] (_) in
            guard let self = self else { return }
            self.showAddPartUsedView(part: partItem, isEditingEnabled: false)
        }
        
        editHandler: { [weak self] (_) in
            guard let self = self else { return }
            self.showAddPartUsedView(part: partItem)
            
        }
        
        deleteHandler:{ [weak self] (_) in
            guard let self = self else { return }
            self.viewModel.deletePartUsed(part: partItem) { error in
                if let error = error {
                    DispatchQueue.main.async { [unowned self] in
                        GlobalFunction.showMessageAlert(fromView: self, title: self.title ?? "", message: error)
                    }
                }
                else {
                    DispatchQueue.main.async { [unowned self] in
                        self.viewModel.removePartUsedItemFromArray(part: partItem, index: indexPath.section)
                        self.tableView.reloadData()
                        self.getPartItems()
                    }
                }
            }
        }
        
        if let cell = dataTable.collectionView.cellForItem(at: indexPath) {
            presentAlert(alert: actionSheet, sourceView: cell)
        }
    }
    
    func supplyUsedActions(indexPath: IndexPath,dataTable: SwiftDataTable) {
        if !isEditingEnabled {
            return
        }
        guard let supplyItem = viewModel.getSupplyItem(at: indexPath.section) else { return }
        let actionSheet = GlobalFunction.showListActionSheet() { [weak self] (_) in
            guard let self = self else { return }
            self.showAddSupplyUsedView(supply: supplyItem, isEditingEnabled: false)
        }
        
        editHandler: { [weak self] (_) in
            guard let self = self else { return }
            self.showAddSupplyUsedView(supply: supplyItem)
            
        }
        
        deleteHandler:{ [weak self] (_) in
            guard let self = self else { return }
            self.viewModel.deleteSupplyUsed(supply: supplyItem) { error in
                if let error = error {
                    DispatchQueue.main.async { [unowned self] in
                        GlobalFunction.showMessageAlert(fromView: self, title: self.title ?? "", message: error)
                    }
                }
                else {
                    DispatchQueue.main.async { [unowned self] in
                        self.viewModel.removeSupplyUsedItemFromArray(supply: supplyItem, index: indexPath.section)
                        self.tableView.reloadData()
                        self.getSuppliesItems()
                    }
                }
            }
        }
        
        if let cell = dataTable.collectionView.cellForItem(at: indexPath) {
            presentAlert(alert: actionSheet, sourceView: cell)
        }
    }
}

//MARK: -  Service Used item Delegate

extension CreateInvoiceView: ServiceUsedItemDelegate {
    func didAddService(service: ServiceUsed) {
        DispatchQueue.main.async { [unowned self] in
            self.viewModel.addServiceUsed(service: service)
            self.tableView.reloadData()
            reloadTableValues(indexPath: IndexPath(row: 9, section: 0))
        }
    }
    
    func didUpdateService(service: ServiceUsed) {
        DispatchQueue.main.async { [unowned self] in
            self.viewModel.updateServiceUsed(service: service)
            self.tableView.reloadData()
            reloadTableValues(indexPath: IndexPath(row: 9, section: 0))
            
        }
    }
}

//MARK: - Parts Used item Delegate
extension CreateInvoiceView: PartUsedItemDelegate {
    func didAddPart(part: PartUsed) {
        DispatchQueue.main.async { [unowned self] in
            self.viewModel.addPartUsed(part: part)
            self.tableView.reloadData()
            reloadTableValues(indexPath: IndexPath(row: 12, section: 0))
        }
    }
    
    func didUpdatePart(part: PartUsed) {
        DispatchQueue.main.async { [unowned self] in
            self.viewModel.updatePartUsed(part: part)
            self.tableView.reloadData()
            reloadTableValues(indexPath: IndexPath(row: 12, section: 0))
        }
    }
}


//MARK: - Supply Used item Delegate
extension CreateInvoiceView: SupplyUsedItemDelegate {
    
    func didAddSupply(supply: SupplyUsed) {
        DispatchQueue.main.async { [unowned self] in
            self.viewModel.addSupplyUsed(supply: supply)
            self.tableView.reloadData()
            reloadTableValues(indexPath: IndexPath(row: 15, section: 0))
        }
    }
    
    func didUpdateSupply(supply: SupplyUsed) {
        DispatchQueue.main.async { [unowned self] in
            self.viewModel.updateSupplyUsed(supply: supply)
            self.tableView.reloadData()
            reloadTableValues(indexPath: IndexPath(row: 15, section: 0))
        }
    }
}
