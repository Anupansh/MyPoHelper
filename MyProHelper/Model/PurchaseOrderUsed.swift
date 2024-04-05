//
//  PurchaseOrderUsed.swift
//  MyProHelper
//
//  Created by sismac010 on 25/03/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

import GRDB


struct PurchaseOrderUsed: RepositoryBaseModel {
    
    var lineItemId                  : Int? // Only for display
    var purchaseOrderUsedId         : Int?
    var purchaseOrderId             : Int?
    var part                        : Part?
    var supply                      : Supply?
    var nonStockable                : String?
    var vendorPartNumber            : String?
    var quantity                    : Int?
    var pricePerItem                : Double?
    var amountOfLineItem            : Double?
    var salesTax                    : Double?
    var shipping                    : Double?
    var orderedDate                 : Date?
    var samplePurchaseOrder         : Int?
    var dateReceived                : Date?
    var removed                     : Bool?
    var removedDate                 : Date?
    var numberOfAttachments         : Int?
    
    init() { }

    init(row: GRDB.Row) {
        let column = RepositoryConstants.Columns.self
        lineItemId              = row["LineItemID"]
        purchaseOrderUsedId     = row[column.PURCHASE_ORDER_USED_ID]
        purchaseOrderId         = row[column.PURCHASE_ORDER_ID]
        part                    = Part(row: row)
        supply                  = Supply(row: row)
        nonStockable            = row[column.NON_STOCKABLE]
        vendorPartNumber        = row[column.VENDOR_PART_NUMBER]
        quantity                = row[column.QUANTITY]
        pricePerItem            = row[column.PRICE_PER_ITEM]
        amountOfLineItem        = row[column.AMOUNT_OF_LINE_ITEM]
        salesTax                = row[column.SALES_TAX]
        shipping                = row[column.SHIPPING]
        orderedDate             = DateManager.stringToDate(string: row[column.ORDERED_DATE] ?? "")
        samplePurchaseOrder     = row[column.SAMPLE_PURCHASE_ORDER]
        dateReceived            = DateManager.stringToDate(string: row[column.DATE_RECEIVED] ?? "")
        removed                 = row[column.REMOVED]
        removedDate             = createDate(with: column.REMOVED_DATE)
        numberOfAttachments     = row[column.NUMBER_OF_ATTACHMENTS]
        
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
        let ID = purchaseOrderUsedId != nil ? purchaseOrderUsedId : lineItemId
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
            getFormattedStringValue(value: amountOfLineItem),
        ]
    }
        
}


extension PurchaseOrderUsed: Equatable {
    static func == (lhs: PurchaseOrderUsed, rhs: PurchaseOrderUsed) -> Bool {
        return
            lhs.part                == rhs.part   &&
            lhs.supply              == rhs.supply   &&
            lhs.vendorPartNumber    == rhs.vendorPartNumber        &&
            lhs.pricePerItem        == rhs.pricePerItem
    }
}
