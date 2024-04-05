//
//  WorkersDBService.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 23/05/1942 Saka.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import GRDB

class WorkerRepository: BaseRepository{
    
    init() {
        super.init(table: .WORKERS)
        createSelectedLayoutTable()
    }
    
    override func setIdKey() -> String {
        return COLUMNS.WORKER_ID
    }
    
    private func createSelectedLayoutTable() {
        let sql = """
            CREATE TABLE IF NOT EXISTS \(tableName)(
                \(COLUMNS.WORKER_ID) INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
                \(COLUMNS.FIRST_NAME)       TEXT(100) NOT NULL,
                \(COLUMNS.MIDDLE_NAME)      TEXT(100),
                \(COLUMNS.LAST_NAME)        TEXT(100) NOT NULL,
                \(COLUMNS.NICKNAME)         TEXT(100),
                \(COLUMNS.CELL_NUMBER)      TEXT(100),
                \(COLUMNS.EMAIL)            TEXT(100),
                \(COLUMNS.HOURLY_WORKER)    INTEGER     DEFAULT(0),
                \(COLUMNS.SALARY)           INTEGER     DEFAULT(0),
                \(COLUMNS.CONTRACTOR)       INTEGER     DEFAULT(0),
                \(COLUMNS.WORKER_THEME)     TEXT,
                \(COLUMNS.BACKGROUND_COLOR) TEXT,
                \(COLUMNS.FONT_COLOR)       TEXT,
                \(COLUMNS.SAMPLE_WORKER)    INTEGER     DEFAULT(0),
                \(COLUMNS.REMOVED)          INTEGER     DEFAULT(0),
                \(COLUMNS.REMOVED_DATE)     TEXT,
                \(COLUMNS.CREATED_DATE)     TEXT,
                \(COLUMNS.MODIFIED_DATE)    TEXT
            )
        """
        AppDatabase.shared.executeSQL(sql: sql,
                                      arguments: [],typeOfAction: .create, updatedId: nil) { (_) in
            print("TABLE WORKERS IS CREATED SUCCESSFULLY")
        } fail: { (error) in
            print(error)
        }
    }
    
