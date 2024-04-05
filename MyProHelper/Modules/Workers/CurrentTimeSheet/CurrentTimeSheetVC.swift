//
//  CurrentTimeSheetVC.swift
//  MyProHelper
//
//  Created by Anupansh on 18/03/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit
import SwiftDataTables
import GRDB
import SideMenu

class CurrentTimeSheetVC: UIViewController {
    
    // MARK: - OUTLETS AND VARIABLES
    var filteredModel = [CurrentTimeSheetModel]()
    var currentTimeSheetModel = [CurrentTimeSheetModel]()
    var isSearching = false
    var columnArray = ["","Date Worked","Start Time","End Time","Break Start","Break Stop","Lunch Start","Lunch Stop","Work Time","Break Time","Lunch Time"]
    var toShowRemoved = false
    var workerModel = [Worker]()
    lazy var dataTable = getDataTable()
    var showRemovedSwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
    var showRemovedButton: UIBarButtonItem?

    // MARK: - VIEW LIFECYCLE
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
    
    // MARK: - NAVIGATION ITEMS
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
    
    @objc func handleShowRemoved() {
        if toShowRemoved == false {
            showRemovedSwitch.isOn = true
//            let showRemovedBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_show_removed"), style: .done, target: self, action: #selector(handleShowRemoved))
//            let addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddItem))
//            self.navigationItem.rightBarButtonItems = [addBtn,showRemovedBtn]
            toShowRemoved = true
            self.fetchList()
        }
        else {
            showRemovedSwitch.isOn = false
//            let showRemovedBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_hide_removed"), style: .done, target: self, action: #selector(handleShowRemoved))
//            let addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddItem))
//            self.navigationItem.rightBarButtonItems = [addBtn,showRemovedBtn]
            toShowRemoved = false
            self.fetchList()
        }
    }
    
