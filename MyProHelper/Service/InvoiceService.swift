//
//  InvoiceService.swift
//  MyProHelper
//
//  Created by Deep on 2/4/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

final class InvoiceService {
    private let repository = InvoiceRepository()
    
    func fetchInvoices(showRemoved: Bool = false,isApproval: Bool, key: String? = nil, sortBy: InvoiceField? = nil, sortType: SortType? = nil, offset: Int, completion: @escaping ((Result<[Invoice], ErrorResult>) -> Void)) {
        repository.fetchInvoices(showRemoved: showRemoved, with: key, isApproval: isApproval, sortBy: sortBy, sortType: sortType, offset: offset) { (invoices) in
            completion(.success(invoices))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }

    func createInvoice(invoice: Invoice, completion: @escaping ((Result<Int64, ErrorResult>) -> Void)) {
        repository.insertInvoice(invoice: invoice) { (invoiceId) in
            completion(.success(invoiceId))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }

    func updateInvoice(invoice: Invoice, completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        repository.updateInvoice(invoice: invoice) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }

    func deleteInvoice(invoice: Invoice, _ completion:@escaping((Result<String,ErrorResult>) -> Void)) {
        repository.deleteInvoice(invoice: invoice) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }

    func restoreInvoice(invoice: Invoice, _ completion:@escaping((Result<String,ErrorResult>) -> Void)) {
        repository.restoreInvoice(invoice: invoice) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
}
