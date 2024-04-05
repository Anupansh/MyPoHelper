//
//  PurchaseOrderModal.swift
//  MyProHelper
//
//  Created by Sarvesh on 21/04/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation


class PurchaseOrderModal: BaseDataTableViewModel<PurchaseOrder, PurchaseOrderField1> {

    private let service = PurchaseOrderService()
    
    override func reloadData() {
        hasMoreData = true
        fetchPurchaseOrder(reloadData: true)
    }
    
    override func fetchMoreData() {
        fetchPurchaseOrder(reloadData: true)
    }
    
    private func fetchPurchaseOrder(reloadData: Bool) {
        guard hasMoreData else { return }
        let offset = (reloadData == false) ? data.count : 0
        
        service.fetchPurchaseOrders(showRemoved: isShowingRemoved, offset: offset, key: searchKey) { [weak self] (result) in
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
