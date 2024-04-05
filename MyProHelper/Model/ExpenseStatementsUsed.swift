//
//  ExpenseStatementsUsed.swift
//  MyProHelper
//
//  Created by sismac010 on 18/05/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB
struct ExpenseStatementsUsed: RepositoryBaseModel {

    var lineItemId                  : Int? // Only for display
    var expenseStatementsUsedId     : Int?
    var expenseStatementsId         : Int?
    var description                 : String?
    var part                        : Part?
    var supply                      : Supply?
    var nonStockable                : String?
    var vendorPartNumber            : String?
    var quantity                    : Int?
    var pricePerItem                : Double?
    var amountToReimburse           : Double?
    var dateCreated                 : Date?
    var dateModified                : Date?
    var sampleExpenseStatementsUsed : Int?
    var removed                     : Bool?
    var removedDate                 : Date?
    
    
    init() { }
    
    init(row: GRDB.Row) {
        let column = RepositoryConstants.Columns.self
        lineItemId                  = row["LineItemID"]
        expenseStatementsUsedId     = row[column.EXPENSE_STATEMENT_USED_ID]
        expenseStatementsId         = row[column.EXPENSE_STATEMENT_ID]
        description                 = row[column.DESCRIPTION]
        part                        = Part(row: row)
        supply                      = Supply(row: row)
        nonStockable                = row[column.NON_STOCKABLE]
        vendorPartNumber            = row[column.VENDOR_PART_NUMBER]
        quantity                    = row[column.QUANTITY]
        pricePerItem                = row[column.PRICE_PER_ITEM]
        amountToReimburse           = row[column.AMOUNT_TO_REIMBURSE]
        dateCreated                 = DateManager.stringToDate(string: row[column.DATE_CREATED] ?? "")
        dateModified                = DateManager.stringToDate(string: row[column.DATE_MODIFIED] ?? "")
        sampleExpenseStatementsUsed = row[column.SAMPLE_EXPENSE_STATEMENT_USED]
        removed                     = row[column.REMOVED]
        removedDate                 = createDate(with: column.REMOVED_DATE)

    }
    
    mutating func increaseQuantity(by value: Int?) {
        guard let value = value else {
            return
        }
        if let quantity = quantity {
            self.quantity = quantity + value
        }
        else {
            self.quantity = value
        }
    }
    
    mutating func decreaseQuantity(by value: Int?) -> Bool{
        guard let value = value else {
            return false
        }
        if let quantity = quantity, value <= quantity {
            self.quantity = quantity - value
            return true
        }
        else {
            return false
        }
    }

    
    func getDataArray() -> [Any] {
        let ID = expenseStatementsUsedId != nil ? expenseStatementsUsedId : lineItemId
        let partName = part?.partName == Constants.DefaultValue.SELECT_LIST ? "" : part?.partName
        let supplyName = supply?.supplyName == Constants.DefaultValue.SELECT_LIST ? "" : supply?.supplyName
        return [
            getIntValue(value: ID),
            getStringValue(value: partName),
            getStringValue(value: supplyName),
            getStringValue(value: nonStockable),
            getStringValue(value: vendorPartNumber),
            getIntValue(value: quantity),
            getFormattedStringValue(value: pricePerItem),
            getFormattedStringValue(value: amountToReimburse),
        ]
        
    }
    
    mutating func updateModifyDate() {
        dateModified = Date()
    }
}

extension ExpenseStatementsUsed: Equatable {
    static func == (lhs: ExpenseStatementsUsed, rhs: ExpenseStatementsUsed) -> Bool {
        return
            lhs.part                == rhs.part   &&
            lhs.supply              == rhs.supply   &&
            lhs.vendorPartNumber    == rhs.vendorPartNumber        &&
            lhs.pricePerItem        == rhs.pricePerItem
    }
}
