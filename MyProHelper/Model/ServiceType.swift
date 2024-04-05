//
//  ServiceType.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 30/07/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import GRDB

struct ServiceType: RepositoryBaseModel {
    
    var serviceTypeID       : Int?
    var description         : String?
    var priceQuote          : Double?
    var dateCreated         : Date?
    var dateModified        : Date?
    var removed             : Bool?
    var removedDate         : Date?

    init() {
        dateCreated = Date()
    }
    
    init(row: GRDB.Row) {
        self.serviceTypeID      = row[RepositoryConstants.Columns.SERICE_TYPE_ID]
        self.description        = row[RepositoryConstants.Columns.DESCRIPTION]
        self.priceQuote         = row[RepositoryConstants.Columns.PRICE_QUOTE]
        self.dateCreated        = DateManager.stringToDate(string: row[RepositoryConstants.Columns.DATE_CREATED] ?? "")
        self.dateModified       = DateManager.stringToDate(string: row[RepositoryConstants.Columns.DATE_MODIFIED] ?? "")
        self.removed            = row[RepositoryConstants.Columns.REMOVED]
        self.removedDate        = DateManager.stringToDate(string: row[RepositoryConstants.Columns.REMOVED_DATE] ?? "")
    }
    
    func getDataArray() -> [Any] {
        let formattedDateCreated = DateManager.dateToString(date: dateCreated)
        return [
            description             as String?  ?? "",
            getFormattedStringValue(value: priceQuote),
            formattedDateCreated    as String?  ?? ""
        ]
    }
    
    //Only for alignment right side for specific colom index
    func decimalAlignRightSideIndex()->[Int]{
        return [1]
    }

    mutating func updateModifyDate() {
        dateModified = Date()
    }
}
