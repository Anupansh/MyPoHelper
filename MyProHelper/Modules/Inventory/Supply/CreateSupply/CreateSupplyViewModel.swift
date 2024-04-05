//
//  CreateSupplyViewModel.swift
//  MyProHelper
//
//  Created by sismac010 on 10/03/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

class CreateSupplyViewModel: BaseAttachmentViewModel {
//    private var supply = Supply()
    var supply:Box<Supply> = Box(Supply())
    private var isUpdatingSupply = false
    private var supplyStock: [SupplyFinder] = []
    private var vendors: [Vendor] = []
    private var supplyLocations: [SupplyLocation] = []
    private var supplyService = SupplyService()
    private var hasMoreStocks = false
    
    func setSupply(supply: Supply) {
        self.isUpdatingSupply = true
        self.supply.value = supply
        self.sourceId = supply.supplyId
        self.supply.value.updateModifyDate()
    }
    
    func countStock() -> Int {
        return supplyStock.count
    }
    
    func getStock(at index: Int) -> SupplyFinder? {
        guard supplyStock.count > index else { return nil }
        return supplyStock[index]
    }
    
    func getStocks() -> [SupplyFinder] {
        return supplyStock
    }
    
    func addStock(stock: SupplyFinder) {
        
        if let index = supplyStock.firstIndex(of: stock) {
            supplyStock[index].increaseQuantity(by: stock.quantity)
        }
        else {
            supplyStock.append(stock)
        }
    }

    func updateStock(stock: SupplyFinder) {
        if let index = supplyStock.firstIndex(where: { $0.supplyFinderId == stock.supplyFinderId }) {
            supplyStock[index] = stock
        }
    }
    
    func setRemoveStock(stock: SupplyFinder) {
        if let index = supplyStock.firstIndex(where: { $0.supplyFinderId == stock.supplyFinderId }) {
            supplyStock[index] = stock
        }
    }
    
    func removeStock(stock: SupplyFinder) {
        if let index = supplyStock.firstIndex(of: stock) {
            supplyStock.remove(at: index)
        }
    }
    
    func getPartName() -> String? {
        return supply.value.supplyName
    }
    
    func getPartDescription() -> String? {
        return supply.value.description
    }
    
    func setSupplyName(name: String?) {
        supply.value.supplyName = name
    }
    
    func setSupplyDescription(description: String?) {
        supply.value.description = description
    }
    
    func validateName() -> ValidationResult {
        return Validator.validateName(name: supply.value.supplyName)
    }
    
    func validateDescription() -> ValidationResult {
        guard let description = supply.value.description, !description.isEmpty else {
            return .Valid
        }
        return Validator.validateName(name: description)
    }
    
    func isValidData() -> Bool {
        return  validateName()          == .Valid &&
                validateDescription()   == .Valid
    }
    
    func getVendors(completion: @escaping () -> ()) {
        let vendorService = VendorService()
        vendorService.fetchVendors(offset: 0) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let vendors):
                self.vendors = vendors
                
            case .failure(let error):
                print(error)
            }
        }
    }

    func getSupplyLocations(completion: @escaping () -> ()) {
        let supplyLocationService = SupplyLocationService()
        supplyLocationService.fetchSupplyLocations(offset: 0) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let supplyLocations):
                self.supplyLocations = supplyLocations
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getStocks(isReload: Bool = true, showRemoved:Bool, completion: @escaping () -> ()) {
        if !isReload && !hasMoreStocks {
            return
        }
        guard let supplyId = supply.value.supplyId else {
            return
        }
        
        let offset = (isReload) ? 0 : supplyStock.count
        let stockService = SupplyFinderService()
        
        stockService.fetchStock(supplyID: supplyId, showRemoved: showRemoved, offset: offset) { (result) in
            switch result {
                
            case .success(let stocks):
                self.hasMoreStocks = stocks.count == Constants.DATA_OFFSET
                if isReload {
                    self.supplyStock = stocks
                }
                else {
                    self.supplyStock.append(contentsOf: stocks)
                }
                
                completion()
            case .failure(let error):
                print(error)
                completion()
            }
        }
    }
    
    func addSupply(completion: @escaping (_ error: String?, _ isValidData: Bool) -> ()) {
        if !isValidData() {
            completion(nil,false)
            return
        }
        supply.value.numberOfAttachments = numberOfAttachment
        if isUpdatingSupply {
            updateSupply { (error) in
                completion(error,true)
            }
        }
        else {
            saveSupply { (error) in
                completion(error,true)
            }
        }
        
    }
    
    private func updateSupply(completion: @escaping (_ error: String?) -> ()) {
        guard let supplyID = supply.value.supplyId else {
            completion("an error has occurred")
            return
        }
        
        supplyService.updateSupply(supply: supply.value) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.saveAttachment(id: supplyID)
                self.saveStock(for: supplyID) { (error) in
                    completion(error)
                }
                break
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    private func saveSupply(completion: @escaping (_ error: String?) -> ()) {
        supplyService.createSupply(supply: supply.value) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let supply):
                self.saveAttachment(id: Int(supply.supplyId!))
                self.saveStock(for: Int(supply.supplyId!)) { error in
                    self.supply.value = supply
                    completion(error)
                }
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    private func saveStock(for supplyID: Int, completion: @escaping (_ error: String?)->()) {
        let stockService = SupplyFinderService()
        var numberOfStocks = supplyStock.count
        
        if numberOfStocks == 0 {
            completion(nil)
            return
        }
        
        for var stock in supplyStock {
            stock.supplyId = supplyID
            stockService.addStock(stock: stock) { (result) in
                switch result {
                case .success(_):
                    numberOfStocks -= 1
                    if numberOfStocks == 0 {
                        completion(nil)
                    }
                case .failure(let error):
                    completion(error.localizedDescription)
                }
            }
        }
    }
    
    func deleteStock(stock: SupplyFinder, completion: @escaping (_ error: String?)->()) {
        let stockService = SupplyFinderService()
        stockService.delete(stock: stock) { (result) in
            switch result {
            case .success(_):
                completion(nil)
                
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    func undeleteStock(stock: SupplyFinder, completion: @escaping (_ error: String?)->()) {
        let stockService = SupplyFinderService()
        stockService.undeleteStock(stock: stock) { (result) in
            switch result {
            case .success(_):
                completion(nil)
                
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }

}
