//
//  CreateJobDetailView.swift
//  MyProHelper
//
//  Created by sismac010 on 08/07/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import SwiftDataTables

private enum JobDetailListCell: String {
//    case CUSTOMER_NAME        = "CUSTOMER_NAME"
    case SHORT_DESCRIPTION    = "SHORT_DESCRIPTION"
    case DETAILS              = "DETAILS"
    case LINE_ITEM            = "LINE_ITEM"
    case ATTACHMENTS          = "ATTACHMENTS"
    case ENTERED_DATE_TIME    = "ENTERED_DATE_TIME"
    case ENTERED_BY           = "ENTERED_BY"
}

private enum JobDetailListCell2: String {
    case CUSTOMER_NAME          = "CUSTOMER_NAME"
    case JOB_TITLE            = "Job"
    case SHORT_DESCRIPTION    = "SHORT_DESCRIPTION"
}


class CreateJobDetailView: BaseCreateWithAttachmentView<CreateJobDetailViewModel>, Storyboarded {
//    var isAdding = false
    
    private let detailTableHeader = [
                                    "DETAILS".localize,
                                    "ENTERED_BY".localize,
                                    "ENTERED_DATE_TIME".localize]


    override func viewDidLoad() {
        super.viewDidLoad()
        getCustomers()
//        getJobs()
        setupCellsData()
        getLineItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "OPEN_JOB_DETAILS".localize
//        super.addShowRemovedButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        super.hideShowRemovedButton()
    }
    
