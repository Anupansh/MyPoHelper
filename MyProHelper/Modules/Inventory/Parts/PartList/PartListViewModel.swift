//
//  PartListViewModel.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/25/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB

class PartListViewModel: BaseDataTableViewModel<Part, PartField> {
    
    private let service = PartsService()
    private let stockService = PartFinderService()
    
    func hasWaitingJobs(at index: Int) -> Bool{
//        guard let partUsed = data[index].partUsed else {
//            return false
//        }
//        return partUsed.waitingForPart ?? false
        return false
    }
    
    override func reloadData() {
        hasMoreData = true
        fetchParts(reloadData: true)
    }
    
    override func fetchMoreData() {
        fetchParts(reloadData: false)
    }
    
    override func deleteItem(at row: Int) {
        let part = data[row]
        service.deletePart(part: part) { [weak self] (result) in
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
        let part = data[row]
        service.undeletePart(part: part) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.reloadData()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
    
    private func fetchParts(reloadData: Bool) {
        guard hasMoreData else { return }
        let offset = (reloadData == false) ? data.count : 0
        
        service.fetchParts(showRemoved: isShowingRemoved,key: searchKey, sortBy: sortWith?.sortBy, sortType: sortWith?.sortType, offset: offset) { [weak self] (result) in
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
            select * from \(tables.INVOICES) i join \(tables.PARTS_USED) pu join \(tables.CUSTOMERS) c join \(tables.PARTS) p where c.\(columns.CUSTOMER_ID) = i.\(columns.CUSTOMER_ID) AND
            i.\(columns.INVOICE_ID) = pu.\(columns.INVOICE_ID) and p.\(columns.PART_ID) = pu.\(columns.PART_ID) and pu.\(columns.WAITING_FOR_PART) = 1 and pu.\(columns.PART_ID) = \(partId)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        sql += """
            Group By pu.\(columns.PART_ID) order by pu.\(columns.PART_ID)
        """
        do {
            try queue.read({ (db) in
                let rows = try Row.fetchCursor(db, sql: sql)
                while let row = try rows.next() {
                    print(row)
                    let partWaiting = PartWaitingForInvoice(row: row, isPart: true)
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
