//
//  PartsUsed.swift
//  MyProHelper
//
//  Created by Deep on 2/9/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import GRDB

struct PartUsed: RepositoryBaseModel {
    
    var partUsedId          : Int?
    var partID              : Int?
    var partFinderId        : Int?
    var InvoiceId           : Int?
    var priceToResell       : Double?
    var quantity            : Int?
    var partLocationId      : Int?
    var wherePurchased      : Int?
    var waitingForPart      : Bool?
    var countWaitingFor     : Int?
    var dateAdded           : Date?
    var dateModified        : Date?
    var removed             : Bool?
    var removedDate         : Date?
    
    var part                : Part?
    var partLocation        : PartLocation?
    var vendor              : Vendor?
    
    
    
    init() {
        dateAdded       = Date()
        part            = Part()
        partLocation    = PartLocation()
        vendor          = Vendor()
    }
    
    init(row: GRDB.Row) {
        let column = RepositoryConstants.Columns.self
        
        partUsedId          = row[column.PART_USED_ID]
        partID              = row[column.PART_ID]
        partFinderId        = row[column.PART_FINDER_ID]
        InvoiceId           = row[column.INVOICE_ID]
        priceToResell       = row[column.PRICE_TO_RESELL]
        quantity            = row[column.QUANTITY]
        partLocationId      = row[column.PART_LOCATION_ID]
        wherePurchased      = row[column.WHERE_PURCHASED]
        waitingForPart      = row[column.WAITING_FOR_PART]
        countWaitingFor     = row[column.COUNT_WAITING_FOR]
        dateAdded           = DateManager.stringToDate(string: row[column.DATE_ADDED] ?? "") 
        dateModified        = DateManager.stringToDate(string: row[column.DATE_MODIFIED] ?? "")
        removed             = row[column.REMOVED]
        removedDate         = DateManager.stringToDate(string: row[column.REMOVED_DATE] ?? "")
        
        part                = Part(row: row)
        partLocation        = PartLocation(row: row)
        vendor              = Vendor(row: row)
        
    }
    
    
    func getQuantityAndWaitingFor() -> String {
        let UsedQuantity = getIntValue(value: quantity)
        let waitingFor = getIntValue(value: countWaitingFor)
        return "\(UsedQuantity), W-\(waitingFor) "
    }
    
    func getDataArray() -> [Any] {
        return [
            getStringValue(value: part?.partName),
            getStringValue(value: partLocation?.locationName),
            getStringValue(value: vendor?.vendorName),
            getQuantityAndWaitingFor(),
            getStringValue(value: priceToResell?.stringValue)
        ]
    }
    
    mutating func updateModifyDate() {
        dateModified = Date()
    }
}
