//
//  CustomerJobsRepository.swift
//  MyProHelper
//
//  Created by Deep on 2/9/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB

class CustomerJobsRepository: BaseRepository {
    
    init() {
        super.init(table: .SCHEDULED_JOBS)
    }
    
    func fetchJobs(for customer: Customer,showRemoved: Bool, with key: String? = nil, sortBy: JobField? = nil, sortType: SortType? = nil ,offset: Int,success: @escaping(_ job: [Job]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        guard let customerID = customer.customerID else { return }
 
        
        var sql = """
        SELECT * FROM main.\(tableName)
        LEFT JOIN main.\(TABLES.CUSTOMERS) ON main.\(tableName).\(COLUMNS.CUSTOMER_ID) == main.\(TABLES.CUSTOMERS).\(COLUMNS.CUSTOMER_ID)
        WHERE main.\(tableName).\(COLUMNS.CUSTOMER_ID) == \(customerID)
        LIMIT \(LIMIT) OFFSET \(offset);
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            let jobs = try queue.read({ (db) -> [Job] in
                var jobs: [Job] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    jobs.append(.init(row: row))
                }
                return jobs
            })
            success(jobs)
        }
        catch {
            failure(error)
            print(error)
        }
    }
}

