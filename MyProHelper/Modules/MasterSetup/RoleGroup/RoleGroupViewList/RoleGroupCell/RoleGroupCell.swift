//
//  RoleGroupCell.swift
//  MyProHelper
//
//  Created by sismac010 on 29/07/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit
import SwiftDataTables

enum RoleGroupFields: String {
    case GROUP_NAME                         = "GROUP_NAME"
    case ADMIN                              = "ADMIN"
    case COMPANY_SETUP                      = "COMPANY_SETUP"
    case ADD_WORKERS                        = "ADD_WORKERS"
    case ADD_CUSTOMERS                      = "ADD_CUSTOMERS"
    case RUN_PAYROLL                        = "RUN_PAYROLL"
    case SEE_WAGES                          = "SEE_WAGES"
    case SCHEDULE                           = "SCHEDULE"
    case INVENTORY                          = "INVENTORY"
    case RUN_REPORTS                        = "RUN_REPORTS"
    case ADD_REMOVE_INVENTORY_ITEMS         = "ADD_REMOVE_INVENTORY_ITEMS"
    case EDIT_TIME_ALREADY_ENTERED          = "EDIT_TIME_ALREADY_ENTERED"
    case REQUEST_VACATION                   = "REQUEST_VACATION"
    case REQUEST_SICK                       = "REQUEST_SICK"
    case REQUEST_PERSONAL_TIME              = "REQUEST_PERSONAL_TIME"
    case CAN_EDIT_JOB_HISTORY               = "CAN_EDIT_JOB_HISTORY"
    case CAN_SHCEDULE_JOBS                  = "CAN_SHCEDULE_JOBS"
    case CAN_APPROVE_PURCHASE_ORDERS        = "CAN_APPROVE_PURCHASE_ORDERS"
    case CAN_APPROVE_WORK_ORDERS            = "CAN_APPROVE_WORK_ORDERS"
    case CAN_APPROVE_INVOICES               = "CAN_APPROVE_INVOICES"
    case RECEIVE_EMAILS_FOR_REJECTED_JOBS   = "RECEIVE_EMAILS_FOR_REJECTED_JOBS"
    
    
    func stringValue() -> String {
        return self.rawValue.localize
    }
}


class RoleGroupCell: UICollectionViewCell, SwiftDataTableDelegate {

    static let ID = String(describing: RoleGroupCell.self)
    
    @IBOutlet weak private var dataTableContainerView: UIView!
    private var dataTable: SwiftDataTable!
    
    private let dataTableFields: [RoleGroupFields] = [.GROUP_NAME,
                                                      .ADMIN,
                                                      .COMPANY_SETUP,
                                                      .ADD_WORKERS,
                                                      .ADD_CUSTOMERS,
                                                      .RUN_PAYROLL,
                                                      .SEE_WAGES,
//                                                      .SCHEDULE,
                                                      .INVENTORY,
                                                      .RUN_REPORTS,
                                                      .ADD_REMOVE_INVENTORY_ITEMS,
                                                      .EDIT_TIME_ALREADY_ENTERED,
                                                      .REQUEST_VACATION,
                                                      .REQUEST_SICK,
                                                      .REQUEST_PERSONAL_TIME,
                                                      .CAN_EDIT_JOB_HISTORY,
                                                      .CAN_SHCEDULE_JOBS,
                                                      .CAN_APPROVE_PURCHASE_ORDERS,
                                                      .CAN_APPROVE_WORK_ORDERS,
                                                      .CAN_APPROVE_INVOICES,
                                                      .RECEIVE_EMAILS_FOR_REJECTED_JOBS]
    
    private var searchKey: String?
    private var sortType: SortType?
    private var sortField: RoleGroupFields?
    var showViewDelegate: ShowViewDelegate?
    var toShowRemoved = false
    
    var viewModel2: CreateWorkerViewModel? {
        didSet {
            fetchRolesGroup()
        }
    }
    