    func createWorker(worker: Worker, success: @escaping(_ id: Int64) -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "firstName"         : worker.firstName,
            "middleName"        : worker.middleName,
            "lastName"          : worker.lastName,
            "nickname"          : worker.nickName,
            "cellNumber"        : worker.cellNumber,
            "email"             : worker.email,
            "salary"            : worker.salary,
            "hourlyWorker"      : worker.hourlyWorker,
            "contractor"        : worker.contractor,
            "workerTheme"       : worker.workerTheme,
            "backgroundColor"   : worker.backgroundColor,
            "fontColor"         : worker.fontColor,
            "removed"           : worker.removed ?? 1,
            "removeDate"        : DateManager.getStandardDateString(date: worker.removedDate),
            "createdData"       : DateManager.getStandardDateString(date: worker.createdDate),
            "modifiedDate"      : DateManager.getStandardDateString(date: worker.modifiedDate)
        ]
        let sql = """
            INSERT INTO chg.\(tableName) (
                \(COLUMNS.FIRST_NAME),
                \(COLUMNS.MIDDLE_NAME),
                \(COLUMNS.LAST_NAME),
                \(COLUMNS.NICKNAME),
                \(COLUMNS.CELL_NUMBER),
                \(COLUMNS.EMAIL),
                \(COLUMNS.SALARY),
                \(COLUMNS.HOURLY_WORKER),
                \(COLUMNS.CONTRACTOR),
                \(COLUMNS.WORKER_THEME),
                \(COLUMNS.BACKGROUND_COLOR),
                \(COLUMNS.FONT_COLOR),
                \(COLUMNS.REMOVED),
                \(COLUMNS.REMOVED_DATE),
                \(COLUMNS.CREATED_DATE),
                \(COLUMNS.MODIFIED_DATE)
            )

            VALUES (:firstName,
                    :middleName,
                    :lastName,
                    :nickname,
                    :cellNumber,
                    :email,
                    :salary,
                    :hourlyWorker,
                    :contractor,
                    :workerTheme,
                    :backgroundColor,
                    :fontColor,
                    :removed,
                    :removeDate,
                    :createdData,
                    :modifiedDate
            )
            """
        AppDatabase.shared.executeSQL(sql: sql,
                                      arguments: arguments,typeOfAction: .insert, updatedId: nil,
                                      success: { id in
                                        success(id)
                                      },
                                      fail: failure)
    }
    
    func updateWorker(worker: Worker, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "id"                : worker.workerID,
            "firstName"         : worker.firstName,
            "middleName"        : worker.middleName,
            "lastName"          : worker.lastName,
            "nickname"          : worker.nickName,
            "cellNumber"        : worker.cellNumber,
            "email"             : worker.email,
            "salary"            : worker.salary,
            "hourlyWorker"      : worker.hourlyWorker,
            "contractor"        : worker.contractor,
            "workerTheme"       : worker.workerTheme,
            "backgroundColor"   : worker.backgroundColor,
            "fontColor"         : worker.fontColor,
            "removed"           : worker.removed,
            "removeDate"        : DateManager.getStandardDateString(date: worker.removedDate),
            "createdData"       : DateManager.getStandardDateString(date: worker.createdDate),
            "modifiedDate"      : DateManager.getStandardDateString(date: worker.modifiedDate)
        ]
        
        let sql = """
            UPDATE \(tableName) SET
                \(COLUMNS.FIRST_NAME)               = :firstName,
                \(COLUMNS.MIDDLE_NAME)              = :middleName,
                \(COLUMNS.LAST_NAME)                = :lastName,
                \(COLUMNS.NICKNAME)                 = :nickname,
                \(COLUMNS.CELL_NUMBER)              = :cellNumber,
                \(COLUMNS.EMAIL)                    = :email,
                \(COLUMNS.SALARY)                   = :salary,
                \(COLUMNS.HOURLY_WORKER)            = :hourlyWorker,
                \(COLUMNS.CONTRACTOR)               = :contractor,
                \(COLUMNS.WORKER_THEME)             = :workerTheme,
                \(COLUMNS.BACKGROUND_COLOR)         = :backgroundColor,
                \(COLUMNS.FONT_COLOR)               = :fontColor,
                \(COLUMNS.REMOVED)                  = :removed,
                \(COLUMNS.REMOVED_DATE)             = :removeDate,
                \(COLUMNS.CREATED_DATE)             = :createdData,
                \(COLUMNS.MODIFIED_DATE)            = :modifiedDate
            WHERE \(tableName).\(setIdKey()) = :id;
            """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                      arguments: arguments,
                                      typeOfAction: .update, updatedId: UInt64(worker.workerID!),
                                      success: { _ in
                                        success()
                                      },
                                      fail: failure)
    }
    
    func deleteWorker(worker: Worker, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = worker.workerID else { return }
        softDelete(atId: id, success: success, fail: failure)
    }
    
    func restoreWorker(worker: Worker, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = worker.workerID else { return }
        restoreItem(atId: id, success: success, fail: failure)
    }
    
    func fetchWorkers(showSelect: Bool, with key: String? = nil, offset: Int,success: @escaping(_ workers: [Worker]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        let searchable = makeSearchableItems(key: key)
        
        let noSelectCondition = """
            main.\(tableName).\(COLUMNS.FIRST_NAME) != '--SELECT--'
            """

        var condition = ""
        if showSelect {
            condition = (searchable.isEmpty) ? "" : "WHERE \(searchable)"
        }
        else {
            condition = (searchable.isEmpty) ? "WHERE \(noSelectCondition)" : """
                WHERE \(noSelectCondition)
                AND \(searchable)
            """
        }

        var sql = """
        SELECT * FROM main.\(tableName)
        \(condition)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        sql += """
                LIMIT \(LIMIT) OFFSET \(offset);
        """
        do {
            let workers = try queue.read({ (db) -> [Worker] in
            var workers: [Worker] = []
            let rows = try Row.fetchAll(db,
                                        sql: sql,
                                        arguments: [])
            rows.forEach { (row) in
                workers.append(.init(row: row))
            }
            return workers
            })
            success(workers)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    func fetchWorkers(showRemoved: Bool, with key: String? = nil, sortBy: WorkerField? = nil, sortType: SortType? = nil ,offset: Int,success: @escaping(_ workers: [Worker]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        let sortable = makeSortableItems(sortBy: sortBy, sortType: sortType)
        let searchable = makeSearchableItems(key: key)
        let condition = getShowRemoveCondition(showRemoved: showRemoved, searchable: searchable)
        var sql = """
        SELECT * FROM main.\(tableName)
        LEFT JOIN main.\(TABLES.WORKER_HOME_ADDRESSES) ON main.\(tableName).\(COLUMNS.WORKER_ID) = main.\(TABLES.WORKER_HOME_ADDRESSES).\(COLUMNS.WORKER_ID)
        LEFT JOIN main.\(TABLES.WAGES) ON main.\(tableName).\(COLUMNS.WORKER_ID) = main.\(TABLES.WAGES).\(COLUMNS.WORKER_ID)
        LEFT JOIN main.\(TABLES.WORKER_ROLES) ON main.\(tableName).\(COLUMNS.WORKER_ID) = main.\(TABLES.WORKER_ROLES).\(COLUMNS.WORKER_ID)
        LEFT JOIN main.\(TABLES.WORKER_ROLES_GROUPS) ON main.\(TABLES.WORKER_ROLES).\(COLUMNS.WORKER_ROLES_GROUP_ID) = main.\(TABLES.WORKER_ROLES_GROUPS).\(COLUMNS.WORKER_ROLES_GROUP_ID)
        \(condition)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        sql += """
                \(sortable)
        """
        do {
            let workers = try queue.read({ (db) -> [Worker] in
                var workers: [Worker] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    if row["FirstName"] != "--SELECT--" {
                        workers.append(.init(row: row))
                    }
                }
                return workers
            })
            success(workers)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    func fetchWorkerCanEditTimeAlreadyEntered(workerID:String, success: @escaping(_ value: Bool) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        
        var sql = """
        SELECT * FROM main.\(tableName)
        LEFT JOIN main.\(TABLES.WORKER_ROLES) ON main.\(tableName).\(COLUMNS.WORKER_ID) = main.\(TABLES.WORKER_ROLES).\(COLUMNS.WORKER_ID)
        WHERE main.\(TABLES.WORKER_ROLES).\(COLUMNS.WORKER_ID) = \(workerID) AND
                    main.\(TABLES.WORKER_ROLES).\(COLUMNS.CAN_EDIT_TIME_ALREADY_ENTERED) = 1
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            let workers = try queue.read({ (db) -> [Worker] in
                var workers: [Worker] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    workers.append(.init(row: row))
                }
                return workers
            })
            success(workers.count > 0)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    func fetchWorkerCanRunPayroll(workerID:String, success: @escaping(_ value: Bool) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        
        var sql = """
        SELECT * FROM main.\(tableName)
        LEFT JOIN main.\(TABLES.WORKER_ROLES) ON main.\(tableName).\(COLUMNS.WORKER_ID) = main.\(TABLES.WORKER_ROLES).\(COLUMNS.WORKER_ID)
        WHERE main.\(TABLES.WORKER_ROLES).\(COLUMNS.WORKER_ID) = \(workerID) AND
                    main.\(TABLES.WORKER_ROLES).\(COLUMNS.CAN_RUN_PAYROLL) = 1
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            let workers = try queue.read({ (db) -> [Worker] in
                var workers: [Worker] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    workers.append(.init(row: row))
                }
                return workers
            })
            success(workers.count > 0)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    private func makeSortableItems(sortBy: WorkerField?, sortType: SortType?) -> String {
        guard let sortBy = sortBy, let sortType = sortType else {
            return makeSortableCondition(key: COLUMNS.FIRST_NAME, sortType: .ASCENDING)
        }
        switch sortBy {
        case .FIRST_NAME:
            return makeSortableCondition(key: COLUMNS.FIRST_NAME, sortType: sortType)
        case .LAST_NAME:
            return makeSortableCondition(key: COLUMNS.LAST_NAME, sortType: sortType)
        case .CELL_NUMBER:
            return makeSortableCondition(key: COLUMNS.CELL_NUMBER, sortType: sortType)
        case .EMAIL:
            return makeSortableCondition(key: COLUMNS.EMAIL, sortType: sortType)
        case .HOURLY_WORKER:
            return makeSortableCondition(key: COLUMNS.HOURLY_WORKER, sortType: sortType)
        case .SALARY:
            return makeSortableCondition(key: COLUMNS.SALARY, sortType: sortType)
        case .CONTRACTOR:
            return makeSortableCondition(key: COLUMNS.CONTRACTOR, sortType: sortType)
        }
    }
    
    private func makeSearchableItems(key: String?) -> String {
        guard let key = key else { return "" }
        var yesOrNoCondition = ""
        if key.lowercased() == "yes" || key.lowercased() == "no" {
            let yesOrNoValue: String = (key.lowercased() == "yes") ? "1" : "0"
            yesOrNoCondition = "OR " + makeSearchableCondition(key: yesOrNoValue,
                                                               fields: [COLUMNS.SALARY,
                                                                        COLUMNS.HOURLY_WORKER,
                                                                        COLUMNS.CONTRACTOR
                                                               ])
        }
        return makeSearchableCondition(key: key,
                                       fields: [
                                        COLUMNS.FIRST_NAME,
                                        COLUMNS.LAST_NAME,
                                        COLUMNS.CELL_NUMBER,
                                        COLUMNS.EMAIL])
            + yesOrNoCondition
    }
}
