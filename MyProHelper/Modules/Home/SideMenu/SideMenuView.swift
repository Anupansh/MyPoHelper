//
//  SideMenuView.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/1/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit
import ExpandableCell
import GRDB


fileprivate enum MainCell {
    case dashboard
    case profile
    case JobList
    case Calendar
    case Customers
    case Jobs
    case Inventory
    case Workers
    case Payroll
    case Approvals
    case Reports
    case MasterSetup
    case Help
}

fileprivate enum SubCell {
    case ScheduledJobs
    case JobList
    case QuotesOrEstimates
    case Parts
    case WorkerList
    case ExpenseStatements
    case CreatePayroll
    case InvoiceApprovals
    case WorkOrderApprovals
    case PurchaseOrderApprovals
    case ExpenseStatementApprovals
    case Jobs
    case UnscheduledJobs
    case BalanceAmount
    case ReceivedAmount
    case technicalSupport
    case ContactUs
    case AuditTrail
    case ReferToFriend
    case AboutProgram
    case AdjustCompanySettings
    case CompanyInformation
    case AssetType
    case Assets
    case Services
    case RoleGroup
    case Devices
    case PartLocations
    case SupplyLocations
    case Vendors
    case TimeOffRules
    case Holidays
    case JobHistory
    case JobConfirmation
    case Invoices
    case Payments
    case Receipts
    case Supplies
    case PurchaseOrders
    case WorkOrders
    case CurrentTimeSheet
    case TimeSheetHistory
    case TimeOffRequest
    case Wages
    case TimeSheets
    case TimeOffApprovals
    case JobsToReschedule
    case OpenJobDetails
}

class SideMenuView: UIViewController, Storyboarded {

    @IBOutlet weak private var expandableTableView: ExpandableTableView!
    private var mainTableCells: [MainCell] = [.profile,
                                              .dashboard,
                                              .Calendar,
                                              .Customers,
                                              .Jobs,
                                              .Inventory,
                                              .Workers,
                                              .Payroll,
                                              .Approvals,
                                              .Reports,
                                              .MasterSetup,
                                              .Help]
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    private func setupTableView() {
        let mainCell = UINib(nibName: SideMenuCell.ID, bundle: nil)
        let profileCell = UINib(nibName: ProfileCell.ID, bundle: nil)
        let sideMenuSubCell = UINib(nibName: SideMenuSubCell.ID, bundle: nil)

        expandableTableView.expandableDelegate = self
        expandableTableView.animation = .automatic
        expandableTableView.expansionStyle = .multi
        expandableTableView.allowsSelection = true
        expandableTableView.separatorStyle = .none
        expandableTableView.showsVerticalScrollIndicator = false
        expandableTableView.register(sideMenuSubCell, forCellReuseIdentifier: SideMenuSubCell.ID)
        expandableTableView.register(mainCell, forCellReuseIdentifier: SideMenuCell.ID)
        expandableTableView.register(profileCell, forCellReuseIdentifier: ProfileCell.ID)
        expandableTableView.contentInset = UIEdgeInsets(top: DeviceType.IS_IPAD ? 20 : 0,
                                                        left: 0,
                                                        bottom: 20,
                                                        right: 0)
    }

