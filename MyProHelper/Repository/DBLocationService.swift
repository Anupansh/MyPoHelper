//
//  DBLocationService.swift
//  MyProHelper
//
//  Created by Sourabh Nag on 02/07/20.
//  Copyright © 2020 Sourabh Nag. All rights reserved.
//

import Foundation
import SQLite

/// Interface for accessing private functions of DBHelper
protocol DBLocationServiceDelegate {
    func getLocations() -> [Location]
}

/// Use this to define protocol functions
extension LocationRepository:DBLocationServiceDelegate {
    func getLocations() -> [Location] {
        return self.getDBLocations()
    }
}

class LocationRepository: RepositoryBaseModel<Location> {
    
    /// Contains the private instance of the database
    
    init() {
        super.init(table: .locationData)
    }
    
    //TODO: HandleError
    /// Use this function to get all the locations from table LocationData
    private func getDBLocations(from table:TableName = .locationData) -> [Location] {
        guard let db = self.applicationDB else {
            return []
        }
        
        let locationTable = Table(table.rawValue)
        var locations = [Location]()
        do {
            for locationRow in try db.prepare(locationTable) {
                let location = Location(locationDataID: locationRow[locationDataID], workerID: locationRow[workerID])
                locations.append(location)
            }
            return locations
        }catch {
            return []
        }
    }
    
}
