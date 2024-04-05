//
//  WorkOrderListView.swift
//  MyProHelper
//
//  Created by sismac010 on 06/04/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit

enum WorkOrderField: String {
    case WORKER_NAME            = "WORKER_NAME"
    case CUSTOMER_NAME          = "CUSTOMER_NAME"
    case DESCRIPTION            = "DESCRIPTION"
    case TOTAL_AMOUNT           = "TOTAL_AMOUNT"
    case STATUS                 = "STATUS"
    case REMARKS                = "REMARKS"
    case APPROVED_BY            = "APPROVED_BY"
    case APPROVED_DATE          = "APPROVED_DATE"
    case ATTACHMENTS            = "ATTACHMENTS"
}


class WorkOrderListView: BaseDataTableView<WorkOrder, WorkOrderField>, Storyboarded {

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = WorkOrderListViewModel(delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "WORK_ORDERS".localize
        super.addShowRemovedButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        super.hideShowRemovedButton()
    }

    override func setDataTableFields() {
        dataTableFields = [
            .WORKER_NAME,
            .CUSTOMER_NAME,
            .DESCRIPTION,
            .TOTAL_AMOUNT,
            .STATUS,
            .REMARKS,
            .APPROVED_BY,
            .APPROVED_DATE,
            .ATTACHMENTS,
        ]
    }
    
    override func getHeader(for columnIndex: NSInteger) -> String {
        return dataTableFields[columnIndex].rawValue.localize
    }
    
    @objc override func handleAddItem() {
        let createWorkOrderView = CreateWorkOrderView.instantiate(storyboard: .WORK_ORDER)
        createWorkOrderView.viewModel = CreateWorkOrderViewModel(attachmentSource: .WORK_ORDER)
        createWorkOrderView.setViewMode(isEditingEnabled: true)
        navigationController?.pushViewController(createWorkOrderView, animated: true)
    }

    
    override func showItem(at indexPath: IndexPath) {
        let createWorkOrderView = CreateWorkOrderView.instantiate(storyboard: .WORK_ORDER)
        let workOrder = viewModel.getItem(at: indexPath.section)
        createWorkOrderView.viewModel = CreateWorkOrderViewModel(attachmentSource: .WORK_ORDER)
        createWorkOrderView.setViewMode(isEditingEnabled: false)
        createWorkOrderView.viewModel.setWorkOrder(workOrder: workOrder)
        navigationController?.pushViewController(createWorkOrderView, animated: true)
    }
    
    override func editItem(at indexPath: IndexPath) {
        
        let createWorkOrderView = CreateWorkOrderView.instantiate(storyboard: .WORK_ORDER)
        let workOrder = viewModel.getItem(at: indexPath.section)
        createWorkOrderView.viewModel = CreateWorkOrderViewModel(attachmentSource: .WORK_ORDER)
        createWorkOrderView.setViewMode(isEditingEnabled: true)
        createWorkOrderView.viewModel.setWorkOrder(workOrder: workOrder)
        navigationController?.pushViewController(createWorkOrderView, animated: true)
    }

}
