//
//  ServerURL.swift
//  MyprohelperSample
//
//  Created by David Bench on 3/21/21.
//

import Foundation

 class ServerURL {
     static var serverSetup:ServerConfiguration = ServerConfiguration.MyProhelper
 //    static var serverSetup:ServerConfiguration = ServerConfiguration.DavidDesktop

    public enum ServerConfiguration {
        case MyProhelper
        case DavidDesktop
//        case KarenDesktop
    }
    
    public enum apiName {
        case GetSpecificByDeviceCode
        case DBChanges
        case SetDeviceFromDevCode
        case DownloadDB
        case GenerateDeviceCode
        case LocationDataRequest
    }
    
    
    
    private static var portServer = 5005
    private static var schemeServer = "https"
//    private static let host = "smartip1.com"
    private static var hostServer = "myprohelper.com"
    
    
    private static var hostGlobalAccess = ""
    private static var schemeGlobalAccess = ""
    private static var portGlobalAccess:Int = 0
    
    private static var socketServerURL:URL = URL(string: "https://myprohelper.com:8441")!
    let url:String
    
    init() {
        url = "ffo"
        var components = URLComponents()
           
        components.port = 5000
        components.scheme = "http"
        components.host = "192.168.0.9"
        components.path = "/api/Location"
        
        switch (ServerURL.serverSetup) {
        case .DavidDesktop:
            ServerURL.schemeGlobalAccess = "http"
            ServerURL.portGlobalAccess = 44366
            ServerURL.hostGlobalAccess = "192.168.0.1"
            ServerURL.schemeServer = "http"
            ServerURL.portServer = 5011
            ServerURL.hostServer = "192.168.0.1"
            ServerURL.socketServerURL = URL(string: "https://smartip1.com:8441")!
            
        case .MyProhelper:
        ServerURL.schemeGlobalAccess = "https"
        ServerURL.portGlobalAccess = 5005
        ServerURL.hostGlobalAccess = "myprohelper.com"
        ServerURL.schemeServer = "https"
        ServerURL.portServer = 5005
        ServerURL.hostServer = "myprohelper.com"
        ServerURL.socketServerURL = URL(string: "https://myprohelper.com:8441")!

            
        
        }
        
//        switch (ServerURL.serverSetup)
//        {
//        case ServerConfiguration.DavidDesktop:
//            components.host = "192.168.0.1"
//
//        }
            
        
    }
    
    func  getURLSocketServer() -> URL {
        return ServerURL.socketServerURL
    }
    
    func getURL(_ api:apiName) -> URL{
        
        var components = URLComponents()
        
        switch(api) {
        case .GetSpecificByDeviceCode:
            //        var urlComponents = URLComponents(string: "http://192.168.0.1:44366/ga/Devices/GetSpecificByDeviceCode")
            components.scheme = ServerURL.schemeGlobalAccess
            components.host = ServerURL.hostGlobalAccess
            components.port = ServerURL.portGlobalAccess
            components.path = "/ga/Devices/GetSpecificByDeviceCode"
            print("GetSpecificByDeviceCode")
        case .DBChanges:
            //                     let urlStr   = "http://192.168.1:5011/api/DBChanges"
            print("DBChanges")
            components.scheme = ServerURL.schemeServer
            components.host = ServerURL.hostServer
            components.port = ServerURL.portServer
            components.path = "/api/DBChanges"
        
        case .SetDeviceFromDevCode:
            components.scheme = ServerURL.schemeServer
            components.host = ServerURL.hostServer
            components.port = ServerURL.portServer
            components.path = "/api/Devices/SetDeviceFromDevCode"

        case .DownloadDB:
            components.scheme = ServerURL.schemeServer
            components.host = ServerURL.hostServer
            components.port = ServerURL.portServer
            components.path = "/api/DownloadDB"
        
        case .GenerateDeviceCode:
            components.scheme = ServerURL.schemeServer
            components.host = ServerURL.hostServer
            components.port = ServerURL.portServer
            components.path = "/api/DeviceCode/"

        
        case .LocationDataRequest:
            components.scheme = ServerURL.schemeServer
            components.host = ServerURL.hostServer
            components.port = ServerURL.portServer
            components.path = "/api/ReportLocation/doit1"
        }
        
        return components.url!
        
        
    }
    
    static func useLocalServer() {
        ServerURL.portServer = 5000;
        ServerURL.schemeServer = "http"
        ServerURL.hostServer = "192.168.0.1"
    }
    
    static func dummy() -> String {
        return "aa"
    }
    static func getServerReportLocationUrl() -> String {
        var components = URLComponents()
           
           components.port = ServerURL.portServer
           components.scheme = ServerURL.schemeServer
           components.host = ServerURL.hostServer
           components.path = "/api/ReportLocation"

//        components.port = 5000
//        components.scheme = "http"
//        components.host = "smartip1.com"
//        components.path = "/api/Location"

        return components.string!
    }
    static func getServerReportLocationUrl() -> URL {
        return URL(string: getServerReportLocationUrl())!
    }

    static func getUploadUrl() -> String {
        var components = URLComponents()
           
           components.port = ServerURL.portServer
           components.scheme = ServerURL.schemeServer
           components.host = ServerURL.hostServer
           components.path = "/api/UploadFile"
        
        return components.string!
    }

    
}
