//
//  ReceiptService.swift
//  MyProHelper
//
//  Created by Deep on 2/15/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

final class ReceiptService {
    
    private let repository = ReceiptRepository()
    
    func fetchReceipt(showRemoved: Bool = false, key: String? = nil, sortBy: ReceiptListField? = nil,sortType: SortType? = nil ,offset: Int, completion:@escaping((Result<[Receipt],ErrorResult>) -> Void)) {
        repository.fetchReceipt(showRemoved: showRemoved,
                                with: key,
                                sortBy: sortBy,
                                sortType: sortType,
                                offset: offset) { (receipts) in
            completion(.success(receipts))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func createReceipt(receipt: Receipt, completion: @escaping ((Result<Int64, ErrorResult>) -> Void)) {
        repository.createReceipt(receipt: receipt) { (receiptId) in
            completion(.success(receiptId))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
}
