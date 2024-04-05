//
//  Vendor.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 17/06/1942 Saka.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import GRDB

struct Vendor: RepositoryBaseModel, Codable {
    
    var vendorID            : Int?
    var vendorName          : String?
    var phone               : String?
    var email               : String?
    var contactName         : String?
    var accountNumber       : String?
    var mostRecentContact   : Date?
    var numberOfAttachments : Int?
    var removed             : Bool?
    var removedDate         : Date?
    
    init() { }
    
    init(row: GRDB.Row) {
        vendorID               = row[RepositoryConstants.Columns.VENDOR_ID]
        vendorName             = row[RepositoryConstants.Columns.VENDOR_NAME]
        phone                  = row[RepositoryConstants.Columns.PHONE]
        email                  = row[RepositoryConstants.Columns.EMAIL]
        contactName            = row[RepositoryConstants.Columns.CONTACT_NAME]
        accountNumber          = row[RepositoryConstants.Columns.ACCOUNT_NUMBER]
        mostRecentContact      = DateManager.stringToDate(string: row[RepositoryConstants.Columns.MOST_RECENT_COTACT] ?? "")
        numberOfAttachments    = row[RepositoryConstants.Columns.NUMBER_OF_ATTACHMENTS]
        removed                = row[RepositoryConstants.Columns.REMOVED]
        removedDate            = DateManager.stringToDate(string: row[RepositoryConstants.Columns.REMOVED_DATE] ?? "")
    }
    
    func getDataArray() -> [Any] {
        let mostRecentString = DateManager.dateToString(date: mostRecentContact)
        return [
            self.vendorName             as String?  ??  "",
            self.phone                  as String?  ??  "",
            self.email                  as String?  ??  "",
            self.contactName            as String?  ??  "",
            self.accountNumber          as String?  ??  "",
            mostRecentString            as String?  ??  "",
            self.numberOfAttachments    as Int?     ??  0
        ]
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

extension Vendor: Equatable {
    
    static func == (lhs: Vendor, rhs: Vendor) -> Bool {
        return lhs.vendorID == rhs.vendorID
    }
}