    private func getSupCellsFor(section: MainCell) -> [SubCell] {
        switch section {
        case .dashboard:
            return []
        case .profile:
            return []
        case .JobList:
            return []
        case .Calendar:
            return []
        case .Customers:
            return []
        case .Jobs:
            return [.ScheduledJobs, .JobList, .OpenJobDetails, .JobConfirmation,
                    .JobHistory ,.QuotesOrEstimates, .Invoices,
                    .Payments, .Receipts]
        case .Inventory:
            return [.Parts,.Supplies,.PurchaseOrders,.WorkOrders]
        case .Workers:
            return [.WorkerList, .ExpenseStatements,.CurrentTimeSheet,
                    .TimeSheetHistory,.TimeOffRequest,.Wages]
        case .Payroll:
            return [.CreatePayroll,.TimeSheets]
        case .Approvals:
            return [.JobsToReschedule,.TimeOffApprovals,.InvoiceApprovals, .WorkOrderApprovals,
                    .PurchaseOrderApprovals, .ExpenseStatementApprovals]
        case .Reports:
            return [.Jobs ,.ScheduledJobs ,.UnscheduledJobs,
                    .BalanceAmount, .ReceivedAmount]
        case .MasterSetup:
            return [.AdjustCompanySettings, .CompanyInformation, .AssetType,
                    .Assets, .Services, .RoleGroup,
                    .Devices, .PartLocations, .SupplyLocations,
                    .Vendors, .TimeOffRules, .Holidays]
        case .Help:
            return [.technicalSupport, .ContactUs, .AuditTrail,
                    .ReferToFriend, .AboutProgram]
        }
    }
    
    private func getTitleForSupCell(cell: SubCell) -> String {
        switch cell {
        
        case .ScheduledJobs:
            return "SCHEDULE_JOBS".localize
        case .JobList:
            return "JOB_LIST".localize
        case .QuotesOrEstimates:
            return "\("QOUTES".localize)/\("ESTIMATES".localize)"
        case .Parts:
            return "PARTS".localize
        case .WorkerList:
            return "WORKERS_LIST".localize
        case .ExpenseStatements:
            return "EXPENSE_STATEMENTS".localize
        case .CreatePayroll:
            return "CREATE_PAYROLL".localize
        case .InvoiceApprovals:
            return "INVOICE_APPROVALS".localize
        case .WorkOrderApprovals:
            return "WORK_ORDER_APPROVALS".localize
        case .PurchaseOrderApprovals:
            return "PURCHASE_ORDER_APPROVALS".localize
        case .ExpenseStatementApprovals:
            return "EXPENSE_STATEMENT_APPROVALS".localize
        case .Jobs:
            return "JOBS".localize
        case .UnscheduledJobs:
            return "UNSCHEDULED_JOBS".localize
        case .BalanceAmount:
            return "BALANCE_AMOUNT".localize
        case .ReceivedAmount:
            return "RECEIVED_AMOUNT".localize
        case .technicalSupport:
            return "TECHNICAL_SUPPORT".localize
        case .ContactUs:
            return "CONTACT_US".localize
        case .AuditTrail:
            return "AUDIT_TRAIL".localize
        case .ReferToFriend:
            return "REFER_A_FRIEND".localize
        case .AboutProgram:
            let appVersion = GlobalFunction.getAppVersion() ?? ""
            return "ABOUT_PROGRAM".localize + "\t v " + appVersion
        case .AdjustCompanySettings:
            return "ADJUST_COMPANY_SETTINGS".localize
        case .CompanyInformation:
            return "COMPANY_INFORMATION".localize
        case .AssetType:
            return "ASSET_TYPE".localize
        case .Assets:
            return "ASSETS".localize
        case .Services:
            return "SERVICES".localize
        case .RoleGroup:
            return "ROLES_GROUP".localize
        case .Devices:
            return "DEVICES".localize
        case .PartLocations:
            return "PART_LOCATIONS".localize
        case .SupplyLocations:
            return "SUPPLY_LOCATIONS".localize
        case .Vendors:
            return "VENDORS".localize
        case .TimeOffRules:
            return "TIME_OFF_RULES".localize
        case .Holidays:
            return "HOLIDAYS".localize
        case .JobHistory:
            return "JOB_HISTORY".localize
        case .JobConfirmation:
            return "JOB_CONFIRMATION".localize
        case .Invoices:
            return "INVOICES".localize
        case .Payments:
            return "PAYMENTS".localize
        case .Receipts:
            return "RECEIPTS".localize
        case .Supplies:
            return "SUPPLIES".localize
        case .PurchaseOrders:
            return "PURCHASE_ORDERS".localize
        case .WorkOrders:
            return "WORK_ORDERS".localize
        case .CurrentTimeSheet:
            return "CURRENT_TIME_SHEET".localize
        case .TimeSheetHistory:
            return "TIME_SHEET_HISTORY".localize
        case .TimeOffRequest:
            return "TIME_OFF_REQUEST".localize
        case .Wages:
            return "WAGES".localize
        case .TimeSheets:
            return "TIME_SHEETS".localize
        case .TimeOffApprovals:
            return "TIME_OFF_APPROVALS".localize
        case .OpenJobDetails:
            return "OPEN_JOB_DETAILS".localize
        case .JobsToReschedule:
            return "JOBS_TO_RESCHEDULE".localize
        
        }
    }
    
