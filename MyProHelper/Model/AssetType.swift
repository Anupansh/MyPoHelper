//
//  AssetType.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/26/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import GRDB

struct AssetType: RepositoryBaseModel {
    
    var id              : Int?
    var typeOfAsset     : String?
    var dateCreated     : Date?
    var dateModified    : Date?
    var removed         : Bool?
    var removedDate     : Date?
    
    init() {
        dateCreated = Date()
    }
   
    init(row: GRDB.Row) {
        id              = row[RepositoryConstants.Columns.ASSET_TYPE_ID]
        typeOfAsset     = row[RepositoryConstants.Columns.TYPE_OF_ASSET] as String?
        dateCreated     = DateManager.stringToDate(string: row[RepositoryConstants.Columns.DATE_CREATED] ?? "")
        dateModified    = DateManager.stringToDate(string: row[RepositoryConstants.Columns.DATE_MODIFIED] ?? "")
        removed         = row[RepositoryConstants.Columns.REMOVED]
        removedDate     = DateManager.stringToDate(string: row[RepositoryConstants.Columns.REMOVED_DATE] ?? "")
    }
    
    func getDataArray() -> [Any] {
        let formattedDateCreated = DateManager.dateToString(date: dateCreated)
        
        return [
            typeOfAsset             as String?  ?? "",
            formattedDateCreated    as String?  ?? ""
        ]
    }
    
    mutating func updateModifyDate() {
        dateModified = Date()
    }
}
