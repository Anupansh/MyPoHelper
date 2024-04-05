//
//  WorkersDBService.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 23/05/1942 Saka.
//  Copyright © 1942 Sourabh Nag. All rights reserved.
//

import Foundation
import SQLite

class WorkerRepository: RepositoryBaseModel<Worker> {
    
    
    init() {
        super.init(table: .workers)
        createSelectedLayoutTable()
    }
    
    //TODO: Handle Error
    /// This fucntion creates table by specifying table name
    func createSelectedLayoutTable() {
        guard let db = self.applicationDB else {
            return
        }
                
        do {
            try db.run(table.create(ifNotExists: true) { t in
                t.column(workerID, unique: true)
                t.column(firstName)
                t.column(middleName)
                t.column(lastName)
                t.column(nickName)
                t.column(cellNumber)
                t.column(email)
                t.column(hourlyWorker)
                t.column(salary)
                t.column(contractor)
                t.column(workerTheme)
                t.column(backgroundColor)
                t.column(fontColor)
                t.column(sampleWorker)
                t.column(removed)
                t.column(removedDate)
                t.column(createdDate)
                t.column(modifiedDate)
            })
        }catch {
            
        }
    }
    
    func insertWorker(worker: Worker, success: @escaping(Worker?) -> (), failure: @escaping() -> ()) {
        guard let db = self.applicationDB
            else {
            return
        }
        
        let workerId = self.getWorkerCount() ?? -1
        let insert = table.insert(workerID <- workerId,
                                        firstName <- worker.firstName ?? "",
                                        middleName <- worker.middleName ?? "",
                                        lastName <- worker.lastName ?? "",
                                        nickName <- worker.nickName ?? "",
                                        cellNumber <- worker.cellNumber ?? "",
                                        email <- worker.email ?? "",
                                        hourlyWorker <- worker.hourlyWorker ?? false,
                                        salary <- worker.salary ?? false,
                                        contractor <- worker.contractor ?? false,
                                        workerTheme <- worker.workerTheme ?? "",
                                        backgroundColor <- worker.backgroundColor ?? "",
                                        fontColor <- worker.fontColor ?? "",
                                        sampleWorker <- worker.sampleWorker ?? false,
                                        removed <- worker.removed ?? false,
                                        removedDate <- worker.removedDate ?? "",
                                        modifiedDate <- worker.modifiedDate ?? "",
                                        createdDate <- worker.createdDate ?? ""
        )
        do {
            let rowid = try db.run(insert)
            print(rowid)
            success(self.fetchWorker(with: workerId))
        }catch {
            failure()
        }
    }
    
    func update(worker: Worker, success: @escaping() -> (), failure: @escaping() -> ()) {
        guard let db = self.applicationDB
            else {
            return
        }
        
        let receiptUpdate = table.filter(workerID == (worker.workerID ?? -1))
        let update = receiptUpdate.update(
            firstName <- worker.firstName ?? "",
            middleName <- worker.middleName ?? "",
            lastName <- worker.lastName ?? "",
            nickName <- worker.nickName ?? "",
            cellNumber <- worker.cellNumber ?? "",
            email <- worker.email ?? "",
            hourlyWorker <- worker.hourlyWorker ?? false,
            salary <- worker.salary ?? false,
            contractor <- worker.contractor ?? false,
            workerTheme <- worker.workerTheme ?? "",
            backgroundColor <- worker.backgroundColor ?? "",
            fontColor <- worker.fontColor ?? "",
            sampleWorker <- worker.sampleWorker ?? false,
            removed <- worker.removed ?? false,
            removedDate <- worker.removedDate ?? "",
            modifiedDate <- worker.modifiedDate ?? ""
        )
        do {
            let rowid = try db.run(update)
            print(rowid)
            success()
        }catch {
            failure()
        }
    }
    
    func fetchWorker(with id: Int) -> Worker? {
        guard let db = self.applicationDB
            else {
            return nil
        }
                
        do {
            var worker: Worker?
            for row in try db.prepare(table) {
                worker = Worker(row: row)
            }
            return worker
        }catch {
            return nil
        }
    }
    
    func fetchWorkerRows(offset: Int) -> [Row] {
        guard let db = self.applicationDB else {
            return []
        }
        
        do {
            let query = table.limit(10, offset: offset)
            var rows = [Row]()
            for row in try db.prepare(query) {
                rows.append(row)
            }
            return rows
        }catch {
            return []
        }
    }
    
    func getWorkerCount() -> Int? {
        guard let db = self.applicationDB
            else {
            return nil
        }
        
        do {
            let count = try db.scalar(table.count)
            return count
        }catch {
            return nil
        }
    }
}
