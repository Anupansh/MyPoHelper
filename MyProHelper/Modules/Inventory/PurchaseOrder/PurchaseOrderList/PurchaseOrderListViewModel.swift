//
//  PurchaseOrderListViewModel.swift
//  MyProHelper
//
//  Created by sismac010 on 19/03/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation


class PurchaseOrderListViewModel: BaseDataTableViewModel<PurchaseOrder, PurchaseOrderField> {

    private let service = PurchaseOrderService()
    
    override func reloadData() {
        hasMoreData = true
        fetchPurchaseOrder(reloadData: true)
    }
    
    override func fetchMoreData() {
        fetchPurchaseOrder(reloadData: false)
    }
    
    private func fetchPurchaseOrder(reloadData: Bool) {
        guard hasMoreData else { return }
        let offset = (reloadData == false) ? data.count : 0
        
        service.fetchPurchaseOrders(showRemoved: isShowingRemoved,
                              key: searchKey,
                              sortBy: sortWith?.sortBy,
                              sortType: sortWith?.sortType,
                              offset: offset) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let purchaseOrdersArray):
                self.hasMoreData = purchaseOrdersArray.count == Constants.DATA_OFFSET
                if reloadData {
                    self.data = purchaseOrdersArray
                }
                else {
                    self.data.append(contentsOf: purchaseOrdersArray)
                }
                self.delegate.reloadView()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
    
    override func deleteItem(at row: Int) {
        let purchaseOrder = data[row]
        service.deletePurchaseOrder(purchaseOrder: purchaseOrder) { [weak self] (result) in
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
        let purchaseOrder = data[row]
        service.undeletePurchaseOrder(purchaseOrder: purchaseOrder) { [weak self] (result) in
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
