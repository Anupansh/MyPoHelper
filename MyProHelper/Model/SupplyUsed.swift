//
//  SupplyUsed.swift
//  MyProHelper
//
//  Created by Deep on 2/17/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import GRDB

struct SupplyUsed: RepositoryBaseModel {
    var supplyUsedId          : Int?
    var supplyId              : Int?
    var supplyFinderId        : Int?
    var InvoiceId             : Int?
    var supplyName            : String?
    var priceToResell         : Double?
    var quantity              : Int?
    var supplyLocationId      : Int?
    var supplyLocationName    : String?
    var wherePurchased        : Int?
    var vendorName            : String?
    var waitingForSupply      : Bool?
    var countWaitingFor       : Int?
    var dateAdded             : Date?
    var dateModified          : Date?
    var removed               : Bool?
    var removedDate           : Date?
 
    var supply                : Supply?
    var supplyLocation        : SupplyLocation?
    var vendor                : Vendor?
    
    init() {
        dateAdded       = Date()
        supplyLocation  = SupplyLocation()
        vendor          = Vendor()
        supply          = Supply()
    }
    
    init(row: GRDB.Row) {
        let column = RepositoryConstants.Columns.self
        
        supplyUsedId        = row[column.SUPPLY_USED_ID]
        supplyId            = row[column.SUPPLY_ID]
        supplyFinderId      = row[column.SUPPLY_FINDER_ID]
        InvoiceId           = row[column.INVOICE_ID]
        supplyName          = row[column.SUPPLY_NAME]
        priceToResell       = row[column.PRICE_TO_RESELL]
        quantity            = row[column.QUANTITY]
        supplyLocationId    = row[column.SUPPLY_LOCATION_ID]
        supplyLocationName  = row[column.SUPPLY_LOCATION_NAME]
        wherePurchased      = row[column.WHERE_PURCHASED]
        vendorName          = row[column.VENDOR_NAME]
        waitingForSupply    = row[column.WAITING_FOR_SUPPLY]
        countWaitingFor     = row[column.COUNT_WAITING_FOR]
        dateAdded           = createDate(with: row[column.DATE_ADDED])
        dateModified        = createDate(with: row[column.DATE_MODIFIED])
        removed             = row[column.REMOVED]
        removedDate         = createDate(with: row[column.REMOVED_DATE])
        
        supplyLocation      = SupplyLocation(row: row)
        vendor              = Vendor(row: row)
        supply              = Supply(row: row)
    }
    
    func getQuantityAndWaitingFor() -> String {
        let UsedQuantity = getIntValue(value: quantity)
        let waitingFor = getIntValue(value: countWaitingFor)
        return "\(UsedQuantity), W-\(waitingFor) "
    }
    
    func getDataArray() -> [Any] {
        
        return [
            getStringValue(value: supplyName),
            getStringValue(value: supplyLocationName),
            getStringValue(value: vendorName),
            getQuantityAndWaitingFor(),
            getStringValue(value: priceToResell?.stringValue)
        ]
    }
    
    mutating func updateModifyDate() {
        dateModified = Date()
    }
}
