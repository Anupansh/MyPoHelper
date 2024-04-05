//
//  TimeOffRequestVC.swift
//  MyProHelper
//
//  Created by Anupansh on 10/03/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit
import SwiftDataTables
import GRDB
import SideMenu

class TimeOffRequestVC: UIViewController {
    
    // MARK: OUTLETS AND VARIABLES
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var dataView: UIView!
    
    var timeOffRequest = [TimeOffRequestsModel]()
    var filteredTimeOffRequest = [TimeOffRequestsModel]()
    lazy var dataTable = getDataTable()
    var isSearching = false
    var toShowRemoved = false
    var columnName = ["","Worker Name","Description","Start Date","End Date","Type Of Leave","Status","Requested Date","Remarks","Approved By","Approved Date"]
    var showRemovedSwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
    var showRemovedButton: UIBarButtonItem?
    
    //MARK: VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        fetchList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //fetchList()
        self.showSnackbar()
    }
    
    //MARK: - NAVIGATION ITEMS
    @objc func sideMenuPressed() {
        let sideMenuView = SideMenuView.instantiate(storyboard: .HOME)
        let menu = SideMenuNavigationController(rootViewController: sideMenuView)
        let screenWidth = UIScreen.main.bounds.width
        menu.leftSide = true
        menu.statusBarEndAlpha = 0
        menu.presentationStyle = .menuSlideIn
        menu.isNavigationBarHidden = true
        menu.menuWidth = (screenWidth > 400) ? 400 : screenWidth
        menu.sideMenuManager.addScreenEdgePanGesturesToPresent(toView: view)
        self.present(menu, animated: true, completion: nil)
    }
    
    @objc func addNewTimeout() {
        let vc = AppStoryboards.workers.instantiateViewController(withIdentifier: AddTimeOffRequestVC.className) as! AddTimeOffRequestVC
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.isEditable = true
        vc.toShowWorkerDropdown = true
        vc.passDataClosure = { (workerId,startDate,endDate,leave,status,description,remarks) in
            self.executeAddQuery(typeOfLeave: leave, startDate: startDate, endDate: endDate, description: description,workerId: workerId,status: status,remarks: remarks)
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func handleShowRemoved() {
        if toShowRemoved == false {
            showRemovedSwitch.isOn = true
            toShowRemoved = true
            self.fetchList()
        }
        else {
            showRemovedSwitch.isOn = false
            toShowRemoved = false
            self.fetchList()
        }
    }
    
    fileprivate func showSnackbar(){
        
        DispatchQueue.main.async {
            if self.isSearching {
                self.filteredTimeOffRequest.count == 0 ? self.dataTable.setEmptyMessage(show: true, message: Constants.Message.No_Data_To_Display) : self.dataTable.setEmptyMessage(show: false, message: "")
            }else {
                self.timeOffRequest.count == 0 ? self.dataTable.setEmptyMessage(show: true, message: Constants.Message.No_Data_To_Display) : self.dataTable.setEmptyMessage(show: false, message: "")
            }
        }
        
    }

    //MARK: - EXECUTE SQL QUERIES
    func fetchList() {
        timeOffRequest.removeAll()
        guard let queue = AppDatabase.shared.attachDababaseQueue else {return}
        var removedCondition = ""
        if !toShowRemoved {
            removedCondition = "WHERE main.\(RepositoryConstants.Tables.TIME_OFF_REQUESTS).\(RepositoryConstants.Columns.REMOVED) = 0"
        }
        else {
            removedCondition = "WHERE main.\(RepositoryConstants.Tables.TIME_OFF_REQUESTS).\(RepositoryConstants.Columns.REMOVED) = 1"
        }
        var roleCondition = ""
        let workerID = AppLocals.worker.workerID!
        if !AppLocals.workerRole.role.canAddWorkers! {
            roleCondition   = "AND main.\(RepositoryConstants.Tables.TIME_OFF_REQUESTS).\(RepositoryConstants.Columns.WORKER_ID) = \(workerID)"
        }
        var sql = """
            Select * from main.\(RepositoryConstants.Tables.TIME_OFF_REQUESTS)
            LEFT JOIN main.\(RepositoryConstants.Tables.WORKERS) ON main.\(RepositoryConstants.Tables.TIME_OFF_REQUESTS).\(RepositoryConstants.Columns.WORKER_ID) =
                main.\(RepositoryConstants.Tables.WORKERS).\(RepositoryConstants.Columns.WORKER_ID)
                \(removedCondition)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            try queue.read { (database) in
                let rows = try Row.fetchCursor(database, sql: sql)
                while let row = try rows.next() {
                    print(row)
                    let singleRequest = TimeOffRequestsModel.init(row: row)
                    timeOffRequest.append(singleRequest)
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
        dataTable.reload()
       
        self.showSnackbar()
    }
    
    func executeAddQuery(typeOfLeave: String,startDate: String,endDate: String,description: String,workerId: Int,status: String,remarks: String) {
        let arguments : StatementArguments = [
            "workerID" : workerId,
            "description" : description,
            "startDate" : startDate,
            "endDate" : endDate,
            "typeOfLeave" : typeOfLeave,
            "dateRequested" : DateManager.dateToString(date: Date()),
            "remarks" : remarks,
            "status" : status,
            "dateApproved" : "1900-00-01",
            "approvedBy" : 0,
            "removed"    : "0"
        ]
        let sql = """
            INSERT INTO chg.\(RepositoryConstants.Tables.TIME_OFF_REQUESTS) (
                \(RepositoryConstants.Columns.WORKER_ID),
                \(RepositoryConstants.Columns.DESCRIPTION),
                \(RepositoryConstants.Columns.StartDate),
                \(RepositoryConstants.Columns.EndDate),
                \(RepositoryConstants.Columns.TypeOfLeave),
                \(RepositoryConstants.Columns.DateRequested),
                \(RepositoryConstants.Columns.Remarks),
                \(RepositoryConstants.Columns.STATUS),
                \(RepositoryConstants.Columns.DateApproved),
                \(RepositoryConstants.Columns.APPROVED_BY),
                \(RepositoryConstants.Columns.REMOVED)
            )
            VALUES (
                :workerID,
                :description,
                :startDate,
                :endDate,
                :typeOfLeave,
                :dateRequested,
                :remarks,
                :status,
                :dateApproved,
                :approvedBy,
                :removed
            )
        """
        AppDatabase.shared.executeSQL(sql: sql, arguments: arguments,typeOfAction: .insert, updatedId: nil) { (id) in
//            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//                self.fetchList()
//            }
        } fail: { (error) in
            print(error.localizedDescription)
        }
    }
    
    func executeEditQuery(typeOfLeave: String,startDate: String,endDate: String,description: String,index: Int,workerId: Int,status: String,remarks: String) {
        var torID = ""
        if isSearching {
            torID = filteredTimeOffRequest[index].id!
        }
        else {
            torID = timeOffRequest[index].id!
        }
        let arguments : StatementArguments = [
            "workerID" : workerId,
            "id" : torID,
            "description" : description,
            "startDate" : startDate,
            "endDate" : endDate,
            "typeOfLeave" : typeOfLeave,
            "remarks" : remarks,
            "status" : status
        ]
        let sql = """
            UPDATE \(RepositoryConstants.Tables.TIME_OFF_REQUESTS) SET
                \(RepositoryConstants.Columns.WORKER_ID)         =  :workerID,
                \(RepositoryConstants.Columns.DESCRIPTION)       =  :description,
                \(RepositoryConstants.Columns.StartDate)         =  :startDate,
                \(RepositoryConstants.Columns.EndDate)           =  :endDate,
                \(RepositoryConstants.Columns.TypeOfLeave)       =  :typeOfLeave,
                \(RepositoryConstants.Columns.STATUS)            =  :status,
                \(RepositoryConstants.Columns.Remarks)           =  :remarks
            WHERE \(RepositoryConstants.Tables.TIME_OFF_REQUESTS).TimeOffRequestID  =   :id
        """
        AppDatabase.shared.executeSQL(sql: sql, arguments: arguments,typeOfAction: .update, updatedId: UInt64(torID)) { (id) in
            self.fetchList()
        } fail: { (error) in
            print(error.localizedDescription)
        }
    }
    
    func executeCancelQuery(remarks: String,index: Int) {
        var torID = ""
        if isSearching {
            torID = filteredTimeOffRequest[index].id!
        }
        else {
            torID = timeOffRequest[index].id!
        }
        let arguments : StatementArguments = [
            "id" : torID,
            "remarks" : remarks,
            "status" : "Rejected"
        ]
        let sql = """
            UPDATE \(RepositoryConstants.Tables.TIME_OFF_REQUESTS) SET
                \(RepositoryConstants.Columns.Remarks)       = :remarks,
                \(RepositoryConstants.Columns.STATUS)       = :status
            WHERE \(RepositoryConstants.Tables.TIME_OFF_REQUESTS).TimeOffRequestID  =   :id
        """
        AppDatabase.shared.executeSQL(sql: sql, arguments: arguments,typeOfAction: .update, updatedId: UInt64(torID)) { (id) in
            self.fetchList()
        } fail: { (error) in
            print(error.localizedDescription)
        }
    }
    
    func executeSoftDeleteQuery(index : Int) {
        var torID = ""
        if isSearching {
            torID = filteredTimeOffRequest[index].id!
        }
        else {
            torID = timeOffRequest[index].id!
        }
        let arguments : StatementArguments = [
            "id" : torID,
            "removed" : "1"
        ]
        let sql = """
            UPDATE \(RepositoryConstants.Tables.TIME_OFF_REQUESTS) SET
                \(RepositoryConstants.Columns.REMOVED)          = :removed
            WHERE \(RepositoryConstants.Tables.TIME_OFF_REQUESTS).TimeOffRequestID  =   :id
        """
        AppDatabase.shared.executeSQL(sql: sql, arguments: arguments,typeOfAction: .update, updatedId: UInt64(torID)) { (id) in
            self.fetchList()
        } fail: { (error) in
            print(error.localizedDescription)
        }
    }
    
    func restoreQuery(index : Int) {
        var torID = ""
        if isSearching {
            torID = filteredTimeOffRequest[index].id!
        }
        else {
            torID = timeOffRequest[index].id!
        }
        let arguments : StatementArguments = [
            "id" : torID,
            "removed" : "0"
        ]
        let sql = """
            UPDATE \(RepositoryConstants.Tables.TIME_OFF_REQUESTS) SET
                \(RepositoryConstants.Columns.REMOVED)          = :removed
            WHERE \(RepositoryConstants.Tables.TIME_OFF_REQUESTS).TimeOffRequestID  =   :id
        """
        AppDatabase.shared.executeSQL(sql: sql, arguments: arguments,typeOfAction: .update, updatedId: UInt64(torID)) { (id) in
            self.fetchList()
        } fail: { (error) in
            print(error.localizedDescription)
        }
    }
    
    //MARK: HELPER FUNCTIONS
    func initialSetup() {
        title = "Time Off Requests"
        self.navigationController?.isNavigationBarHidden = false
        let backBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "menu"), style: .done, target: self, action: #selector(sideMenuPressed))
        let addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewTimeout))
        showRemovedSwitch.cornerRadius = 15
        showRemovedSwitch.borderColor = .white
        showRemovedSwitch.onTintColor = .red
        showRemovedSwitch.borderWidth = 2
        showRemovedSwitch.addTarget(self, action: #selector(handleShowRemoved), for: .valueChanged)
        showRemovedButton = UIBarButtonItem(customView: showRemovedSwitch)
        self.navigationItem.leftBarButtonItem = backBtn
        self.navigationItem.rightBarButtonItems = [addBtn,showRemovedButton!]
        view.addSubview(dataTable)
        setupConstraints()
        dataTable.reload()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: .serverChanges, object: nil)
    }
    
    @objc func refreshData() {
        fetchList()
    }

    
    func getDataTable() -> SwiftDataTable {
        let dtb = SwiftDataTable(dataSource: self)
        dtb.translatesAutoresizingMaskIntoConstraints = false
        dtb.delegate = self
        return dtb
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            dataTable.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            dataTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dataTable.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            dataTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    func tableValue(index: NSInteger) -> [DataTableValueType] {
        var data = [DataTableValueType]()
        let singleData = isSearching ? filteredTimeOffRequest[index] : timeOffRequest[index]
        data.append(DataTableValueType.string("⚙️"))
        data.append(DataTableValueType.string(singleData.workerName ?? "-"))
        data.append(DataTableValueType.string(singleData.description ?? "-"))
        data.append(DataTableValueType.string(singleData.startDate ?? "-"))
        data.append(DataTableValueType.string(singleData.endDate ?? "-"))
        data.append(DataTableValueType.string(singleData.typeOffLeave ?? "-"))
        data.append(DataTableValueType.string(singleData.status ?? "-"))
        data.append(DataTableValueType.string(singleData.dateRequested ?? "-"))
        data.append(DataTableValueType.string(singleData.remarks ?? "-"))
        var approverName = "-------"
        if singleData.approvedBy != 0 {
            DBHelper.getWorker(workerId: singleData.approvedBy) { worker in
                approverName = (worker?.fullName)!
            }
        }
        data.append(DataTableValueType.string(approverName))
        data.append(DataTableValueType.string(singleData.dateApproved ?? "-"))
        return data
    }
    
    //MARK: SEARCH FUNCTION
    func fetchList(key: String) {
        filteredTimeOffRequest.removeAll()
        var tempArr = [TimeOffRequestsModel]()
        for request in timeOffRequest {
            if ((request.id!.contains(key)) || (request.workerName!.contains(key)) || (request.description!.contains(key)) || (request.startDate!.contains(key)) || (request.endDate!.contains(key)) || (request.typeOffLeave!.contains(key)) || (request.dateRequested!.contains(key)) || (request.remarks!.contains(key)) || (request.status!.contains(key)) || (request.dateApproved!.contains(key)) || (String(request.approvedBy).contains(key))) {
                tempArr.append(request)
            }
        }
        filteredTimeOffRequest = tempArr
        dataTable.reload()
    }
    
    //MARK: PRESENTING ACTION SHEET
    func presentActionSheet(index: Int,indexpath: IndexPath) {
        if !toShowRemoved {
            ActionSheetManager.shared.showActionSheet(typeOfAction: [.viewAction,.editAction,.deleteAction], presentingView: dataTable.collectionView.cellForItem(at: indexpath)!.contentView, vc: self, actionPerformed: { [weak self] actionPerformed in
                switch actionPerformed {
                case .viewAction:
                    self?.editAction(index: index, isEditable: false)
                case .editAction:
                    self?.editAction(index: index, isEditable: true)
                case .deleteAction:
                    self?.deleteAction(index: index)
                default:
                    print("Nothing to do")
                }
                return nil
            })
        }
        else {
            ActionSheetManager.shared.showActionSheet(typeOfAction: [.undeleteAction], presentingView: dataTable.collectionView.cellForItem(at: indexpath)!.contentView, vc: self, actionPerformed: { [weak self] actionPerformed in
                self?.restoreAction(index: index)
            })
        }
    }
    
    //MARK: - ACTION SHEET METHODS
    func editAction(index: Int, isEditable: Bool) {
        let vc = AppStoryboards.workers.instantiateViewController(withIdentifier: AddTimeOffRequestVC.className) as! AddTimeOffRequestVC
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.isEditable = isEditable
        vc.toShowWorkerDropdown = false
        vc.passDataClosure = { (workerId,startDate,endDate,leave,status,description,remarks) in
            self.executeEditQuery(typeOfLeave: leave, startDate: startDate, endDate: endDate, description: description, index: index,workerId: workerId,status: status,remarks: remarks)
        }
        if isSearching {
            vc.workerId = Int(filteredTimeOffRequest[index].workerId!)
            vc.typeOfLeave = filteredTimeOffRequest[index].typeOffLeave
            vc.startDate = filteredTimeOffRequest[index].startDate
            vc.endDate = filteredTimeOffRequest[index].endDate
            vc.desc = filteredTimeOffRequest[index].description
            vc.status = filteredTimeOffRequest[index].status ?? "Requested"
            vc.remarks = filteredTimeOffRequest[index].remarks ?? ""
        }
        else {
            vc.workerId = Int(timeOffRequest[index].workerId!)
            vc.typeOfLeave = timeOffRequest[index].typeOffLeave
            vc.startDate = timeOffRequest[index].startDate
            vc.endDate = timeOffRequest[index].endDate
            vc.desc = timeOffRequest[index].description
            vc.status = timeOffRequest[index].status ?? "Requested"
            vc.remarks = timeOffRequest[index].remarks ?? ""
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func cancelAction(index: Int) {
        let alert = UIAlertController(title: "Cancel Remarks".localize, message: "", preferredStyle: .alert)
        alert.addTextField { (textfeild) in
            textfeild.placeholder = "Remarks"
        }
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (alertAction) in
            let tf = alert.textFields![0] as UITextField
            if tf.text == "" {
                CommonController.shared.showSnackBar(message: "Please enter remarks.", view: self)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.cancelAction(index: index)
                }
            }
            else {
                self.executeCancelQuery(remarks: tf.text!, index: index)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel".localize, style: .cancel, handler: nil)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func deleteAction(index: Int) {
        let alert = UIAlertController(title: "Please Confirm".localize, message: "Are you sure you want to delete this item?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (alertAction) in
            self.executeSoftDeleteQuery(index: index)
        }
        let cancelAction = UIAlertAction(title: "Cancel".localize, style: .cancel, handler: nil)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func restoreAction(index: Int) {
        let alert = UIAlertController(title: "Please Confirm".localize, message: "Are you sure you want to restore this item?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (alertAction) in
            self.restoreQuery(index: index)
        }
        let cancelAction = UIAlertAction(title: "Cancel".localize, style: .cancel, handler: nil)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
}

//MARK: UITABLEVIEW DELEGATES AND DATASOURCE
extension TimeOffRequestVC: SwiftDataTableDataSource, SwiftDataTableDelegate {
    func didTapSort(_ dataTable: SwiftDataTable, type: DataTableSortType, column: Int) {
        print(type)
    }
    
    func didSearchForKey(_ dataTable: SwiftDataTable, Key: String) {
        if Key.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            isSearching = false
            dataTable.reload()
        }
        else {
            isSearching = true
            fetchList(key: Key)
        }
       
        self.showSnackbar()
    }
    
    func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
        self.presentActionSheet(index: indexPath.section, indexpath: indexPath)
    }
    
    func numberOfColumns(in: SwiftDataTable) -> Int {
       
        if isSearching {
            if filteredTimeOffRequest.count == 0 {
                return 0
            } else {
                return columnName.count
            }
        } else {
            if timeOffRequest.count == 0 {
                return 0
            } else {
                return columnName.count
            }
        }
        
    }
    
    func numberOfRows(in: SwiftDataTable) -> Int {
        isSearching ? filteredTimeOffRequest.count : timeOffRequest.count
    }
    
    func dataTable(_ dataTable: SwiftDataTable, dataForRowAt index: NSInteger) -> [DataTableValueType] {
        
        return tableValue(index: index)
    }
    
    func dataTable(_ dataTable: SwiftDataTable, headerTitleForColumnAt columnIndex: NSInteger) -> String {
        return columnName[columnIndex]
    }
    
    func heightForSectionFooter(in dataTable: SwiftDataTable) -> CGFloat {
        return 0
    }
    
    func fixedColumns(for dataTable: SwiftDataTable) -> DataTableFixedColumnType {
        return DataTableFixedColumnType.init(leftColumns: 1)
    }
    
    func shouldContentWidthScaleToFillFrame(in dataTable: SwiftDataTable) -> Bool {
        return true
    }
    
    func dataTable(_ dataTable: SwiftDataTable, widthForColumnAt index: Int) -> CGFloat {
        if index == 0 {
            return 50
        }
        else {
            return 200
        }
    }
}
