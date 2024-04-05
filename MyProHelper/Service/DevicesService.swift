//
//  DevicesService.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 29/07/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

final class DevicesService {
    
    private let repository = DeviceRepository()
    
    func fetchDevicesList(showRemoved: Bool, for worker: Worker, isFilter:Bool, isDeviceSetup:Bool,key: String? = nil,sortBy: DeviceFields? = nil, sortType: SortType? = nil ,offset: Int, completion: @escaping ((Result<[Device], ErrorResult>) -> Void)) {
        if isFilter{
            repository.fetchDevice(showRemoved: showRemoved, for: worker, isDeviceSetup: isDeviceSetup, key: key, sortBy: sortBy, sortType: sortType, offset: offset) { (devices) in
                completion(.success(devices))
            } failure: { (error) in
                completion(.failure(.custom(string: error.localizedDescription)))
            }
        }
        else{
            fetchDevicesList(showRemoved: showRemoved, for: worker, key: key,sortBy: sortBy, sortType: sortType, offset: offset) { (result) in
                completion(result)
            }
        }
        
    }
    
    
    func fetchDevicesList(showRemoved: Bool,for worker: Worker,key: String? = nil,sortBy: DeviceFields? = nil, sortType: SortType? = nil ,offset: Int, completion: @escaping ((Result<[Device], ErrorResult>) -> Void)) {
        repository.fetchDevice(showRemoved: showRemoved,for: worker, key: key,sortBy: sortBy, sortType: sortType, offset: offset) { (devices) in
            completion(.success(devices))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func createDevice(device: Device, completion: @escaping ((Result<Int64, ErrorResult>) -> Void)) {
        repository.insertDevice(device: device) { (deviceId) in
            completion(.success(deviceId))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    
    func updateDevice(device: Device, completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        repository.update(device: device) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func deleteDevice(device: Device, completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        repository.deleteDevice(device: device) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func restoreDevice(device: Device, completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        repository.restoreDevice(device: device) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
}