    private func getCanRunPayroll(_ completion: @escaping (_ canRunPayroll:Bool) -> ()){
        guard let workerID = UserDefaults.standard.value(forKey: UserDefaultKeys.userId) as? String else{return}
        
        getWorkerCanRunPayroll(workerID:workerID) { [weak self] (canRunPayroll) in
            guard let _ = self else { return }
            completion(canRunPayroll)
        }
    }
    
    func getWorkerCanRunPayroll(workerID:String, completion: @escaping (_ canRunPayroll:Bool) -> ()) {
        let workersService = WorkersService()
        workersService.fetchWorkerCanRunPayroll(workerID:workerID) { [weak self] (result) in
            guard let _ = self else { return }
            switch result {
            case .success(let value):
                completion(value)
            case .failure(let error):
                print(error)
            }
        }
    }
}

// MARK: - Conforming to Expandable Delegate
extension SideMenuView: ExpandableDelegate {
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mainCell = mainTableCells[indexPath.section]
        guard let cell = expandableTableView.dequeueReusableCell(withIdentifier: SideMenuCell.ID) as? SideMenuCell else {
            return UITableViewCell()
        }
        switch mainCell {
        case .dashboard:
            let title = "DASHBOARD".localize
            let icon = UIImage(named: Constants.Image.DASHBOARD)
            cell.setupCell(title: title, icon: icon)
        case .profile:
            guard let cell = expandableTableView.dequeueReusableCell(withIdentifier: ProfileCell.ID) as? ProfileCell else {
                return UITableViewCell()
            }
            cell.nameLabel.text = AppLocals.worker.fullName
            cell.emailLabel.text = AppLocals.worker.email
            
            cell.setupButtons(//AppLocals.currentTimeSheetId != nil,
                              AppLocals.startDateWorked != nil,
                              AppLocals.isBreakRunning,
                              AppLocals.isLunchRunning,
                              AppLocals.startDateWorked == nil || AppLocals.startDateWorked != nil &&
                              AppLocals.isLunchEnd)
            cell.didPressCloseButton = {
                self.dismiss(animated: true, completion: nil)
            }
            
            //Profile
            cell.didPressProfileButton = {
                self.profileClicked()
            }
            
            // Start Day
            cell.didPressStartButton = {
                self.startDay()
            }
            // End Day
            cell.didPressEndButton = {
                self.endDay()
            }
            
            //Start Break
            cell.didPressStartBreakButton = {
                self.startBreak()
            }
            //Stop Break
            cell.didPressStopBreakButton = {
                self.stopBreak()
            }
            //Start Lunch
            cell.didPressStartLunchButton = {
                self.startLunch()
            }
            //Stop Lunch
            cell.didPressStopLunchButton = {
                self.stopLunch()
            }
            
            return cell
        case .JobList:
            let title = "JOB_LIST".localize
            let icon = UIImage(named: Constants.Image.JOB_LIST)
            cell.setupCell(title: title, icon: icon)
        case .Calendar:
            let title = "CALENDAR".localize
            let icon = UIImage(named: Constants.Image.CALENDAR)
            cell.setupCell(title: title, icon: icon)
        case .Customers:
            let title = "CUSTOMERS".localize
            let icon = UIImage(named: Constants.Image.CUSTOMERS)
            cell.setupCell(title: title, icon: icon)
        case .Jobs:
            let title = "JOBS".localize
            let icon = UIImage(named: Constants.Image.JOBS)
            cell.setupCell(title: title, icon: icon)
        case .Inventory:
            let title = "INVENTORY".localize
            let icon = UIImage(named: Constants.Image.INVENTORY)
            cell.setupCell(title: title, icon: icon)
        case .Workers:
            let title = "WORKERS".localize
            let icon = UIImage(named: Constants.Image.WORKERS)
            cell.setupCell(title: title, icon: icon)
        case .Payroll:
            let title = "PAYROLL".localize
            let icon = UIImage(named: Constants.Image.PAYROLL)
            cell.setupCell(title: title, icon: icon)
        case .Approvals:
            let title = "APPROVALS".localize
            let icon = UIImage(named: Constants.Image.APPROVALS)
            cell.setupCell(title: title, icon: icon)
        case .Reports:
            let title = "REPORTS".localize
            let icon = UIImage(named: Constants.Image.REPORTS)
            cell.setupCell(title: title, icon: icon)
        case .MasterSetup:
            let title = "MASTER_SETUP".localize
            let icon = UIImage(named: Constants.Image.MASTER_SETUP)
            cell.setupCell(title: title, icon: icon)
        case .Help:
            let title = "HELP".localize
            let icon = UIImage(named: Constants.Image.HELP)
            cell.setupCell(title: title, icon: icon)
        }
        if getSupCellsFor(section: mainCell).isEmpty {
            cell.hideExpandArrow()
        }
        else {
            cell.showExpandArrow()
        }
        return cell
        
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, expandedCellsForRowAt indexPath: IndexPath) -> [UITableViewCell]? {
        let mainCell = mainTableCells[indexPath.section]
        let subCells = getSupCellsFor(section: mainCell)
        var cells: [SideMenuSubCell] = []
        
        for subCell in subCells {
            let title = getTitleForSupCell(cell: subCell)
            if let cell = expandableTableView.dequeueReusableCell(withIdentifier: SideMenuSubCell.ID) as? SideMenuSubCell {
                cell.setTitle(title: title)
                cells.append(cell)
            }
        }
        return cells
    }
    
    func numberOfSections(in expandableTableView: ExpandableTableView) -> Int {
        return mainTableCells.count
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height:CGFloat = 0.0
        if mainTableCells[indexPath.section] == .profile {
            return 250
        }
        
        if DeviceType.IS_IPAD{
            height = 60
        }
        else if DeviceType.IS_IPHONE{
            height = 45
        }
        return height
//        return 60
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, heightsForExpandedRowAt indexPath: IndexPath) -> [CGFloat]? {
        let mainCell = mainTableCells[indexPath.section]
        let subCells = getSupCellsFor(section: mainCell)
        var heights: [CGFloat] = []
        for _ in subCells {
            heights.append(40)
        }
        return heights
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = expandableTableView.cellForRow(at: indexPath) as? SideMenuCell {
            cell.animate()
        }

        let selectedCell = mainTableCells[indexPath.section]
        switch selectedCell {
        case .dashboard:
            navigateToView(withKey: .dashboard)
        case .JobList:
            navigateToView(withKey: .jobList)
        case .Calendar:
            navigateToView(withKey: .calendar)
        case .Customers:
            navigateToView(withKey: .customerList)
        default:
            break
        }
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, didSelectExpandedRowAt indexPath: IndexPath) {
        let mainCell = mainTableCells[indexPath.section]
        let subCells = getSupCellsFor(section: mainCell)
        let subCell = subCells[indexPath.row - 1]
        navigateFromSubCell(withCell: subCell)
    }
 
    func expandableTableView(_ expandableTableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }

}

