//
//  Quote.swift
//  MyProHelper
//
//  Created by sismac010 on 27/10/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import GRDB

struct Quote: RepositoryBaseModel {
    
    var quoteId             : Int?
    var estimateId          : Int?
    var customerID          : Int?
    var description         : String?
    var priceQuoted         : Double?
    var priceEstimate       : Bool?
    var priceFixedPrice     : Bool?
    var dateCreated         : Date?
    var dateModified        : Date?
    var priceExpires        : Date?
    var sampleQuote         : Bool?
    var removed             : Bool?
    var removedDate         : Date?
    var numberOfAttachments : Int?
    var customer            : Customer?
    
    init() {
        customer    = Customer()
        dateCreated = Date()
    }
    
    init(row: GRDB.Row) {
        
        let column               = RepositoryConstants.Columns.self
        
        quoteId                  = row[column.QUOTE_ID]
        estimateId               = row[column.ESTIMATE_ID]
        customerID               = row[column.CUSTOMER_ID]
        description              = row[column.DESCRIPTION]
        priceQuoted              = row[column.PRICE_QUOTED]
        priceEstimate            = row[column.PRICE_ESTIMATE]
        priceFixedPrice          = row[column.PRICE_FIXED_PRICE]
        dateCreated              = DateManager.stringToDate(string:row[RepositoryConstants.Columns.DATE_CREATED] ?? "")
        dateModified             = DateManager.stringToDate(string:row[RepositoryConstants.Columns.DATE_MODIFIED] ?? "")
        priceExpires             = row[column.PRICE_EXPIRES]
        sampleQuote              = row[column.SAMPLE_QOUTE]
        removed                  = row[column.REMOVED]
        removedDate              = DateManager.stringToDate(string:row[RepositoryConstants.Columns.REMOVED_DATE] ?? "")
        numberOfAttachments      = row[column.NUMBER_OF_ATTACHMENTS]
        customer                 = Customer(row: row)
    }
    
    func getCustomerName() -> String {
        return (customer?.customerName ?? "")
    }
    
    private func getYesNo(value: Bool?) -> String {
        guard let value = value else {
            return "Yes".localize
        }
        return (value == true) ? "Yes".localize : "No".localize
    }
    
    func getDataArray() -> [Any] {
        let quoteExpirationDate      = DateManager.dateToString(date: priceExpires)
        
        return [
            getIntValue(value: quoteId),
            getCustomerName(),
            getStringValue(value: description),
            getFormattedStringValue(value: priceQuoted),
            getYesNo(value: priceEstimate),
            getYesNo(value: priceFixedPrice),
            quoteExpirationDate
        ]
    }
    
    func decimalAlignRightSideIndex() -> [Int] {
        return [3]
    }
    
    mutating func addAttachment() {
        if numberOfAttachments != nil {
            numberOfAttachments! += 1
        }
        else {
            numberOfAttachments = 0
        }
    }
    
    mutating func removeAttachment() {
        if numberOfAttachments != nil, numberOfAttachments != 0 {
            numberOfAttachments! -= 1
        }
        else {
            numberOfAttachments = 0
        }
    }
}

