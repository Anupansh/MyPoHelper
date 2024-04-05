//
//  CreatedPurchaseOrderLineItemModel.swift
//  MyProHelper
//
//  Created by Pooja Mishra on 03/04/1943 Saka.
//  Copyright © 1943 Benchmark Computing. All rights reserved.
//

import Foundation

class CreatedPurchaseOrderLineItemModel{
    
    private var lineItem = PurchaseOrderUsed()
    private var parts: [Part] = []
    private var supplies: [Supply] = []
    private var isEditing = false
    
    private var isPart: Bool = true
    private var isSupply: Bool = false
    private var isNonStockable: Bool = false
    private var lineItemType: LineItemType1 = .PART
    
    func setLineItem(lineItem: PurchaseOrderUsed) {
        self.lineItem = lineItem
        isEditing = true
        let type:LineItemType1 = validatePart() == .Valid ? .PART : (validateSupply() == .Valid ? .SUPPLYS : .NON_STOCKABLE_ITEM)
        setLineItemType(type)
        type == .PART ? setIsPart() : (type == .SUPPLYS ? setIsSupply() : setIsNonStockable())
    }
    
    func getLineItem() -> PurchaseOrderUsed {
        return lineItem
    }
    
    func isUpdateLineItem() -> Bool {
        return isEditing
    }
    func getLineItemType()-> LineItemType1{
        return lineItemType
    }
    
    func setLineItemType(_ type:LineItemType1){
        lineItemType = type
    }
    
    func setIsPart() {
        isPart = true
        isSupply = false
        isNonStockable = false
    }
    
    func setIsSupply() {
        isPart = false
        isSupply = true
        isNonStockable = false
    }
    
    func setIsNonStockable() {
        isPart = false
        isSupply = false
        isNonStockable = true
    }
    
    func getIsPart () -> Bool {
        return isPart
    }
    func getIsSupply() -> Bool {
        return isSupply
    }
    func getIsNonStockable() -> Bool {
        return isNonStockable
    }

    
    func getParts() -> [String] {
        return parts.compactMap({ $0.partName })
    }
    
    func getSupplies() -> [String] {
        return supplies.compactMap({ $0.supplyName })
    }
    
    func validateQuantity() -> ValidationResult {
        guard let quantity = lineItem.quantity else {
            return .Valid
        }
        return Validator.validateIntegerValue(value: quantity)
    }
    
    func validatePricePerItem() -> ValidationResult {
        guard let pricePerItem = lineItem.pricePerItem else {
            return .Valid
        }
        return Validator.validatePrice(price: pricePerItem)
    }
    
    func validatePartAndSupply() -> ValidationResult {
        if lineItem.part == nil && lineItem.supply == nil{
            return .Invalid(message: Constants.Message.PART_SUPPLY_NAME_SELECT_ERROR)
        }
        
        if let partName = lineItem.part?.partName , lineItem.supply == nil{
            if partName == Constants.DefaultValue.SELECT_LIST{

                return .Invalid(message: Constants.Message.PART_SUPPLY_NAME_SELECT_ERROR)
            }
            return .Valid
        }
        if let supplyName = lineItem.supply?.supplyName , lineItem.part == nil{
            if supplyName == Constants.DefaultValue.SELECT_LIST{

                return .Invalid(message: Constants.Message.PART_SUPPLY_NAME_SELECT_ERROR)
            }
            return .Valid
        }
        if let partName = lineItem.part?.partName , let supplyName = lineItem.supply?.supplyName {
            if partName == Constants.DefaultValue.SELECT_LIST && supplyName == Constants.DefaultValue.SELECT_LIST{

                return .Invalid(message: Constants.Message.PART_SUPPLY_NAME_SELECT_ERROR)
            }
            else if partName != Constants.DefaultValue.SELECT_LIST  && !partName.isEmpty && supplyName != Constants.DefaultValue.SELECT_LIST  && !supplyName.isEmpty{
                
                return .Invalid(message: Constants.Message.PART_SUPPLY_NAME_SELECT_ERROR)
            }
            return .Valid
        }
        
        return .Valid
    }
    
    func validatePart() -> ValidationResult {
        if lineItem.part == nil{
            return .Invalid(message: Constants.Message.PART_SUPPLY_NAME_SELECT_ERROR)
        }
        
        if let partName = lineItem.part?.partName , partName == Constants.DefaultValue.SELECT_LIST || partName.isEmpty{
                return .Invalid(message: Constants.Message.PART_SUPPLY_NAME_SELECT_ERROR)
        }
        
        return .Valid
    }
    
