import Foundation
import UIKit

protocol RDelegate {
    func rejectFunction()
}

class rejectView: UIViewController,Storyboarded {
    
    // MARK: - OUTLETS AND VARIABLES
    @IBOutlet weak var showView: UIView!
    @IBOutlet weak var showViewLbl: UILabel!
    @IBOutlet weak var remarkView: UIView!
    @IBOutlet weak var backgroundViewContainer: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var rejectNameLbl: UILabel!
    @IBOutlet weak var DiscardButton: UIButton!
    @IBOutlet weak var SaveButton: UIButton!
    @IBOutlet weak var remarksTextField: UITextField!
    
    var rejectdelegate: RDelegate!
    var isFrom = ""
    var purchaseOrder = PurchaseOrder()
    var workOrder = WorkOrder()
    var expenseOrder = ExpenseStatements()
    var invoice = Invoice()
    var timeOffApproval = Approval()
    var invoiceOrder = InvoiceRepository()
    let timeOffApprovalservice = TimeOffApprovalService()
    let workOrderService = WorkOrderService()
    let InvoiceOrderService = InvoiceService()
    let purchaseOrderService = PurchaseOrderService()
    let expenseOrderService = ExpenseOrderService()
    
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
    var timeOffReqID = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    func initialSetup() {
        setupTapGesture()
        backgroundViewContainer.cornerRadius = 15
        if isFrom == "PurchaseOrderApprovals" {
            rejectNameLbl.text = "Reject Purchase Order"
            showViewLbl.text = "Are you sure,do you want to approve?"
            remarkView.isHidden = false
            showView.isHidden = false
        }
        else if isFrom == "WorkOrderListCreatedView" {
            rejectNameLbl.text = "Reject Work Order"
        }
        else if isFrom == "ExpenseStatementApprovals" {
                rejectNameLbl.text = "Reject Expense Statement Confirmation"
        }
        else if isFrom == "InvoiceListApprovals" {
                rejectNameLbl.text = "Reject Invoice"
                showViewLbl.text = "Are you sure,do you want to approve?"
                remarkView.isHidden = false
                showView.isHidden = false
        }
        else {
            rejectNameLbl.text = "Reject Time-Off "
        }
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDismissView))
        backgroundViewContainer.addGestureRecognizer(tapGesture)
    }
    @objc private func handleDismissView() {
        dismiss(animated: true, completion: nil)
        //self.viewModel.fetchMoreData()
    
    }
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        handleDismissView()
    }
    @IBAction func saveAction(_sender :UIButton){
            if isFrom == "WorkOrderListCreatedView" {
                saveWorkOrderApproval()
            }
            else if isFrom == "PurchaseOrderApprovals" {
                savePurchaseOrderApproval()
            }
            else if isFrom == "InvoiceListApprovals" {
                saveInvoiceApproval()
            }
            else if isFrom == "ExpenseStatementApprovals" {
                saveExpenseStatmentApproval()
            }
            else {
                saveTimeOffApproval()
            }
             
        }
    
    
    // MARK: SAVE DATA
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
        approvaldata.status = "Rejected"
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
                self!.rejectdelegate.rejectFunction()
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
        workOrd.status = "Rejected"
        workOrd.Remarks = remarksTextField.text ?? ""
        workOrd.priceExpires = invoice.priceExpires
        workOrd.isInvoiceCreated =  invoice.isInvoiceCreated
        workOrd.isInvoiceFinal = invoice.isInvoiceFinal
        workOrd.dateApproved = Date()
        workOrd.ApprovedBy = invoice.ApprovedBy
        workOrd.sampleInvoice = invoice.sampleInvoice
        workOrd.removed = invoice.removed
        workOrd.removedDate = invoice.removedDate
        workOrd.numberOfAttachments = invoice.numberOfAttachments
        InvoiceOrderService.updateInvoice(invoice: workOrd, completion:  { [weak self] (result) in
            guard self != nil else { return }
            switch result {
            case .success(_):
                self!.rejectdelegate.rejectFunction()
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
            workOrd.approvedBy = workOrder.approvedBy
            workOrd.customerId = workOrder.customerId
            workOrd.dateCreated = workOrder.dateCreated
            workOrd.dateModified = workOrder.dateModified
            workOrd.description = workOrder.description
            workOrd.sampleWorkOrder = 0
            workOrd.numberOfAttachments = workOrder.numberOfAttachments
            workOrd.status = "Rejected"
            workOrd.remarks = remarksTextField.text ?? ""
            workOrd.dateModified = Date()
            workOrd.removed = workOrder.removed
            workOrderService.updateWorkOrder(workOrder: workOrd, completion: { [weak self] (result) in
               guard self != nil else { return }
               switch result {
               case .success(_):
                self!.rejectdelegate.rejectFunction()
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
        workOrd.approvedBy = 1
        workOrd.dateApproved = Date()
        workOrd.vendorId = purchaseOrder.vendorId
        workOrd.samplePurchaseOrder = 0
        workOrd.dateReceived = purchaseOrder.dateReceived
        workOrd.numberOfAttachments = purchaseOrder.numberOfAttachments
        workOrd.status = "Rejected"
        workOrd.remarks = remarksTextField.text ?? ""
        workOrd.rejectConfirm = true
        workOrd.expectedDate =  purchaseOrder.expectedDate
        workOrd.removed = purchaseOrder.removed
        workOrd.removedDate = purchaseOrder.removedDate
        
        purchaseOrderService.updatePurchaseOrder(purchaseOrder: workOrd, completion:
        { [weak self] (result) in
           guard self != nil else { return }
           switch result {
           case .success(_):
            self!.rejectdelegate.rejectFunction()
               self!.handleDismissView()
               print("sucees while Fetching Workers")
               
           case .failure( _):
               self!.handleDismissView()
               print("ERROR while Fetching Workers")
           }

       })
    }
    
    func saveExpenseStatmentApproval() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        var workOrd = ExpenseStatements()
        workOrd.expenseStatementsId = expenseOrder.expenseStatementsId
        workOrd.expenseStatementsId = expenseOrder.expenseStatementsId
        workOrd.workerId = expenseOrder.workerId
        workOrd.customerId = expenseOrder.customerId
        workOrd.salesTax = expenseOrder.salesTax
        workOrd.shipping = expenseOrder.shipping
        workOrd.description = expenseOrder.description
        workOrd.status = "Rejected"
        workOrd.remarks = remarksTextField.text ?? ""
        workOrd.dateCreated = workOrder.dateCreated
        workOrd.dateApproved = Date()
        workOrd.approvedBy = expenseOrder.approvedBy
        workOrd.dateModified = expenseOrder.dateModified
workOrd.sampleExpenseStatement = expenseOrder.sampleExpenseStatement
        workOrd.removed = expenseOrder.removed
        workOrd.removedDate = expenseOrder.removedDate
        workOrd.numberOfAttachments = expenseOrder.numberOfAttachments
        
        expenseOrderService.updateExpenseOrder(expenseStatements:  workOrd, completion: { [weak self] (result) in
           guard self != nil else { return }
           switch result {
           case .success(_):
            self!.rejectdelegate.rejectFunction()
               self!.handleDismissView()
               print("sucees while Fetching Workers")

           case .failure( _):
               self!.handleDismissView()
               print("ERROR while Fetching Workers")
           }

       })
       
    }
}


