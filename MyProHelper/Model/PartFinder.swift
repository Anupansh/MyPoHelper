//
//  PartFinder.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 11/1/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import GRDB

struct PartFinder: RepositoryBaseModel {
    
    var partFinderId        : Int?
    var partID              : Int?
    var partLocationId      : Int?
    var partLocation        : PartLocation?
    var quantity            : Int?
    var vendorId            : Int?
    var wherePurchased      : Vendor?
    var lastPurchased       : Date?
    var pricePaid           : Double?
    var priceToResell       : Double?
    var removed             : Bool?
    var removedDate         : Date?
    var numberOfAttachment  : Int?
    
    init() { }
    
    init(stock: PartFinder) {
        partID              = stock.partID
        lastPurchased       = stock.lastPurchased
        pricePaid           = stock.pricePaid
        priceToResell       = stock.priceToResell
        partLocation        = stock.partLocation
        wherePurchased      = stock.wherePurchased
    }

    init(row: GRDB.Row) {
        partFinderId        = row[RepositoryConstants.Columns.PART_FINDER_ID]
        partID              = row[RepositoryConstants.Columns.PART_ID]
        partLocationId      = row[RepositoryConstants.Columns.PART_LOCATION_ID]
        quantity            = row[RepositoryConstants.Columns.QUANTITY]
        vendorId            = row[RepositoryConstants.Columns.VENDOR_ID]
        lastPurchased       = DateManager.stringToDate(string: row[RepositoryConstants.Columns.LAST_PURHCASED] ?? "")
        pricePaid           = row[RepositoryConstants.Columns.PRICE_PAID]
        priceToResell       = row[RepositoryConstants.Columns.PRICE_TO_RESELL]
        removed             = row[RepositoryConstants.Columns.REMOVED]
        removedDate         = DateManager.stringToDate(string: row[RepositoryConstants.Columns.REMOVED_DATE] ?? "")
        numberOfAttachment  = row[RepositoryConstants.Columns.NUMBER_OF_ATTACHMENTS]
        wherePurchased      = Vendor(row: row)
        partLocation        = PartLocation(row: row)
    }
    
    func getDataArray() -> [Any] {
        let lastPurchasedString = DateManager.dateToString(date: lastPurchased)
        
        return [
            getIntValue(value: quantity),
            getStringValue(value: lastPurchasedString),
            getFormattedStringValue(value: pricePaid),
            getFormattedStringValue(value: priceToResell),
            getStringValue(value: wherePurchased?.vendorName),
            getStringValue(value: partLocation?.locationName),
        ]
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
}

extension PartFinder: Equatable {
    static func == (lhs: PartFinder, rhs: PartFinder) -> Bool {
        return
            lhs.wherePurchased  == rhs.wherePurchased   &&
            lhs.partLocation    == rhs.partLocation     &&
            lhs.pricePaid       == rhs.pricePaid        &&
            lhs.priceToResell   == rhs.priceToResell
    }
}
