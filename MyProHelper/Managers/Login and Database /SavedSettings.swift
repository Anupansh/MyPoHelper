//
//  SavedSettings.swift
//  MyprohelperSample
//
//  Created by Anupansh on 3/15/21.
//

import Foundation
import GRDB


open class SavedSettings {

    var db1: DatabaseQueue?
    
    public init() {
        createDbTableIfNeeded()
    }
    
    private func tableCreateSQLServerAccess() -> String {
        let sql =
        """
           CREATE TABLE IF NOT EXISTS settings_ServerAccess
             (
                 rowID1 INTEGER UNIQUE, DeviceCodeExpiration text, SubDomain text, UPDBCode1 text, UPDBCode2 text, UPDBCode3 text,
                 CompanyID text, DeviceID INTEGER, WorkerID INTEGER
             )
        """

        return sql
    }
    

    open func createDbTableIfNeeded() {
        let sqlCreate_AppRunCount:String = "CREATE TABLE IF NOT EXISTS settings_AppRunCount(rowID1 INT UNIQUE, appRunCount INT)"
        let sqlCreate_dbVersion:String = "CREATE TABLE IF NOT EXISTS settings_dbVersion(rowID1 INT UNIQUE, version INT)"
        let sqlCreate_DeviceID:String = "CREATE TABLE IF NOT EXISTS settings_deviceID(rowID1 INT UNIQUE, deviceID TEXT)"
        do {
            let dbQueue = getDB()
            try dbQueue.inDatabase {
                db in
                try db.execute(sql: sqlCreate_AppRunCount)
                try db.execute(sql: sqlCreate_dbVersion)
                try db.execute(sql: sqlCreate_DeviceID)
                
                try db.execute(sql: tableCreateSQLServerAccess())
            }
        }
        catch let error as DatabaseError {
            print("createDbTableIfNeeded catch \(error.message ?? "")")
        }
        catch {
            print("createDbTableIfNeeded default catch ")
        }
    }
    
