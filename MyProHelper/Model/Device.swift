//
//  Device.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 29/07/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB

struct Device: RepositoryBaseModel {
    
    var deviceID                : Int?
    var workerID                : Int?
    var deviceGUID              : String?
    var deviceName              : String?
    var deviceType              : String?
    var deviceCode              : String?
    var deviceCodeExpiration    : Date?
    var isDeviceSetup           : Bool?
    var removed                 : Bool?
    var removedDate             : Date?
    var worker                  : Worker?
    
    init() {
        worker = Worker()
    }
    
    init(row: Row) {
        let column = RepositoryConstants.Columns.self
        
        deviceID               = row[column.DEVICE_ID]
        workerID               = row[column.WORKER_ID]
        deviceGUID             = row[column.DEVICE_GUID]
        deviceName             = row[column.DEVICE_NAME]
        deviceType             = row[column.DEVICE_TYPE]
        deviceCode             = row[column.DEVICE_CODE]
        deviceCodeExpiration   = DateManager.stringToDate(string: row[column.DEVICE_CODE_EXPIRATION] ?? "")
        isDeviceSetup          = row[column.IS_DEVICE_SETUP]
        removed                = row[column.REMOVED]
        removedDate            = DateManager.stringToDate(string: row[column.REMOVED_DATE] ?? "")
        worker                 = Worker(row: row)
    }
    
    func getDataArray() -> [Any] {
        let formattedExirationCode = DateManager.dateToString(date: deviceCodeExpiration)
        return [
            worker?.fullName        as String? ?? "",
            deviceName              as String? ?? "",
            deviceType              as String? ?? "",
            deviceCode              as String? ?? "",
            isDeviceSetup           as Bool?   ?? "",
            formattedExirationCode  as String? ?? ""
        ]
    }
}
