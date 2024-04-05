//
//  VendorService.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 17/06/1942 Saka.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

final class VendorService {
    
    private let dbService = VendorRepository()
    
    func fetchVendors(showRemoved: Bool = false, key: String? = nil, sortBy: VendorField? = nil, sortType: SortType? = nil, offset: Int, completion: @escaping ((Result<[Vendor], ErrorResult>) -> Void)) {
        dbService.fetchVendors(showRemoved: showRemoved, with: key, sortBy: sortBy, sortType: sortType, offset: offset) { (vendors) in
            completion(.success(vendors))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func createVendor(vendor: Vendor, completion: @escaping ((Result<Int64, ErrorResult>) -> Void)) {
        dbService.insertVendor(vendor: vendor, success: { vendorID in
            completion(.success(vendorID))
        }) { error in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func updateVendor(vendor: Vendor, completion: @escaping ((Result<Vendor, ErrorResult>) -> Void)) {
        dbService.update(vendor: vendor, success: {
            completion(.success(vendor))
        }) { error in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func deleteVendor(at vendor: Vendor, completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        dbService.deleteVendor(vendor: vendor) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func restoreVendor(at vendor: Vendor, completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        dbService.restoreVendor(vendor: vendor) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
}
