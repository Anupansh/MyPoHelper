//
//  MyprohelperServer.swift
//  MyprohelperSample
//
//  Created by David Bench on 3/15/21.
//

// po String(decoding: data, as: UTF8.self)

//https://stackoverflow.com/questions/48175697/how-to-retry-network-request-that-has-failed
import Foundation

import CryptoKit

// to dump json
//

// po String(data: data, encoding: String.Encoding.utf8)
class appURLSessionNormal{
    
    static var timeoutIntervalForRequest:Int = 120
    static var timeoutIntervalForResource:Int = 120
    
    static let shared:appURLSessionNormal = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = TimeInterval(timeoutIntervalForRequest)
        config.timeoutIntervalForResource = TimeInterval(timeoutIntervalForResource)
        config.waitsForConnectivity = true
        var urlSession1:URLSession  = URLSession(configuration: config)
        
        let instance = appURLSessionNormal(fromLength: urlSession1)
        
        return instance
        
    }()
    
    private init(fromLength urlsession1: URLSession) {
        self.urlSession = urlsession1
    }
    
    var urlSession:URLSession
    
    
    func configure(timeout1: Int, timeout2: Int) -> URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = TimeInterval(120)
        config.timeoutIntervalForResource = TimeInterval(120)
        config.waitsForConnectivity = true
        let urlSession1 = URLSession(configuration: config)
        return urlSession1
    }
    
    func requestForLocation(){
        //Code Process
        print("Location granted")
    }
    
}

public enum DownloadFailure: Error {
    case HashMismatch
    case NoNetworkConnectivity
    case BadDeviceCode

}
public enum ConversionFailure: Error {
    case invalidData
    case NoNetworkConnectivity
    case BadDeviceCode
}

struct ServerSubDomain: Codable {
    var SubDomain: String?
    var DeviceGUID: String?
    var WorkerID: Int?
    var CompanyID: Int?
}
public struct DeviceToServerAccess: Codable {
    var DeviceCodeExpiration: String
    var SubDomain: String?
    var UPDBCode1: String
    var UPDBCode2: String
    var UPDBCode3: String
    var CompanyID: String
    var subDomain: String?
    var DeviceID: Int
}

public struct  DatabaseChanges: Codable {
    var sql: String
    var rowid:String
}

public struct DatabaseChangesWithOriginalChangesDBVersion: Codable {
    var changes: [DatabaseChanges]
    var serverCurrentDBVersion:Int
    var dbVersionBeforeRequest:Int
    var ChangesDBCount:Int
    var UpdateTime: String?
    var hash:String

}

public struct DatabaseChanges2: Codable {
    var accesscode: String
    var dbVersion:Int
    var UpdateTime: String?
    var changes: [DatabaseChanges]
    var Hash: String
}

public struct DatabaseChanges1: Codable {
    var accesscode: String
    var changes: [DatabaseChanges]
}


public struct SubDomainCompanyID: Codable {
    var subDomain: String
    var companyID: Int
}
class MyProHelperServer {
    public enum ErrorReponseReason {
      case NoNetworkConnectivity, BadDeviceCode, OtherError
  }
    
    
    var deviceGuid = "123-123"
    
    var companyID = 0

    init() {
        
    }
    
    deinit {
        print("MyProHelperServer.deinit")
    }
    

