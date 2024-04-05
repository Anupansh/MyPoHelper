//
//  TimeSheetCollectionCell.swift
//  MyProHelper
//
//  Created by sismac010 on 25/11/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit
import SwiftDataTables
import GRDB
import SideMenu

class TimeSheetCollectionCell: UICollectionViewCell {

    static let ID = String(describing: TimeSheetCollectionCell.self)
    
    @IBOutlet weak private var dataTableContainerView: UIView!
    
    // MARK: - OUTLETS AND VARIABLES
    var filteredModel = [TimeSheetListModel]()
    var currentTimeSheetModel = [TimeSheetListModel]()
    var isSearching = false
    var columnArray = ["No.","Worker Name","Description","Date Worked","Start Time","End Time","Break Start","Break Stop","Lunch Start","Lunch Stop","Work Time","Break Time","Lunch Time"]
    var toShowRemoved = false
    var workerModel = [Worker]()
    private var dataTable: SwiftDataTable!
//    var showRemovedSwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
//    var showRemovedButton: UIBarButtonItem?

    // MARK: - VIEW LIFECYCLE
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
        fetchList()
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
        let workerID = AppLocals.worker.workerID!
        var roleCondition = ""
        if !AppLocals.workerRole.role.canRunPayroll! {
            roleCondition   = "AND main.\(RepositoryConstants.Tables.CURRENT_TIME_SHEETS).\(RepositoryConstants.Columns.WORKER_ID) = \(workerID)"
        }
        if AppLocals.workerRole.role.techSupport! || AppLocals.workerRole.role.owner! {
            roleCondition = ""
        }
        var sql = """
            Select
            \(RepositoryConstants.Tables.WORKERS).\(RepositoryConstants.Columns.FIRST_NAME),
            \(RepositoryConstants.Tables.WORKERS).\(RepositoryConstants.Columns.LAST_NAME),
            *
            from main.\(RepositoryConstants.Tables.CURRENT_TIME_SHEETS)
            LEFT JOIN main.\(RepositoryConstants.Tables.WORKERS) ON main.\(RepositoryConstants.Tables.CURRENT_TIME_SHEETS).\(RepositoryConstants.Columns.WORKER_ID) =
                main.\(RepositoryConstants.Tables.WORKERS).\(RepositoryConstants.Columns.WORKER_ID)
            LEFT JOIN main.\(RepositoryConstants.Tables.WORKER_ROLES) ON main.\(RepositoryConstants.Tables.CURRENT_TIME_SHEETS).\(RepositoryConstants.Columns.WORKER_ID) =
                main.\(RepositoryConstants.Tables.WORKER_ROLES).\(RepositoryConstants.Columns.WORKER_ID)
            \(removedCondition)
            \(roleCondition)
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
//                print(rows)
                while let row = try rows.next() {
//                    print(row)
                    let singleTimeSheet = TimeSheetListModel.init(row: row)
                    currentTimeSheetModel.append(singleTimeSheet)
                }
            }
            dataTable.reload()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    private func makeSortableItems(sortType: SortType?) -> String {
        return BaseRepository(table: .CURRENT_TIME_SHEETS).makeSortableCondition(key: RepositoryConstants.Columns.DateWorked, sortType: sortType!)
    }
    
    
    //MARK: - HELPER FUNCTIONS
    func initialSetup() {
        initializeDataTable()
        setupDataTableLayout()
        dataTable.reload()
//        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: .serverChanges, object: nil)
    }
    
    @objc func refreshData() {
        fetchList()
    }
    
    
    private func initializeDataTable() {
        var option = DataTableConfiguration()
        option.shouldContentWidthScaleToFillFrame = true
        dataTable = SwiftDataTable(dataSource: self, options: option)
        dataTable.dataSource = self
        dataTable.delegate = self
        dataTable.backgroundColor = UIColor.init(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
    }
    
    private func setupDataTableLayout() {
        dataTable.translatesAutoresizingMaskIntoConstraints = false
        dataTableContainerView.backgroundColor = UIColor.white
        dataTableContainerView.addSubview(dataTable)
        
        NSLayoutConstraint.activate([
            dataTable.topAnchor.constraint(equalTo: dataTableContainerView.topAnchor),
            dataTable.leadingAnchor.constraint(equalTo: dataTableContainerView.leadingAnchor),
            dataTable.bottomAnchor.constraint(equalTo: dataTableContainerView.bottomAnchor),
            dataTable.trailingAnchor.constraint(equalTo: dataTableContainerView.trailingAnchor),
        ])
    }
    
    func tableValue(index: NSInteger) -> [DataTableValueType] {
        var data = [DataTableValueType]()
        let singleData = isSearching ? filteredModel[index] : currentTimeSheetModel[index]
//        data.append(DataTableValueType.string("⚙️"))
        data.append(DataTableValueType.string("\(index+1)"))
        data.append(DataTableValueType.string(singleData.workerName ?? "-"))
        data.append(DataTableValueType.string(singleData.description ?? "-"))
        var formattedDateWorked = DateManager.standardDateToStringWithoutHours(date: singleData.dateWorked)
        formattedDateWorked = formattedDateWorked.isEmpty ? "-" : formattedDateWorked
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
        var tempArr = [TimeSheetListModel]()
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
    
}

//MARK: UITABLEVIEW DELEGATES AND DATASOURCE
extension TimeSheetCollectionCell: SwiftDataTableDataSource, SwiftDataTableDelegate {
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
//        self.presentActionSheet(index: indexPath.section, indexpath: indexPath)
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
        return DataTableFixedColumnType.init(leftColumns: 1)
    }
    
    func dataTable(_ dataTable: SwiftDataTable, widthForColumnAt index: Int) -> CGFloat {
        if index == 0 {
            return 80
        }
        else if index == 2 {
            return 300
        }
        else {
            return 200
        }
    }
    
}


