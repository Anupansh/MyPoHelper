//
//  User.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 05/06/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import GRDB

struct Customer: RepositoryBaseModel {
    
    var customerID          : Int?
    var customerName        : String?
    var billingAddress1     : String?
    var billingAddress2     : String?
    var billingAddressCity  : String?
    var billingAddressState : String?
    var billingAddressZip   : String?
    var contactName         : String?
    var contactPhone        : String?
    var contactEmail        : String?
    var mostRecentContact   : Date?
    var removed             : Bool?
    var removedDate         : Date?
    
    init() { }
    
    init(row: Row) {
        self.customerID             = row[RepositoryConstants.Columns.CUSTOMER_ID]
        self.customerName           = row[RepositoryConstants.Columns.CUSTOMER_NAME]
        self.billingAddress1        = row[RepositoryConstants.Columns.BILLING_ADDRESS_1]
        self.billingAddress2        = row[RepositoryConstants.Columns.BILLING_ADDRESS_2]
        self.billingAddressCity     = row[RepositoryConstants.Columns.BILLING_ADDRESS_CITY]
        self.billingAddressState    = row[RepositoryConstants.Columns.BILLING_ADDRESS_STATE]
        self.billingAddressZip      = row[RepositoryConstants.Columns.BILLING_ADDRESS_ZIP]
        self.contactName            = row[RepositoryConstants.Columns.CUSTOMER_NAME]
        self.contactPhone           = row[RepositoryConstants.Columns.CONTACT_PHONE]
        self.contactEmail           = row[RepositoryConstants.Columns.CONTACT_EMAIL]
        self.mostRecentContact      = DateManager.stringToDate(string: row[RepositoryConstants.Columns.MOST_RECENT_COTACT] ?? "")
        self.removed                = row[RepositoryConstants.Columns.REMOVED]
        self.removedDate            = DateManager.stringToDate(string: row[RepositoryConstants.Columns.REMOVED_DATE] ?? "")
    }
    
    func getDataArray() -> [Any] {
        let city    = billingAddressCity ?? ""
        let state   = billingAddressState ?? ""
        let cityAndState  = city + ", " + state
        
        return [
            self.customerID             as Int?     ?? 0,
            self.customerName           as String?  ?? "",
            self.contactPhone           as String?  ?? "",
            self.contactEmail           as String?  ?? "",
            self.billingAddress1        as String?  ?? "",
            self.billingAddress2        as String?  ?? "",
            cityAndState,
            self.billingAddressZip      as String?  ?? ""
        ]
    }
}
