//
//  CreateAssetViewModel.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/27/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

class CreateAssetViewModel: BaseAttachmentViewModel {
    
    private var asset = Asset()
    private var isUpdatingAsset = false
    private var assetType: [AssetType] = []
    private let service = AssetService()
    
    func setAsset(asset: Asset) {
        self.asset = asset
        self.isUpdatingAsset = true
        self.sourceId = asset.assetId
        self.asset.updateModifyDate()
    }
    
    func setName(name: String?) {
        asset.assetName = name
    }
    
    func setDescription(description: String?) {
        asset.description = description
    }
    
    func setModelInfo(info: String?) {
        asset.modelInfo = info
    }
    
    func setAssetType(assetIndex: Int?){
        guard let assetIndex = assetIndex, assetIndex < assetType.count else {
            return
        }
        let type = assetType[assetIndex]
        asset.assetType = type
    }
    
    func setAssetType(assetType: AssetType){
        asset.assetType = assetType
    }
    
    func setSerialNumber(number: String?) {
        asset.serialNumber = number
    }
    
    func setPurchasePrice(price: String?) {
        guard let price = price else { return }
        let priceValue = Double(price)
        asset.purchasePrice = priceValue
    }
    
    func setMileage(mileage: String?) {
        guard let mileage = mileage else { return }
        let mileageValue = Int(mileage)
        asset.mileage = mileageValue
    }
    
    func setHoursUsed(hours: String?) {
        guard let hours = hours else { return }
        let hoursValue = Int(hours)
        asset.hoursUsed = hoursValue
    }
    
    func setPurchaseDate(date: String?) {
        asset.datePurchased = DateManager.stringToDate(string: date ?? "")
    }
    
    func setLastMaintenanceDate(date: String?) {
        asset.lastMaintenanceDate = DateManager.stringToDate(string: date ?? "")
    }
    
    func getAssetName() -> String? {
        return asset.assetName
    }
    
    func getDescription() -> String? {
        return asset.description
    }
    
    func getModelInfo() -> String? {
        return asset.modelInfo
    }
    
    func getAssetType() -> String? {
        return asset.assetType?.typeOfAsset
    }
    
    func getSerialNumber() -> String? {
        return asset.serialNumber
    }
    
    func getPurchasePrice() -> String? {
        return asset.purchasePrice?.stringValue
    }
    
    func getMileage() -> String? {
        return String(asset.mileage ?? 0)
    }
    
    func getHoursUsed() -> String? {
        return String(asset.hoursUsed ?? 0)
    }
    
    func getPurchasedDate() -> String? {
        return DateManager.getStandardDateString(date: asset.datePurchased)
    }
    
    func getLastMaintenanceDate() -> String? {
        return DateManager.getStandardDateString(date: asset.lastMaintenanceDate)
    }
    
    func getAssetTypes() -> [String] {
        return assetType.compactMap({ $0.typeOfAsset })
    }
    
    func validateName() -> ValidationResult {
        return Validator.validateName(name: asset.assetName)
    }
    
    func validateDescription() -> ValidationResult {
        guard let description = asset.description, !description.isEmpty else {
            return .Valid
        }
        return Validator.validateDescription(description: description)
    }
    
    func validateModelInfo() -> ValidationResult {
        guard let modelInfo = asset.modelInfo, !modelInfo.isEmpty else {
            return .Valid
        }
        return Validator.validateInfo(info: modelInfo)
    }
    
    func validateAssetType() -> ValidationResult {
        return Validator.validateAssetType(type: asset.assetType)
    }
    
    func validateSerialNumber() -> ValidationResult {
        guard let serialNumber = asset.serialNumber, !serialNumber.isEmpty else {
            return .Valid
        }
        return Validator.validateSerialNumber(number: serialNumber)
    }
    
    func validatePurchasePrice() -> ValidationResult {
        guard let price = asset.purchasePrice else {
            return .Valid
        }
        return Validator.validatePrice(price: price)
    }
    
    func validateMileage() -> ValidationResult {
        guard let mileage = asset.mileage else {
            return .Valid
        }
        return Validator.validateIntegerValue(value: mileage)
    }
    
    func validateHoursUsed() -> ValidationResult {
        guard let hours = asset.hoursUsed else {
            return .Valid
        }
        return Validator.validateIntegerValue(value: hours)
    }
    
    private func isValidData() -> Bool {
        return
            validateName()                  == .Valid &&
            validateDescription()           == .Valid &&
            validateModelInfo()             == .Valid &&
            validateAssetType()             == .Valid &&
            validateSerialNumber()          == .Valid &&
            validatePurchasePrice()         == .Valid &&
            validateMileage()               == .Valid &&
            validateHoursUsed()             == .Valid
    }
    
    func fetchAssetType(completion: @escaping ()->()) {
        let typeService = AssetTypeService()
        typeService.fetchAssetType(offset: 0) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let types):
                self.assetType = types
                completion()
            case .failure(let error):
                print(error)
                self.assetType = []
                completion()
            }
        }
    }
    
    func saveAsset(completion: @escaping (_ error: String?, _ isValidData: Bool) -> ()) {
        if !isValidData() {
            completion(nil, false)
            return
        }
        asset.numberOfAttachment = numberOfAttachment
        if isUpdatingAsset {
            updateAsset { (error) in
                completion(error, true)
            }
        }
        else {
            createAsset { (error) in
                completion(error, true)
            }
        }
    }
    
    private func updateAsset(completion: @escaping (_ error: String?)->()) {
        service.updateAsset(asset: asset) { (result) in
            switch result {
            case .success:
                if let assetID = self.asset.assetId {
                    self.saveAttachment(id: assetID)
                }
                completion(nil)
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    private func createAsset(completion: @escaping (_ error: String?)->()) {
        service.createAsset(asset: asset) { (result) in
            switch result {
            case .success(let assetID):
                self.saveAttachment(id: Int(assetID))
                completion(nil)
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
}