// MARK: - Navigation Helpers
extension SideMenuView {
    private func navigateToView(withKey view: ControllerKeys) {
        let genericController = ControllerFactory().getViewController(from:view)
        if let viewController = genericController.viewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }

    private func navigateFromSubCell(withCell cell: SubCell) {
        switch cell {
        case .ScheduledJobs:
            navigateToView(withKey: .scheduleJobs)
        case .JobList:
            navigateToView(withKey: .jobList)
        case .OpenJobDetails:
            navigateToView(withKey: .jobDetail)
        case .QuotesOrEstimates:
            navigateToView(withKey: .quotesAndEstimates)
        case .Invoices:
            navigateToView(withKey: .invoice)
        case .Payments:
            navigateToView(withKey: .payment)
        case .Receipts:
            navigateToView(withKey: .receipt)
        case .Parts:
            navigateToView(withKey: .parts)
        case .WorkerList:
            navigateToView(withKey: .workersList)
        case .ExpenseStatements:
            navigateToView(withKey: .expenseStatements)
            break
        case .InvoiceApprovals:
            navigateToView(withKey: .Invoiceapproval)
//        case .InvoiceApprovals:
//            navigateToView(withKey: .invoice)
        case .WorkOrderApprovals:
            navigateToView(withKey: .WorkOrderApprovals)
        case .PurchaseOrderApprovals:
            navigateToView(withKey: .PurchaseOrderApprovals)
        case .ExpenseStatementApprovals:
            navigateToView(withKey: .ExpenseStatementApprovals)
        case .Jobs:
            break
        case .UnscheduledJobs:
            break
        case .BalanceAmount:
            break
        case .ReceivedAmount:
            break
        case .technicalSupport:
            navigateToView(withKey: .technicalSupport)
        case .ContactUs:
            navigateToView(withKey: .contactUs)
        case .AuditTrail:
            break
        case .ReferToFriend:
            break
        case .AboutProgram:
            navigateToView(withKey: .aboutProgram)
            break
        case .AdjustCompanySettings:
            break
        case .CompanyInformation:
            navigateToView(withKey: .companyInformation)
        case .AssetType:
            navigateToView(withKey: .assetType)
        case .Assets:
            navigateToView(withKey: .asset)
        case .Services:
            navigateToView(withKey: .serviceType)
        case .RoleGroup:
            navigateToView(withKey: .roleGroup)
            break
        case .Devices:
            navigateToView(withKey: .devices)
            break
        case .PartLocations:
            navigateToView(withKey: .partLocation)
        case .SupplyLocations:
            navigateToView(withKey: .supplyLocation)
        case .Vendors:
            navigateToView(withKey: .vendors)
        case .TimeOffRules:
            break
        case .Holidays:
            navigateToView(withKey: .holidays)
            break
        case .JobHistory:
            navigateToView(withKey: .jobHistory)
        case .JobConfirmation:
            navigateToView(withKey: .jobConfirmation)
        case .Supplies:
            navigateToView(withKey: .supplies)
            break
        case .PurchaseOrders:
            navigateToView(withKey: .purchaseOrder)
            break
        case .WorkOrders:
            navigateToView(withKey: .workOrder)
            break
        case .CurrentTimeSheet:
            navigateToView(withKey: .currentTimeSheet)
            break
        case .TimeSheetHistory:
            navigateToView(withKey: .timeSheetHistory)
            break
        case .TimeOffRequest:
            navigateToView(withKey: .timeOffRequest)
            break
        case .Wages:
            navigateToView(withKey: .wagesView)
            break
        case .TimeSheets:
            if AppLocals.workerRole.role.canRunPayroll!{
                self.navigateToView(withKey: .timeSheets)
            }
//            getCanRunPayroll { (canRunPayroll) in
//                if canRunPayroll{
//                    DispatchQueue.main.async {
//                        self.navigateToView(withKey: .timeSheets)
//                    }
//                }
//            }
            break
        case .TimeOffApprovals:
            navigateToView(withKey: .timeoffapproval)
            break
        case .JobsToReschedule:
            navigateToView(withKey: .jobsToReschedule)
            break
        case .CreatePayroll:
            break
        }
    }
}

