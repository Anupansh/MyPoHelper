//
//  DBHelper.swift
//  MyProHelper
//
//  Created by Sourabh Nag on 05/06/20.
//  Copyright © 2020 Sourabh Nag. All rights reserved.
//

import Foundation
import SQLite

class UserRepository: RepositoryBaseModel<User> {
    
    /// Contains the private instance of the database
    init() {
        super.init(table: .users)
    }
    
    //TODO: Handle Error
    /// This fucntion creates table by specifying table name
    private func createUserTable(with tableName:TableName) {
        
        guard let db = self.applicationDB else {
            return
        }
        
        do {
            try db.run(table.create { t in
                t.column(customerID, unique: true)
                t.column(customerName)
                t.column(email, unique: true)
            })
        }catch {
            
        }
    }
    
    //TODO: Handle Error
    /// This function insert a new user to the users table
    private func insertUser(user:User) {
        guard let db = self.applicationDB,
              let userName = user.customerName,
              let userEmail = user.contactEmail else {
            return
        }
        
        let insert = table.insert(name <- userName, email <- userEmail)
        do {
            let rowid = try db.run(insert)
            print(rowid)
        }catch {
            
        }
    }
    
    //TODO: HandleError
    /// Use this function to get all the users in the table
    private func getDBUsers() -> [User] {
        guard let db = self.applicationDB else {
            return []
        }
        
        var users = [User]()
        do {
            for userRow in try db.prepare(table) {
                let user = User(row: userRow)
                users.append(user)
            }
            return users
        }catch {
            return []
        }
    }
    
}
