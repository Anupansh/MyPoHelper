//
//  Supply.swift
//  MyProHelper
//
//  Created by Deep on 2/17/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import GRDB

struct Supply: RepositoryBaseModel {
    
    var supplyId              : Int?
    var supplyName            : String?
    var description         : String?
    var stock               : SupplyFinder?
    var purchasedFrom       : Vendor?
    var supplyLocation      : SupplyLocation?
    var dateCreated         : Date?
    var dateModified        : Date?
    
    var removed             : Bool?
    var removedDate         : Date?
    var numberOfAttachments : Int?
    
    init() {
        
        stock           = SupplyFinder()
        purchasedFrom   = Vendor()
        supplyLocation  = SupplyLocation()
        dateCreated     = Date()
    }
    
    init(row: GRDB.Row) {
        let column = RepositoryConstants.Columns.self
        
        supplyId               = row[column.SUPPLY_ID]
        supplyName             = row[column.SUPPLY_NAME]
        description            = row[column.DESCRIPTION]
        dateCreated            = DateManager.stringToDate(string: row[column.CREATED_DATE] ?? "")
        dateModified           = DateManager.stringToDate(string: row[column.MODIFIED_DATE] ?? "")
        removed                = row[column.REMOVED]
        removedDate            = createDate(with: column.REMOVED_DATE)
        numberOfAttachments    = row[column.NUMBER_OF_ATTACHMENTS]
        stock                  = SupplyFinder(row: row)
        supplyLocation         = SupplyLocation(row: row)
        purchasedFrom          = Vendor(row: row)
    }
    
    func getDataArray() -> [Any] {
        let formattedLastPurchased = DateManager.dateToString(date: stock?.lastPurchased)
        return [
            getStringValue(value: supplyName),
            getStringValue(value: description),
            getStringValue(value: purchasedFrom?.vendorName),
            getStringValue(value: supplyLocation?.locationName),
            getIntValue(value: stock?.quantity),
            getFormattedStringValue(value: stock?.pricePaid),
            getFormattedStringValue(value: stock?.priceToResell),
            getStringValue(value: formattedLastPurchased),
            getIntValue(value: numberOfAttachments)
        ]
    }
    
    mutating func updateModifyDate() {
        dateModified = Date()
    }
}


extension Supply: Equatable {
    
    static func == (lhs: Supply, rhs: Supply) -> Bool {
        return lhs.supplyId == rhs.supplyId
    }
}
