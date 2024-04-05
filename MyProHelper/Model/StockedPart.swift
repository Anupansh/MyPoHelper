//
//  StockedPart.swift
//  MyProHelper
//
//  Created by sismac010 on 19/11/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import GRDB

struct StockedPart: RepositoryBaseModel {
    
    var partID              : Int?
    var partName            : String?
    var description         : String?
    var partUsed            : PartUsed?
    var stock               : PartFinder?
    var purchasedFrom       : Vendor?
    var partLocation        : PartLocation?
    var removed             : Bool?
    var removedDate         : Date?
    var numberOfAttachments : Int?
    
    init() {
        partUsed        = PartUsed()
        stock           = PartFinder()
        purchasedFrom   = Vendor()
        partLocation    = PartLocation()
//        dateCreated     = Date()
    }
    
    init(row: GRDB.Row) {
        partID                 = row[RepositoryConstants.Columns.PART_ID]
        partName               = row[RepositoryConstants.Columns.PART_NAME]
        description            = row[RepositoryConstants.Columns.DESCRIPTION]
        removed                = row[RepositoryConstants.Columns.REMOVED]
        removedDate            = DateManager.stringToDate(string: row[RepositoryConstants.Columns.REMOVED_DATE] ?? "")
        numberOfAttachments    = row[RepositoryConstants.Columns.NUMBER_OF_ATTACHMENTS]
        partUsed               = PartUsed(row: row)
        stock                  = PartFinder(row: row)
        partLocation           = PartLocation(row: row)
        purchasedFrom          = Vendor(row: row)
    }
    
    func getDataArray() -> [Any] {
        let formattedLastPurchased = DateManager.dateToString(date: stock?.lastPurchased)
        let partName = self.partName == Constants.DefaultValue.SELECT_LIST ? "" : self.partName
        return [
            getIntValue(value: self.partID),
            getStringValue(value: partName),
            getStringValue(value: description),
            getStringValue(value: purchasedFrom?.vendorName),
            getStringValue(value: partLocation?.locationName),
            getIntValue(value: stock?.quantity),
            getIntValue(value: partUsed?.countWaitingFor),
            getStringValue(value: formattedLastPurchased),
        ]
    }
    
//    mutating func updateModifyDate() {
//        dateModified = Date()
//    }
}

extension StockedPart: Equatable {
    
    static func == (lhs: StockedPart, rhs: StockedPart) -> Bool {
        return lhs.partID == rhs.partID
    }
}

