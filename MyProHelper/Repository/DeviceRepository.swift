//
//  DeviceDBService.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 25/06/1942 Saka.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB

class DeviceRepository: BaseRepository {
        
    init() {
        super.init(table: .DEVICES)
        createSelectedLayoutTable()
    }
    
    override func setIdKey() -> String {
        return COLUMNS.DEVICE_ID
    }
    
    private func createSelectedLayoutTable() {
       let sql = """
            CREATE TABLE IF NOT EXISTS \(tableName) (
            \(COLUMNS.DEVICE_ID)                INTEGER PRIMARY KEY  AUTOINCREMENT UNIQUE NOT NULL,
            \(COLUMNS.WORKER_ID)                INTEGER References \(TABLES.WORKERS) (\(COLUMNS.WORKER_ID)),
            \(COLUMNS.DEVICE_GUID)              TEXT,
            \(COLUMNS.DEVICE_NAME)              TEXT,
            \(COLUMNS.DEVICE_TYPE)              TEXT,
            \(COLUMNS.DEVICE_CODE)              TEXT,
            \(COLUMNS.DEVICE_CODE_EXPIRATION)   TEXT,
            \(COLUMNS.IS_DEVICE_SETUP)          INTEGER DEFAULT (0),
            \(COLUMNS.SAMPLE_DEVICE)            INTEGER DEFAULT (0),
            \(COLUMNS.REMOVED)                  INTEGER DEFAULT (0),
            \(COLUMNS.REMOVED_DATE)             TEXT)
        """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                      arguments: [],typeOfAction: .create, updatedId: nil) { (_) in
            print("TABLE DEVICES IS CREATED SUCCESSFULLY")
        } fail: { (error) in
            print(error)
        }

    }
    
    func insertDevice(device: Device, success: @escaping(_ id: Int64) -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "workerId"              : device.workerID,
            "deviceGUID"            : device.deviceGUID,
            "deviceName"            : device.deviceName,
            "deviceType"            : device.deviceType,
            "deviceCode"            : device.deviceCode,
            "deviceCodeExpiration"  : DateManager.getStandardDateString(date: device.deviceCodeExpiration),
            "isDeviceSetup"         : device.isDeviceSetup,
            "removed"               : device.removed,
            "removedDate"           : DateManager.getStandardDateString(date: device.removedDate)
        ]
        let sql = """
            INSERT INTO chg.\(tableName) (
                            \(COLUMNS.WORKER_ID),
                            \(COLUMNS.DEVICE_GUID),
                            \(COLUMNS.DEVICE_NAME),
                            \(COLUMNS.DEVICE_TYPE),
                            \(COLUMNS.DEVICE_CODE),
                            \(COLUMNS.DEVICE_CODE_EXPIRATION),
                            \(COLUMNS.IS_DEVICE_SETUP),
                            \(COLUMNS.REMOVED),
                            \(COLUMNS.REMOVED_DATE)
                        )
            VALUES (:workerId,
                    :deviceGUID,
                    :deviceName,
                    :deviceType,
                    :deviceCode,
                    :deviceCodeExpiration,
                    :isDeviceSetup,
                    :removed,
                    :removedDate)
            """
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,typeOfAction: .insert, updatedId: nil,
                                     success: { id in
                                        success(id)
                                     },
                                     fail: failure)
    }
    
    func update(device: Device, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "id"                    : device.deviceID,
            "workerId"              : device.workerID,
            "deviceGUID"            : device.deviceGUID,
            "deviceName"            : device.deviceName,
            "deviceType"            : device.deviceType,
            "deviceCode"            : device.deviceCode,
            "deviceCodeExpiration"  : DateManager.getStandardDateString(date: device.deviceCodeExpiration),
            "isDeviceSetup"         : device.isDeviceSetup,
            "removed"               : device.removed,
            "removedDate"           : DateManager.getStandardDateString(date: device.removedDate)
        ]
        
        let sql = """
            UPDATE \(tableName) SET
                            \(COLUMNS.WORKER_ID)                = :workerId,
                            \(COLUMNS.DEVICE_GUID)              = :deviceGUID,
                            \(COLUMNS.DEVICE_NAME)              = :deviceName,
                            \(COLUMNS.DEVICE_TYPE)              = :deviceType,
                            \(COLUMNS.DEVICE_CODE)              = :deviceCode,
                            \(COLUMNS.DEVICE_CODE_EXPIRATION)   = :deviceCodeExpiration,
                            \(COLUMNS.IS_DEVICE_SETUP)          = :isDeviceSetup,
                            \(COLUMNS.REMOVED)                  = :removed,
                            \(COLUMNS.REMOVED_DATE)             = :removedDate
            WHERE \(tableName).\(setIdKey()) = :id;
            """
        AppDatabase.shared.executeSQL(sql: sql,
                                     arguments: arguments,
                                     typeOfAction: .update, updatedId: UInt64(device.deviceID!),
                                     success: { _ in
                                        success()
                                     },
                                     fail: failure)
    }
    
    func deleteDevice(device: Device, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = device.deviceID else { return }
        softDelete(atId: id, success: success, fail: failure)
    }
    
    func restoreDevice(device: Device, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = device.deviceID else { return }
        restoreItem(atId: id, success: success, fail: failure)
    }
    
    func fetchDevice(showRemoved: Bool,for worker: Worker,key: String? = nil,sortBy: DeviceFields? = nil, sortType: SortType? = nil,offset: Int, success: @escaping(_ devices: [Device]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let workerId = worker.workerID else { return }
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        
        let searchable = makeSearchableItems(key: key)
        let sortable = makeSortableItems(sortBy: sortBy, sortType: sortType)
        let removedCondition = """
        WHERE (main.\(tableName).\(COLUMNS.REMOVED) = 0
        OR main.\(tableName).\(COLUMNS.REMOVED) is NULL)
        """
//        let condition = (searchable.isEmpty) ? removedCondition :"\(removedCondition) AND \(searchable)"
        let showRemovedCondition = " WHERE (main.\(tableName).\(COLUMNS.REMOVED) = 1) "
        let condition = (searchable.isEmpty) ? (showRemoved ? showRemovedCondition : removedCondition) : " \((showRemoved ? showRemovedCondition : removedCondition)) AND \(searchable)"

        
        var sql = """
        SELECT * FROM main.\(tableName) JOIN main.\(TABLES.WORKERS) ON main.\(tableName).\(COLUMNS.WORKER_ID) = main.\(TABLES.WORKERS).\(COLUMNS.WORKER_ID)
        \(condition)
        AND main.\(tableName).\(COLUMNS.WORKER_ID) = \(workerId)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        sql += """
                \(sortable.replaceMain())
                LIMIT \(LIMIT) OFFSET \(offset);
        """
        do {
            let devices = try queue.read({ (db) -> [Device] in
                var devices: [Device] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    devices.append(.init(row: row))
                }
                return devices
            })
            success(devices)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    func fetchDevice(showRemoved: Bool,for worker: Worker, isDeviceSetup:Bool,key: String? = nil,sortBy: DeviceFields? = nil, sortType: SortType? = nil,offset: Int, success: @escaping(_ devices: [Device]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let workerId = worker.workerID else { return }
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        
        let searchable = makeSearchableItems(key: key)
        let sortable = makeSortableItems(sortBy: sortBy, sortType: sortType)
        let removedCondition = """
        WHERE (main.\(tableName).\(COLUMNS.REMOVED) = 0
        OR main.\(tableName).\(COLUMNS.REMOVED) is NULL)
        """
//        let condition = (searchable.isEmpty) ? removedCondition :"\(removedCondition) AND \(searchable)"
        let showRemovedCondition = " WHERE (main.\(tableName).\(COLUMNS.REMOVED) = 1) "
        let condition = (searchable.isEmpty) ? (showRemoved ? showRemovedCondition : removedCondition) : " \((showRemoved ? showRemovedCondition : removedCondition)) AND \(searchable)"

        
        var sql = """
        SELECT * FROM main.\(tableName) JOIN main.\(TABLES.WORKERS) ON main.\(tableName).\(COLUMNS.WORKER_ID) = main.\(TABLES.WORKERS).\(COLUMNS.WORKER_ID)
        \(condition)
        AND main.\(tableName).\(COLUMNS.WORKER_ID) = \(workerId)
        AND main.\(tableName).\(COLUMNS.IS_DEVICE_SETUP) = \(isDeviceSetup)
        """
        
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        sql += """
                \(sortable.replaceMain())
                LIMIT \(LIMIT) OFFSET \(offset);
        """
        do {
            let devices = try queue.read({ (db) -> [Device] in
                var devices: [Device] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    devices.append(.init(row: row))
                }
                return devices
            })
            success(devices)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    private func makeSortableItems(sortBy: DeviceFields?, sortType: SortType?) -> String {
        guard let sortBy = sortBy, let sortType = sortType else {
            return makeSortableCondition(key: "main.\(TABLES.WORKERS).\(COLUMNS.FIRST_NAME)", sortType: .ASCENDING)
        }
        switch sortBy {
        case .WORKER_NAME:
            let key = "main.\(TABLES.WORKERS).\(COLUMNS.FIRST_NAME)"
            return makeSortableCondition(key: key, sortType: sortType)
        case .DEVICE_NAME:
            return makeSortableCondition(key: COLUMNS.DEVICE_NAME, sortType: sortType)
        case .DEVICE_TYPE:
            return makeSortableCondition(key: COLUMNS.DEVICE_TYPE, sortType: sortType)
        case .DEVICE_CODE:
            return makeSortableCondition(key: COLUMNS.DEVICE_CODE, sortType: sortType)
        case .IS_DEVICE_SETUP:
            return makeSortableCondition(key: COLUMNS.IS_DEVICE_SETUP, sortType: sortType)
        case .CODE_EXPIRES:
            return makeSortableCondition(key: COLUMNS.DEVICE_CODE_EXPIRATION, sortType: sortType)
        }
    }
    
    private func makeSearchableItems(key: String?) -> String {
        guard let key = key else { return "" }
        return  makeSearchableCondition(key: key,
                                        fields: [
                                            "main.\(TABLES.WORKERS).\(COLUMNS.FIRST_NAME)",
                                            COLUMNS.DEVICE_NAME,
                                            COLUMNS.DEVICE_TYPE,
                                            COLUMNS.DEVICE_CODE,
                                            COLUMNS.IS_DEVICE_SETUP,
                                            COLUMNS.DEVICE_CODE_EXPIRATION])
    }
}
