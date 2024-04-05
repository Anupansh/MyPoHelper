//
//  CallLogCollectionCell.swift
//  MyProHelper
//
//  Created by sismac010 on 26/10/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit
import SwiftDataTables

enum CallLogFields: String {
    case CONTACT_NAME         = "NAME"
    case DESCRIPTION          = "DESCRIPTION"
    case CONTACT_PHONE        = "PHONE"
    case CUSTOMER_NAME        = "CUSTOMER"
//    case DATE_CREATED         = "DATE_CREATED"
    
    func stringValue() -> String {
        return self.rawValue.localize
    }
}


class CallLogCollectionCell: UICollectionViewCell, SwiftDataTableDelegate {
    static let ID = String(describing: CallLogCollectionCell.self)
    
    @IBOutlet weak private var dataTableContainerView: UIView!
    private var dataTable: SwiftDataTable!
    
    
    private let dataTableFields: [CallLogFields] = [.CONTACT_NAME,
                                                    .DESCRIPTION,
                                                    .CONTACT_PHONE,
                                                    .CUSTOMER_NAME,
//                                                    .DATE_CREATED
                                                    ]
    private var searchKey: String?
    private var sortType: SortType?
    private var sortField: CallLogFields?
    private let service = CallLogsService()
    var hasMoreData:Bool = true
    var isShowingRemoved:Bool = false
    var hasDecimalAlignRightSide:Bool = false
    var data:[CallLog] = []
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initializeDataTable()
        setupDataTableLayout()
        fetchCallLogs(reloadData: true)
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
    
    private func getHeader(for columnIndex: NSInteger) -> String {
        return dataTableFields[columnIndex].stringValue()
    }
    
    private func fetchCallLogs(reloadData: Bool) {
        guard hasMoreData else { return }
        let offset = (reloadData == false) ? data.count : 0
        service.fetchCallLogs(showRemoved: isShowingRemoved, key: searchKey, sortBy: .CONTACT_NAME, sortType: .ASCENDING, offset: offset) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let estimate):
                self.hasMoreData = estimate.count == Constants.DATA_OFFSET
                if reloadData {
                    self.data = estimate
                }
                else {
                    self.data.append(contentsOf: estimate)
                }
                self.dataTable.reload()
            case .failure(let error):
                break
//                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
    
    func didSearchForKey(_ dataTable: SwiftDataTable, Key: String) {
        searchKey = Key
        fetchCallLogs(reloadData: true)
    }
    
    private func createData(at index: NSInteger) -> [DataTableValueType] {
//        guard let viewModel = viewModel else { return [] }
//        let device = ["⚙️"] + viewModel.getDevice(at: index).getDataArray()
//        let quotes = data[index].getDataArray()
//        return quotes.compactMap(DataTableValueType.init)
        
        var tmp:[[Any]] = []
        if hasDecimalAlignRightSide{
            
            var dicAlignColom:[Int:Int] = [:]
            
            data.forEach { obj in
                for index in obj.decimalAlignRightSideIndex(){
                    var maxLength = dicAlignColom[index] ?? 0
                    let fieldValue = (obj.getDataArray()[index] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                    if !fieldValue.isEmpty, maxLength < fieldValue.count{
                        maxLength = fieldValue.count
                    }
                    dicAlignColom[index] = maxLength
                }
            }
            
            data.forEach { Obj in
                var tmp2:[Any] = []
                if dicAlignColom.keys.count > 0{
                    var i = 0
                    Obj.getDataArray().forEach { obj2 in
                        let fieldValue = (obj2 as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                        if dicAlignColom.keys.contains(i), let maxLength = dicAlignColom[i], maxLength > fieldValue.count{
                            var result = " "
                            result += fieldValue.PadLeft(totalWidth: maxLength, byString: "0")
                            result += " "
                            tmp2.append(result)
                        }
                        else if dicAlignColom.keys.contains(i){
                            tmp2.append(" \(fieldValue) ")
                        }
                        else{
                            tmp2.append(obj2)
                        }
                        
                        i += 1
                    }
                }
                else{
                    tmp2.append(contentsOf: Obj.getDataArray())
                }
                
                
                tmp.append(tmp2)
            }
            
        }
        else{
            tmp = data.map { $0.getDataArray() }
        }
        
        let userArray = tmp
        return userArray[index].compactMap(DataTableValueType.init)
    }
    
    func heightForSectionFooter(in dataTable: SwiftDataTable) -> CGFloat {
        return 0
    }

    
    

}

//MARK: - Swift data source methods
extension CallLogCollectionCell: SwiftDataTableDataSource {

    func numberOfColumns(in: SwiftDataTable) -> Int {
        return dataTableFields.count// + 1
    }

    func numberOfRows(in: SwiftDataTable) -> Int {
        return data.count//viewModel?.countDevices() ?? 0
    }

    func dataTable(_ dataTable: SwiftDataTable, dataForRowAt index: NSInteger) -> [DataTableValueType] {
        return createData(at: index)
    }

    func dataTable(_ dataTable: SwiftDataTable, headerTitleForColumnAt columnIndex: NSInteger) -> String {
        return getHeader(for: columnIndex)
//        if columnIndex == 0 {
//            return "ACTION".localize
//        }
//        return getHeader(for: columnIndex - 1)
    }

    func didTapSort(_ dataTable: SwiftDataTable, type: DataTableSortType, column: Int) {
        sortType  = (type == DataTableSortType.ascending) ? .ASCENDING : .DESCENDING
        sortField = dataTableFields[column - 1]
        fetchCallLogs(reloadData: true)
        
    }
}
