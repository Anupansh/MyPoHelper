//
//  ServiceUsed.swift
//  MyProHelper
//
//  Created by Deep on 2/7/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import GRDB

struct ServiceUsed: RepositoryBaseModel {
    
    var serviceUsedId       : Int?
    var serviceTypeId       : Int?
    var invoiceId           : Int?
    var priceToResell       : Double?
    var quantity            : Int?
    var dateAdded           : Date?
    var dateModified        : Date?
    var removed             : Bool?
    var removedDate         : Date?
    
    var serviceType         : ServiceType?

    init() {
        dateAdded    = Date()
        serviceType  = ServiceType()
    }
    
    init(row: GRDB.Row) {
        let column = RepositoryConstants.Columns.self
        
        self.serviceUsedId      = row[column.SERVICE_USED_ID]
        self.serviceTypeId      = row[column.SERICE_TYPE_ID]
        self.invoiceId          = row[column.INVOICE_ID]
        self.priceToResell      = row[column.PRICE_TO_RESELL]
        self.quantity           = row[column.QUANTITY]
        self.dateAdded        = DateManager.stringToDate(string: row[RepositoryConstants.Columns.DATE_CREATED] ?? "")
        self.dateModified       = DateManager.stringToDate(string: row[RepositoryConstants.Columns.DATE_MODIFIED] ?? "")
        self.removed            = row[RepositoryConstants.Columns.REMOVED]
        self.removedDate        = DateManager.stringToDate(string: row[RepositoryConstants.Columns.REMOVED_DATE] ?? "")
        
        self.serviceType        = ServiceType(row: row)
    }
    
    func getServiceTypeName() -> String {
        return (serviceType?.description ?? "")
    }

    func getDataArray() -> [Any] {
        return [
            getServiceTypeName(),
            quantity              as Int?  ?? 0,
            priceToResell         as Double?  ?? 0.0
        ]
    }
    
    mutating func updateModifyDate() {
        dateModified = Date()
    }
}
