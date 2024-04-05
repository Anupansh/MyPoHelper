//
//  WorkerRoles.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 30/07/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB

struct WorkerRoles: RepositoryBaseModel {
    
    var workerID            : Int?
    var workerRoleGroupID   : Int?
    var role                : Role
    var rolesGroup          : WorkerRolesGroup?
    var removedDate         : Date?
    var removed             : Bool?
   
    init() {
        role = Role()
    }
    
    init(row: Row) {
        let columns = RepositoryConstants.Columns.self
        
        workerID            = row[columns.WORKER_ID]
        workerRoleGroupID   = row[columns.WORKER_ROLES_GROUP_ID]
        removed             = row[columns.REMOVED]
        role                = Role(row: row)
        rolesGroup          = WorkerRolesGroup(row: row)
    }
    
    func getDataArray() -> [Any] {
        return []
    }
    
    
}
