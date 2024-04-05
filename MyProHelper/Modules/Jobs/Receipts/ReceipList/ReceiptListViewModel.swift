//
//  ReceiptListViewModel.swift
//  MyProHelper
//
//  Created by Deep on 2/15/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

class ReceiptListViewModel: BaseDataTableViewModel<Receipt,ReceiptListField> {
    
    private let service = ReceiptService()

    override func reloadData() {
        hasMoreData = true
        fetchReceipt(reloadData: true)
    }

    override func fetchMoreData() {
        fetchReceipt(reloadData: false)
    }
    
    private func fetchReceipt(reloadData: Bool) {
        guard hasMoreData else { return }
        let offset = (reloadData == false) ? data.count : 0
        service.fetchReceipt(showRemoved: isShowingRemoved,
                             key: searchKey,
                             sortBy: sortWith?.sortBy,
                             sortType: sortWith?.sortType,
                             offset: offset) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let receipts):
                self.hasMoreData = receipts.count == Constants.DATA_OFFSET
                if reloadData {
                    self.data = receipts
                }
                else {
                    self.data.append(contentsOf: receipts)
                }
                self.delegate.reloadView()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
    
}
