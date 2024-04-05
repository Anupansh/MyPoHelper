//
//  SocketController.swift
//  MyProHelper
//
//  Created by Anupansh on 26/05/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import Starscream

class SocketManager: WebSocketDelegate {
    
    
    //MARK: - VARIABLES
    static var shared = SocketManager()
    var didStartSocketServer = false
    var socket: WebSocket!
    let server = MyProHelperServer()
   
    func startSocket() {
        if didStartSocketServer { return }
        NotificationCenter.default.addObserver(self, selector: #selector(socketDBChanged(_:)), name: .socketDBChanged, object: nil)
        guard let serverAccessCode = AppLocals.serverAccessCode else { return }
        let server = ServerURL()
        let serverURL = server.getURLSocketServer()
        print("socketServer \(serverURL)")
        var request = URLRequest(url: serverURL)
        request.timeoutInterval = 3000
        request.setValue(serverAccessCode.UPDBCode1, forHTTPHeaderField: "UpDBCode")
        request.setValue("/", forHTTPHeaderField: "GET")
        request.setValue("http://localhost", forHTTPHeaderField: "Origin")
        request.setValue("localhost", forHTTPHeaderField: "Origin")
        request.setValue("websocket", forHTTPHeaderField: "Upgrade")
        request.setValue("Upgrade", forHTTPHeaderField: "Connection")
        let pinner = FoundationSecurity(allowSelfSigned: true)
        socket = WebSocket(request: request, certPinner: pinner)
        socket.delegate = self
        socket.connect()
        didStartSocketServer = true
    }
    
    func startLocationUpdates() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.socket.write(string: "[SendLocationData]")
        }
    }
    
    func stopSocketServer() {
        if !didStartSocketServer {
            return
        }
        socket.disconnect()
        didStartSocketServer = false
    }
    
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
    
        case .connected(_):
            print("Socket Connected")
        case .disconnected(_, _):
            print("Socket Disconnected")
        case .text(let ss):
            print("Received text: \(ss)")
            let components = ss.components(separatedBy: "_")
            if components.count > 1 {
                if components[0] == "DBUPDATE" {
                    let dbStr = components[1]
                    let newDBVersion = Int(dbStr) ?? 0
                    let dbVersionDict:[String: Int] = ["NewDBVersion": newDBVersion]
                    NotificationCenter.default.post(name: .socketDBChanged, object: nil, userInfo: dbVersionDict)
                }
                else if components[0] == "LOCATIONDATA" {
                    let jsonData = Data(components[1].utf8)
                    let decoder = JSONDecoder()
                    if let locationData = try? decoder.decode(SocketLocationData.self, from: jsonData) {
                        updateLocationData(newData: locationData)
                    }
                }
            }
        case .binary(_):
            print("Binary")
        case .pong(_):
            print("Pong recieved")
        case .ping(_):
            print("Ping Recieved")
        case .error(_):
            print("Error")
        case .viabilityChanged(_):
            print("Viability Changed")
        case .reconnectSuggested(_):
            print("Suggested Reconnect")
            socket.connect()
        case .cancelled:
            print("Cancelled")
        }
    }
    
    @objc func socketDBChanged(_ notification: Notification) {
        print("socketDBChanged")
        if let dict = notification.userInfo as NSDictionary? {
            if let currentServerDBVersionNumber = dict["NewDBVersion"] as? Int{
                let currentDBVersion = DBHelper.getDBVersion()
                if currentDBVersion != currentServerDBVersionNumber {
                    print("need to update local db!")
                    DispatchQueue.main.async {
                        self.server.getDBChanges(completionHandler: {_ in   })
                    }
                }
                else {
                    print("local db is current")
                }
            }
        }
    }
    
    func updateLocationData(newData: SocketLocationData) {
        guard let localData = AppLocals.savedLocationData else {return}
        let keys = Array(localData.keys)
        if keys.contains("\(newData.deviceID)") {
            var locationData = localData["\(newData.deviceID)"]!
            let newLocationThisDeviceData = LocationsThisDeviceID(latitude: newData.latitude, longitude: newData.longitude, secondsFromGMT: newData.secondsFromGMT, timeStamp: Float(newData.timeStamp))
            locationData.locationsThisDeviceID.append(newLocationThisDeviceData)
            AppLocals.savedLocationData!["\(newData.deviceID)"] = locationData
        }
        else {
            let locationData = LocationData(locationsThisDeviceID: [LocationsThisDeviceID(latitude: newData.latitude, longitude: newData.longitude, secondsFromGMT: newData.secondsFromGMT, timeStamp: Float(newData.timeStamp))], deviceID: newData.deviceID)
            AppLocals.savedLocationData!["\(newData.deviceID)"] = locationData
        }
        NotificationCenter.default.post(name: .locationDataChanged, object: nil)
    }
    
}
