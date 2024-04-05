//
//  SupplyListViewModel.swift
//  MyProHelper
//
//  Created by sismac010 on 09/03/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit
import GRDB

class SupplyListViewModel: BaseDataTableViewModel<Supply, SupplyField> {

    private let service = SupplyService()
//    private let stockService = PartFinderService()
    
    func hasWaitingJobs(at index: Int) -> Bool{
//        guard let partUsed = data[index].partUsed else {
//            return false
//        }
//        return partUsed.waitingForPart ?? false
        return false
    }
    
    override func reloadData() {
        hasMoreData = true
        fetchSupply(reloadData: true)
    }
    
    override func fetchMoreData() {
        fetchSupply(reloadData: false)
    }
    
    override func deleteItem(at row: Int) {
        let supply = data[row]
        service.deleteSupply(supply: supply) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.reloadData()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
    
    override func undeleteItem(at row: Int) {
        let supply = data[row]
        service.undeleteSupply(supply: supply) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.reloadData()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }

    private func fetchSupply(reloadData: Bool) {
        guard hasMoreData else { return }
        let offset = (reloadData == false) ? data.count : 0
        
        service.fetchSupplies(showRemoved: isShowingRemoved,
                              key: searchKey,
                              sortBy: sortWith?.sortBy,
                              sortType: sortWith?.sortType,
                              offset: offset) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let partArray):
                self.hasMoreData = partArray.count == Constants.DATA_OFFSET
                if reloadData {
                    self.data = partArray
                }
                else {
                    self.data.append(contentsOf: partArray)
                }
                self.delegate.reloadView()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
    
    func getInvoiceWaitingForJob(partId: Int) -> [PartWaitingForInvoice] {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return []}
        var partsWaiting = [PartWaitingForInvoice]()
        let tables = RepositoryConstants.Tables.self
        let columns = RepositoryConstants.Columns.self
        var sql = """
            select * from \(tables.INVOICES) i join \(tables.SUPPLIES_USED) su join \(tables.CUSTOMERS) c join \(tables.SUPPLIES) s where c.\(columns.CUSTOMER_ID) = i.\(columns.CUSTOMER_ID) AND
            i.\(columns.INVOICE_ID) = su.\(columns.INVOICE_ID) and s.\(columns.SUPPLY_ID) = su.\(columns.SUPPLY_ID) and su.\(columns.WAITING_FOR_SUPPLY) = 1 and su.\(columns.SUPPLY_ID) = \(partId)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        sql += """
            Group By su.\(columns.SUPPLY_ID) order by su.\(columns.SUPPLY_ID)
        """
        do {
            try queue.read({ (db) in
                let rows = try Row.fetchCursor(db, sql: sql)
                while let row = try rows.next() {
                    let partWaiting = PartWaitingForInvoice(row: row, isPart: false)
                    partsWaiting.append(partWaiting)
                }
            })
        }
        catch(let error) {
            print(error.localizedDescription)
        }
        return partsWaiting
    }

}