//MARK: - Profile Cell
extension SideMenuView{
    
    func profileClicked(){
        navigateToView(withKey: .profile)
    }
    
    func startDay(){
        print("startDay")
        var timeSheet = CurrentTimeSheetModel()
        timeSheet.workerId = AppLocals.worker.workerID!
        timeSheet.workerName = AppLocals.worker.fullName
        timeSheet.dateWorked = Date()
        timeSheet.startTime = DateManager.timeFrameToString(date: Date())
        
        self.executeInsertQuery(timeSheet: timeSheet, success: { ID in
            AppLocals.currentTimeSheetId = ID
            AppLocals.startDateWorked = timeSheet.dateWorked
            self.expandableTableView.reloadData()
        }) { (error) in
        }
    }
    
    func endDay(){
        print("endDay")
        guard AppLocals.startDateWorked != nil else{return}
        
        let startDateWorked = DateManager.getStandardDateString(date: AppLocals.startDateWorked!)
//        executeFetchQuery(timeSheetId: AppLocals.currentTimeSheetId?.description ?? "") { timesheet in
        executeFetchQuery(dateWorked:startDateWorked) { timesheet in
            if timesheet != nil{
                var timesheet = timesheet!
                timesheet.endTime = DateManager.timeFrameToString(date: Date())
                
                self.executeEditQuery(timeSheet: timesheet) { success in
                    if success{
                        DispatchQueue.main.async {
                            AppLocals.currentTimeSheetId = nil
                            AppLocals.startDateWorked = nil
                            AppLocals.isBreakRunning = false
                            AppLocals.isLunchRunning = false
                            AppLocals.isLunchEnd = false
                            self.expandableTableView.reloadData()
                        }
                    }
                } failure: { error in
                    
                }
            }

        } failure: { error in
            
        }

    }
    
