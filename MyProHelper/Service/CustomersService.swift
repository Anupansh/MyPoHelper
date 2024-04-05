//
//  CustomersService.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 17/07/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

final class CustomersService {
    
    var dbService = CustomerRepository()
    
    func fetchCustomers(showSelect: Bool = false, offset: Int, completion: @escaping ((Result<[Customer], ErrorResult>) -> Void)) {
        dbService.fetchCustomers(showSelect: showSelect, offset: offset) { (customers) in
            completion(.success(customers))
        }
        failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchCustomers(showRemoved: Bool = false, key: String? = nil, sortBy: CustomerField? = nil, sortType: SortType? = nil, offset: Int, completion: @escaping ((Result<[Customer], ErrorResult>) -> Void)) {
        dbService.fetchCustomers(showRemoved: showRemoved, with: key, sortBy: sortBy, sortType: sortType, offset: offset) { (customers) in
            completion(.success(customers))
        }
        failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func createCustomer(_ customer: Customer, completion: @escaping ((Result<Int64, ErrorResult>) -> Void)) {
        dbService.insertCustomer(customer: customer, success: { id in
            completion(.success(id))
        }) { error in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func updateCustomer(_ customer: Customer, completion: @escaping ((Result<Customer, ErrorResult>) -> Void)) {
        dbService.updateCustomer(customer: customer, success: {
            completion(.success(customer))
        }) { error in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func deleteCustomer(_ customer: Customer, completion:@escaping((Result<String,ErrorResult>) -> Void)) {
        dbService.deleteCustomer(customer: customer) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: Constants.Message.DELETE_CUSTOMER_ERROR)))
        }
    }
    
    func restoreCustomer(_ customer: Customer, completion:@escaping((Result<String,ErrorResult>) -> Void)) {
        dbService.restoreCustomer(customer: customer) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: Constants.Message.DELETE_CUSTOMER_ERROR)))
        }
    }
}
