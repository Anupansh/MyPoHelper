//
//  DBHelper.swift
//  MyProHelper
//
//  Created by Anupansh on 21/05/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB

class DBHelper {
    
    enum JobStatus: String {
        case scheduled = "Scheduled"
        case inProgress = "In Progress"
        case endingSoon = "Ending Soon"
        case completed = "Completed"
        case invoiced = "Invoiced"
    }
    
    static func getApprovedBy(value: String,tableName: String,columnName: String) -> String {
        
        let queue = AppDatabase.shared.attachDababaseQueue
        var workerName = ""
        var sql = """
            Select * from main.\(tableName)
            LEFT JOIN main.\(RepositoryConstants.Tables.WORKERS) ON main.\(tableName).\(RepositoryConstants.Columns.APPROVED_BY) =
                main.\(RepositoryConstants.Tables.WORKERS).\(RepositoryConstants.Columns.WORKER_ID)
            WHERE main.\(tableName).\(columnName) = \(value)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            try queue!.read { (database) in
                let rows = try Row.fetchCursor(database, sql: sql)
                while let row = try rows.next() {
                    workerName = row["FirstName"] + " " + row["LastName"]
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
        return workerName
    }
    
    static func getWorkerList(workerId: Int?,completion: ([Worker],[String],String) -> ()?) {
        var workerName = ""
        var workerNameArray = [String]()
        var workerModel = [Worker]()
        guard let queue = AppDatabase.shared.attachDababaseQueue else {return}
        var sql = """
            SELECT * FROM main.\(RepositoryConstants.Tables.WORKERS)
            WHERE  (\(RepositoryConstants.Tables.WORKERS).\(RepositoryConstants.Columns.FIRST_NAME) != '--SELECT--')
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            try queue.read { (database) in
                let rows = try Row.fetchCursor(database, sql: sql)
                while let row = try rows.next() {
                    let singleWorker = Worker.init(row: row)
                    workerModel.append(singleWorker)
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
        for worker in workerModel {
            workerNameArray.append(worker.fullName ?? "")
            if let workerId = workerId {
                if workerId == worker.workerID {
                    workerName = worker.fullName!
                }
            }
        }
        completion(workerModel,workerNameArray,workerName)
    }
    
    static func updateJobStatus(status: JobStatus,jobID: Int,completed: @escaping ()->()?) {
        let arguments : StatementArguments = [
            "id" : jobID,
            "status" : status.rawValue
        ]
        let sql = """
            UPDATE \(RepositoryConstants.Tables.SCHEDULED_JOBS) SET
                \(RepositoryConstants.Columns.JOB_STATUS)                            =   :status
            WHERE \(RepositoryConstants.Tables.SCHEDULED_JOBS).\(RepositoryConstants.Columns.JOB_ID)  =   :id
        """
        AppDatabase.shared.executeSQL(sql: sql, arguments: arguments,typeOfAction: .update, updatedId: UInt64(jobID)) { (id) in
            completed()
        } fail: { (error) in
            print(error.localizedDescription)
        }
    }
    

    
    static func fetchInvoice(invoiceID: Int) -> Invoice {
        let queue = AppDatabase.shared.attachDababaseQueue!
        let COLUMNS = RepositoryConstants.Columns.self
        let TABLES  = RepositoryConstants.Tables.self
        var sql = """
        SELECT * FROM main.\(TABLES.INVOICES)
        LEFT JOIN main.\(TABLES.CUSTOMERS) ON main.\(TABLES.INVOICES).\(COLUMNS.CUSTOMER_ID) == main.\(TABLES.CUSTOMERS).\(COLUMNS.CUSTOMER_ID)
        LEFT JOIN main.\(TABLES.SCHEDULED_JOBS) ON main.\(TABLES.INVOICES).\(COLUMNS.JOB_ID) == main.\(TABLES.SCHEDULED_JOBS).\(COLUMNS.JOB_ID)
        WHERE main.\(TABLES.INVOICES).\(COLUMNS.INVOICE_ID) = \(invoiceID)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        var invoice = Invoice()
        do {
            try queue.read { (database) in
                let rows = try Row.fetchCursor(database, sql: sql)
                while let row = try rows.next() {
                    invoice = Invoice.init(row: row)
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
        return invoice
    }
    
    static func getCompanyInformation() -> CompanySettingsModel {
        var companyInformation = CompanySettingsModel()
        guard let queue = AppDatabase.shared.attachDababaseQueue else {return companyInformation}
        let companyID = AppLocals.serverAccessCode?.CompanyID
        var sql = """
            Select * from main.\(RepositoryConstants.Tables.COMPANY_SETTINGS)
            WHERE main.\(RepositoryConstants.Tables.COMPANY_SETTINGS).\(DataFeilds.companyId.rawValue.removeSpace()) = \(companyID ?? "299")
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            try queue.read { (database) in
                let rows = try Row.fetchCursor(database, sql: sql)
                while let row = try rows.next() {
                    print(row)
                    companyInformation = CompanySettingsModel.init(row: row)
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
        return companyInformation
    }
    
    static func fetchJob(jobID: Int64) -> Job {
        let queue = AppDatabase.shared.attachDababaseQueue!
        var sql = """
            Select * from main.\(RepositoryConstants.Tables.SCHEDULED_JOBS)
            LEFT JOIN main.\(RepositoryConstants.Tables.CUSTOMERS) ON main.\(RepositoryConstants.Tables.SCHEDULED_JOBS).\(RepositoryConstants.Columns.CUSTOMER_ID) =
                            main.\(RepositoryConstants.Tables.CUSTOMERS).\(RepositoryConstants.Columns.CUSTOMER_ID)
            LEFT JOIN main.\(RepositoryConstants.Tables.WORKERS) ON main.\(RepositoryConstants.Tables.SCHEDULED_JOBS).\(RepositoryConstants.Columns.WORKER_SCHEDULED) =
                            main.\(RepositoryConstants.Tables.WORKERS).\(RepositoryConstants.Columns.WORKER_ID)
            WHERE main.\(RepositoryConstants.Tables.SCHEDULED_JOBS).\(RepositoryConstants.Columns.JOB_ID) = \(jobID)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        var job = Job()
        do {
            try queue.read { (database) in
                let rows = try Row.fetchCursor(database, sql: sql)
                while let row = try rows.next() {
                    job = Job.init(row: row)
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
        return job
    }
    
    static func getMaxRowId(columnName: String,tablename: String) -> Int {
        let queue = AppDatabase.shared.companyDbQueue
        let sql = "SELECT MAX(\(columnName)) FROM \(tablename)"
        var maxRowId = 0
        do {
            try queue!.read({ (db) in
                let row = try Row.fetchOne(db, sql: sql)
                if let id:Int  = row!["MAX(\(columnName))"] {
                    maxRowId = id
                }
            })
        }
        catch let error {
            print(error.localizedDescription)
        }
        return maxRowId
    }
    
    static func getSupplyName(supplyId: Int) -> String {
        let queue = AppDatabase.shared.companyDbQueue!
        let sql = "Select SupplyName from Supplies where SupplyID = \(supplyId)"
        var supplyName = ""
        do {
            try queue.read { (database) in
                let rows = try Row.fetchCursor(database, sql: sql)
                while let row = try rows.next() {
                    supplyName = row[RepositoryConstants.Columns.SUPPLY_NAME]
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
        return supplyName
    }
    
    static func getScheduledJobs() -> [Job] {
        var jobList = [Job]()
        let workerId = AppLocals.worker.workerID ?? 2
        guard let queue = AppDatabase.shared.attachDababaseQueue else {return [Job]()}
        var sql = """
            Select * from main.\(RepositoryConstants.Tables.SCHEDULED_JOBS)
            LEFT JOIN main.\(RepositoryConstants.Tables.CUSTOMERS) ON main.\(RepositoryConstants.Tables.SCHEDULED_JOBS).\(RepositoryConstants.Columns.CUSTOMER_ID) =
                            main.\(RepositoryConstants.Tables.CUSTOMERS).\(RepositoryConstants.Columns.CUSTOMER_ID)
            LEFT JOIN main.\(RepositoryConstants.Tables.WORKERS) ON main.\(RepositoryConstants.Tables.SCHEDULED_JOBS).\(RepositoryConstants.Columns.WORKER_SCHEDULED) =
                            main.\(RepositoryConstants.Tables.WORKERS).\(RepositoryConstants.Columns.WORKER_ID)
            WHERE main.\(RepositoryConstants.Tables.SCHEDULED_JOBS).\(RepositoryConstants.Columns.WORKER_SCHEDULED) = \(workerId)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            try queue.read { (database) in
                let rows = try Row.fetchCursor(database, sql: sql)
                while let row = try rows.next() {
                    let singleJob = Job.init(row: row)
                    jobList.append(singleJob)
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
        return jobList
    }
    
    static func getScheduledJobsForAllWorkers() -> [Job] {
        var jobList = [Job]()
        guard let queue = AppDatabase.shared.attachDababaseQueue else {return [Job]()}
        var sql = """
            Select * from main.\(RepositoryConstants.Tables.SCHEDULED_JOBS)
            LEFT JOIN main.\(RepositoryConstants.Tables.CUSTOMERS) ON main.\(RepositoryConstants.Tables.SCHEDULED_JOBS).\(RepositoryConstants.Columns.CUSTOMER_ID) =
                            main.\(RepositoryConstants.Tables.CUSTOMERS).\(RepositoryConstants.Columns.CUSTOMER_ID)
            LEFT JOIN main.\(RepositoryConstants.Tables.WORKERS) ON main.\(RepositoryConstants.Tables.SCHEDULED_JOBS).\(RepositoryConstants.Columns.WORKER_SCHEDULED) =
                            main.\(RepositoryConstants.Tables.WORKERS).\(RepositoryConstants.Columns.WORKER_ID)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            try queue.read { (database) in
                let rows = try Row.fetchCursor(database, sql: sql)
                while let row = try rows.next() {
                    let singleJob = Job.init(row: row)
                    jobList.append(singleJob)
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
        return jobList
    }
    
    static func getWorker(workerId: Int?,_ completion: (Worker?) -> ()) {
        var workerModel = [Worker]()
        guard let queue = AppDatabase.shared.attachDababaseQueue else {return}
        var sql = """
            SELECT * FROM main.\(RepositoryConstants.Tables.WORKERS)
            WHERE  (main.\(RepositoryConstants.Tables.WORKERS).\(RepositoryConstants.Columns.FIRST_NAME) != '--SELECT--') AND
                main.\(RepositoryConstants.Tables.WORKERS).\(RepositoryConstants.Columns.WORKER_ID) = \(workerId!)
        
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            try queue.read { (database) in
                let rows = try Row.fetchCursor(database, sql: sql)
                while let row = try rows.next() {
                    let singleWorker = Worker.init(row: row)
                    workerModel.append(singleWorker)
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
        completion(workerModel.first)
    }
    
    static func getWorker(workerId: Int?)->Worker? {
        var workerModel = [Worker]()
        guard let queue = AppDatabase.shared.attachDababaseQueue else {return nil}
        var sql = """
            SELECT * FROM main.\(RepositoryConstants.Tables.WORKERS)
            WHERE  (main.\(RepositoryConstants.Tables.WORKERS).\(RepositoryConstants.Columns.FIRST_NAME) != \(Constants.DefaultValue.SELECT_LIST) AND
                main.\(RepositoryConstants.Tables.WORKERS).\(RepositoryConstants.Columns.WORKER_ID) = \(workerId!)
        
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            try queue.read { (database) in
                let rows = try Row.fetchCursor(database, sql: sql)
                while let row = try rows.next() {
                    print(row)
                    let singleWorker = Worker.init(row: row)
                    workerModel.append(singleWorker)
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
        return workerModel.first
    }
    
    static func fetchWorker() {
        guard let queue = AppDatabase.shared.attachDababaseQueue else {return}
        let workerId = UserDefaults.standard.value(forKey: UserDefaultKeys.workerId)!
        var sql = """
            Select * from main.\(RepositoryConstants.Tables.WORKERS)
            LEFT JOIN main.\(RepositoryConstants.Tables.WORKER_HOME_ADDRESSES) ON main.\(RepositoryConstants.Tables.WORKERS).\(RepositoryConstants.Columns.WORKER_ID) = main.\(RepositoryConstants.Tables.WORKER_HOME_ADDRESSES).\(RepositoryConstants.Columns.WORKER_ID)
            Where main.\(RepositoryConstants.Tables.WORKERS).\(RepositoryConstants.Columns.WORKER_ID) = \(workerId)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            try queue.read({ (db) in
                let rows = try Row.fetchCursor(db, sql: sql)
                while let row = try rows.next() {
                    let worker = Worker.init(row: row)
                    AppLocals.worker = worker
                }
            })
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    static func fetchWorkerRoles() {
        guard let queue = AppDatabase.shared.attachDababaseQueue else {return}
        let workerId = UserDefaults.standard.value(forKey: UserDefaultKeys.workerId)!
        var sql = """
            Select * from main.\(RepositoryConstants.Tables.WORKER_ROLES)
            Where main.\(RepositoryConstants.Tables.WORKER_ROLES).\(RepositoryConstants.Columns.WORKER_ID) = \(workerId)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            try queue.read({ (db) in
                let rows = try Row.fetchCursor(db, sql: sql)
                while let row = try rows.next() {
                    let workerRole = WorkerRoles.init(row: row)
                    AppLocals.workerRole = workerRole
                }
            })
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    static func fetchWorkerRolesGroup() {
        guard let queue = AppDatabase.shared.attachDababaseQueue else {return}
        let workerId = UserDefaults.standard.value(forKey: UserDefaultKeys.workerId)!
        var sql = """
            Select * from main.\(RepositoryConstants.Tables.WORKER_ROLES_GROUPS)
            LEFT JOIN main.\(RepositoryConstants.Tables.WORKER_ROLES) ON main.\(RepositoryConstants.Tables.WORKER_ROLES_GROUPS).\(RepositoryConstants.Columns.WORKER_ROLES_GROUP_ID) = main.\(RepositoryConstants.Tables.WORKER_ROLES).\(RepositoryConstants.Columns.WORKER_ROLES_GROUP_ID)
            Where main.\(RepositoryConstants.Tables.WORKER_ROLES).\(RepositoryConstants.Columns.WORKER_ID) = \(workerId)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            try queue.read({ (db) in
                let rows = try Row.fetchCursor(db, sql: sql)
                while let row = try rows.next() {
                    let workerRolesGroup = WorkerRolesGroup.init(row: row)
                    AppLocals.workerRolesGroup = workerRolesGroup
                }
            })
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    static func fetchStartDay() {
        guard let queue = AppDatabase.shared.attachDababaseQueue else {return}
        let dateWorked:String = DateManager.standardDateToStringWithoutHours(date: Date())
        let COLOM = RepositoryConstants.Columns.self
        let TABLE = RepositoryConstants.Tables.self
        var sql = """
            Select * from main.\(TABLE.CURRENT_TIME_SHEETS)
            WHERE (\(TABLE.CURRENT_TIME_SHEETS).\(COLOM.StartTime)  != '' OR
                    \(TABLE.CURRENT_TIME_SHEETS).\(COLOM.StartTime) IS NOT NULL OR
                    \(TABLE.CURRENT_TIME_SHEETS).\(COLOM.StartTime) !=  '00:00:00') AND
                    (\(TABLE.CURRENT_TIME_SHEETS).\(COLOM.EndTime)  =  '' OR
                    \(TABLE.CURRENT_TIME_SHEETS).\(COLOM.EndTime)  =  '00:00:00' OR
                    \(TABLE.CURRENT_TIME_SHEETS).\(COLOM.EndTime) IS NULL) AND
                    \(TABLE.CURRENT_TIME_SHEETS).\(COLOM.DateWorked) LIKE '%\(dateWorked)%'
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
//        print(sql)
        do {
            let currentTimeSheets = try queue.read({ (db) -> [CurrentTimeSheetModel] in
                var currentTimeSheets: [CurrentTimeSheetModel] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    currentTimeSheets.append(.init(row: row))
                }
                return currentTimeSheets
            })
            if currentTimeSheets.count > 0 {
//                success(currentTimeSheets.first)
                AppLocals.startDateWorked = currentTimeSheets.first!.dateWorked
            }
        }
        catch {
            print(error.localizedDescription)
//            failure(error)
        }
    }
    
    static func getInvoicesForJob(id: Int,completionHandler: ([Invoice]) -> ()?) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        let tables = RepositoryConstants.Tables.self
        let columns = RepositoryConstants.Columns.self
        let condition = "Where main.\(tables.INVOICES).\(columns.JOB_ID) = \(id)"
        
        var sql = """
        SELECT * FROM main.\(tables.INVOICES)
        LEFT JOIN main.\(tables.CUSTOMERS) ON main.\(tables.INVOICES).\(columns.CUSTOMER_ID) == main.\(tables.CUSTOMERS).\(columns.CUSTOMER_ID)
        LEFT JOIN main.\(tables.SCHEDULED_JOBS) ON main.\(tables.INVOICES).\(columns.JOB_ID) == main.\(tables.SCHEDULED_JOBS).\(columns.JOB_ID)
        \(condition)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            let invoices = try queue.read({ (db) -> [Invoice] in
                var invoices: [Invoice] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    invoices.append(.init(row: row))
                }
                return invoices
            })
            completionHandler(invoices)
        }
        catch {
            print(error)
        }
    }
    
    public static func installServerDBChanges(chg:DatabaseChangesWithOriginalChangesDBVersion) {
        let currentdbVersion = DBHelper.getDBVersion()
        let currentChangesDBCount = DBHelper.getChangesDBCount()
        if (currentdbVersion == chg.dbVersionBeforeRequest)  {
            if (currentChangesDBCount == chg.ChangesDBCount) {
                if (currentdbVersion != chg.serverCurrentDBVersion) {
                    var sqlChangeCount = 0
                    if let dbFilename = getDBFileName() {
                        do
                        {
                            let dbQueue = try DatabaseQueue(path: dbFilename)
                            try dbQueue.write {  db in
                                for item in chg.changes {
                                    if item.sql.count > 0 {
                                        try db.execute(sql: item.sql)
                                        if isTableChange(sql: item.sql) {
                                            print("handle table change here")
                                            applyOfflineTableChange(sql: item.sql)
                                        }
                                    }
                                    sqlChangeCount += 1
                                }
                                let updateTime = chg.UpdateTime ?? "0"
                                try db.execute(sql: "insert into Versions(id, UpdateTime) values(?, ?)",arguments:[chg.serverCurrentDBVersion, updateTime])
                            }
                            self.emptyChangesDB()     /* Empty Database */
                            if sqlChangeCount != chg.changes.count {
                                print("dbHelper.installServerDBChanges error applied \(sqlChangeCount) changes but server had \(chg.changes.count) changes!!!!")
                            }
                            else {
                                print("dbHelper.installServerDBChanges applied \(sqlChangeCount) changes")
                            }
                        }
                        catch let error {
                             print("dbHelper.installServerDBChanges catch \(error)")
                        }
                        let computedHash = DBHash.getDBHash()
                        if computedHash == chg.hash {
                            print("Hash match Computed hash: \(computedHash)  server hash: \(chg.hash)")
                        }
                        else {
                            print("Hash doesn't match!!!! Computed hash: \(computedHash)  server hash: \(chg.hash)")

                        }
                        DBHelper.fetchWorker()
                        DBHelper.fetchWorkerRoles()
                        DBHelper.fetchStartDay()
                        NotificationCenter.default.post(name: .serverChanges, object: nil, userInfo: [:])
                    }
                }
                else {
                    print("No new server changes")
                }
            }
            else {
                print("No new server changes")
            }
        }
        else {
            print("No new server changes")
        }
    }
    
    public static func isTableChange(sql:String) -> Bool {
        var tableChange:Bool = false
        let components = sql.components(separatedBy: " ")
        if components.count > 3  { // alter table tbname
            if (components[0].caseInsensitiveCompare("Alter") == ComparisonResult.orderedSame) &&
               (components[1].caseInsensitiveCompare("Table") == ComparisonResult.orderedSame){
                tableChange = true
            }
            else if (components[0].caseInsensitiveCompare("Create") == ComparisonResult.orderedSame) &&
               (components[1].caseInsensitiveCompare("Table") == ComparisonResult.orderedSame){
                tableChange = true
            }
        }
        if !tableChange && (components.count >= 2)  { // drop tbname
            if components[0].caseInsensitiveCompare("drop") == ComparisonResult.orderedSame  {
                tableChange = true
            }
        }
        return tableChange
    }
    
    public static func applyOfflineTableChange(sql: String) {
        let dbChangesFilename = getChangesDBFilename()
        do {
            let dbQueue = try DatabaseQueue(path: dbChangesFilename)
            try dbQueue.write{ db in
                try db.execute(sql: sql)
            }
        }
        catch let error1 as DatabaseError {
            var isDuplicateColumnNameOrTableName:Bool = false
            if "\(error1)".range(of: "duplicate column name:", options: .caseInsensitive) != nil {
                isDuplicateColumnNameOrTableName = true
            }
            else {
                if ("\(error1)".range(of: "table", options: .caseInsensitive) != nil) &&
                    ("\(error1)".range(of: "already exists", options: .caseInsensitive) != nil) {
                    isDuplicateColumnNameOrTableName = true
                }
            }
            if !isDuplicateColumnNameOrTableName {
                print("error1 \(error1)")
            }
        }
        catch let error {
             print("dbHelper.applyOfflineTableChange catch \(error)")
        }
    }
    
    public static func getChangesDBCount() -> Int {
        var changeCount:Int = 0
        let dbQueue = AppDatabase.shared.attachDababaseQueue
        let sql = "select * from main.DBVersionChanges union select * from chg.DBVersionChanges"
        do {
            try dbQueue!.read {
               db /* -> Int?  */ in

                let rows = try Row.fetchCursor(db, sql: sql)
                while let _ = try rows.next() {
                    changeCount += 1
                }
            }
        }
        catch let error {
            print("dbHelper.getChangeDBCount catch \(error)")
        }
        return changeCount
    }
    
    public static func emptyChangesDB() {
        var didCreateEmptyChanges:Bool = false
        let changeDBURL = getChangesDBURL()
        if FileManager.default.fileExists(atPath: changeDBURL.path) == false {
            guard let companyID  = AppLocals.serverAccessCode?.CompanyID else {
                print("dbHelper.emptyChangesDB couldn't get CompanyID")
                return }
            let company = CompanyID(id: companyID)
            guard  let custDB = company.getDBFileNameWithPath() else {
                print("dbHelper.emptyChangesDB couldn't get getDBFileNameWithPath")
                return}
            if FileManager.default.fileExists(atPath: custDB.path) == false {
                print("dbHelper.emptyChangesDB copy needed but source file is missing! source: \(custDB) ")
                return
            }
            do {
                try FileManager.default.copyItem(at: custDB, to: changeDBURL)
                didCreateEmptyChanges = true
            }
            catch let error {
                print("dbHelper.emptyChangesDB catch 1 can't copy \(custDB) to \(changeDBURL) \(error)")
                return
            }
        }
        var sqlTableNames:[String] = []
        let dbFilename = getChangesDBFilename()
        do {
            let dbQueue = try DatabaseQueue(path: dbFilename)
            try dbQueue.read { db in
                let rows = try String.fetchCursor(db, sql: "select name from sqlite_master where type = 'table' AND name != 'sqlite_sequence' Order by name")
                while let row = try rows.next() {
                    sqlTableNames.append(row)
                }
            }
        }
        catch let error {
            print("dbHelper.emptyChangesDB catch 2 \(error)")
            return
        }
        do {
            var config = Configuration()
            config.readonly = false
            config.foreignKeysEnabled = false // Default is true
            let dbFilename = getChangesDBFilename()
            print("dbFileName: \(dbFilename)")
            
            let dbQueue = try DatabaseQueue(path: dbFilename, configuration: config)
            try dbQueue.inDatabase { db in
                try db.inTransaction {
                    let testSql = "PRAGMA foreign_keys = 0"
                    print("100")
                    try db.execute(sql: testSql)
                    for thisTable in sqlTableNames {
                        let sql1 = "delete from \(thisTable)"
                        try db.execute(sql: sql1)
                    }
                    // Only the first time, set the starting sequence numbers to 5 gig
                    if didCreateEmptyChanges {

                        for thisTable in sqlTableNames {
                            print("Table",thisTable)
                            let ss1 = """
                                    UPDATE sqlite_sequence SET seq = 5000000000 WHERE name = '\(thisTable)';

                                    INSERT INTO sqlite_sequence (name,seq) SELECT '\(thisTable)', 5000000000 WHERE NOT EXISTS
                                    (SELECT changes() AS change FROM sqlite_sequence WHERE change <> 0)
                                    """
                            print("ss1 - \(ss1)")
                            try db.execute(sql: ss1)
                        }
                    }
                    else{
                        AppDatabase.shared.reconnectDatabase()
                    }
                    return .commit
                }
            }
        }
        catch let error {
            print("dbHelper.emptyChangesDB catch 3 \(error)")
            return
        }
    }

/*
        var sqlTableDeletes:[String] = []
        
        let dbFilename = getChangesDBFilename()
        do {
            let dbQueue = try DatabaseQueue(path: dbFilename)
            try dbQueue.read {
               db /* -> Int?  */ in

//                try db.execute(sql: "PRAGMA foreign_keys=0")
                let rows = try String.fetchCursor(db, sql: "select 'delete from ' || name || ';' from sqlite_master where type = 'table'AND name != 'sqlite_sequence' Order by name;")
                while let row = try rows.next() {
                    
//                    print(row)
                    sqlTableDeletes.append(row)
                }
                print("after rows")
            }
        }
        catch let error
        {
            print("dbHelper.emptyChangesDB catch \(error)")
            return
        }

        do {
            var config = Configuration()
            config.readonly = false
            config.foreignKeysEnabled = false // Default is true
            
            let dbQueue = try DatabaseQueue(path: dbFilename, configuration: config)
            try dbQueue.inDatabase { db in
                try db.inTransaction {
                    
                    let testSql = "PRAGMA foreign_keys = 0"
                    print("100")
                    try db.execute(sql: testSql)
                    let journalMode = try String.fetchOne(db, sql: "PRAGMA journal_mode")
                    let foreign_keyMode = try String.fetchOne(db, sql: "PRAGMA foreign_keys")
                    print("200")

                    for thisDelete in sqlTableDeletes {
                        print("sql to delete \(thisDelete)")
                        try db.execute(sql: thisDelete)
                    }
                    
                    // Only the first time, set the starting sequence numbers to 5 gig
                    if didCreaterEmptyChanges {

                       let rowsUpdateSeq = try String.fetchCursor(db, sql: "select 'update SQLITE_SEQUENCE set seq= ? where name = ' || '\"'  || name || '\";' from sqlite_master where type = 'table' AND name != 'sqlite_sequence' Order by name", arguments: [5000000000])
                       while let rowsUpdateSeq = try rowsUpdateSeq.next() {
                                print(rowsUpdateSeq)
                                try db.execute(sql: rowsUpdateSeq)
                       }
                    }
                    
                    return .commit

                }

            }
        }
        catch let error
        {
            print("dbHelper.emptyChangesDB catch \(error)")
            return
        }
*/
    
    public static func getDBVersion() ->Int {
        var id1:Int = 0
        if let dbFilename = getDBFileName() {
            print("DBFileName",dbFilename)
            do
            {
                let dbQueue = try DatabaseQueue(path: dbFilename)
                try dbQueue.read {
                   db in
                if let row = try Row.fetchOne(db, sql:
                                     """
                                        select id from Versions order by id desc limit 1
                                     """ ) {
                
                        if let id:Int  = row["id"] {
                            id1 = id
                        }
                    }
//                    return nil
                }
            }
                
            catch let error
            {
                print("dbHelper.getDBVersion catch \(error)")
            }
        }
        return id1
    }
    
    public static func getDatabaseChanges() -> ([DatabaseChanges], Int) {
        let fileManager = FileManager.default
        var maxDBVersionChangeID:Int = 0
        var chgs:[DatabaseChanges] = []
        let offlineDBFilename = GlobalFunction.getofflineDBFullFileNameString()
        if FileManager().fileExists(atPath: offlineDBFilename)  {
            print("offlineDBFilename exists \(offlineDBFilename)")
        }
        do {
//            let dbQueue = try DatabaseQueue(path: offlineDBFilename)
            let dbQueue = AppDatabase.shared.attachDababaseQueue
            let sql = "select * from main.DBVersionChanges union select * from chg.DBVersionChanges"
            try dbQueue!.read { db  in
                let rows = try Row.fetchCursor(db, sql: sql)
                while let row = try rows.next() {
                    let sql1:String = row["sql"]
                    let id:Int = row["id"]
                    maxDBVersionChangeID = id
                    let chgRow:DatabaseChanges = DatabaseChanges(sql: sql1, rowid: "\(id)")
                    chgs.append(chgRow)
                }
            }
        }
            
        catch let error {
            print("dbHelper.getDatabaseChanges catch \(error)")
        }
        return (chgs, maxDBVersionChangeID)
    }

    public static func getDBFileName() -> String?{
        guard let companyID  = AppLocals.serverAccessCode?.CompanyID else { return nil}
        let company = CompanyID(id: companyID)
        
        if let url = company.getDBFileNameWithPath() {
            return url.absoluteString
        }
        return nil
        
        
    }
    
    public static func removeTableData(tableName: String) {
        let companyQueue = AppDatabase.shared.companyDbQueue
        let offlineQueue = AppDatabase.shared.offlineDbQueue
        let sql = "Delete from \(tableName)"
        do {
            try companyQueue?.write({ (db) in
                try db.execute(sql: sql)
            })
            try offlineQueue?.write({ (db) in
                try db.execute(sql: sql)
            })
        }
        catch let error {
            print(error.localizedDescription)
        }
        
        print(DBHelper.getChangesDBCount())
    }
    

    static internal func getChangesDBDocName() -> String {
        return "offline"
    }
    
    static internal func getChangesDBDocNameExtension() -> String {
        return "db"
    }
    
    static func getChangesDBURL() -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let destURL = documentsURL!.appendingPathComponent(getChangesDBDocName()).appendingPathExtension(getChangesDBDocNameExtension())
        return destURL

    }
    
    static func getChangesDBFilename() -> String {

        let url = getChangesDBURL()
        return "\(url.absoluteString)"
        
    }
    
    static func getChangeDURLCopyIfNeeded() ->URL? {
        
        return copyFileToDocumentsFolder(nameForFile: getChangesDBDocName(), extForFile: getChangesDBDocNameExtension(), overWrite: false)
    }
    
    static func removeCompanyDatabase() {
        guard let dbFileName = getDBFileName() else { return }
        do {
            try FileManager.default.removeItem(atPath: dbFileName)
        }
        catch _ as NSError {
        }
        
    }
    
    static func copyFileToDocumentsFolder(nameForFile: String, extForFile: String, overWrite: Bool) -> URL? {
        
        var dest1:URL?
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let destURL = documentsURL!.appendingPathComponent(nameForFile).appendingPathExtension(extForFile)

        guard let sourceURL = Bundle.main.url(forResource: nameForFile, withExtension: extForFile)
        else {
            print("Source File not found. \(nameForFile)\(extForFile)")
            return dest1
        }
        
        let fileManager = FileManager.default
        do {
            dest1 = destURL
            
            if (fileManager.existence(atUrl: destURL) == FileExistence.file) && (overWrite == false) {
                return dest1 // already exists and don't overwrite
            }
            try? fileManager.removeItem(at: destURL)
            try fileManager.copyItem(at: sourceURL, to: destURL)
            
        } catch {
            print("Unable to copy file")
        }
        
        return dest1
    }
}
