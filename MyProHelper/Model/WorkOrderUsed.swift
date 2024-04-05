//
//  WorkOrderUsed.swift
//  MyProHelper
//
//  Created by sismac010 on 12/04/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

import GRDB


struct WorkOrderUsed: RepositoryBaseModel {
    
    var lineItemId                  : Int? // Only for display
    var workOrderUsedId             : Int?
    var workOrderId                 : Int?
    var part                        : Part?
    var supply                      : Supply?
    var nonStockable                : String?
    var vendorPartNumber            : String?
    var quantity                    : Int?
    var pricePerItem                : Double?
    var amountOfLineItem            : Double?
    var dateCreated                 : Date?
    var dateModified                : Date?
    var sampleWorkOrderUsed         : Int?
    var removed                     : Bool?
    var removedDate                 : Date?

    init() { }

    init(row: GRDB.Row) {
        let column = RepositoryConstants.Columns.self
        lineItemId              = row["LineItemID"]
        workOrderUsedId         = row[column.WORK_ORDER_USED_ID]
        workOrderId             = row[column.WORK_ORDER_ID]
        part                    = Part(row: row)
        supply                  = Supply(row: row)
        nonStockable            = row[column.NON_STOCKABLE]
        vendorPartNumber        = row[column.VENDOR_PART_NUMBER]
        quantity                = row[column.QUANTITY]
        pricePerItem            = row[column.PRICE_PER_ITEM]
        amountOfLineItem        = row[column.AMOUNT_OF_LINE_ITEM]
        dateCreated             = DateManager.stringToDate(string: row[column.CREATED_DATE] ?? "")
        dateModified            = DateManager.stringToDate(string: row[column.MODIFIED_DATE] ?? "")
        sampleWorkOrderUsed     = row[column.SAMPLE_WORK_ORDER_USED]
        removed                 = row[column.REMOVED]
        removedDate             = createDate(with: column.REMOVED_DATE)
//        numberOfAttachments     = row[column.NUMBER_OF_ATTACHMENTS]
        
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
        let ID = workOrderUsedId != nil ? workOrderUsedId : lineItemId
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

extension WorkOrderUsed: Equatable {
    static func == (lhs: WorkOrderUsed, rhs: WorkOrderUsed) -> Bool {
        return
            lhs.part                == rhs.part   &&
            lhs.supply              == rhs.supply   &&
            lhs.vendorPartNumber    == rhs.vendorPartNumber        &&
            lhs.pricePerItem        == rhs.pricePerItem
    }
}
