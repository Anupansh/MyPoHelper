//
//  SupplyLocation.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 30/07/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import GRDB

struct SupplyLocation: RepositoryBaseModel, Codable {
    
    var supplyLocationID    : Int?
    var locationName        : String?
    var locationDescription : String?
    var dateCreated         : Date?
    var dateModified        : Date?
    var removed             : Bool?
    var removedDate         : Date?
    
    init() {
        dateCreated = Date()
    }
    
    init(row: GRDB.Row) {
        supplyLocationID        = row[RepositoryConstants.Columns.SUPPLY_LOCATION_ID]
        locationName            = row[RepositoryConstants.Columns.LOCATION_NAME]
        locationDescription     = row[RepositoryConstants.Columns.LOCATION_DESCRIPTION]
        dateCreated             = DateManager.stringToDate(string: row[RepositoryConstants.Columns.DATE_CREATED] ?? "")
        dateModified            = DateManager.stringToDate(string: row[RepositoryConstants.Columns.DATE_MODIFIED] ?? "")
        removed                 = row[RepositoryConstants.Columns.REMOVED]
        removedDate             = DateManager.stringToDate(string: row[RepositoryConstants.Columns.REMOVED_DATE] ?? "")
    }
    
    func getDataArray() -> [Any] {
        let formattedDateCreated = DateManager.dateToString(date: dateCreated)
        
        return [
            locationName            as String? ?? "",
            locationDescription     as String? ?? "",
            formattedDateCreated    as String? ?? ""
        ]
    }
    
    mutating func updateModifyDate() {
        dateModified = Date()
    }
}


extension SupplyLocation: Equatable {
    
    static func == (lhs: SupplyLocation, rhs: SupplyLocation) -> Bool {
        return lhs.supplyLocationID == rhs.supplyLocationID
    }
}