    var viewModel: CreateWorkerViewModel2? {
        didSet {
            viewModel?.delegate2 = self
            fetchRolesGroup2()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        initializeDataTable()
        setupDataTableLayout()
        self.showSnackbar()
    }

    private func initializeDataTable() {
        var option = DataTableConfiguration()
        option.shouldContentWidthScaleToFillFrame = true
        dataTable = SwiftDataTable(dataSource: self, options: option)
        dataTable.dataSource = self
        dataTable.delegate = self
        dataTable.backgroundColor = UIColor.init(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
    }

    private func setupDataTableLayout() {
        dataTable.translatesAutoresizingMaskIntoConstraints = false
        dataTableContainerView.backgroundColor = UIColor.white
        dataTableContainerView.addSubview(dataTable)
        
        NSLayoutConstraint.activate([
            dataTable.topAnchor.constraint(equalTo: dataTableContainerView.topAnchor),
            dataTable.leadingAnchor.constraint(equalTo: dataTableContainerView.leadingAnchor),
            dataTable.bottomAnchor.constraint(equalTo: dataTableContainerView.bottomAnchor),
            dataTable.trailingAnchor.constraint(equalTo: dataTableContainerView.trailingAnchor),
        ])
    }
    
    private func fetchRolesGroup() {
        guard let viewModel = viewModel2 else { return }
        viewModel.fetchRolesGroup(showRemoved: toShowRemoved,
                                  searchKey: searchKey,
                                  showSelect: false,
                                  completion: { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.dataTable.reload()
            }
        })
        self.showSnackbar()
    }
    
    fileprivate func showSnackbar(){
        DispatchQueue.main.async {
            self.viewModel?.createWorkerViewModel.countRolesGroup() == 0 ? self.dataTable.setEmptyMessage(show: true, message: Constants.Message.No_Data_To_Display) : self.dataTable.setEmptyMessage(show: false, message: "")
        }
    }
    
    private func editGroup(at index: Int) {
        guard let viewModel = viewModel else { return }
        let createRoleGroup = CreateRoleGroup.instantiate(storyboard: .ROLE_GROUP)
        createRoleGroup.isEditingEnabled = true
        createRoleGroup.viewModel.setRolesGroup(group: viewModel.createWorkerViewModel.getRolesGroup(at: index))
        showViewDelegate?.pushView(view: createRoleGroup)
    }
    
    private func showGroup(at index: Int) {
        guard let viewModel = viewModel else { return }
        let createRoleGroup = CreateRoleGroup.instantiate(storyboard: .ROLE_GROUP)
        createRoleGroup.isEditingEnabled = false
        createRoleGroup.viewModel.setRolesGroup(group: viewModel.createWorkerViewModel.getRolesGroup(at: index))
        showViewDelegate?.pushView(view: createRoleGroup)
    }
    
    private func deleteGroup(at index: Int) {
        guard let viewModel = viewModel else { return }
        let deleteTitle = "DELETE_ROLE_GROUP_TITLE".localize
        let deleteMessage = "DELETE_ROLE_GROUP_MESSAGE".localize
        let deleteAlert = GlobalFunction.showDeleteAlert(title: deleteTitle, message: deleteMessage) {
            viewModel.createWorkerViewModel.deleteRolesGroupAt(at: index) { [weak self] in
                guard let self = self else { return }
                self.fetchRolesGroup()
            }
        }
        
        if viewModel.createWorkerViewModel.isRolesGroupRemoved(at: index) {
            viewModel.createWorkerViewModel.restoreRolesGroupAt(at: index) { [weak self] in
                guard let self = self else { return }
                self.fetchRolesGroup()
            }
        }
        else {
            showViewDelegate?.presentView(view: deleteAlert, completion: { })
        }
    }
    
    private func getHeader(for columnIndex: NSInteger) -> String {
        return dataTableFields[columnIndex].stringValue()
    }

    private func createData(at index: NSInteger) -> [DataTableValueType] {
        guard let viewModel = viewModel else { return [] }
        let device = ["⚙️"] + viewModel.createWorkerViewModel.getRolesGroup(at: index).getDataArray()
        return device.compactMap(DataTableValueType.init)
    }
    
    
    //MARK: - Implement data table delegate methods
    func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        guard let showViewDelegate = showViewDelegate else { return }
        let removeTitle = (viewModel.createWorkerViewModel.isRolesGroupRemoved(at: indexPath.section)) ? "UNDELETE".localize : "DELETE".localize
        
        let actionSheet = GlobalFunction.showListActionSheet(deleteTitle: removeTitle) { [weak self] (showAction) in
            guard let self = self else { return }
            self.showGroup(at: indexPath.section)
        }
        editHandler: { [weak self] (editAction) in
            guard let self = self else { return }
            self.editGroup(at: indexPath.section)
        }
        deleteHandler: { [weak self] (deleteAction) in
            guard let self = self else { return }
            self.deleteGroup(at: indexPath.section)
        }
        if let cell = dataTable.collectionView.cellForItem(at: indexPath) {
            showViewDelegate.showAlert?(alert: actionSheet, sourceView: cell)
        }

    }
    
