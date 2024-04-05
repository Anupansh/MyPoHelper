//
//  CustomerListViewModel.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 16/04/1942 Saka.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

class CustomerListViewModel: BaseDataTableViewModel<Customer, CustomerField> {
    
    private let service = CustomersService()
    
    override func reloadData() {
        hasMoreData = true
        fetchCustomers(reloadData: true)
    }
    
    override func fetchMoreData() {
        fetchCustomers(reloadData: false)
    }
    
    override func deleteItem(at row: Int) {
        let customer = data[row]
        service.deleteCustomer(customer) { [weak self] (result) in
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
        let customer = data[row]
        service.restoreCustomer(customer) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.reloadData()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
    
    private func fetchCustomers(reloadData: Bool) {
        guard hasMoreData else { return }
        let offset = (reloadData == false) ? data.count : 0
        
        service.fetchCustomers(showRemoved: isShowingRemoved, key: searchKey, sortBy: sortWith?.sortBy, sortType: sortWith?.sortType, offset: offset) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let customers):
                self.hasMoreData = customers.count == Constants.DATA_OFFSET
                if reloadData {
                    self.data = customers
                }
                else {
                    self.data.append(contentsOf: customers)
                }
                self.delegate.reloadView()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
}