    func getDBChanges(completionHandler: @escaping (Result<Int, ConversionFailure>) -> Void) {
        let dbVersionBeforeRequest = DBHelper.getDBVersion()
        
        let rr = DBHelper.getDatabaseChanges()
        let chgs:[DatabaseChanges] = rr.0
        let changeCountBeforeRequest = DBHelper.getChangesDBCount()
        let dbVersion = DBHelper.getDBVersion()
        if let UPDBCode  = AppLocals.serverAccessCode?.UPDBCode1 {
        
        
        
            if (try? JSONEncoder().encode(chgs)) != nil {
                print("have changes \(chgs.count)")
                
                let cc:DatabaseChanges2 = DatabaseChanges2(accesscode: UPDBCode, dbVersion: dbVersion, changes: chgs, Hash: "")
                let encoder  = JSONEncoder()
                if let jsonData1 = try? encoder.encode(cc) {
                    print("Json Data",cc)
                    let serverURL = ServerURL()
                    var request = URLRequest(url: serverURL.getURL(ServerURL.apiName.DBChanges))
                    request.httpMethod = "PUT"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    let thisDeviceInfo = GlobalFunction.getDeviceInfo()
                    for thisParm in thisDeviceInfo {
                        print("getDBChanges value - \(thisParm.value) - key - \(thisParm.key)")
                        request.setValue("\(thisParm.value)", forHTTPHeaderField: "\(thisParm.key)")
                    }
                    request.httpBody = jsonData1
                    let hash1:String
                    
                    if chgs.count == 0 {
                        hash1 = DBHash.getDBHash()
                    }
                    else {
                        hash1 = ""
                    }
                    request.allHTTPHeaderFields = ["UpDnCode" : "\(UPDBCode)", "DBHash": hash1]
                    let myurlsession1 = appURLSessionNormal.shared
                    let task = myurlsession1.urlSession.dataTask(with: request) { (data, response, error) in
                        if let httpResponse = response as? HTTPURLResponse {
                            
                            print("statusCode: \(httpResponse.statusCode)")
                            if httpResponse.statusCode != 200 {
                                DispatchQueue.main.async {
                                    print("bad device code")
                                    //failure(ErrorReponseReason.BadDeviceCode)
                                }
                                return
        
                            }
                            
                            guard let data = data else {
                                print("MyProHelperServer.getDBChanges unable to get response data")
                                return
                                
                            }
                            let decoder = JSONDecoder()
                            if let user = try? decoder.decode(DatabaseChanges2.self, from: data) {
                                print("after user change count \(user.changes.count)")
                                print("User",user)
                                DispatchQueue.main.async {
                                        let foo1 = DatabaseChangesWithOriginalChangesDBVersion(changes: user.changes, serverCurrentDBVersion: user.dbVersion, dbVersionBeforeRequest: dbVersionBeforeRequest, ChangesDBCount: changeCountBeforeRequest, UpdateTime: user.UpdateTime, hash: user.Hash)
                                        DBHelper.installServerDBChanges(chg: foo1)
                                    completionHandler(.success(user.changes.count))
                                }
                            }
                            else {
                                print("MyProHelperServer.getDBChanges can't decode json response")
                            }

                        }
        
                        if let error = error {
                            print("error:", error)
                            DispatchQueue.main.async {
                                completionHandler(.failure(.NoNetworkConnectivity))
                                
                            }
                            return
                        }

  
                    }
                    task.resume()
                }
            }
            else {
                print("MyProHelperServer.getDBChanges couldn't  encode json encode db changes. Change count:  \(chgs.count)")

            }
        }
        else {
            print("MyProHelperServer.getDBChanges couldn't  get serverAccessCode?.UPDBCode1")
        }
    }



    
    
    
    func getSubDomainForThisDevice(_ deviceCode: String, completionHandler: @escaping (Result<SubDomainCompanyID, ConversionFailure>) -> Void) {
        let parameters = ["DeviceCode": deviceCode]
        let serverURL = ServerURL()
        let ss  = serverURL.getURL(ServerURL.apiName.GetSpecificByDeviceCode).absoluteString
        var urlComponents = URLComponents(string: ss)
        var queryItems = [URLQueryItem]()
        for (key, value) in parameters {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        urlComponents?.queryItems = queryItems
        var request = URLRequest(url: (urlComponents?.url)!)
        request.httpMethod = "get"
        request.setValue(deviceCode, forHTTPHeaderField: "DeviceCode")
        let myurlsession1 = appURLSessionNormal.shared
        myurlsession1.urlSession.dataTask(with: request) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode != 200 {
                        DispatchQueue.main.async {
                            completionHandler(.failure(ConversionFailure.invalidData))
                        }
                        return
                    }
                }
                if let error = error {
                    print("error:", error)
                    DispatchQueue.main.async {
                        completionHandler(.failure(ConversionFailure.NoNetworkConnectivity))
                    }
                    return
                }
        guard let data = data else { return }
        let decoder = JSONDecoder()
        if let user = try? decoder.decode(ServerSubDomain.self, from: data) {
            var subDomain = ""
            if let foo = user.SubDomain, !foo.isEmpty {
                subDomain = foo
            }
            if let workerID = user.WorkerID {
                UserDefaults.standard.setValue(workerID, forKey: UserDefaultKeys.workerId)
            }
            if let guid = user.DeviceGUID {
                self.deviceGuid = guid
            }
            
            if let company = user.CompanyID {
                self.companyID = company
            }
            
            let subDomainCompany:SubDomainCompanyID = SubDomainCompanyID(subDomain: subDomain, companyID: self.companyID)
            
            DispatchQueue.main.async {
                completionHandler(.success(subDomainCompany))
            }
        }
        else {
                    DispatchQueue.main.async {
                        completionHandler(.failure(ConversionFailure.invalidData))
                    }
            }
        }.resume()
    }
    
    
    
    static func requestGetURL2a(accessCode: String, subDomain: String,  companyID: Int, completionHandler: @escaping (Result<DeviceToServerAccess, ConversionFailure>) -> Void) {
        let serverURL = ServerURL()
        let url   = serverURL.getURL(ServerURL.apiName.SetDeviceFromDevCode)
        let id:String = "123-123"
        let parameters = ["DeviceCode": accessCode,
                          "DeviceGUID": id,
                          "CompanyID": "\(companyID)",
                          "DeviceName": "notme"]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            completionHandler(.failure(ConversionFailure.invalidData))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "put"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        let myurlsession1 = appURLSessionNormal.shared
        myurlsession1.urlSession.dataTask(with: request) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse {
                    print("statusCode: \(httpResponse.statusCode)")
                    if httpResponse.statusCode != 200 {
                        DispatchQueue.main.async {
                            completionHandler(.failure(ConversionFailure.BadDeviceCode))
                        }
                        return
                    }
                }
                if let error = error {
                    print("error:", error)
                    DispatchQueue.main.async {
                        completionHandler(.failure(ConversionFailure.NoNetworkConnectivity))
                    }
                    return
                }
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let user = try? decoder.decode(DeviceToServerAccess.self, from: data) {
                    print("after user = ")
                    if let foo = user.SubDomain, !foo.isEmpty {
                        print("have sub \(foo)")
                    }
                    else {
                        print("no subdomain")
                    }
                    DispatchQueue.main.async {
                        completionHandler(.success(user))
                    }
                }
                else {
                    DispatchQueue.main.async {
                        completionHandler(.failure(ConversionFailure.invalidData))
                }
            }
        }.resume()
    }
}


