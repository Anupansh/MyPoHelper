//
//  Part.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 10/07/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import GRDB

struct Part: RepositoryBaseModel {
    
    var partID              : Int?
    var partName            : String?
    var description         : String?
    var stock               : PartFinder?
    var purchasedFrom       : Vendor?
    var partLocation        : PartLocation?
    var dateCreated         : Date?
    var dateModified        : Date?
    var removed             : Bool?
    var removedDate         : Date?
    var numberOfAttachments : Int?
    
    init() {
        stock           = PartFinder()
        purchasedFrom   = Vendor()
        partLocation    = PartLocation()
        dateCreated     = Date()
    }
    
    init(row: GRDB.Row) {
        partID                 = row[RepositoryConstants.Columns.PART_ID]
        partName               = row[RepositoryConstants.Columns.PART_NAME]
        description            = row[RepositoryConstants.Columns.DESCRIPTION]
        dateCreated            = DateManager.stringToDate(string: row[RepositoryConstants.Columns.CREATED_DATE] ?? "")
        dateModified           = DateManager.stringToDate(string: row[RepositoryConstants.Columns.MODIFIED_DATE] ?? "")
        removed                = row[RepositoryConstants.Columns.REMOVED]
        removedDate            = DateManager.stringToDate(string: row[RepositoryConstants.Columns.REMOVED_DATE] ?? "")
        numberOfAttachments    = row[RepositoryConstants.Columns.NUMBER_OF_ATTACHMENTS]
        stock                  = PartFinder(row: row)
        partLocation           = PartLocation(row: row)
        purchasedFrom          = Vendor(row: row)
    }
    
    func getDataArray() -> [Any] {
        let formattedLastPurchased = DateManager.dateToString(date: stock?.lastPurchased)
        let partName = self.partName == Constants.DefaultValue.SELECT_LIST ? "" : self.partName
        return [
            getStringValue(value: partName),
            getStringValue(value: description),
            getStringValue(value: purchasedFrom?.vendorName),
            getStringValue(value: partLocation?.locationName),
            getIntValue(value: stock?.quantity),
            getFormattedStringValue(value: stock?.pricePaid),
            getFormattedStringValue(value: stock?.priceToResell),
            0,
            getStringValue(value: formattedLastPurchased),
            getIntValue(value: numberOfAttachments)
        ]
    }
    
    mutating func updateModifyDate() {
        dateModified = Date()
    }
}

extension Part: Equatable {
    
    static func == (lhs: Part, rhs: Part) -> Bool {
        return lhs.partID == rhs.partID
    }
}