    private func getCustomers() {
        viewModel.getCustomers { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    override func reloadData() {
        getLineItems()
    }
    
    private func getLineItems(isReload: Bool = true) {
        viewModel.getLineItems(isReload: isReload, showRemoved: isShowingRemoved) { [weak self] in
            guard let self = self else { return }
//            self.viewModel.setTotal()
//            self.updateTotalCell()
            self.tableView.reloadData()
        }
    }
    

    

    private func getJobs() {
        if !viewModel.isNewRecord(){return}

        viewModel.getJobs { [weak self] in
            guard let self = self else { return }
            self.setupCellsData()
            self.tableView.reloadData()
        }
    }
    
    private func setupCellsData() {
        
        if viewModel.isNewRecord(){
            cellData = [
                .init(title: JobDetailListCell2.CUSTOMER_NAME.rawValue.localize,
                      key: JobDetailListCell2.CUSTOMER_NAME.rawValue,
                      dataType: viewModel.isNewRecord() ? .ListView : .Text,
                      isRequired: viewModel.isNewRecord(),
                      isActive: viewModel.isNewRecord(),
                      keyboardType: .default,
                      validation: viewModel.validateCustomer2(),
                      text: viewModel.getCustomer() != nil ? viewModel.getCustomer() : "",
                      listData: viewModel.isNewRecord() ? viewModel.getCustomers() : []),
                
                .init(title: JobDetailListCell2.SHORT_DESCRIPTION.rawValue.localize,
                      key: JobDetailListCell2.SHORT_DESCRIPTION.rawValue,
                      dataType: viewModel.isNewRecord() ? .ListView : .Text,
                      isRequired: viewModel.isNewRecord(),
                      isActive: viewModel.isNewRecord(),
                      keyboardType: .default,
                      validation: viewModel.validatejobShortDescription2(),
                      text: viewModel.getJobShortDescription2() != nil ? viewModel.getJobShortDescription2() : "",
                      listData: viewModel.isNewRecord() ? viewModel.getJobs() : []),

                .init(title: JobDetailListCell.DETAILS.rawValue.localize,
                      key: JobDetailListCell.DETAILS.rawValue,
                      dataType: .Text,
                      isRequired: false,
                      isActive: isEditingEnabled,
                      validation: viewModel.validatejobDetails(),
                      text: viewModel.getDetails()),
                
                .init(title: JobDetailListCell.ATTACHMENTS.rawValue.localize,
                      key: JobDetailListCell.ATTACHMENTS.rawValue,
                      dataType: .Text,
                      isRequired: false,
                      isActive: isEditingEnabled,
                      validation: .Valid,
                      text: ""),
                
                .init(title: JobDetailListCell.ENTERED_BY.rawValue.localize,
                      key: JobDetailListCell.ENTERED_BY.rawValue,
                      dataType: .Text,
                      isRequired: false,
                      isActive: false,//isEditingEnabled ,
                      keyboardType: .default,
                      validation: .Valid,
                      text: viewModel.getCurrentWorker()),
                


                ]
        }
        else{
        
        cellData = [
            .init(title: JobDetailListCell2.CUSTOMER_NAME.rawValue.localize,
                  key: JobDetailListCell2.CUSTOMER_NAME.rawValue,
                  dataType: .Text,//isEditingEnabled ? .ListView : .Text,
                  isRequired: false,
                  isActive: false,//isEditingEnabled ,
                  keyboardType: .default,
                  validation: viewModel.validateCustomer(),
                  text: viewModel.getCustomer() != nil ? viewModel.getCustomer() : /*((viewModel.getCustomers().count > 0) ? viewModel.getCustomers().first : */""),
                  //listData: viewModel.getCustomers()),

            
            .init(title: JobDetailListCell.SHORT_DESCRIPTION.rawValue.localize,
                  key: JobDetailListCell.SHORT_DESCRIPTION.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: false,//isEditingEnabled ,
                  keyboardType: .default,
                  validation: viewModel.validatejobShortDescription(),
                  text: viewModel.getJobShortDescription() != nil ? viewModel.getJobShortDescription() : /*((viewModel.getWorkers().count > 0) ? viewModel.getWorkers().first : */""),
            
            .init(title: JobDetailListCell.DETAILS.rawValue.localize,
                  key: JobDetailListCell.DETAILS.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: viewModel.validatejobDetails(),
                  text: viewModel.getDetails()),

            .init(title: JobDetailListCell.ATTACHMENTS.rawValue.localize,
                  key: JobDetailListCell.ATTACHMENTS.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: ""),
            
            .init(title: JobDetailListCell.LINE_ITEM.rawValue.localize,
                  key: JobDetailListCell.LINE_ITEM.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: ""),


//            .init(title: JobDetailListCell.ENTERED_BY.rawValue.localize,
//                  key: JobDetailListCell.ENTERED_BY.rawValue,
//                  dataType: .Text,
//                  isRequired: false,
//                  isActive: false,//isEditingEnabled ,
//                  keyboardType: .default,
//                  validation: .Valid,
//                  text: viewModel.getWorker()),
//            .init(title: JobDetailListCell.ENTERED_DATE_TIME.rawValue.localize,
//                  key: JobDetailListCell.ENTERED_DATE_TIME.rawValue,
//                  dataType: .Date,
//                  isRequired: false,
//                  isActive: false,//isEditingEnabled,
//                  validation: .Valid,
//                  text: /*isEditingEnabled ? "" : */viewModel.getCreatedDate()),
            
        ]
            
        }
    }
    
    override func getCell(at indexPath: IndexPath) -> BaseFormCell {
        if let cellType = JobDetailListCell2(rawValue:  cellData[indexPath.row].key) , cellType == .CUSTOMER_NAME  || cellType == .SHORT_DESCRIPTION{

            guard let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.ID) as? TextFieldCell else {
                 return BaseFormCell()
            }
            cell.bindTextField(data: cellData[indexPath.row])
            cell.hideListAddButton()
            cell.delegate = self
            cell.listDelegate = self
            return cell
        }
        
        guard let cellType = JobDetailListCell(rawValue:  cellData[indexPath.row].key) else {
            return BaseFormCell()
        }
        if cellType == .ATTACHMENTS {
            return instantiateAttachmentCell()
        }
        else if let cellType = JobDetailListCell(rawValue:  cellData[indexPath.row].key), cellType == .LINE_ITEM {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DataTableViewCell.ID) as? DataTableViewCell else {
                return BaseFormCell()
            }
            
            cell.setAddButtonTitle(title: "ADD".localize)
            cell.bindData(stockData: viewModel.getLineItems(),
                          fields: detailTableHeader,
                          canAddValue: false/*isEditingEnabled*/,
                          data: .init(key: JobDetailListCell.LINE_ITEM.rawValue))
            
            cell.setGearIcon(isAailable: isEditingEnabled)
            cell.delegate = self
            return cell
        }

        else if cellType == .DETAILS {
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
        viewModel.addJobDetail { (error, isValidData) in
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


extension CreateJobDetailView: TextFieldCellDelegate {
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        guard let cell = JobDetailListCell(rawValue: data.key) else {
            return
        }
        switch cell {

        case .SHORT_DESCRIPTION:
            viewModel.setJobShortDescription(description: text)
            break
        case .LINE_ITEM,.ENTERED_BY,.ATTACHMENTS:
            break
        case .DETAILS:
            viewModel.setDetails(detail: text)
            break

        case .ENTERED_DATE_TIME:
            viewModel.setCreatedDate(date: text)
        }
    }
}


extension CreateJobDetailView: TextFieldListDelegate {
    
    func willAddItem(data: TextFieldCellData) {
        guard let cell = JobDetailListCell2(rawValue: data.key) else {
            return
        }
        switch cell {
        case .CUSTOMER_NAME:break
//            openCreateVendor()
        case .JOB_TITLE:
            break
        case .SHORT_DESCRIPTION:break
//            openCreateVendor()
        }
    }
    
    func didChooseItem(at row: Int?, data: TextFieldCellData) {
        guard let cell = JobDetailListCell2(rawValue: data.key) else {
            return
        }
        switch cell {
        case .CUSTOMER_NAME:
            DispatchQueue.main.async { [unowned self] in
                self.viewModel.setCustomer(at: row)
                data.text = viewModel.getCustomer()
//                self.viewModel.resetJob()
                self.getJobs()
                self.tableView.reloadData()
            }
            break
        case .JOB_TITLE:
            DispatchQueue.main.async { [unowned self] in
                self.viewModel.setJobDetail(at: row)
                print("JT",viewModel.getJobTitle()!)
                data.text = viewModel.getJobTitle()
                self.tableView.reloadData()
            }
            break
        case .SHORT_DESCRIPTION:
            DispatchQueue.main.async { [unowned self] in
                self.viewModel.setJobs(at: row)
                data.text = viewModel.getJobShortDescription2()
                self.tableView.reloadData()
            }
            break
        }
    }
}

extension CreateJobDetailView: DataTableViewCellDelegate {
    func willAddItem(data: DataTableData) {
//        showAddLineItem()
    }
    
    func didTapOnItem(at indexPath: IndexPath,dataTable: SwiftDataTable, data: DataTableData) {
        if !isEditingEnabled {
            return
        }
        
        guard let lineItem = viewModel.getLineItem(at: indexPath.section) else { return }
        let isItemRemoved = lineItem.removed ?? false
//        let removeTitle = isItemRemoved ? "UNDELETE".localize : "DELETE".localize
        let actionSheet = GlobalFunction.showViewAndEditActionSheet { [weak self] (_) in
            guard let self = self else { return }
//            self.showAddLineItem(item: lineItem, isEditingEnabled: false)
            
        } editHandler: { [weak self] (_) in
            guard let self = self else { return }
//            self.showAddLineItem(item: lineItem)
            
            
        }/* deleteHandler: { [weak self] (_) in
            guard let self = self else { return }
            /*
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
            }*/
            self.tableView.reloadData()
            
        }*/
        if let cell = dataTable.collectionView.cellForItem(at: indexPath) {
            presentAlert(alert: actionSheet, sourceView: cell)
        }
    
    }
    
    func fetchMoreData(data: DataTableData) {
        getLineItems(isReload: false)
    }
}


