//
//  Asset.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/27/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import GRDB

struct Asset: RepositoryBaseModel  {
    
    var assetId             : Int?
    var assetName           : String?
    var description         : String?
    var modelInfo           : String?
    var datePurchased       : Date?
    var serialNumber        : String?
    var dateCreated         : Date?
    var dateModified        : Date?
    var purchasePrice       : Double?
    var assetType           : AssetType?
    var lastMaintenanceDate : Date?
    var mileage             : Int?
    var hoursUsed           : Int?
    var removed             : Bool?
    var removedDate         : Date?
    var numberOfAttachment  : Int?
    
    init() {
       dateCreated = Date()
    }
    
    init(row: GRDB.Row) {
        assetId                 = row[RepositoryConstants.Columns.ASSET_ID]
        assetName               = row[RepositoryConstants.Columns.ASSET_NAME]
        description             = row[RepositoryConstants.Columns.DESCRIPTION]
        modelInfo               = row[RepositoryConstants.Columns.MODEL_INFO]
        datePurchased           = DateManager.stringToDate(string: row[RepositoryConstants.Columns.DATE_PURHCASED] ?? "")
        serialNumber            = row[RepositoryConstants.Columns.SERIAL_NUMBER]
        dateCreated             = DateManager.stringToDate(string: row[RepositoryConstants.Columns.DATE_CREATED] ?? "")
        dateModified            = DateManager.stringToDate(string: row[RepositoryConstants.Columns.DATE_MODIFIED] ?? "")
        purchasePrice           = row[RepositoryConstants.Columns.PURHCASE_PRICE]
        lastMaintenanceDate     = DateManager.stringToDate(string: row[RepositoryConstants.Columns.LATEST_MAINTENANCE_DATE] ?? "")
        mileage                 = row[RepositoryConstants.Columns.MILEAGE]
        hoursUsed               = row[RepositoryConstants.Columns.HOURS_USED]
        removed                 = row[RepositoryConstants.Columns.REMOVED]
        removedDate             = DateManager.stringToDate(string: row[RepositoryConstants.Columns.REMOVED_DATE] ?? "")
        numberOfAttachment      = row[RepositoryConstants.Columns.NUMBER_OF_ATTACHMENTS]
        assetType               = AssetType(row: row)
    }
    
    func getDataArray() -> [Any] {
        let attachment = "\(numberOfAttachment ?? 0)-Attachments"
        let formattedDatePurchased = DateManager.dateToString(date: datePurchased)
        let formattedlastMaintenance = DateManager.dateToString(date: lastMaintenanceDate)
        
        return [
            assetName                   as String? ?? "",
            description                 as String? ?? "",
            modelInfo                   as String? ?? "",
            serialNumber                as String? ?? "",
            assetType?.typeOfAsset      as String? ?? "",
//            purchasePrice?.stringValue  as String? ?? "",
            getFormattedStringValue(value: purchasePrice),
//            mileage                     as Int? ?? 0,
            getFormattedStringValueFromInt(value: mileage),
//            hoursUsed                   as Int? ?? 0,
            getFormattedStringValueFromInt(value: hoursUsed),
            
            attachment,
            formattedlastMaintenance    as String? ?? "",
            formattedDatePurchased      as String? ?? ""
        ]
    }
    
    func decimalAlignRightSideIndex() -> [Int] {
        return [5,6,7]
    }
    
    mutating func updateModifyDate() {
        dateModified = Date()
    }
}
