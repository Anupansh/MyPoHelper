//
//  CallLog.swift
//  MyProHelper
//
//  Created by sismac010 on 02/11/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import GRDB

struct CallLog: RepositoryBaseModel {
    
    var removed             : Bool?
    var removedDate         : Date?
    var customerName        : String?
    var contactName         : String?
    var contactPhone        : String?
    var dateCreated         : Date?
    var description         : String?
//    var customer            : Customer?
    
    init() {
//        customer    = Customer()
        dateCreated = Date()
    }
    init(row: GRDB.Row) {
        
        let column               = RepositoryConstants.Columns.self
        removed                  = row[column.REMOVED]
        removedDate              = DateManager.stringToDate(string:row[column.REMOVED_DATE] ?? "")
        dateCreated              = DateManager.stringToDate(string:row[column.DATE_CREATED] ?? "")
        customerName             = row[column.CUSTOMER_NAME]
        contactName              = row[column.CONTACT_NAME]
        contactPhone             = row[column.CONTACT_PHONE]
        description              = row[column.DESCRIPTION]
//        customer                 = Customer(row: row)
    }
//    func getCustomerName() -> String {
//        return (customer?.customerName ?? "")
//    }
    
    func getDataArray() -> [Any] {
        var dateCreatedFormatted      = DateManager.dateToString(date: dateCreated)
        dateCreatedFormatted = dateCreatedFormatted == "1900-01-01 00:00:00" ? "" : dateCreatedFormatted
        
        return [
            getStringValue(value: contactName),
            getStringValue(value: description),
            getStringValue(value: contactPhone),
            getStringValue(value: customerName),
//            dateCreatedFormatted
        ]
    }
    
}
