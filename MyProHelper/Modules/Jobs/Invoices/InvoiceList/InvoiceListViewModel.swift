//
//  InvoiceListViewModel.swift
//  MyProHelper
//
//  Created by Deep on 2/3/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

class InvoiceListViewModel: BaseDataTableViewModel<Invoice, InvoiceField> {
    
    private let service = InvoiceService()
    
    override func reloadData() {
        hasMoreData = true
        fetchInvoice(reloadData: true)
    }
    
    override func fetchMoreData() {
        fetchInvoice(reloadData: false)
    }
    
    private func fetchInvoice(reloadData: Bool) {
        guard hasMoreData else { return }
        let offset = (reloadData == false) ? data.count : 0

        service.fetchInvoices(showRemoved: isShowingRemoved,isApproval: isApprovals, key: searchKey, sortBy: sortWith?.sortBy, sortType: sortWith?.sortType, offset: offset) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let invoices):
                self.hasMoreData = invoices.count == Constants.DATA_OFFSET
                if reloadData {
                    self.data = invoices
                }
                else {
                    self.data.append(contentsOf: invoices)
                }
                self.delegate.reloadView()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
    
    override func deleteItem(at row: Int) {
        let invoice = data[row]
        service.deleteInvoice(invoice: invoice) { [weak self] (result) in
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
        let invoice = data[row]
        service.restoreInvoice(invoice: invoice) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.reloadData()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
}
