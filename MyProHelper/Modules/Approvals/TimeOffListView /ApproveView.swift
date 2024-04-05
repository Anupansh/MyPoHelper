//
//  ApproveView.swift
//  MyProHelper
//
//  Created by Sarvesh on 07/04/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import UIKit
protocol BDelegate {
    func approveFunction()
    
}
class ApproveView: UIViewController,Storyboarded {
    
    // MARK: - OUTLETS AND VARIABLES
    @IBOutlet weak var showView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var approveViewHeight: NSLayoutConstraint!
    @IBOutlet weak var showRemarkLbl: UILabel!
    @IBOutlet weak var remarkView: UIView!
    @IBOutlet weak var backgroundViewContainer: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var DiscardButton: UIButton!
    @IBOutlet weak var SaveButton: UIButton!
    @IBOutlet weak var remarksNamelbl: UILabel!
    @IBOutlet weak var remarksTextField: UITextField!
    @IBOutlet weak var expectedDateTf: UITextField!
    @IBOutlet weak var orderedDateTf: UITextField!
    
    let timeOffApprovalservice = TimeOffApprovalService()
    var purchaseOrder = PurchaseOrder()
    var invoice = Invoice()
    var timeOffApproval = Approval()
    var codedelegate: BDelegate!
    var invoiceOrder = InvoiceRepository()
    let expenseOrderService = ExpenseOrderService()
    let purchaseOrderService = PurchaseOrderService()
    let InvoiceOrderService = InvoiceService()
    let workOrderService = WorkOrderService()
    var expenseOrder = ExpenseStatements()
    var selectedWorker: Worker!
    var workersPickerDataSource: [Worker] = []
    var workername = String()
    var startdate = Date()
    var enddate = Date()
    var leavetype = String()
    var leavestatus = String()
    var descriptiontext = String()
    var remark = String()
    var workerID = Int()
    var isFromBtnAction = ""
    var timeOffReqID = 0
    var isFromWorkOrderApproval = ""
    var workOrder = WorkOrder()
    var orderDatePicker = UIDatePicker()
    var expectedDatePicker = UIDatePicker()
    
    // MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
     
    // MARK: - HELPER FUNCTIONS
    func initialSetup() {
        setupTapGesture()
        setupExpectedDatePicker()
        setupOrderedDatePicker()
        backgroundViewContainer.cornerRadius = 15
        if isFromBtnAction == "PurchaseOrderApprovals" {
            remarksNamelbl.text = "Approve Purchase Order"
            showRemarkLbl.text = "Are you sure,do you want to approve?"
            remarkView.isHidden = false
            showView.isHidden = false
            bottomView.isHidden = false
            containerViewHeightConstraint.constant = 404
        }
        else if isFromWorkOrderApproval == "WorkOrderListCreatedView" {
            remarksNamelbl.text = " Approve Work Order"
            bottomView.isHidden = true
            containerViewHeightConstraint.constant = 254
        }
        else if isFromBtnAction == "ExpenseStatementApprovals" {
            remarksNamelbl.text = "Approve Expense Statements"
            bottomView.isHidden = true
            containerViewHeightConstraint.constant = 254
        }
        else if isFromBtnAction == "InvoiceListApprovals" {
            remarksNamelbl.text = "Approve Invoice"
            showRemarkLbl.text = "Are you sure,do you want to approve?"
            remarkView.isHidden = false
            showView.isHidden = false
            bottomView.isHidden = true
            containerViewHeightConstraint.constant = 254
        }
        else {
            remarksNamelbl.text = "Approve Time-Off"
            bottomView.isHidden = true
            containerViewHeightConstraint.constant = 254
        }
    }
    
