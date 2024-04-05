//
//  StockedPartsListCollectionCell.swift
//  MyProHelper
//
//  Created by sismac010 on 19/11/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit
import SwiftDataTables

enum StockedPartFields: String {
    case NO_DOT                 = "NO_DOT"
    case PART_NAME              = "PART_NAME"
    case DESCRIPTION            = "DESCRIPTION"
    case PURCHASED_FROM         = "PURCHASED_FROM"
    case PART_LOCATION          = "PART_LOCATION"
    case QUANTITY               = "QUANTITY"
    case WAITING_COUNT          = "WAITING_COUNT"
    case PURCHASED_DATE         = "PURCHASED_DATE"
    
    func stringValue() -> String {
        return self.rawValue.localize
    }
}

class StockedPartsListCollectionCell: UICollectionViewCell ,SwiftDataTableDelegate{
    static let ID = String(describing: StockedPartsListCollectionCell.self)
    
    @IBOutlet weak private var dataTableContainerView: UIView!
    private var dataTable: SwiftDataTable!
    
    private let dataTableFields: [StockedPartFields] = [
                                                .NO_DOT,
                                                .PART_NAME,
                                                .DESCRIPTION,
                                                .PURCHASED_FROM,
                                                .PART_LOCATION,
                                                .QUANTITY,
                                                .WAITING_COUNT,
                                                .PURCHASED_DATE
                                                ]
//    private let dataTableFields: [BillingInvoice] = [
//                                                .NO_DOT,
//                                                .CUSTOMER_NAME,
//                                                .DESCRIPTION,
//                                                .PRICE_QUOTED,
//                                                .ADJUSTMENT_AMOUNT,
//                                                .STATUS,
//                                                .COMPLETED_DATE
//                                                ]
    
    private var searchKey: String?
    private var sortType: SortType?
    private var sortField: StockedPartFields?
    var hasMoreData:Bool = true
    var isShowingRemoved:Bool = false
    var isApprovals:Bool = false
    var data:[StockedPart] = []
    var hasDecimalAlignRightSide:Bool = false
    private let service = PartsService()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initializeDataTable()
        setupDataTableLayout()
        fetchStockedParts(reloadData: true)
    }
        
    private func initializeDataTable() {
        var option = DataTableConfiguration()
        option.shouldContentWidthScaleToFillFrame = true
        dataTable = SwiftDataTable(dataSource: self, options: option)
        dataTable.dataSource = self
        dataTable.delegate = self
        dataTable.backgroundColor = UIColor.init(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        hasDecimalAlignRightSide = true
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
    
    private func fetchStockedParts(reloadData: Bool) {
        guard hasMoreData else { return }
        let offset = (reloadData == false) ? data.count : 0
        service.fetchStockedParts(showRemoved: isShowingRemoved,isApproval: isApprovals, key: searchKey, sortBy: .PART_NAME, sortType: .ASCENDING, offset: offset) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let stockedParts):
                self.hasMoreData = stockedParts.count == Constants.DATA_OFFSET
                if reloadData {
                    self.data = stockedParts
                }
                else {
                    self.data.append(contentsOf: stockedParts)
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
        fetchStockedParts(reloadData: true)
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
//                tmp2.append(contentsOf: ["\(index+1)"] )
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
            tmp =  data.map { /*["\(index+1)"] + */$0.getDataArray() }
        }
        let userArray = tmp
        return userArray[index].compactMap(DataTableValueType.init)
    }
    
    func heightForSectionFooter(in dataTable: SwiftDataTable) -> CGFloat {
        return 0
    }

        

}


//MARK: - Swift data source methods
extension StockedPartsListCollectionCell: SwiftDataTableDataSource {

    func numberOfColumns(in: SwiftDataTable) -> Int {
        return dataTableFields.count //+ 1
    }

    func numberOfRows(in: SwiftDataTable) -> Int {
        return data.count//viewModel?.countDevices() ?? 0
    }

    func dataTable(_ dataTable: SwiftDataTable, dataForRowAt index: NSInteger) -> [DataTableValueType] {
        return createData(at: index)
    }

    func dataTable(_ dataTable: SwiftDataTable, headerTitleForColumnAt columnIndex: NSInteger) -> String {
        return getHeader(for: columnIndex)
//
//        if columnIndex == 0 {
//            return "ACTION".localize
//        }
//        return getHeader(for: columnIndex - 1)
    }

    func didTapSort(_ dataTable: SwiftDataTable, type: DataTableSortType, column: Int) {
        sortType  = (type == DataTableSortType.ascending) ? .ASCENDING : .DESCENDING
        sortField = dataTableFields[column - 1]
        fetchStockedParts(reloadData: true)
        
    }
}
