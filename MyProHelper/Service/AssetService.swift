//
//  AssetService.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/27/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

class AssetService {
    
   private let repository = AssetRepository()
    
    func fetchAsset(showRemoved: Bool, key: String? = nil, sortBy: AssetField? = nil, sortType: SortType? = nil, offset: Int, completion: @escaping ((Result<[Asset], ErrorResult>) -> Void)) {
        repository.fetchAsset(showRemoved: showRemoved, with: key, sortBy: sortBy, sortType: sortType, offset: offset) { (assets) in
            completion(.success(assets))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    
    func createAsset(asset: Asset, _ completion: @escaping ((Result<Int64, ErrorResult>) -> Void)) {
        repository.createAsset(asset: asset) { assetID in
            completion(.success(assetID))
        } fail: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    
    func updateAsset(asset: Asset, _ completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        repository.updateAsset(asset: asset) {
            completion(.success(""))
        } fail: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    
    func deleteAsset(asset: Asset, _ completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        repository.deleteAsset(asset: asset) {
            completion(.success(""))
        } fail: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func restoreAsset(asset: Asset, _ completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        repository.restoreAsset(asset: asset) {
            completion(.success(""))
        } fail: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
}
