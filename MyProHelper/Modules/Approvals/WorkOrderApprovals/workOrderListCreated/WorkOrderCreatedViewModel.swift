//
//  WorkOrderCreatedViewModel.swift
//  MyProHelper
//
//  Created by Pooja Mishra on 01/04/1943 Saka.
//  Copyright © 1943 Benchmark Computing. All rights reserved.
//


import Foundation



class  WorkOrderCreatedViewModel: BaseDataTableViewModel<WorkOrder, WorkOrderField2> {
    
    private let service = WorkOrderService()
    
    override func reloadData() {
        hasMoreData = true
        fetchWorkOrder(reloadData: true)
    }
    
    override func fetchMoreData() {
        fetchWorkOrder(reloadData: false)
    }

    private func fetchWorkOrder(reloadData: Bool) {
        guard hasMoreData else { return }
        let offset = (reloadData == false) ? data.count : 0
        
        service.fetchWorkOrders(showRemoved: isShowingRemoved, key: searchKey, offset: offset) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let workOrdersArray):
                self.hasMoreData = workOrdersArray.count == Constants.DATA_OFFSET
                if reloadData {
                    self.data = workOrdersArray
                }
                else {
                    self.data.append(contentsOf: workOrdersArray)
                }
                self.delegate.reloadView()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
    
    override func deleteItem(at row: Int) {
        let workOrder = data[row]
        service.deleteWorkOrder(workOrder: workOrder) { [weak self] (result) in
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
        let workOrder = data[row]
        service.undeleteWorkOrder(workOrder: workOrder) { [weak self] (result) in
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