    func setupExpectedDatePicker() {
        expectedDateTf.text = DateManager.dateToString(date: purchaseOrder.expectedDate)
        let screenWidth = UIScreen.main.bounds.width
        expectedDatePicker = UIDatePicker.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 200))
        expectedDatePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {expectedDatePicker.preferredDatePickerStyle = .wheels}
        expectedDateTf.inputView = expectedDatePicker
        let toolbar = UIToolbar(frame: CGRect(x: 200, y: 0, width: screenWidth, height: 44))
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(expectedDateDonePressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPressed))
        toolbar.setItems([cancelButton,spaceButton,doneBtn], animated: true)
        expectedDateTf.inputAccessoryView = toolbar
    }
    
    func setupOrderedDatePicker() {
        orderedDateTf.text = DateManager.dateToString(date: purchaseOrder.orderedDate)
        let screenWidth = UIScreen.main.bounds.width
        orderDatePicker = UIDatePicker.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 200))
        orderDatePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {orderDatePicker.preferredDatePickerStyle = .wheels}
        orderedDateTf.inputView = orderDatePicker
        let toolbar = UIToolbar(frame: CGRect(x: 200, y: 0, width: screenWidth, height: 44))
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(orderedDateDonePressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPressed))
        toolbar.setItems([cancelButton,spaceButton,doneBtn], animated: true)
        orderedDateTf.inputAccessoryView = toolbar
    }
    
    @objc func expectedDateDonePressed() {
        expectedDateTf.text = DateManager.getStandardDateString(date: expectedDatePicker.date)
        purchaseOrder.expectedDate = expectedDatePicker.date
        self.view.endEditing(true)
    }
    
    @objc func orderedDateDonePressed() {
        orderedDateTf.text = DateManager.getStandardDateString(date: orderDatePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelPressed() {
        self.view.endEditing(true)
    }
        
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDismissView))
        backgroundViewContainer.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleDismissView() {
        dismiss(animated: true, completion: nil)
        //self.viewModel.fetchMoreData()
    }
    
    // MARK: - IBACTIONS
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        handleDismissView()
    }
    
    @IBAction func saveAction(_sender :UIButton){
        if isFromBtnAction == "PurchaseOrderApprovals" {
            savePurchaseOrderApproval()
        }
        else if isFromWorkOrderApproval == "WorkOrderListCreatedView" {
            saveWorkOrderApproval()
        }
        else if isFromBtnAction == "InvoiceListApprovals" {
           saveInvoiceApproval()
        }
        else if isFromBtnAction == "ExpenseStatementApprovals" {
            saveExpenseStatementApproval()
        }
        else {
           saveTimeOffApproval()
        }
    }
    
    // MARK: - SAVING DATA
    func saveTimeOffApproval() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        var approvaldata = Approval()
        approvaldata.approvedby = AppLocals.worker.workerID
        approvaldata.approveddate = Date()
        approvaldata.workerID = timeOffApproval.workerID
        approvaldata.workername = timeOffApproval.workername
        approvaldata.worker = selectedWorker
        approvaldata.startdate = timeOffApproval.startdate
        approvaldata.endDate = timeOffApproval.endDate
        approvaldata.typeofleave = timeOffApproval.typeofleave
        approvaldata.status = "Approved"
        approvaldata.description = timeOffApproval.description
        approvaldata.remark = remarksTextField.text
        approvaldata.requesteddate = Date()
        approvaldata.removed = timeOffApproval.removed
        approvaldata.TimeOffRequestsID = timeOffApproval.TimeOffRequestsID
        approvaldata.removedDate = timeOffApproval.removedDate
        timeOffApprovalservice.updateApproval(approvaldata, completion: { [weak self] (result) in
            guard self != nil else { return }
            switch result {
            case .success(_):
                self!.codedelegate.approveFunction()
                self!.handleDismissView()
            print("sucees while Fetching Workers")
            
            case .failure( _):
                self!.handleDismissView()
                print("ERROR while Fetching Workers")
            }
        })
    }

    func saveInvoiceApproval() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        var workOrd = Invoice()
        workOrd.invoiceID = invoice.invoiceID
        workOrd.customerID = invoice.customerID
        workOrd.jobID = invoice.jobID
        workOrd.description = invoice.description
        workOrd.priceQuoted = invoice.priceQuoted
        workOrd.priceEstimate = invoice.priceEstimate
        workOrd.priceFixedPrice = invoice.priceFixedPrice
        workOrd.invoiceAdjustement = invoice.invoiceAdjustement
        workOrd.percentDiscount = invoice.percentDiscount
        workOrd.totalInvoiceAmount = invoice.totalInvoiceAmount
        workOrd.dateCompleted = Date()
        workOrd.dateCreated = Date()
        workOrd.dateModified = invoice.dateModified
        workOrd.status = "Approved"
        workOrd.Remarks = remarksTextField.text ?? ""
        workOrd.priceExpires = invoice.priceExpires
        workOrd.isInvoiceCreated =  invoice.isInvoiceCreated
        workOrd.isInvoiceFinal = invoice.isInvoiceFinal
        workOrd.dateApproved = Date()
        workOrd.ApprovedBy = AppLocals.worker.workerID
        workOrd.sampleInvoice = invoice.sampleInvoice
        workOrd.removed = invoice.removed
        workOrd.removedDate = invoice.removedDate
        workOrd.numberOfAttachments = invoice.numberOfAttachments
        InvoiceOrderService.updateInvoice(invoice: workOrd, completion:  { [weak self] (result) in
            guard self != nil else { return }
            switch result {
            case .success(_):
                self!.codedelegate.approveFunction()
                self!.handleDismissView()
                print("sucees while Fetching Workers")
            case .failure( _):
                self!.handleDismissView()
                print("ERROR while Fetching Workers")
            }
        })
    }
    
    func saveWorkOrderApproval() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        var workOrd = WorkOrder()
        workOrd.workOrderId = workOrder.workOrderId
        workOrd.workerId = workOrder.workerId
        workOrd.dateApproved = Date()
        workOrd.approvedBy = AppLocals.worker.workerID
        workOrd.customerId = workOrder.customerId
        workOrd.dateCreated = workOrder.dateCreated
        workOrd.dateModified = workOrder.dateModified
        workOrd.description = workOrder.description
        workOrd.sampleWorkOrder = 0
        workOrd.numberOfAttachments = workOrder.numberOfAttachments
        workOrd.status = "Approved"
        workOrd.remarks = remarksTextField.text
        workOrd.removed = workOrder.removed
        workOrd.dateModified = Date()
        workOrderService.updateWorkOrder(workOrder: workOrd, completion: { [weak self] (result) in
            guard self != nil else { return }
            switch result {
            case .success(_):
                self!.codedelegate.approveFunction()
                self!.handleDismissView()
                print("sucees while Fetching Workers")
            case .failure( _):
                self!.handleDismissView()
                print("ERROR while Fetching Workers")
            }
       })
    }
    
    func savePurchaseOrderApproval() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        var workOrd = PurchaseOrder()
        workOrd.purchaseOrderId = purchaseOrder.purchaseOrderId
        workOrd.salesTax = purchaseOrder.salesTax
        workOrd.shipping = purchaseOrder.shipping
        workOrd.enteredDate = purchaseOrder.enteredDate
        workOrd.orderedDate = purchaseOrder.orderedDate
        workOrd.expectedDate =  purchaseOrder.expectedDate
        workOrd.approvedBy = AppLocals.worker.workerID
        workOrd.dateApproved = Date()
        workOrd.vendorId = purchaseOrder.vendorId
        workOrd.samplePurchaseOrder = 0
        workOrd.dateReceived = purchaseOrder.dateReceived
        workOrd.numberOfAttachments = purchaseOrder.numberOfAttachments
        workOrd.status = "Approved"
        workOrd.remarks = remarksTextField.text
        workOrd.removed = purchaseOrder.removed
        workOrd.removedDate = purchaseOrder.removedDate
        purchaseOrderService.updatePurchaseOrder(purchaseOrder: workOrd, completion:
        { [weak self] (result) in
           guard self != nil else { return }
           switch result {
           case .success(_):
            self!.codedelegate.approveFunction()
               self!.handleDismissView()
               print("sucees while Fetching Workers")
           case .failure( _):
               self!.handleDismissView()
               print("ERROR while Fetching Workers")
           }
       })
    }
    
    func saveExpenseStatementApproval() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        var workOrd = ExpenseStatements()
        workOrd.expenseStatementsId = expenseOrder.expenseStatementsId
        workOrd.workerId = expenseOrder.workerId
        workOrd.customerId = expenseOrder.customerId
        workOrd.salesTax = expenseOrder.salesTax
        workOrd.shipping = expenseOrder.shipping
        workOrd.description = expenseOrder.description
        workOrd.status = "Approved"
        workOrd.remarks = remarksTextField.text
        workOrd.dateCreated = workOrder.dateCreated
        workOrd.dateApproved = Date()
        workOrd.approvedBy = AppLocals.worker.workerID
        workOrd.dateModified = expenseOrder.dateModified
        workOrd.sampleExpenseStatement = expenseOrder.sampleExpenseStatement
        workOrd.removed = expenseOrder.removed
        workOrd.removedDate = expenseOrder.removedDate
        workOrd.numberOfAttachments = expenseOrder.numberOfAttachments
        expenseOrderService.updateExpenseOrder(expenseStatements:  workOrd, completion: { [weak self] (result) in
            guard self != nil else { return }
            switch result {
            case .success(_):
                self!.codedelegate.approveFunction()
                self!.handleDismissView()
                print("sucees while Fetching Workers")
                
            case .failure( _):
                self!.handleDismissView()
                print("ERROR while Fetching Workers")
            }
       })
    }
}
