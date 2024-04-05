//
//  TimeOffListView.swift
//  MyProHelper
//
//  Created by Macbook pro on 16/03/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit


enum TimeOffApprovalField: String {
  
    case WORKER_NAME             = "Worker Name"
    case DESCRIPTION             = "Description"
    case START_DATE              = "Start Date"
    case END_DATE                = "End Date"
    case TYPEOF_LEAVE            = "Type Of Leave"
    case STATUS                  = "Status"
    case REMARK                  = "Remarks"
    case REQUESTED_DATE          = "Requested Date"
    case APPROVER_NAME           = "Approved By"
    case APPROVED_DATE           = "Approved Date"
    
}

class TimeOffListView: BaseDataTableView<Approval, TimeOffApprovalField>, Storyboarded,ClassBDelegate,BDelegate, RDelegate {
    func rejectFunction(isConfirmed: Bool) {
        print("Okkk")
    }
    
    
    private var isshowNavTitle: UIBarButtonItem?
    var isShowingTitle = false
    
    func rejectFunction() {
        viewModel.isShowingRemoved = false
         viewModel.reloadData()
    }
    
    func approveFunction() {
        viewModel.isShowingRemoved = false
         viewModel.reloadData()
    }
    
    
    
    func dummyFunction() {
        viewModel.isShowingRemoved = true
        viewModel.reloadData()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = TimeOffListViewModel(delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.addShowRemovedButton()
        title = "Time Off Approvals"
//        self.showNavTitle()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isShowingTitle = true
    }
    
    func showNavTitle() {
        isshowNavTitle = UIBarButtonItem(image: nil,
                                         style: .plain,
                                         target: nil,
                                         action: nil)
        navigationItem.leftBarButtonItems?.append(isshowNavTitle!)
        setupShowButtonTitle()
    }
    
    private func setupShowButtonTitle() {
        if isShowingTitle {
            isshowNavTitle?.title = ""
        }
        else {
            isshowNavTitle?.title = "Time Off Approvals"
        }
    }
    
    
    @objc override func handleAddItem() {
    let createWorker = AddTimeOffApprovalView.instantiate(storyboard: .ADD_TIMEOFF)
        createWorker.coddelegate = self
        self.present(createWorker, animated: true, completion: nil)
    }

    override func setDataTableFields() {
        dataTableFields = [
            .WORKER_NAME,
            .DESCRIPTION,
            .START_DATE,
            .END_DATE,
            .TYPEOF_LEAVE,
            .STATUS,
            .REMARK,
            .REQUESTED_DATE,
            .APPROVER_NAME,
            .APPROVED_DATE
            
        ]
    }
    
    override func getHeader(for columnIndex: NSInteger) -> String {
        return dataTableFields[columnIndex].rawValue.localize
    }

    
    override func setMoreAction(at indexPath: IndexPath) -> [UIAlertAction] {
        let addPurchaseAction      = UIAlertAction(title: "Approve", style: .default) { [unowned self] (action) in
            self.ApprovelAction(for: indexPath.section, with: .APPROVE)
        }
        let removePurchaseAction   = UIAlertAction(title: "Reject", style: .default) { [unowned self] (action) in
            self.RejectionAction(for: indexPath.section, with: .REJECT)
        }
       
        return [addPurchaseAction,removePurchaseAction]
    }
    
    
    private func ApprovelAction(for index: Int, with action: ShowApprovelAction) {
        let createTimeOffApprovals = ApproveView.instantiate(storyboard: .APPROVEVIEW)
        let timeOffApprovals = viewModel.getItem(at:index)
       print("awsthi",timeOffApprovals)
     
        createTimeOffApprovals.codedelegate = self
        createTimeOffApprovals.isFromBtnAction = "TimeOffApprovals"
        createTimeOffApprovals.timeOffApproval = timeOffApprovals
        self.present(createTimeOffApprovals, animated: true, completion: nil)
        
        
    }
    private func RejectionAction(for index: Int, with action: ShowApprovelAction) {
        let createTimeOffApprovals = rejectView.instantiate(storyboard: .REJECTVIEW)
        let timeOffApprovals = viewModel.getItem(at:index)
        print("awsthi",timeOffApprovals)

        createTimeOffApprovals.rejectdelegate = self
        createTimeOffApprovals.isFrom = "TimeOffApprovals"
        createTimeOffApprovals.timeOffApproval = timeOffApprovals
        self.present(createTimeOffApprovals, animated: true, completion: nil)
        
        
    }
//    override func showItem(at indexPath: IndexPath) {
//        let createPurchaseOrderView = CreatedPurchaseOrderView.instantiate(storyboard: .PURCHAGEORDERAPPROVALS)
//        let purchaseOrder = viewModel.getItem(at: indexPath.section)
//        createPurchaseOrderView.viewModel = CreatedPurchaseOrderViewModel(attachmentSource: .PURCHASE_ORDER)
//        createPurchaseOrderView.setViewMode(isEditingEnabled: false)
//       // createPurchaseOrderView.viewModel.setPurchaseOrder(purchaseOrder: purchaseOrder)
//        navigationController?.pushViewController(createPurchaseOrderView, animated: true)
//    }
//    override func editItem(at indexPath: IndexPath) {
//
//        let createPurchaseOrderView = CreatedPurchaseOrderView.instantiate(storyboard: .PURCHAGEORDERAPPROVALS)
//        let purchaseOrder = viewModel.getItem(at: indexPath.section)
//        createPurchaseOrderView.viewModel = CreatedPurchaseOrderViewModel(attachmentSource: .PURCHASE_ORDER)
//        createPurchaseOrderView.setViewMode(isEditingEnabled: true)
//       // createPurchaseOrderView.viewModel.setPurchaseOrder(purchaseOrder: purchaseOrder)
//        navigationController?.pushViewController(createPurchaseOrderView, animated: true)
//    }
//
//
//}






    override func showItem(at indexPath: IndexPath) {

        let createWorker = AddTimeShowView.instantiate(storyboard: .ADDTIMEOFF)
        let worker = viewModel.getItem(at: indexPath.section)
        createWorker.workername = (worker.worker?.firstName ?? "")  + " " + (worker.worker?.lastName ?? "")
//        createWorker.startdate = worker.startdate!
//        createWorker.enddate = worker.enddate!
        createWorker.leavetype = worker.typeofleave!
        createWorker.leavestatus = worker.status!
        createWorker.descriptiontext = worker.description!
        createWorker.remark = worker.remark!

        self.present(createWorker, animated: true, completion: nil)
    }

    override func editItem(at indexPath: IndexPath) {

        let createWorker = AddTimeOffApprovalView.instantiate(storyboard: .ADD_TIMEOFF)
        let worker = viewModel.getItem(at: indexPath.section)
        print("hh",worker)
        createWorker.isFromBtnAction = "edit"
        createWorker.coddelegate = self
        createWorker.workername = (worker.worker?.firstName ?? "") + " " + (worker.worker?.lastName ?? "")
//        createWorker.startdate = worker.startdate!
//        createWorker.enddate = worker.enddate!
        createWorker.leavetype = worker.typeofleave!
        createWorker.leavestatus = worker.status!
        createWorker.descriptiontext = worker.description!
        createWorker.remark = worker.remark!
        createWorker.id = worker.workerID ?? 0
        createWorker.timeOffReqID = worker.TimeOffRequestsID ?? 0
        self.present(createWorker, animated: true, completion: nil)

    }

}
