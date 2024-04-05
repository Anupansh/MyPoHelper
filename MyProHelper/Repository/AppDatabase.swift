//
//  AppDatabase.swift
//  MyProHelper
//
//  Created by Samir on 11/29/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB


class AppDatabase {
    
    enum TypeOfAction {
        case create
        case update
        case insert
        case alter
    }
    
    static let shared  = AppDatabase()
    var companyDbQueue: DatabaseQueue?     // Company Database
    var offlineDbQueue: DatabaseQueue?      // Offline Database
    var attachDababaseQueue: DatabaseQueue?  // Attached Database
    
    private init() {
        connectDatabase()
    }
    
    private func connectDatabase() {
        let offlineDbFileName = DBHelper.getChangesDBURL()
        guard let companyId = AppLocals.serverAccessCode?.CompanyID else {return}
        let company = CompanyID(id: companyId)
        guard  let companyDbFileName = company.getDBFileNameWithPath() else { return}
        let offlineStr  =  "\(offlineDbFileName.path)"
        let custDBStr  =  "\(companyDbFileName.path)"
        
        var configuration = Configuration()
        configuration.readonly = false
        configuration.label = "MyProHelperDatabase"
        print("offline - \(offlineStr)")
        print("custDBStr - \(custDBStr)")
        do {
            var config = Configuration()
            config.readonly = false
            config.label = "MyProHelper"
            config.foreignKeysEnabled = false
            companyDbQueue = try DatabaseQueue.init(path: custDBStr, configuration: config)
            offlineDbQueue = try DatabaseQueue.init(path: offlineStr, configuration: config)
            attachDababaseQueue = try DatabaseQueue(path: custDBStr, configuration: config)
            try attachDababaseQueue?.inDatabase({ (db) in
                try db.execute(sql: "attach database '\(offlineStr)' as chg")
            })
        }
        catch let error {
            print(error.localizedDescription)
        }
    
    }
    
    func reconnectDatabase(){
        connectDatabase()
    }
    
    func executeSQL(sql: String, arguments: StatementArguments,typeOfAction: TypeOfAction,updatedId: UInt64?, success: @escaping (_ id: Int64) -> (), fail: @escaping (_ error: Error) -> ()) {
        guard let companyQueue = AppDatabase.shared.companyDbQueue else { return }
        guard let offlineQueue = AppDatabase.shared.offlineDbQueue else { return }
        var rowId: Int64 = 0
        var dbVersionChangeArgs = StatementArguments()
        switch typeOfAction {
        
        case .create,.alter:
            do {
                try companyQueue.write({ (db) in
                    try db.execute(sql: sql,arguments: arguments)
                })
                try offlineQueue.write({ (db) in
                    try db.execute(sql: sql,arguments: arguments)
                })
                success(rowId)
            }
            catch {
                print(error)
                fail(error)
            }
        case .update:
            do {
                if updatedId! < 5000000000 {
                    try companyQueue.write({ (db) in
                        try db.insertOrAddMPH(sql: sql, arguments: arguments, completionHandler: { (id,args)  in
                            rowId = id
                            dbVersionChangeArgs = args
                            
                        })
                    })
                }
                else {
                    try offlineQueue.write({ (db) in
                        try db.insertOrAddMPH(sql: sql, arguments: arguments, completionHandler: { (id,args)  in
                            rowId = id
                            dbVersionChangeArgs = args
                        })
                    })
                }
            }
            catch {
                print(error)
                fail(error)
            }
        case .insert:
            do {
                try attachDababaseQueue!.write({ (db) in
                    try db.insertOrAddMPH(sql: sql, arguments: arguments, completionHandler: { (id,args)   in
                        rowId = id
                        dbVersionChangeArgs = args
                    })
                })
                
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
        if dbVersionChangeArgs != [] {
            saveChanges(args: dbVersionChangeArgs)
        }
        success(rowId)
    }
    
    func saveChanges(args: StatementArguments) {
        do {
            try offlineDbQueue?.write({ (db) in
                try db.execute(sql: "insert into DBVersionChanges (sql) values(?)", arguments: args)
            })
        }
        catch let error {
            print(error.localizedDescription)
        }
        let server = MyProHelperServer()
        server.getDBChanges { (result) in
            print(result)
        }
    }
}

extension Database {
    func insertOrAddMPH(sql: String) throws {
        try execute(sql: sql)
        try execute(sql: "insert into  chg.[DBVersionChanges] (isInsert, sql) values(?, ?)",
                    arguments: [1, sql])
        print("Database Changes",DBHelper.getChangesDBCount())
    }
    
    func insertOrAddMPH(sql: String, arguments: StatementArguments = StatementArguments(),completionHandler: (_ rowId: Int64,_ args: StatementArguments) -> ()) throws {
        var sql1Trace:String?
        trace{  sql1Trace = $0.description  }
        try execute(sql: sql,arguments: arguments)
        if let capturedSQL = sql1Trace {
            let args2 = StatementArguments([capturedSQL])
            completionHandler(lastInsertedRowID,args2)
        }
    }

}
