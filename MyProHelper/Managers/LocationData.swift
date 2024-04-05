//
//  LocationData.swift
//  MyProHelper
//
//  Created by Anupansh on 23/11/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

struct LocationData: Codable {
    var locationsThisDeviceID: [LocationsThisDeviceID]
    let deviceID: Int
    enum CodingKeys: String, CodingKey {
        case locationsThisDeviceID = "LocationsThisDeviceID"
        case deviceID = "DeviceID"
    }
}
    
struct LocationsThisDeviceID: Codable {
    let latitude, longitude: Double
    let secondsFromGMT: Int
    let timeStamp: Float
    enum CodingKeys: String, CodingKey {
        case latitude = "Latitude"
        case longitude = "Longitude"
        case timeStamp = "TimeStamp"
        case secondsFromGMT = "SecondsFromGMT"
    }
}

public struct SocketLocationData: Codable {
    let deviceIDTimeStampKey, deviceID, timeStamp, secondsFromGMT: Int
    let latitude, longitude: Double

    enum CodingKeys: String, CodingKey {
        case deviceIDTimeStampKey = "DeviceIDTimeStampKey"
        case deviceID = "DeviceID"
        case timeStamp = "TimeStamp"
        case secondsFromGMT = "SecondsFromGMT"
        case latitude = "Latitude"
        case longitude = "Longitude"
    }
}
