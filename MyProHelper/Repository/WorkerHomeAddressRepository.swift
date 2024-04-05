//
//  WorkerHomeAddressDBService.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 20/06/1942 Saka.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB

class WorkerHomeAddressRepository: BaseRepository {
        
    init() {
        super.init(table: .WORKER_HOME_ADDRESS)
        createSelectedLayoutTable()
    }
    
    override func setIdKey() -> String {
        return COLUMNS.THID
    }
    
    private func createSelectedLayoutTable() {
        let sql = """
            CREATE TABLE IF NOT EXISTS \(tableName)(
                \(COLUMNS.THID)         INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
                \(COLUMNS.WORKER_ID)    INTEGER REFERENCES \(TABLES.WORKERS)(\(COLUMNS.WORKER_ID)),
                \(COLUMNS.STREET_ADDRESS_ONE)       TEXT,
                \(COLUMNS.STREET_ADDRESS_TWO)       TEXT,
                \(COLUMNS.CITY)                     TEXT,
                \(COLUMNS.STATE)                    TEXT,
                \(COLUMNS.ZIP)                      TEXT,
                \(COLUMNS.SAMPLE_WORKER_ADDRESS)    INTEGER     DEFAULT(0),
                \(COLUMNS.REMOVED)                  INTEGER     DEFAULT(0),
                \(COLUMNS.REMOVED_DATE)             TEXT
            )
        """
        AppDatabase.shared.executeSQL(sql: sql,
                                      arguments: [],typeOfAction: .create, updatedId: nil) { (_) in
            print("TABLE WORKERS HOME ADDRESS IS CREATED SUCCESSFULLY")
        } fail: { (error) in
            print(error)
        }
    }
    
    func createAddress(workerAddress: WorkerHomeAddress, success: @escaping(_ id: Int64) -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "workerId"      : workerAddress.workerID,
            "addressOne"    : workerAddress.streetAddress1,
            "addressTwo"    : workerAddress.streetAddress2,
            "city"          : workerAddress.city,
            "state"         : workerAddress.state,
            "zip"           : workerAddress.zip,
            "removed"       : workerAddress.removed,
            "removeDate"    : DateManager.getStandardDateString(date: workerAddress.removedDate)
        ]
        let sql = """
            INSERT INTO chg.\(tableName) (
                \(COLUMNS.WORKER_ID),
                \(COLUMNS.STREET_ADDRESS_ONE),
                \(COLUMNS.STREET_ADDRESS_TWO),
                \(COLUMNS.CITY),
                \(COLUMNS.STATE),
                \(COLUMNS.ZIP),
                \(COLUMNS.REMOVED),
                \(COLUMNS.REMOVED_DATE)
            )

            VALUES (:workerId,
                    :addressOne,
                    :addressTwo,
                    :city,
                    :state,
                    :zip,
                    :removed,
                    :removeDate
            )
            """
        AppDatabase.shared.executeSQL(sql: sql,
                                      arguments: arguments,
                                      typeOfAction: .insert, updatedId: nil,
                                      success: { id in
                                        success(id)
                                      },
                                      fail: failure)
    }
    
    func updateAddress(workerAddress: WorkerHomeAddress, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "id"            : workerAddress.thId,
            "workerId"      : workerAddress.workerID,
            "addressOne"    : workerAddress.streetAddress1,
            "addressTwo"    : workerAddress.streetAddress2,
            "city"          : workerAddress.city,
            "state"         : workerAddress.state,
            "zip"           : workerAddress.zip,
            "removed"       : workerAddress.removed,
            "removeDate"    : DateManager.getStandardDateString(date: workerAddress.removedDate)
        ]
        
        let sql = """
            UPDATE \(tableName) SET
                \(COLUMNS.WORKER_ID)            = :workerId,
                \(COLUMNS.STREET_ADDRESS_ONE)   = :addressOne,
                \(COLUMNS.STREET_ADDRESS_TWO)   = :addressTwo,
                \(COLUMNS.CITY)                 = :city,
                \(COLUMNS.STATE)                = :state,
                \(COLUMNS.ZIP)                  = :zip,
                \(COLUMNS.REMOVED)              = :removed,
                \(COLUMNS.REMOVED_DATE)         = :removeDate
            WHERE \(tableName).\(setIdKey()) = :id;
            """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                      arguments: arguments,
                                      typeOfAction: .update, updatedId: UInt64(workerAddress.thId!),
                                      success: { _ in
                                        success()
                                      },
                                      fail: failure)
    }
    
    func deleteAddress(workerAddress: WorkerHomeAddress, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = workerAddress.thId else { return }
        softDelete(atId: id, success: success, fail: failure)
    }
    
    func restoreAddress(workerAddress: WorkerHomeAddress, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = workerAddress.thId else { return }
        restoreItem(atId: id, success: success, fail: failure)
    }
}
