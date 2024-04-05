//
//  PaymentService.swift
//  MyProHelper
//
//  Created by Samir on 07/02/2021.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

final class PaymentService {

    private let repository = PaymentRepository()

    func fetchPayment(showRemoved: Bool = false, key: String? = nil, sortBy: PaymentListField? = nil,sortType: SortType? = nil ,offset: Int, completion:@escaping((Result<[Payment],ErrorResult>) -> Void)) {
        repository.fetchPayment(showRemoved: showRemoved,
                                with: key,
                                sortBy: sortBy,
                                sortType: sortType,
                                offset: offset) { (paymentArray) in
            completion(.success(paymentArray))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }

    func createPayment(payment: Payment, completion: @escaping ((Result<Int64, ErrorResult>) -> Void)) {
        repository.insertPayment(payment: payment) { (paymentId) in
            completion(.success(paymentId))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }

    func updatePayment(payment: Payment, completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        repository.updatePayment(payment: payment) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }

    func deletePayment(payment: Payment, _ completion:@escaping((Result<String,ErrorResult>) -> Void)) {
        repository.delete(payment: payment) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }

    func restorePayment(payment: Payment, _ completion:@escaping((Result<String,ErrorResult>) -> Void)) {
        repository.restorePayment(payment: payment) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
}
