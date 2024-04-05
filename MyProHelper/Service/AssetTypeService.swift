//
//  AssetTypeService.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/26/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

class AssetTypeService {
    private let repository = AssetTypeRepository()
   
    func fetchAssetType(showRemoved: Bool = false, key: String? = nil, sortBy: AssetTypeField? = nil, sortType: SortType? = nil, offset: Int, completion: @escaping ((Result<[AssetType], ErrorResult>) -> Void)) {
        repository.fetchAssetType(showRemoved: showRemoved, with: key, sortBy: sortBy, sortType: sortType, offset: offset) { (assetTypes) in
            completion(.success(assetTypes))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    
    func createAssetType(assetType: AssetType, _ completion: @escaping ((Result<Int64, ErrorResult>) -> Void)) {
        repository.createAssetType(assetType: assetType) { typeID in
            completion(.success(typeID))
        } fail: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    
    func updateAssetType(assetType: AssetType, _ completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        repository.updateAssetType(assetType: assetType) {
            completion(.success(""))
        } fail: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    
    func deleteAssetTypes(assetType: AssetType, _ completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        repository.delete(assetType: assetType) {
            completion(.success(""))
        } fail: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func restoreAssetTypes(assetType: AssetType, _ completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        repository.restoreAssetType(assetType: assetType) {
            completion(.success(""))
        } fail: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
}
