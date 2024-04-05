//
//  SupplyFinder.swift
//  MyProHelper
//
//  Created by Deep on 2/17/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import GRDB

struct SupplyFinder: RepositoryBaseModel {
    
    var supplyFinderId      : Int?
    var supplyId            : Int?
    var supplyLocationID    : Int?
    var supplyLocation      : SupplyLocation?
    var quantity            : Int?
//    var wherePurchased      : Int?
    var wherePurchased      : Vendor?
    var lastPurchased       : Date?
    var pricePaid           : Double?
    var priceToResell       : Double?
    var removed             : Bool?
    var removedDate         : Date?
    
    init() { }
    
    init(stock: SupplyFinder) {
        supplyId            = stock.supplyId
        lastPurchased       = stock.lastPurchased
        pricePaid           = stock.pricePaid
        priceToResell       = stock.priceToResell
        supplyLocation      = stock.supplyLocation
        wherePurchased      = stock.wherePurchased
    }

    
    init(row: GRDB.Row) {
        let column = RepositoryConstants.Columns.self
        
        supplyFinderId      = row[column.SUPPLY_FINDER_ID]
        supplyId            = row[column.SUPPLY_ID]
        quantity            = row[column.QUANTITY]
//        wherePurchased      = row[column.WHERE_PURCHASED]
        wherePurchased      = Vendor(row: row)
        lastPurchased       = createDate(with: row[column.LAST_PURHCASED])
        pricePaid           = row[column.PRICE_PAID]
        priceToResell       = row[column.PRICE_TO_RESELL]
        removed             = row[column.REMOVED]
        removedDate         = createDate(with: row[column.REMOVED_DATE])
        supplyLocation      = SupplyLocation(row: row)
    }
    
    func getDataArray() -> [Any] {
        let lastPurchasedString = DateManager.dateToString(date: lastPurchased)
        
        return [
            getIntValue(value: quantity),
            getStringValue(value: lastPurchasedString),
            getFormattedStringValue(value: pricePaid),
            getFormattedStringValue(value: priceToResell),
            getStringValue(value: wherePurchased?.vendorName),
            getStringValue(value: supplyLocation?.locationName),
//            getYesNo(value: removed ?? false),
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


extension SupplyFinder: Equatable {
    static func == (lhs: SupplyFinder, rhs: SupplyFinder) -> Bool {
        return
            lhs.wherePurchased  == rhs.wherePurchased   &&
            lhs.supplyLocation  == rhs.supplyLocation   &&
            lhs.pricePaid       == rhs.pricePaid        &&
            lhs.priceToResell   == rhs.priceToResell
    }
}