    open func removeSettingsTableRows() {
        let sqlRemoveServerAccess = "DROP TABLE settings_ServerAccess"
        let sqlRemoveAppRunCount = "DROP TABLE settings_AppRunCount"
        let sqlRemoveDbVersion = "DROP TABLE settings_dbVersion"
        let sqlRemoveDeviceId = "DROP TABLE settings_deviceID"
        do {
            let dbQueue = getDB()
            try dbQueue.inDatabase({ (db) in
                try db.execute(sql: sqlRemoveServerAccess)
                try db.execute(sql: sqlRemoveAppRunCount)
                try db.execute(sql: sqlRemoveDbVersion)
                try db.execute(sql: sqlRemoveDeviceId)
            })
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    func setServerAccess(serverAccess: DeviceToServerAccess) {

        do
        {
//            SavedSettings.DeviceID = serverAccess.DeviceID // cache it since it doesn't change
            let dbQueue = getDB()
            try dbQueue.write {
                db in


                try db.execute(literal:
                    """
                       insert or replace into settings_ServerAccess
                         (
                             rowID1, DeviceCodeExpiration, SubDomain,
                             UPDBCode1, UPDBCode2, UPDBCode3,
                             CompanyID, DeviceID
                         )
                      values
                         (1, \(serverAccess.DeviceCodeExpiration), \(serverAccess.SubDomain),
                              \(serverAccess.UPDBCode1), \(serverAccess.UPDBCode2), \(serverAccess.UPDBCode3),
                              \(serverAccess.CompanyID), \(serverAccess.DeviceID)
                         )
                    """ )
                               

            }

            }

            catch let error as DatabaseError
            {
                print("setServerAccess catch \(error.message)")
            }

            catch
            {
                print("setServerAccess default catch ")
            }



    }


    func setdbVersion(_ newdbVersion: Int64)
    {
        do {
            let dbQueue = getDB()
            try dbQueue.inDatabase {
                db in
                
                let sqlUpdateAppRunCount:String = "update or ignore settings_dbVersion set version=\(newdbVersion) where rowID1=1"
                let sqlInsertAppRunCount:String = "insert or ignore into settings_dbVersion (rowID1, version) values(1, \(newdbVersion))"
                
                try db.execute(sql: sqlUpdateAppRunCount)
                try db.execute(sql: sqlInsertAppRunCount)
            }
        }
        catch let error as DatabaseError {
            print("setdbVersion catch \(error.message)")
        }
        catch {
            print("setdbVersion default catch ")
        }

    }

    func getdbVersion() -> Int64 {
        var dbVersion : Int64 = 0
        let dbName = getDbName()
        do {
            let dbQueue = try DatabaseQueue(path: dbName)
            try dbQueue.inDatabase {
                db in
                
                //dmb 06.04.19 swift4
                
//                let stmt = try db.makeSelectStatement("select version from settings_dbVersion where rowID1 = 1 limit 1")
//                for row in Row.fetch(stmt)
                let rows = try Row.fetchCursor(db, sql: "select version from settings_dbVersion where rowID1 = 1 limit 1")
                while let row = try rows.next()
                {
                    if let dbVersion1 = row["version"] as Int64? {
                        dbVersion = dbVersion1
                    }
                } // for row in Row.fetch(stmt1)
            } // try db.inDatabase
        } // do
        catch let error as DatabaseError {
            print("getdbVersion catch \(error.message!)")
        }
        catch {
            print("getdbVersion default catch ")
        }
        return dbVersion
    }
    
    func getAppRunCount() -> Int
    {
        var appRunCount:Int = 0
        let dbName = getDbName()
        do {
            let dbQueue = try DatabaseQueue(path: dbName)
            try dbQueue.inDatabase {
                db in
                
                if let count  = try Int.fetchOne(db, sql:"select appRunCount from settings_AppRunCount where rowID1 = 1 limit 1") {
                    appRunCount = count
                }
                
            }
        }
        catch let error {
            print("getAppRunCount catch \(error)")
        }
        return appRunCount
    }
    
    func getDeviceToServerAccess() -> DeviceToServerAccess? {
        
        var serverAccessCodes:DeviceToServerAccess?
        
        print("getDeviceToServerAccess")
        do
        {
            let dbQueue = getDB()
            try dbQueue.read {
                db -> DeviceToServerAccess? in

                if let row = try Row.fetchOne(db, sql:
                                 """
                                    select  DeviceCodeExpiration, SubDomain,
                                    UPDBCode1, UPDBCode2, UPDBCode3,
                                    CompanyID, DeviceID from settings_ServerAccess
                                 """ ) {
                
                
                    let DeviceCodeExpiration:String = row["DeviceCodeExpiration"]
                    let SubDomain:String = row["SubDomain"]
                    
                    let UPDBCode1:String = row["UPDBCode1"]
                    let UPDBCode2:String = row["UPDBCode2"]
                    let UPDBCode3:String = row["UPDBCode3"]
                    let CompanyID:String = row["CompanyID"]
                    let DeviceID:Int = row["DeviceID"]
                    
                    serverAccessCodes  = DeviceToServerAccess(DeviceCodeExpiration: DeviceCodeExpiration, SubDomain: SubDomain,  UPDBCode1: UPDBCode1, UPDBCode2: UPDBCode2, UPDBCode3: UPDBCode3, CompanyID: CompanyID, subDomain: "", DeviceID: DeviceID) // dmb fix 06.21.21
                    return serverAccessCodes

                }
                return nil

            }
        }
            
        catch let error as DatabaseError
        {
            print("getDeviceToServerAccess catch \(error.message)")
        }
            
        catch
        {
            print("getDeviceToServerAccess default catch ")
        }
        
        return serverAccessCodes

    }
    func incrementAppRunCount()
    {
        let newAppRunCount = getAppRunCount() + 1 as Int
        
        do
        {
            let dbQueue = getDB()
            try dbQueue.inDatabase {
                db in

                let sqlUpdateAppRunCount:String = "update or ignore settings_AppRunCount set appRunCount=\(newAppRunCount) where rowID1=1"
                let sqlInsertAppRunCount:String = "insert or ignore into settings_AppRunCount (rowID1, appRunCount) values(1, \(newAppRunCount))"

                try db.execute(sql: sqlUpdateAppRunCount)
                try db.execute(sql: sqlInsertAppRunCount)
            }
        }
            
        
            
        catch
        {
            print("incrementAppRunCount catch ")
        }
        
//        return newAppRunCount
    }
    
    
    
    func getDB() -> DatabaseQueue
    {
        if let dd = db1 {
            return dd
        }
        let dbName = getDbName()
        self.db1 = try! DatabaseQueue(path: dbName)
        return self.db1!
        
    }
    
    func getDbName() -> String {
        let documentDir = getDocumentDir()
        let dbName = (documentDir as NSString).appendingPathComponent("/settings1.db")
        return dbName
    }
    
    func getDocumentDir() -> String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return documentsPath
    }
    
    func getDeviceID() -> String
    {
        var deviceID:String = ""
        var haveDeviceID: Bool = false
        let dbName = getDbName()
        
        do
        {
            let dbQueue = try DatabaseQueue(path: dbName)
            try dbQueue.inDatabase {
                db in
                
                // dmb 06.04.19 swift4
//                let stmt = try db.makeSelectStatement("select deviceID from settings_deviceID where rowID1 = 1 limit 1")
//                for row in Row.fetch(stmt)
                let rows = try Row.fetchCursor(db, sql: "select deviceID from settings_deviceID where rowID1 = 1 limit 1")
                while let row = try rows.next()
                {
                    if let deviceID1 = row["deviceID"] as String?
                    {
                        deviceID = deviceID1
                        haveDeviceID = true
                    }
                } // for row in Row.fetch(stmt1)
                
                if haveDeviceID == false
                {
                    let uuid = NSUUID().uuidString
                    
                    deviceID = uuid
                    
                    
                    let ss:String  = "INSERT OR IGNORE INTO settings_deviceID(rowID1, deviceID) values(1, '\(deviceID)')"
                    print("ss = \(ss)")
                    try db.execute(sql: ss)
                }
            } // try db.inDatabase
        } // do
            
        catch let error as DatabaseError
        {
            print("getDeviceID catch \(error.message)")
        }
            
        catch
        {
            print("getDeviceID default catch ")
        }
        
        return deviceID
    }
    
}


public class CompanyID {
    var id:String

    init(id: String) {
        self.id = id
    }
    
    private func idToFileNameWithExtension() -> String {
        return  id.appending(".db")
        
    }
    
    func getDBFileName() -> String {
        return idToFileNameWithExtension()
    }
    
    func getDBFileNameWithPath() -> URL? {
        let fileManager = FileManager.default
        
        if let documentDirectory = fileManager.urls(for: .documentDirectory,
                                                            in: .userDomainMask).first {
                    // Construct a URL with desired folder name
                    let folderURL = documentDirectory.appendingPathComponent(id)
                    // If folder URL does not exist, create it
                    if !fileManager.fileExists(atPath: folderURL.path) {
                        do {
                            // Attempt to create folder
                            try fileManager.createDirectory(atPath: folderURL.path,
                                                            withIntermediateDirectories: true,
                                                            attributes: nil)
                        } catch {
                            // Creation failed. Print error & return nil
                            print(error.localizedDescription)
                            return nil
                        }
                    }
                    // Folder either exists, or was created. Return URL
            return folderURL.appendingPathComponent(getDBFileName())
                }
                // Will only be called if document directory not found
                return nil
    }
    
}