    func startBreak(){
        print("startBreak")
        guard AppLocals.startDateWorked != nil else{return}
        if AppLocals.isLunchRunning{
            CommonController.shared.showSnackBar(message: "Please Stop Lunch", view: self)
            return
        }
        let startDateWorked = DateManager.getStandardDateString(date: AppLocals.startDateWorked!)
        executeFetchQuery(dateWorked:startDateWorked) { timesheet in
            if timesheet != nil{
                var timesheet = timesheet!
                timesheet.breakStart = DateManager.timeFrameToString(date: Date())
                
                self.executeEditQuery(timeSheet: timesheet) { success in
                    if success{
                        DispatchQueue.main.async {
                            AppLocals.isBreakRunning = true
                            self.expandableTableView.reloadData()
                        }
                    }
                } failure: { error in
                    
                }
            }

        } failure: { error in
            
        }
    }
    
    func stopBreak(){
        print("stopBreak")
        guard AppLocals.startDateWorked != nil else{return}
        let startDateWorked = DateManager.getStandardDateString(date: AppLocals.startDateWorked!)
        executeFetchQuery(dateWorked:startDateWorked) { timesheet in
            if timesheet != nil{
                var timesheet = timesheet!
                timesheet.breakStop = DateManager.timeFrameToString(date: Date())
                
                self.executeEditQuery(timeSheet: timesheet) { success in
                    if success{
                        DispatchQueue.main.async {
                            AppLocals.isBreakRunning = false
                            self.expandableTableView.reloadData()
                        }
                    }
                } failure: { error in
                    
                }
            }

        } failure: { error in
            
        }
    }
    
