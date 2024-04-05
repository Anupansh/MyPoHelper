//
//  TimeSheetHistoryVC.swift
//  MyProHelper
//
//  Created by sismac010 on 28/06/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit
import SwiftDataTables
import GRDB
import SideMenu

class TimeSheetHistoryVC: UIViewController {
    
    // MARK: - OUTLETS AND VARIABLES
    var filteredModel = [CurrentTimeSheetModel]()
    var currentTimeSheetModel = [CurrentTimeSheetModel]()
    var isSearching = false
    var columnArray = ["Date Worked","Start Time","End Time","Break Start","Break Stop","Lunch Start","Lunch Stop"]
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
        self.title = "TIME_SHEET_HISTORY".localize
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
    @objc func backBtnPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func handleShowRemoved() {
        if toShowRemoved == false {
            showRemovedSwitch.isOn = true
//            let showRemovedBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_show_removed"), style: .done, target: self, action: #selector(handleShowRemoved))
//            self.navigationItem.rightBarButtonItems = [showRemovedBtn]
            toShowRemoved = true
            self.fetchList()
        }
        else {
            showRemovedSwitch.isOn = false
//             self.navigationItem.rightBarButtonItems = [showRemovedBtn]
            toShowRemoved = false
            self.fetchList()
        }
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
    
    
    //MARK: - EXECUTE SQL QUERIES
    func fetchList() {
        currentTimeSheetModel.removeAll()
        guard let queue = AppDatabase.shared.attachDababaseQueue else {return}
        let sortable = makeSortableItems(sortType: .DESCENDING)
        var removedCondition = ""
        if !toShowRemoved {
            removedCondition = "WHERE main.\(RepositoryConstants.Tables.CURRENT_TIME_SHEETS).\(RepositoryConstants.Columns.REMOVED) = 0"
        }
        else {
            removedCondition = "WHERE main.\(RepositoryConstants.Tables.CURRENT_TIME_SHEETS).\(RepositoryConstants.Columns.REMOVED) = 1"
        }
        var sql = """
            Select * from main.\(RepositoryConstants.Tables.CURRENT_TIME_SHEETS)
            LEFT JOIN main.\(RepositoryConstants.Tables.WORKERS) ON main.\(RepositoryConstants.Tables.CURRENT_TIME_SHEETS).\(RepositoryConstants.Columns.WORKER_ID) =
                            main.\(RepositoryConstants.Tables.WORKERS).\(RepositoryConstants.Columns.WORKER_ID)
            LEFT JOIN main.\(RepositoryConstants.Tables.WORKER_ROLES) ON main.\(RepositoryConstants.Tables.CURRENT_TIME_SHEETS).\(RepositoryConstants.Columns.WORKER_ID) =
                            main.\(RepositoryConstants.Tables.WORKER_ROLES).\(RepositoryConstants.Columns.WORKER_ID)

            \(removedCondition)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        sql += """
                \(sortable)
        """
        
        print(sql)
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
        return BaseRepository(table: .CURRENT_TIME_SHEETS).makeSortableCondition(key: RepositoryConstants.Columns.DateWorked, sortType: sortType!)
    }

    
    
    //MARK: - HELPER FUNCTIONS
    func initialSetup() {
        self.navigationController?.isNavigationBarHidden = false
        let sidemenuBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "menu"), style: .done, target: self, action: #selector(sideMenuPressed))
        showRemovedSwitch.cornerRadius = 15
        showRemovedSwitch.borderColor = .white
        showRemovedSwitch.onTintColor = .red
        showRemovedSwitch.borderWidth = 2
        showRemovedSwitch.addTarget(self, action: #selector(handleShowRemoved), for: .valueChanged)
        showRemovedButton = UIBarButtonItem(customView: showRemovedSwitch)
        self.navigationItem.leftBarButtonItem = sidemenuBtn
        self.navigationItem.rightBarButtonItems = [showRemovedButton!]
        view.addSubview(dataTable)
        setupConstraints()
        dataTable.reload()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: .serverChanges, object: nil)
    }
    
    @objc func refreshData() {
        fetchList()
        let backBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .done, target: self, action: #selector(backBtnPressed))
        let showRemovedBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_hide_removed"), style: .done, target: self, action: #selector(handleShowRemoved))
        self.navigationItem.leftBarButtonItem = backBtn
        self.navigationItem.rightBarButtonItems = [showRemovedBtn]
        view.addSubview(dataTable)
        setupConstraints()
        dataTable.reload()
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
//        data.append(DataTableValueType.string(singleData.dateWorked ?? "-"))
        data.append(DataTableValueType.string(formattedDateWorked))
        data.append(DataTableValueType.string(singleData.startTime ?? "-"))
        data.append(DataTableValueType.string(singleData.endTime ?? "-"))
        data.append(DataTableValueType.string(singleData.breakStart ?? "-"))
        data.append(DataTableValueType.string(singleData.breakStop ?? "-"))
        data.append(DataTableValueType.string(singleData.lunchStart ?? "-"))
        data.append(DataTableValueType.string(singleData.lunchStop ?? "-"))
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
                (singleData.lunchStop!.contains(key)))
            {
                tempArr.append(singleData)
            }
        }
        filteredModel = tempArr
        dataTable.reload()
        
        self.showSnackbar()
    }

}

//MARK: UITABLEVIEW DELEGATES AND DATASOURCE
extension TimeSheetHistoryVC: SwiftDataTableDataSource, SwiftDataTableDelegate {
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
        //self.presentActionSheet(index: indexPath.section, indexpath: indexPath)
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
        isSearching ? filteredModel.count : currentTimeSheetModel.count
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
        return DataTableFixedColumnType.init(leftColumns: 0)
    }
    
    func dataTable(_ dataTable: SwiftDataTable, widthForColumnAt index: Int) -> CGFloat {
        return 200
    }
    
}
