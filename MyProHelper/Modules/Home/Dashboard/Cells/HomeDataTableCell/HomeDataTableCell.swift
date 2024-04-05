//
//  HomeDataTableCell.swift
//  MyProHelper
//
//  Created by Anupansh on 13/04/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit
import SwiftDataTables
import GRDB

class HomeDataTableCell: UITableViewCell {
    
    @IBOutlet weak var dataTableView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var currentJobsBtn: UIButton!
    
    var filteredJobList = [Job]()
    var jobList = [Job]()
    var isSearching = false
    var vc: UIViewController?
    var dataTable: SwiftDataTable!
    var columnName = ["Action","Customer Name","Contact Name","Phone Number","Address","Schedule Date/Time","Description"]
//    var isJobPicked = false
    var selectedJob = Job()
    var nextJob: Job?
    var selectedIndex: Int?

    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initialSetup() {
        currentJobsBtn.isHidden = true
        dataTable = SwiftDataTable(dataSource: self)
        dataTable.dataSource = self
        dataTable.delegate = self
        setupConstraints()
        self.showSnackbar()
    }
    
    @IBAction func currentJobsBtnPressed(_ sender: Any) {
//        let vc = AppStoryboards.home.instantiateViewController(withIdentifier: CurrentJobsVC.className) as! CurrentJobsVC
//        vc.job = selectedJob
//        // Checking if next job exists
//        let jobs = isSearching ?filteredJobList:jobList
//        if jobs.indices.contains(selectedIndex! + 1) {
//            vc.nextJob = nextJob
//        }
//        vc.delegate = self
//        self.vc?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableValue(index: NSInteger) -> [DataTableValueType] {
        var data = [DataTableValueType]()
        let singleData = isSearching ? filteredJobList[index] : jobList[index]
        if selectedJob.jobID == singleData.jobID {
            data.append(DataTableValueType.string("Picked"))
            let jobs = isSearching ? filteredJobList:jobList
            self.selectedJob = jobs[index]
            self.selectedIndex = index
        }
        else {
            data.append(DataTableValueType.string("⚙️ Pick"))
        }
        data.append(DataTableValueType.string(singleData.customer?.customerName ?? "-"))
        data.append(DataTableValueType.string(singleData.jobContactPersonName ?? "-"))
        data.append(DataTableValueType.string(singleData.jobContactPhone ?? "-"))
        data.append(DataTableValueType.string(singleData.jobLocationAddress1 ?? "-"))
        data.append(DataTableValueType.string(DateManager.getStandardDateString(date: singleData.startDateTime)))
        data.append(DataTableValueType.string(singleData.jobShortDescription ?? "-"))
        return data
    }
    
    func fetchList(key: String) {
        filteredJobList.removeAll()
        var tempArr = [Job]()
        for request in jobList {
            let customerName = request.customer?.customerName ?? ""
            if ((customerName.contains(key)) || (request.jobContactPersonName!.contains(key)) || (request.jobContactPhone!.contains(key)) || (request.jobLocationAddress1!.contains(key)) || (request.jobShortDescription!.contains(key))) {
                tempArr.append(request)
            }
        }
        filteredJobList = tempArr
        dataTable.reload()
        self.showSnackbar()
    }
    
    fileprivate func showSnackbar(){
        
        DispatchQueue.main.async {
            if self.isSearching {
                self.filteredJobList.count == 0 ? self.dataTable.setEmptyMessage(show: true, message: Constants.Message.No_Data_To_Display) : self.dataTable.setEmptyMessage(show: false, message: "")
            }else {
                self.jobList.count == 0 ? self.dataTable.setEmptyMessage(show: true, message: Constants.Message.No_Data_To_Display) : self.dataTable.setEmptyMessage(show: false, message: "")
            }
        }
        
    }
    
    
    func setupConstraints() {
        dataTable.translatesAutoresizingMaskIntoConstraints = false
        dataTableView.addSubview(dataTable)
        NSLayoutConstraint.activate([
            dataTable.topAnchor.constraint(equalTo: dataTableView.layoutMarginsGuide.topAnchor),
            dataTable.leadingAnchor.constraint(equalTo: dataTableView.leadingAnchor),
            dataTable.bottomAnchor.constraint(equalTo: dataTableView.layoutMarginsGuide.bottomAnchor),
            dataTable.trailingAnchor.constraint(equalTo: dataTableView.trailingAnchor),
        ])
        dataTable.reload()
    }
    
}

extension HomeDataTableCell: SwiftDataTableDelegate, SwiftDataTableDataSource {
    func didTapSort(_ dataTable: SwiftDataTable, type: DataTableSortType, column: Int) {
        
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
    
    func numberOfColumns(in: SwiftDataTable) -> Int {
        
        if isSearching {
            if filteredJobList.count == 0 {
                return 0
            } else {
                return columnName.count
            }
        } else {
            if jobList.count == 0 {
                return 0
            } else {
                return columnName.count
            }
        }
        
    }
    
    func numberOfRows(in: SwiftDataTable) -> Int {
        isSearching ? filteredJobList.count : jobList.count
    }
    
    func dataTable(_ dataTable: SwiftDataTable, dataForRowAt index: NSInteger) -> [DataTableValueType] {
        return tableValue(index: index)
    }
    
    func dataTable(_ dataTable: SwiftDataTable, headerTitleForColumnAt columnIndex: NSInteger) -> String {
        return columnName[columnIndex]
    }
    
    func fixedColumns(for dataTable: SwiftDataTable) -> DataTableFixedColumnType {
        return DataTableFixedColumnType.init(leftColumns: 1)
    }
    
    func heightForSectionFooter(in dataTable: SwiftDataTable) -> CGFloat {
        return 0
    }
    
    func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
        
        // Setting current job and next job
        let list = isSearching ? filteredJobList: jobList
        currentJobsBtn.isHidden = true
        selectedJob = list[indexPath.section]
        if list.indices.contains(indexPath.section + 1) {
            nextJob = list[indexPath.section + 1]
        }
        dataTable.reload()
        
        // Passing data to next vc
        let vc = AppStoryboards.home.instantiateViewController(withIdentifier: CurrentJobsVC.className) as! CurrentJobsVC
        let jobs = isSearching ?filteredJobList:jobList
        vc.job = selectedJob
        vc.jobList = self.jobList
        // Checking if next job exists
        if jobs.indices.contains(selectedIndex! + 1) {
            vc.nextJob = nextJob
        }
        self.vc?.navigationController?.pushViewController(vc, animated: true)
    }
    
}