    func startLunch(){
        print("startLunch")
        guard AppLocals.startDateWorked != nil else{return}
        
        if AppLocals.isBreakRunning{
            CommonController.shared.showSnackBar(message: "Please Stop Break", view: self)
            return
        }
        
        let startDateWorked = DateManager.getStandardDateString(date: AppLocals.startDateWorked!)
        executeFetchQuery(dateWorked:startDateWorked) { timesheet in
            if timesheet != nil{
                var timesheet = timesheet!
                timesheet.lunchStart = DateManager.timeFrameToString(date: Date())
                
                self.executeEditQuery(timeSheet: timesheet) { success in
                    if success{
                        DispatchQueue.main.async {
                            AppLocals.isLunchRunning = true
                            self.expandableTableView.reloadData()
                        }
                    }
                } failure: { error in
                    
                }
            }

        } failure: { error in
            
        }
        
    }
    
    func stopLunch(){
        print("stopLunch")
        guard AppLocals.startDateWorked != nil else{return}
        let startDateWorked = DateManager.getStandardDateString(date: AppLocals.startDateWorked!)
        executeFetchQuery(dateWorked:startDateWorked) { timesheet in
            if timesheet != nil{
                var timesheet = timesheet!
                timesheet.lunchStop = DateManager.timeFrameToString(date: Date())
                
                self.executeEditQuery(timeSheet: timesheet) { success in
                    if success{
                        DispatchQueue.main.async {
                            AppLocals.isLunchRunning = false
                            AppLocals.isLunchEnd = true
                            self.expandableTableView.reloadData()
                        }
                    }
                } failure: { error in
                    
                }
            }

        } failure: { error in
            
        }
    }
    
    func executeInsertQuery(timeSheet: CurrentTimeSheetModel, success: @escaping(_ ID: Int64) -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments : StatementArguments = [
            "workerId"      : timeSheet.workerId,
            "description"   : timeSheet.description,
            "dateWorked"    : DateManager.getStandardDateString(date: timeSheet.dateWorked),
            "startTime"     : timeSheet.startTime,
            "endTime"       : timeSheet.endTime,
            "breakStart"    : timeSheet.breakStart,
            "breakEnd"      : timeSheet.breakStop,
            "lunchStart"    : timeSheet.lunchStart,
            "lunchEnd"      : timeSheet.lunchStop,
            "approvedDate"  : DateManager.getStandardDateString(date: timeSheet.approvedDate),
            "approvedBy"    : timeSheet.approvedBy ?? 0,
            "isPayrollCreated" : timeSheet.isPayrollCreated ?? 0,
            "enteredDate"   : DateManager.getStandardDateString(date: timeSheet.enteredDate),
            "dateModified"  : DateManager.getStandardDateString(date: timeSheet.dateModified),
            "sampleTimeCard": timeSheet.sampleTimeCard ?? 0,
            "removed"       : timeSheet.removed ?? 0,
            "removedDate"   : DateManager.getStandardDateString(date: timeSheet.removedDate),

        ]
        let sql = """
        INSERT INTO chg.\(RepositoryConstants.Tables.CURRENT_TIME_SHEETS) (
                \(RepositoryConstants.Columns.WORKER_ID),
                \(RepositoryConstants.Columns.DESCRIPTION),
                \(RepositoryConstants.Columns.DateWorked),
                \(RepositoryConstants.Columns.StartTime),
                \(RepositoryConstants.Columns.EndTime),
                \(RepositoryConstants.Columns.BreakStart),
                \(RepositoryConstants.Columns.BreakStop),
                \(RepositoryConstants.Columns.LunchStart),
                \(RepositoryConstants.Columns.LunchStop),
                \(RepositoryConstants.Columns.APPROVED_DATE),
                \(RepositoryConstants.Columns.APPROVED_BY),
                \(RepositoryConstants.Columns.IsPayrollCreated),
                \(RepositoryConstants.Columns.DATE_ENTERED),
                \(RepositoryConstants.Columns.DATE_MODIFIED),
                \(RepositoryConstants.Columns.SampleTimeCard),
                \(RepositoryConstants.Columns.REMOVED),
                \(RepositoryConstants.Columns.REMOVED_DATE))
            VALUES (:workerId,
                    :description,
                    :dateWorked,
                    :startTime,
                    :endTime,
                    :breakStart,
                    :breakEnd,
                    :lunchStart,
                    :lunchEnd,
                    :approvedDate,
                    :approvedBy,
                    :isPayrollCreated,
                    :enteredDate,
                    :dateModified,
                    :sampleTimeCard,
                    :removed,
                    :removedDate)
        """
        AppDatabase.shared.executeSQL(sql: sql, arguments: arguments,typeOfAction: .insert, updatedId: nil) { (id) in
            success(id)
        } fail: { (error) in
            print(error.localizedDescription)
            failure(error)
        }
    }
    
