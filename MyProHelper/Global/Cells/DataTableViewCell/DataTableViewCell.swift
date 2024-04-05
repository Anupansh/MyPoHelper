//
//  StockViewCell.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 11/8/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit
import SwiftDataTables

protocol DataTableViewCellDelegate {
    
    func willAddItem(data: DataTableData)
    func didTapOnItem(at indePath: IndexPath, dataTable: SwiftDataTable, data: DataTableData)
    func fetchMoreData(data: DataTableData)
}

class DataTableViewCell: BaseFormCell {

    static let ID = "DataTableViewCell"
    
    @IBOutlet weak private var addStockButton                   : UIButton!
    @IBOutlet weak private var stockTableContainerView          : UIView!
    @IBOutlet weak private var addStockButtonHeightConstraint   : NSLayoutConstraint!
    
    private var dataTable: SwiftDataTable!
    private var stockData: [RepositoryBaseModel] = []
    private var fields: [String] = []
    private var dataTableData: DataTableData?
    
    var delegate: DataTableViewCellDelegate?
    var canAddValue: Bool = true
    var hasGearIcon: Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initializeDataTable()
        setupDataTableLayout()
        setAddButtonTitle()
    }
    
    private func initializeDataTable() {
        var option = DataTableConfiguration()
        option.shouldContentWidthScaleToFillFrame = true
        dataTable = SwiftDataTable(dataSource: self, options: option)
        dataTable.dataSource = self
        dataTable.delegate = self
        dataTable.backgroundColor = .clear
    }
    
    private func setupDataTableLayout() {
        dataTable.translatesAutoresizingMaskIntoConstraints = false
        stockTableContainerView.addSubview(dataTable)
        
        NSLayoutConstraint.activate([
            dataTable.topAnchor.constraint(equalTo: stockTableContainerView.layoutMarginsGuide.topAnchor),
            dataTable.leadingAnchor.constraint(equalTo: stockTableContainerView.leadingAnchor),
            dataTable.bottomAnchor.constraint(equalTo: stockTableContainerView.layoutMarginsGuide.bottomAnchor),
            dataTable.trailingAnchor.constraint(equalTo: stockTableContainerView.trailingAnchor),
        ])
    }
    
    private func createData(at index: NSInteger) -> [DataTableValueType] {
        let gearIcon = (hasGearIcon) ? ["⚙️"] : []
        let userArray = stockData.map { gearIcon + $0.getDataArray() }
        return userArray[index].compactMap(DataTableValueType.init)
    }
    
    private func setupAddButton() {
        if canAddValue {
            addStockButton.isHidden = false
            addStockButtonHeightConstraint.constant = Constants.Dimension.BUTTON_HEIGHT
        }
        else {
            addStockButton.isHidden = true
            addStockButtonHeightConstraint.constant = 0
        }
    }
    func setAddButtonTitle(title: String? = nil) {
        if let title = title {
            addStockButton.setTitle(title, for: .normal)
        }
        else {
            addStockButton.setTitle("ADD".localize, for: .normal)
        }
    }
    
    @IBAction private func addStockButtonPressed(sender: UIButton) {
        guard let data = self.dataTableData else {
            return
        }
        delegate?.willAddItem(data: data)
    }
    
    func bindData(stockData: [RepositoryBaseModel], fields: [String], canAddValue: Bool, data: DataTableData) {
        self.stockData = stockData
        self.fields = fields
        self.dataTable.reload()
        self.canAddValue = canAddValue
        self.dataTableData = data
        setupAddButton()
    }
    
    func setGearIcon(isAailable: Bool) {
        hasGearIcon = isAailable
    }
    
}

//MARK: - Swift data source methods
extension DataTableViewCell: SwiftDataTableDataSource, SwiftDataTableDelegate {
    
    func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
        guard let data = self.dataTableData else {
            return
        }
        delegate?.didTapOnItem(at: indexPath, dataTable: dataTable , data: data)
    }
    
    func didTapSort(_ dataTable: SwiftDataTable, type: DataTableSortType, column: Int) {
        
    }
    
    func numberOfColumns(in: SwiftDataTable) -> Int {
        if hasGearIcon {
            return fields.count + 1
        }
        return fields.count
    }

    func numberOfRows(in: SwiftDataTable) -> Int {
        return stockData.count
    }

    func dataTable(_ dataTable: SwiftDataTable, dataForRowAt index: NSInteger) -> [DataTableValueType] {
        return createData(at: index)
    }

    func dataTable(_ dataTable: SwiftDataTable, headerTitleForColumnAt columnIndex: NSInteger) -> String {
        if hasGearIcon {
            return (columnIndex == 0) ? "ACTION".localize : fields[columnIndex - 1]
        }
        return fields[columnIndex]
    }
    
    func shouldShowSearchSection(in dataTable: SwiftDataTable) -> Bool {
        return false
    }
    
    func willShowLastElement(_ collectionView: UICollectionView, indexPath: IndexPath, data: DataTableData) {
        guard let data = dataTableData else {
            return
        }
        delegate?.fetchMoreData(data: data)
    }
}