    //MARK: - EXECUTE SQL QUERIES
    func fetchList() {
        currentTimeSheetModel.removeAll()
        guard let queue = AppDatabase.shared.attachDababaseQueue else {return}
        let sortable = makeSortableItems(sortType: .DESCENDING)
        let COLUMNS = RepositoryConstants.Columns.self
        let TABLES = RepositoryConstants.Tables.self
        var removedCondition = ""
        if !toShowRemoved {
//            removedCondition = "WHERE main.\(RepositoryConstants.Tables.CURRENT_TIME_SHEETS).\(RepositoryConstants.Columns.REMOVED) = 0"
            removedCondition = "WHERE TC.\(COLUMNS.REMOVED) = 0"
        }
        else {
//            removedCondition = "WHERE main.\(RepositoryConstants.Tables.CURRENT_TIME_SHEETS).\(RepositoryConstants.Columns.REMOVED) = 1"
            removedCondition = "WHERE TC.\(COLUMNS.REMOVED) = 1"
        }
        let workerID = AppLocals.worker.workerID!
        var roleCondition = ""
        if !AppLocals.workerRole.role.canRunPayroll! {
//            roleCondition   = "AND main.\(RepositoryConstants.Tables.CURRENT_TIME_SHEETS).\(RepositoryConstants.Columns.WORKER_ID) = \(workerID)"
            roleCondition   = "AND TC.\(COLUMNS.WORKER_ID) = \(workerID)"
        }
        if AppLocals.workerRole.role.techSupport! || AppLocals.workerRole.role.owner! {
            roleCondition = ""
        }
//        var sql2 = """
//            Select * from main.\(RepositoryConstants.Tables.CURRENT_TIME_SHEETS)
//            LEFT JOIN main.\(RepositoryConstants.Tables.WORKERS) ON main.\(RepositoryConstants.Tables.CURRENT_TIME_SHEETS).\(RepositoryConstants.Columns.WORKER_ID) =
//                main.\(RepositoryConstants.Tables.WORKERS).\(RepositoryConstants.Columns.WORKER_ID)
//            LEFT JOIN main.\(RepositoryConstants.Tables.WORKER_ROLES) ON main.\(RepositoryConstants.Tables.CURRENT_TIME_SHEETS).\(RepositoryConstants.Columns.WORKER_ID) =
//                main.\(RepositoryConstants.Tables.WORKER_ROLES).\(RepositoryConstants.Columns.WORKER_ID)
//            \(removedCondition)
//            \(roleCondition)
//        """
        
        var sql = """
            Select TC.*,
            W.\(COLUMNS.FIRST_NAME),
            W.\(COLUMNS.LAST_NAME),
            ROW_NUMBER() OVER (ORDER BY TC.\(COLUMNS.DATE_ENTERED)) AS RowNum
            FROM main.\(TABLES.CURRENT_TIME_SHEETS) TC
            JOIN main.\(TABLES.WORKERS) W ON W.\(COLUMNS.WORKER_ID) = TC.\(COLUMNS.WORKER_ID)
            \(removedCondition)
            \(roleCondition)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        sql += """
                \(sortable)
        """
        print(sql)

            
//        sql += " ORDER BY \(RepositoryConstants.Columns.DateWorked) DESC"

        do {
            try queue.read { (database) in
                let rows = try Row.fetchCursor(database, sql: sql)
                print(rows)
                while let row = try rows.next() {
                    print(row)
                    let singleTimeSheet = CurrentTimeSheetModel.init(row: row)
                    currentTimeSheetModel.append(singleTimeSheet)
                }
            }
            dataTable.reload()
        }
        catch {
            print(error.localizedDescription)
        }
        
        self.showSnackbar()
    }
    
    private func makeSortableItems(sortType: SortType?) -> String {
        return BaseRepository(table: .CURRENT_TIME_SHEETS).makeSortableCondition(key: "TC.\(RepositoryConstants.Columns.DateWorked)", sortType: sortType!)
    }
    
    func restoreQuery(index : Int) {
        var torID = ""
        if isSearching {
            torID = filteredModel[index].timeCardId?.description ?? ""
        }
        else {
            torID = currentTimeSheetModel[index].timeCardId?.description ?? ""
        }
        let arguments : StatementArguments = [
            "id" : torID,
            "removed" : "0"
        ]
        let sql = """
            UPDATE \(RepositoryConstants.Tables.CURRENT_TIME_SHEETS) SET
                \(RepositoryConstants.Columns.REMOVED)          = :removed
            WHERE \(RepositoryConstants.Tables.CURRENT_TIME_SHEETS).TimeCardID  =   :id
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
            torID = filteredModel[index].timeCardId?.description ?? ""
        }
        else {
            torID = currentTimeSheetModel[index].timeCardId?.description ?? ""
        }
        let arguments : StatementArguments = [
            "id" : torID,
            "removed" : "1"
        ]
        let sql = """
            UPDATE \(RepositoryConstants.Tables.CURRENT_TIME_SHEETS) SET
                \(RepositoryConstants.Columns.REMOVED)          = :removed
            WHERE \(RepositoryConstants.Tables.CURRENT_TIME_SHEETS).TimeCardID  =   :id
        """
        AppDatabase.shared.executeSQL(sql: sql, arguments: arguments,typeOfAction: .update, updatedId: UInt64(torID)) { (id) in
            self.fetchList()
        } fail: { (error) in
            print(error.localizedDescription)
        }
    }
    
    func executeEditQuery(index: Int,timeSheet: CurrentTimeSheetModel) {
        var timeSheetId = ""
        if isSearching {
            timeSheetId = filteredModel[index].timeCardId?.description ?? ""
        }
        else {
            timeSheetId = currentTimeSheetModel[index].timeCardId?.description ?? ""
        }
        let arguments : StatementArguments = [
            "id" : timeSheetId,
            "description" : timeSheet.description,
            "startTime" : timeSheet.startTime,
            "endTime" : timeSheet.endTime,
            "breakStart" : timeSheet.breakStart,
            "breakEnd" : timeSheet.breakStop,
            "lunchStart" : timeSheet.lunchStart,
            "lunchEnd" : timeSheet.lunchStop,
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
        AppDatabase.shared.executeSQL(sql: sql, arguments: arguments,typeOfAction: .update, updatedId: UInt64(timeSheetId)) { (id) in
            self.fetchList()
        } fail: { (error) in
            print(error.localizedDescription)
        }
    }
    
    func executeInsertQuery(timeSheet: CurrentTimeSheetModel) {
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
            self.fetchList()
        } fail: { (error) in
            print(error.localizedDescription)
        }
    }

    
    //MARK: - HELPER FUNCTIONS
    func initialSetup() {
        title = "CURRENT_TIME_SHEET".localize
        self.navigationController?.isNavigationBarHidden = false
        let sidemenuBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "menu"), style: .done, target: self, action: #selector(sideMenuPressed))
        showRemovedSwitch.cornerRadius = 15
        showRemovedSwitch.borderColor = .white
        showRemovedSwitch.onTintColor = .red
        showRemovedSwitch.borderWidth = 2
        showRemovedSwitch.addTarget(self, action: #selector(handleShowRemoved), for: .valueChanged)
        showRemovedButton = UIBarButtonItem(customView: showRemovedSwitch)
        self.navigationItem.leftBarButtonItem = sidemenuBtn
        if AppLocals.workerRole.role.canEditTimeAlreadyEntered! {
            let addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddItem))
            self.navigationItem.rightBarButtonItems = [addBtn,showRemovedButton!]
        }
        else {
            self.navigationItem.rightBarButtonItems = [showRemovedButton!]
        }
        view.addSubview(dataTable)
        setupConstraints()
        dataTable.reload()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: .serverChanges, object: nil)
    }
    
    @objc func refreshData() {
        fetchList()
    }
    
    @objc func handleAddItem() {
          addTimeSheet()
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
        let singleData = isSearching ? filteredModel[index] : currentTimeSheetModel[index]
        var formattedDateWorked = DateManager.standardDateToStringWithoutHours(date: singleData.dateWorked)
        formattedDateWorked = formattedDateWorked.isEmpty ? "-" : formattedDateWorked
        data.append(DataTableValueType.string("⚙️"))
//        data.append(DataTableValueType.string(singleData.dateWorked ?? "-"))
        data.append(DataTableValueType.string(formattedDateWorked))
        data.append(DataTableValueType.string(singleData.startTime ?? "-"))
        data.append(DataTableValueType.string(singleData.endTime ?? "-"))
        data.append(DataTableValueType.string(singleData.breakStart ?? "-"))
        data.append(DataTableValueType.string(singleData.breakStop ?? "-"))
        data.append(DataTableValueType.string(singleData.lunchStart ?? "-"))
        data.append(DataTableValueType.string(singleData.lunchStop ?? "-"))
        data.append(DataTableValueType.string(singleData.workTime ?? "-"))
        data.append(DataTableValueType.string(singleData.breakTime ?? "-"))
        data.append(DataTableValueType.string(singleData.lunchTime ?? "-"))
        return data
    }
    
    func fetchList(key: String) {
        filteredModel.removeAll()
        var tempArr = [CurrentTimeSheetModel]()
        for singleData in currentTimeSheetModel {

            if (
                DateManager.standardDateToStringWithoutHours(date: singleData.dateWorked).contains(key) ||
//                (singleData.dateWorked!.contains(key)) ||
                (singleData.startTime!.contains(key)) ||
                (singleData.endTime!.contains(key)) ||
                (singleData.breakStart!.contains(key)) ||
                (singleData.breakStop!.contains(key)) ||
                (singleData.lunchStart!.contains(key)) ||
                (singleData.lunchStop!.contains(key)) ||
                (singleData.workTime!.contains(key)) ||
                (singleData.breakTime!.contains(key)) ||
                (singleData.lunchStop!.contains(key))) {
                tempArr.append(singleData)
            }
        }
        filteredModel = tempArr
        dataTable.reload()
    }
    
    // MARK: - Action Sheet Functions
    func presentActionSheet(index: Int,indexpath: IndexPath) {
        if !toShowRemoved {
            var tempModel = [CurrentTimeSheetModel]()
            tempModel = isSearching ? filteredModel : currentTimeSheetModel
            if tempModel[index].canEditTime ?? true {
                ActionSheetManager.shared.showActionSheet(typeOfAction: [.viewAction,.editAction,.deleteAction], presentingView: dataTable.collectionView.cellForItem(at: indexpath)!.contentView, vc: self, actionPerformed: { [weak self] actionPerformed in
                    if actionPerformed == .editAction {
                        if tempModel[index].isTwoMonthsBefore! {
                            let alert = UIAlertController(title: AppLocals.appName, message: Constants.Message.TWO_MONTHS_TIMESHEET, preferredStyle: .alert)
                            let continueAction = UIAlertAction(title: "Continue", style: .default) { (alert) in
                                self?.editAction(index: index, viewOnly: false)
                            }
                            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
                            alert.addAction(continueAction)
                            alert.addAction(cancelAction)
                            self?.present(alert, animated: true, completion: nil)
                        }
                        else {
                            self?.editAction(index: index, viewOnly: false)
                        }

                    }
                    else if actionPerformed == .viewAction {
                        self?.editAction(index: index, viewOnly: true)
                    }
                    else if actionPerformed == .deleteAction {
                        self?.deleteAction(index: index)
                    }
                    return nil
                })
            }
            else {
                ActionSheetManager.shared.showActionSheet(typeOfAction: [.viewAction,.deleteAction], presentingView: dataTable.collectionView.cellForItem(at: indexpath)!.contentView, vc: self, actionPerformed: { [weak self] actionPerformed in
                    if actionPerformed == .deleteAction {
                        self?.deleteAction(index: index)
                    }
                    else if actionPerformed == .viewAction {
                        self?.editAction(index: index, viewOnly: true)
                    }
                    return nil
                })
            }
        }
        else {
            ActionSheetManager.shared.showActionSheet(typeOfAction: [.undeleteAction], presentingView: dataTable.collectionView.cellForItem(at: indexpath)!.contentView, vc: self, actionPerformed: { [weak self] _ in
                self?.restoreAction(index: index)
            })
        }
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
    
    func editAction(index: Int,viewOnly: Bool) {
        let vc = AppStoryboards.workers.instantiateViewController(withIdentifier: EditTimeSheetVC.className) as! EditTimeSheetVC
        if isSearching {
            vc.timeSheet = filteredModel[index]
        }
        else {
            vc.timeSheet = currentTimeSheetModel[index]
        }
        vc.passDataClosure = { [weak self] timesheet in
            self?.executeEditQuery(index: index, timeSheet: timesheet)
        }
        vc.viewOnly = viewOnly
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func addTimeSheet() {
        let vc = AppStoryboards.workers.instantiateViewController(withIdentifier: EditTimeSheetVC.className) as! EditTimeSheetVC
        vc.isAddPerformed = true
        vc.passDataClosure = { [weak self] timesheet in
            self?.executeInsertQuery(timeSheet: timesheet)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    fileprivate func showSnackbar(){
        
        DispatchQueue.main.async {
            if self.isSearching {
                self.filteredModel.count == 0 ? self.dataTable.setEmptyMessage(show: true, message: Constants.Message.No_Data_To_Display) : self.dataTable.setEmptyMessage(show: false, message: "")
            }else {
                self.currentTimeSheetModel.count == 0 ? self.dataTable.setEmptyMessage(show: true, message: Constants.Message.No_Data_To_Display) : self.dataTable.setEmptyMessage(show: false, message: "")
            }
        }
        
    }
    
}

//MARK: UITABLEVIEW DELEGATES AND DATASOURCE
extension CurrentTimeSheetVC: SwiftDataTableDataSource, SwiftDataTableDelegate {
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
            if filteredModel.count == 0 {
                return 0
            } else {
                return columnArray.count
            }
        } else {
            if currentTimeSheetModel.count == 0 {
                return 0
            } else {
                return columnArray.count
            }
        }
    }
    
    func numberOfRows(in: SwiftDataTable) -> Int {
        return isSearching ? filteredModel.count : currentTimeSheetModel.count
    }
    
    func dataTable(_ dataTable: SwiftDataTable, dataForRowAt index: NSInteger) -> [DataTableValueType] {
        return tableValue(index: index)
    }
    
    func dataTable(_ dataTable: SwiftDataTable, headerTitleForColumnAt columnIndex: NSInteger) -> String {
        return columnArray[columnIndex]
    }
    
    func heightForSectionFooter(in dataTable: SwiftDataTable) -> CGFloat {
        return 0
    }
    
    func shouldContentWidthScaleToFillFrame(in dataTable: SwiftDataTable) -> Bool {
        return true
    }
    
    func fixedColumns(for dataTable: SwiftDataTable) -> DataTableFixedColumnType {
        return DataTableFixedColumnType.init(leftColumns: 1)
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