    func didSearchForKey(_ dataTable: SwiftDataTable, Key: String) {
        searchKey = Key
        //fetchRolesGroup()
        fetchRolesGroup2()
    }
    
//    func willShowLastElement(_ collectionView: UICollectionView, indexPath: IndexPath) {
////        fetchMoreDevices()
//        fetchMoreRolesGroup()
//    }
//
    func heightForSectionFooter(in dataTable: SwiftDataTable) -> CGFloat {
        return 0
    }
    
    func fixedColumns(for dataTable: SwiftDataTable) -> DataTableFixedColumnType {
        return DataTableFixedColumnType.init(leftColumns: 1)
    }

}

extension RoleGroupCell: CreateWorkerViewModel2Delegate{
   
    func fetchRolesGroup2() {
        guard let viewModel = viewModel else { return }
        viewModel.FetchList(reloadData: true,
                            showRemoved: toShowRemoved,
                            searchKey: searchKey,
                            showSelect: false,
                            completion: { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.dataTable.reload()
            }
        })
        
        self.showSnackbar()
    }
    
    func fetchMoreRolesGroup() {
        guard let viewModel = viewModel else { return }
        viewModel.FetchList(reloadData: false,
                            showRemoved: toShowRemoved,
                            searchKey: searchKey,
                            showSelect: false,
                            completion: { [weak self] in
              DispatchQueue.main.async { [weak self] in
                  guard let self = self else { return }
                  self.dataTable.reload()
              }
          })
        
        self.showSnackbar()
    }
    
}




//MARK: - Swift data source methods
extension RoleGroupCell: SwiftDataTableDataSource {

    func numberOfColumns(in: SwiftDataTable) -> Int {
        if viewModel?.createWorkerViewModel.countRolesGroup() == 0 {
            return 0
        } else {
            return dataTableFields.count + 1
        }
    }

    func numberOfRows(in: SwiftDataTable) -> Int {
        return viewModel?.createWorkerViewModel.countRolesGroup() ?? 0
    }

    func dataTable(_ dataTable: SwiftDataTable, dataForRowAt index: NSInteger) -> [DataTableValueType] {
        return createData(at: index)
    }

    func dataTable(_ dataTable: SwiftDataTable, headerTitleForColumnAt columnIndex: NSInteger) -> String {
        if columnIndex == 0 {
            return "ACTION".localize
        }
        return getHeader(for: columnIndex - 1)
    }

    func didTapSort(_ dataTable: SwiftDataTable, type: DataTableSortType, column: Int) {
        sortType  = (type == DataTableSortType.ascending) ? .ASCENDING : .DESCENDING
        sortField = dataTableFields[column - 1]
        fetchRolesGroup()
        
    }
    
    
    func willShowLastElement(_ collectionView: UICollectionView, indexPath: IndexPath) {
//        fetchMoreDevices()
        fetchMoreRolesGroup()
    }
}
