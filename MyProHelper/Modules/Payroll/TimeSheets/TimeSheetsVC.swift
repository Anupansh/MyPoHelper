//
//  TimeSheetsVC.swift
//  MyProHelper
//
//  Created by sismac010 on 30/06/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit
import SwiftDataTables
import GRDB

class TimeSheetsVC: UIViewController {
    // MARK: - OUTLETS AND VARIABLES
    var filteredModel = [CurrentTimeSheetModel]()
    var currentTimeSheetModel = [CurrentTimeSheetModel]()
    var isSearching = false
    var columnArray = ["Date Worked","Start Time","End Time","Break Start","Break Stop","Lunch Start","Lunch Stop","Work Time","Break Time","Lunch Time"]
    var toShowRemoved = false
    var workerModel = [Worker]()
    lazy var dataTable = getDataTable()
    
    // MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        fetchList()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "TIME_SHEETS".localize
    }

    // MARK: - NAVIGATION ITEMS
    @objc func backBtnPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func handleShowRemoved() {
        if toShowRemoved == false {
            let showRemovedBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_show_removed"), style: .done, target: self, action: #selector(handleShowRemoved))
            self.navigationItem.rightBarButtonItems = [showRemovedBtn]
            toShowRemoved = true
            self.fetchList()
        }
        else {
            let showRemovedBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_hide_removed"), style: .done, target: self, action: #selector(handleShowRemoved))
            self.navigationItem.rightBarButtonItems = [showRemovedBtn]
            toShowRemoved = false
            self.fetchList()
        }
    }
    
    //MARK: - EXECUTE SQL QUERIES
    func fetchList() {
        currentTimeSheetModel.removeAll()
        guard let queue = AppDatabase.shared.dbQueue else {return}
        let COLUMNS = RepositoryConstants.Columns.self
        let TABLES  = RepositoryConstants.Tables.self
        var removedCondition = ""
        if !toShowRemoved {
            removedCondition = "WHERE TC.\(COLUMNS.REMOVED) = 0"
        }
        else {
            removedCondition = "WHERE TC.\(COLUMNS.REMOVED) = 1"
        }
        let condition = "\(removedCondition) AND \(COLUMNS.IsPayrollCreated) != 1"
        
        let sql = """
            Select TC.*,
            W.\(COLUMNS.FIRST_NAME),
            W.\(COLUMNS.LAST_NAME),
            ROW_NUMBER() OVER (ORDER BY TC.\(COLUMNS.DATE_ENTERED)) AS RowNum
            FROM \(TABLES.CURRENT_TIME_SHEETS) TC
            JOIN \(TABLES.WORKERS) W ON W.\(COLUMNS.WORKER_ID) = TC.\(COLUMNS.WORKER_ID)
            \(condition)
        """
//        print(sql)
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
    }
    
    
    //MARK: - HELPER FUNCTIONS
    func initialSetup() {
        self.navigationController?.isNavigationBarHidden = false
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
                (singleData.lunchStop!.contains(key)))
            {
                tempArr.append(singleData)
            }
        }
        filteredModel = tempArr
        dataTable.reload()
    }
    
    

}

//MARK: UITABLEVIEW DELEGATES AND DATASOURCE
extension TimeSheetsVC: SwiftDataTableDataSource, SwiftDataTableDelegate {
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
    }
    
    func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
        //self.presentActionSheet(index: indexPath.section, indexpath: indexPath)
    }
    
    func numberOfColumns(in: SwiftDataTable) -> Int {
        return columnArray.count
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
