//
//  HolidayService.swift
//  MyProHelper
//
//  Created by Deep on 1/13/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

final class HolidayService {
    
    private let dbService = HolidayRepository()
    
    func fetchHolidays(showRemoved: Bool = false, key: String? = nil, sortBy: HolidayField? = nil, sortType: SortType? = nil, offset: Int, completion: @escaping ((Result<[Holiday], ErrorResult>) -> Void)) {
        dbService.fetchHolidays(showRemoved: showRemoved, with: key, sortBy: sortBy, sortType: sortType, offset: offset) { (holidays) in
            completion(.success(holidays))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func createHoliday(holiday: Holiday, _ completion: @escaping ((Result<Int64, ErrorResult>) -> Void)) {
        dbService.createHoliday(holiday: holiday) { typeID in
            completion(.success(typeID))
        } fail: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    
    func updateHoliday(holiday: Holiday, _ completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        dbService.updateHoliday(holiday: holiday) {
            completion(.success(""))
        } fail: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    
    func deleteHoliday(holiday: Holiday, _ completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        dbService.delete(holiday: holiday) {
            completion(.success(""))
        } fail: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func restoreHoliday(holiday: Holiday, _ completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        dbService.restoreHoliday(holiday: holiday) {
            completion(.success(""))
        } fail: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
}
