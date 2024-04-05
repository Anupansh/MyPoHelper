//
//  PaymentListViewModel.swift
//  MyProHelper
//
//  Created by Samir on 07/02/2021.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

class PaymentListViewModel: BaseDataTableViewModel<Payment, PaymentListField> {

    private let service = PaymentService()

    override func reloadData() {
        hasMoreData = true
        fetchService(reloadData: true)
    }

    override func fetchMoreData() {
        fetchService(reloadData: false)
    }

    override func deleteItem(at row: Int) {
        let payment = data[row]
        service.deletePayment(payment: payment) { [weak self] (result) in
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
        let payment = data[row]
        service.restorePayment(payment: payment) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.reloadData()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }

    private func fetchService(reloadData: Bool) {
        guard hasMoreData else { return }
        let offset = (reloadData == false) ? data.count : 0
        service.fetchPayment(showRemoved: isShowingRemoved,
                             key: searchKey,
                             sortBy: sortWith?.sortBy,
                             sortType: sortWith?.sortType,
                             offset: offset) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let services):
                self.hasMoreData = services.count == Constants.DATA_OFFSET
                if reloadData {
                    self.data = services
                }
                else {
                    self.data.append(contentsOf: services)
                }
                self.delegate.reloadView()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
}
