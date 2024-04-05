//
//  CreateAssetTypeViewModel.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/26/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

class CreateAssetTypeViewModel {
    
    var assetType:Box<AssetType> = Box(AssetType())
    private var isUpdatingAssetType = false
    private let service = AssetTypeService()
    
    func setAssetType(assetType: AssetType) {
        self.assetType.value = assetType
        self.isUpdatingAssetType = true
        self.assetType.value.updateModifyDate()
    }
    
    func setTypeOfAsset(typeOfAsset: String?) {
        assetType.value.typeOfAsset = typeOfAsset
    }
    
    
    func getTypeOfAsset() -> String? {
        return assetType.value.typeOfAsset
    }
    
    func validateTypeOfAsset() -> ValidationResult {
        return Validator.validateName(name: assetType.value.typeOfAsset)
    }
    
   
    private func isValidData() -> Bool {
        return validateTypeOfAsset() == .Valid
    }
    
    func saveAssetType(completion: @escaping (_ error: String?, _ isValidData: Bool) -> ()) {
        if !isValidData() {
            completion(nil, false)
            return
        }
        if isUpdatingAssetType {
            updateServiceType { (error) in
                completion(error, true)
            }
        }
        else {
            createServiceType { (error) in
                completion(error, true)
            }
        }
    }
    
    private func updateServiceType(completion: @escaping (_ error: String?)->()) {
        service.updateAssetType(assetType: assetType.value) { (result) in
            switch result {
            case .success(_):
                completion(nil)
                
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    private func createServiceType(completion: @escaping (_ error: String?)->()) {
        service.createAssetType(assetType: assetType.value) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let typeID):
                self.assetType.value.id = Int(typeID)
                completion(nil)
                
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
}
