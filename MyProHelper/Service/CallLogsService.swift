//
//  CallLogsService.swift
//  MyProHelper
//
//  Created by sismac010 on 02/11/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

final class CallLogsService {
    private let dbService = CallLogsRepository()
    
    func fetchCallLogs(showRemoved: Bool = false, key: String? = nil, sortBy: CallLogFields? = nil, sortType: SortType? = nil, offset: Int, completion: @escaping ((Result<[CallLog], ErrorResult>) -> Void)) {
        dbService.fetchCallLogs(showRemoved: showRemoved, with: key, sortBy: sortBy, sortType: sortType, offset: offset) { (callLogs) in
            completion(.success(callLogs))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
}
