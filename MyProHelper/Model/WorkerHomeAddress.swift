//
//  WorkerHomeAddress.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 30/07/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB

struct WorkerHomeAddress: RepositoryBaseModel {
    
    var thId            : Int?
    var workerID        : Int?
    var streetAddress1  : String?
    var streetAddress2  : String?
    var city            : String?
    var state           : String?
    var zip             : String?
    var removed         : Bool?
    var removedDate     : Date?
    
    init(row: Row) {
        let columns = RepositoryConstants.Columns.self
        
        thId           = row[columns.THID]
        workerID       = row[columns.WORKER_ID]
        streetAddress1 = row[columns.STREET_ADDRESS_ONE]
        streetAddress2 = row[columns.STREET_ADDRESS_TWO]
        city           = row[columns.CITY]
        state          = row[columns.STATE]
        zip            = row[columns.ZIP]
        removed        = row[columns.REMOVED]
        removedDate    = DateManager.stringToDate(string: row[columns.REMOVED_DATE] ?? "")
    }
    
    init() { }
    
    func getDataArray() -> [Any] {
        //Do To implement this method
        return []
    }
}