    func validateSupply() -> ValidationResult {
        if lineItem.supply == nil{
            return .Invalid(message: Constants.Message.PART_SUPPLY_NAME_SELECT_ERROR)
        }
        
        if let supplyName = lineItem.supply?.supplyName , supplyName == Constants.DefaultValue.SELECT_LIST || supplyName.isEmpty{
            return .Invalid(message: Constants.Message.PART_SUPPLY_NAME_SELECT_ERROR)
        }
        return .Valid
    }
    
    func validatePart2() -> ValidationResult {
        guard let partName = lineItem.part?.partName else {
            return .Valid
        }
        return Validator.validateName(name: partName)
    }
    
    func validateSupply2() -> ValidationResult {
        guard let supplyName = lineItem.supply?.supplyName else {
            return .Valid
        }
        return Validator.validateName(name: supplyName)
    }
    
 
    func isPartType()->Bool{
        return lineItemType == .PART
    }
    
    func isSupplyType()->Bool{
        return lineItemType == .SUPPLYS
    }
    
    func isNonStockableType()->Bool{
        return lineItemType == .NON_STOCKABLE_ITEM
    }
    
    func isValidData() -> Bool {
        
        let v1 = isPartType() ? (validatePart()  == .Valid) : (isSupplyType() ? (validateSupply() == .Valid) : (isNonStockableType() ? true : true))
        return
            //validatePartAndSupply()     == .Valid &&
            //validatePartNumber()        == .Valid &&
            v1 &&
            validateQuantity()          == .Valid &&
            validatePricePerItem()      == .Valid
    }
    
    func getQuantity() -> String {
        return String(lineItem.quantity ?? 0)
    }
    
    func getPartNumber() -> String? {
        return lineItem.vendorPartNumber
    }
    
    
    func getPricePerItem() -> String? {
        return lineItem.pricePerItem?.stringValue
    }
    
    func getAmountOfLineITem() -> String? {
        return lineItem.amountOfLineItem?.stringValue
    }
    
    func getPart() -> String? {
        return lineItem.part?.partName
    }
    
    func getSupply() -> String? {
        return lineItem.supply?.supplyName
    }
    
    
    func setPart(at index: Int?) {
        guard let index = index, index < parts.count else { return }
        lineItem.part = parts[index]
    }
    
    func setPart(part: Part) {
        lineItem.part = part
    }
    
    
    func setSupply(at index: Int?) {
        guard let index = index, index < supplies.count else { return }
        lineItem.supply = supplies[index]
    }
    
    func setSupply(supply: Supply) {
        lineItem.supply = supply
    }
    
    func setDescription(description: String?) {
        lineItem.nonStockable = description
    }
    
    func getDescription() -> String? {
        return lineItem.nonStockable
    }
    

    
    func setPartNumber(number: String?) {
        guard let number = number else { return }
        lineItem.vendorPartNumber = number
    }
    
    func resetFields(){
        if isPart{
            lineItem.supply = nil
            lineItem.nonStockable = nil
        }
        else if isSupply{
            lineItem.part = nil
            lineItem.vendorPartNumber = nil
            lineItem.nonStockable = nil
        }
        else if isNonStockable{
            lineItem.part = nil
            lineItem.vendorPartNumber = nil
            lineItem.supply = nil
        }
        lineItem.quantity = nil
        lineItem.pricePerItem = nil
        lineItem.amountOfLineItem = nil
    }
    
    func setQuantity(quantity: String?) {
        guard let quantity = quantity else { return }
        lineItem.quantity = Int(quantity)
    }
    
    func setPricePerItem(price: String?) {
        guard let price = price else { return }
        lineItem.pricePerItem = Double(price)
    }
    
    func setAmount(price: String?) {
        guard let price = price else { return }
        lineItem.amountOfLineItem = Double(price)
    }
    
    func setAmount() {
        guard let quantity = lineItem.quantity else { return }
        guard let price = lineItem.pricePerItem else { return }
        
        let total = Double(quantity) * price
        lineItem.amountOfLineItem = Double(total)
        
    }
    
    
    
    func fetchParts(completion: @escaping () -> ()) {
        let service = PartsService()
        let offset = 0
        service.fetchParts(showSelect: false, offset: offset) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let partArray):
                self.parts = partArray
                completion()
            case .failure(let error):
                print(error)
                completion()
            }
        }
    }
    
    func fetchSupplies(completion: @escaping () -> ()) {
        let service = SupplyService()
        let offset = 0
        service.fetchSupplies(showSelect: false, offset: offset) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let suppliesArray):
                self.supplies = suppliesArray
                completion()
            case .failure(let error):
                print(error)
                completion()
            }
        }
    }
    
}
