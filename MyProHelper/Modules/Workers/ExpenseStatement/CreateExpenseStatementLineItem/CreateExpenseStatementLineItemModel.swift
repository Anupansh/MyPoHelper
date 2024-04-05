//
//  CreateExpenseStatementLineItemModel.swift
//  MyProHelper
//
//  Created by sismac010 on 18/05/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

class CreateExpenseStatementLineItemModel{
    
    private var lineItem = ExpenseStatementsUsed()
    private var parts: [Part] = []
    private var supplies: [Supply] = []
    private var isEditing = false
    
    private var isPart: Bool = true
    private var isSupply: Bool = false
    private var isNonStockable: Bool = false
    private var lineItemType: LineItemType = .PART

    func getLineItemType()-> LineItemType{
        return lineItemType
    }
    
    func setLineItemType(_ type:LineItemType){
        lineItemType = type
    }
    
    func setLineItem(lineItem: ExpenseStatementsUsed) {
        self.lineItem = lineItem
        isEditing = true
        let type:LineItemType = validatePart() == .Valid ? .PART : (validateSupply() == .Valid ? .SUPPLYS : .NON_STOCKABLE_ITEM)
        setLineItemType(type)
        type == .PART ? setIsPart() : (type == .SUPPLYS ? setIsSupply() : setIsNonStockable())
    }
    
    func getLineItem() -> ExpenseStatementsUsed {
        return lineItem
    }
    
    func isUpdateLineItem() -> Bool {
        return isEditing
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
    
    func validatePartNumber() -> ValidationResult {
        guard let partNumber = lineItem.vendorPartNumber else {
            return .Valid
        }
        return Validator.validateName(name: partNumber)
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
    
    func setDescription(description: String?) {
        lineItem.nonStockable = description
    }
    
    func getDescription() -> String? {
        return lineItem.nonStockable
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
        let v1 = isPartType() ? (validatePart()  == .Valid && validatePartNumber() == .Valid) : (isSupplyType() ? (validateSupply() == .Valid) : (isNonStockableType() ? true : true))
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
    
    func getAmountToReimburse() -> String? {
        return lineItem.amountToReimburse?.stringValue
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
    
    func setPartNumber(number: String?) {
        guard let number = number else { return }
        lineItem.vendorPartNumber = number
    }
    func resetFields(){
        if isPart{
            lineItem.supply = nil
        }
        else if isSupply{
            lineItem.part = nil
            lineItem.vendorPartNumber = nil
        }
        else if isNonStockable{
            lineItem.part = nil
            lineItem.vendorPartNumber = nil
            lineItem.supply = nil
        }
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
        lineItem.amountToReimburse = Double(price)
    }
    
    func setAmount() {
        guard let quantity = lineItem.quantity else { return }
        guard let price = lineItem.pricePerItem else { return }
        
        let total = Double(quantity) * price
        lineItem.amountToReimburse = Double(total)
        
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