    func executeEditQuery(timeSheet: CurrentTimeSheetModel, success: @escaping(_ success: Bool) -> (), failure: @escaping(_ error: Error) -> ()) {
        
        let timeSheetId = UInt64(timeSheet.timeCardId!)//?.description ?? ""
        let arguments : StatementArguments = [
            "id"            : timeSheetId,
            "description"   : timeSheet.description,
            "startTime"     : timeSheet.startTime,
            "endTime"       : timeSheet.endTime,
            "breakStart"    : timeSheet.breakStart,
            "breakEnd"      : timeSheet.breakStop,
            "lunchStart"    : timeSheet.lunchStart,
            "lunchEnd"      : timeSheet.lunchStop,
        ]
        let sql = """
            UPDATE \(RepositoryConstants.Tables.CURRENT_TIME_SHEETS) SET
                \(RepositoryConstants.Columns.DESCRIPTION)           =  :description,
                \(RepositoryConstants.Columns.StartTime)             =  :startTime,
                \(RepositoryConstants.Columns.EndTime)               =  :endTime,
                \(RepositoryConstants.Columns.BreakStart)            =  :breakStart,
                \(RepositoryConstants.Columns.BreakStop)             =  :breakEnd,
                \(RepositoryConstants.Columns.LunchStart)            =  :lunchStart,
                \(RepositoryConstants.Columns.LunchStop)             =  :lunchEnd
            WHERE \(RepositoryConstants.Tables.CURRENT_TIME_SHEETS).TimeCardID  =   :id
        """
        AppDatabase.shared.executeSQL(sql: sql, arguments: arguments,typeOfAction: .update, updatedId: timeSheetId) { (id) in
            success(true)
        } fail: { (error) in
            print(error.localizedDescription)
            failure(error)
        }
    }
    
    func executeFetchQuery(dateWorked:String,/*timeSheetId:String*/ success: @escaping(_ timeSheet: CurrentTimeSheetModel?) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else {return}
        var sql = """
            Select * from main.\(RepositoryConstants.Tables.CURRENT_TIME_SHEETS)
                    WHERE \(RepositoryConstants.Tables.CURRENT_TIME_SHEETS).\(RepositoryConstants.Columns.DateWorked)  =   '\(dateWorked)'
        """
//        WHERE \(RepositoryConstants.Tables.CURRENT_TIME_SHEETS).\(RepositoryConstants.Columns.TIME_CARD_ID)  =   \(timeSheetId)
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        print(sql)
        do {
            let currentTimeSheets = try queue.read({ (db) -> [CurrentTimeSheetModel] in
                var currentTimeSheets: [CurrentTimeSheetModel] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    currentTimeSheets.append(.init(row: row))
                }
                return currentTimeSheets
            })
//            if currentTimeSheets.count > 0 {
                success(currentTimeSheets.first)
//            }
//            else{
//
//            }
        }
        catch {
            print(error.localizedDescription)
            failure(error)
        }
    }
}
