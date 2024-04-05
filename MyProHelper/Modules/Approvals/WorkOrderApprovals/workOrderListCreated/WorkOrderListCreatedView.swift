//
//  WorkOrderListCreatedView.swift
//  MyProHelper
//
//  Created by Pooja Mishra on 01/04/1943 Saka.
//  Copyright © 1943 Benchmark Computing. All rights reserved.
//

import UIKit

enum WorkOrderField2: String {
    
    case WORKER_NAME            = "Worker Name"
    case CUSTOMER_NAME          = "Customer Name"
    case DESCRIPTION            = "DESCRIPTION"
    case TOTAL_AMOUNT           = "Total Amount"
    case STATUS                 = "STATUS"
    case REMARKS                = "Remarks"
    case APPROVED_BY            = "Approved By"
    case APPROVED_DATE          = "Approved Date"
    case ATTACHMENTS            = "ATTACHMENTS"
}

class WorkOrderListCreatedView: BaseDataTableView<WorkOrder, WorkOrderField2>, Storyboarded, ClassBDelegate, RDelegate, BDelegate {
    
    func rejectFunction(isConfirmed: Bool) {
        print(isConfirmed)
    }
    
    
    private var isshowNavTitle: UIBarButtonItem?
    var isShowingTitle = false
    
    func dummyFunction() {
        viewModel.isShowingRemoved = true
        viewModel.reloadData()
    }
    
    
    func rejectFunction() {
        viewModel.isShowingRemoved = false
         viewModel.reloadData()
    }
    
    func approveFunction() {
        viewModel.isShowingRemoved = false
         viewModel.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = WorkOrderCreatedViewModel(delegate: self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.addShowRemovedButton()
        self.showNavTitle()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        super.hideShowRemovedButton()
        self.isShowingTitle = true
    }
    
    func showNavTitle() {
        isshowNavTitle = UIBarButtonItem(image: nil,
                                         style: .plain,
                                         target: nil,
                                         action: nil)
        navigationItem.leftBarButtonItems?.append(isshowNavTitle!)
        title = "Work Order Approvals"
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
        let createWorkOrderView = CreatedWorkOrderView.instantiate(storyboard: .WORKORDERAPPROVALS)
        createWorkOrderView.viewModel = CreatedViewOrderViewModel(attachmentSource: .WORK_ORDER)
        createWorkOrderView.setViewMode(isEditingEnabled: true)
        navigationController?.pushViewController(createWorkOrderView, animated: true)
    }

    private func ApprovelAction(for index: Int, with action: ShowApprovelAction) {
        let createWorker = ApproveView.instantiate(storyboard: .APPROVEVIEW)
        let worker = viewModel.getItem(at:index)
       print("awsthi",worker)
        createWorker.workername = (worker.worker?.firstName ?? "") + (worker.worker?.lastName ?? "")
        createWorker.codedelegate = self
        createWorker.isFromWorkOrderApproval = "WorkOrderListCreatedView"
        createWorker.workOrder = worker
        self.present(createWorker, animated: true, completion: nil)
        
        
    }
    private func RejectionAction(for index: Int, with action: ShowApprovelAction) {
        let createWorker = rejectView.instantiate(storyboard: .REJECTVIEW)
        let worker = viewModel.getItem(at:index)
        print("awsthi",worker)
        createWorker.rejectdelegate = self
        createWorker.isFrom = "WorkOrderListCreatedView"
        createWorker.workOrder = worker
        self.present(createWorker, animated: true, completion: nil)
        
        
    }
    override func setMoreAction(at indexPath: IndexPath) -> [UIAlertAction] {
        let addWorkOrderAction      = UIAlertAction(title: "Approve", style: .default) { [unowned self] (action) in
            self.ApprovelAction(for: indexPath.section, with: .APPROVE)
        }
        let removeWorkOrderAction  = UIAlertAction(title: "Reject", style: .default) { [unowned self] (action) in
            self.RejectionAction(for: indexPath.section, with: .REJECT)
        }
       
        return [addWorkOrderAction,removeWorkOrderAction]
    }
    
    
    override func showItem(at indexPath: IndexPath) {
        let createWorkOrderView = CreatedWorkOrderView.instantiate(storyboard: .WORKORDERAPPROVALS)
        let workOrder = viewModel.getItem(at: indexPath.section)
        createWorkOrderView.viewModel = CreatedViewOrderViewModel(attachmentSource: .WORK_ORDER)
        createWorkOrderView.setViewMode(isEditingEnabled: false)
        createWorkOrderView.viewModel.setWorkOrder(workOrder: workOrder)
        navigationController?.pushViewController(createWorkOrderView, animated: true)
    }
    
    override func editItem(at indexPath: IndexPath) {
        
        let createWorkOrderView = CreatedWorkOrderView.instantiate(storyboard: .WORKORDERAPPROVALS)
        let workOrder = viewModel.getItem(at: indexPath.section)
        createWorkOrderView.viewModel = CreatedViewOrderViewModel(attachmentSource: .WORK_ORDER)
        createWorkOrderView.setViewMode(isEditingEnabled: true)
        createWorkOrderView.viewModel.setWorkOrder(workOrder: workOrder)
        navigationController?.pushViewController(createWorkOrderView, animated: true)
    }

}
