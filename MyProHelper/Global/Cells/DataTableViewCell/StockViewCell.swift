//
//  StockViewCell.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 11/8/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit
import SwiftDataTables

protocol StockViewDelegate {
    
    func willAddStock()
    func willEditStock(at index: Int)
}

class dataTableViewCell: UITableViewCell {

    static let ID = "StockViewCell"
    
    @IBOutlet weak private var addStockButton           : UIButton!
    @IBOutlet weak private var stockTableContainerView  : UIView!
    
    private var dataTable: SwiftDataTable!
    private var stockData: [RepositoryBaseModel] = []
    private var fields: [String] = []
    
    var delegate: StockViewDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func initializeDataTable() {
        dataTable = SwiftDataTable(dataSource: self)
        dataTable.dataSource = self
        dataTable.delegate = self
        dataTable.backgroundColor = UIColor.init(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
    }
    
    private func setupDataTableLayout() {
        dataTable.translatesAutoresizingMaskIntoConstraints = false
        stockTableContainerView.backgroundColor = UIColor.white
        stockTableContainerView.addSubview(dataTable)
        NSLayoutConstraint.activate([
            dataTable.topAnchor.constraint(equalTo: stockTableContainerView.layoutMarginsGuide.topAnchor),
            dataTable.leadingAnchor.constraint(equalTo: stockTableContainerView.leadingAnchor),
            dataTable.bottomAnchor.constraint(equalTo: stockTableContainerView.layoutMarginsGuide.bottomAnchor),
            dataTable.trailingAnchor.constraint(equalTo: stockTableContainerView.trailingAnchor),
        ])
    }
    
    private func createData(at index: NSInteger) -> [DataTableValueType] {
        let userArray = stockData.map { $0.getDataArray() }
        return userArray[index].compactMap(DataTableValueType.init)
    }
    
    @IBAction private func addStockButtonPressed(sender: UIButton) {
        delegate?.willAddStock()
    }
    
    func bindData(stockData: [RepositoryBaseModel], fields: [String]) {
        self.stockData = stockData
        self.fields = fields
    }
    
}

//MARK: - Swift data source methods
extension dataTableViewCell: SwiftDataTableDataSource, SwiftDataTableDelegate {
    
    func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
        delegate?.willEditStock(at: indexPath.row)
    }
    
    func didTapSort(_ dataTable: SwiftDataTable, type: DataTableSortType, column: Int) {
        
    }
    
    func numberOfColumns(in: SwiftDataTable) -> Int {
        return fields.count
    }

    func numberOfRows(in: SwiftDataTable) -> Int {
        return stockData.count
    }

    func dataTable(_ dataTable: SwiftDataTable, dataForRowAt index: NSInteger) -> [DataTableValueType] {
        return createData(at: index)
    }

    func dataTable(_ dataTable: SwiftDataTable, headerTitleForColumnAt columnIndex: NSInteger) -> String {
        return fields[columnIndex]
    }
}
