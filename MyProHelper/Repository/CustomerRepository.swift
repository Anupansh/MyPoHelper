//
//  CustomersDBService.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 22/05/1942 Saka.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB

class CustomerRepository: BaseRepository {
    
    
    init() {
        super.init(table: .CUSTOMERS)
        self.createSelectedLayoutTable()
    }
    
    override func setIdKey() -> String {
        return COLUMNS.CUSTOMER_ID
    }
    
    private func createSelectedLayoutTable() {
        let sql = """
        CREATE TABLE IF NOT EXISTS \(tableName)(
            \(COLUMNS.CUSTOMER_ID) INTEGER PRIMARY KEY  AUTOINCREMENT UNIQUE NOT NULL,
            \(COLUMNS.CUSTOMER_NAME)            TEXT (100) NOT NULL,
            \(COLUMNS.BILLING_ADDRESS_1)        TEXT (100) NOT NULL,
            \(COLUMNS.BILLING_ADDRESS_2)        TEXT (100),
            \(COLUMNS.BILLING_ADDRESS_CITY)     TEXT (100) NOT NULL,
            \(COLUMNS.BILLING_ADDRESS_STATE)    TEXT (2),
            \(COLUMNS.BILLING_ADDRESS_ZIP)      TEXT (10)  NOT NULL,
            \(COLUMNS.CONTACT_NAME)             TEXT (100) NOT NULL,
            \(COLUMNS.CONTACT_PHONE)            TEXT (14)  NOT NULL,
            \(COLUMNS.CONTACT_EMAIL)            TEXT (100),
            \(COLUMNS.MOST_RECENT_COTACT)       TEXT,
            \(COLUMNS.SAMPLE_CUSTOMER)          INTEGER DEFAULT(0),
            \(COLUMNS.REMOVED)                  INTEGER DEFAUßLT(0),
            \(COLUMNS.REMOVED_DATE)             TEXT
        )
        """
        AppDatabase.shared.executeSQL(sql: sql,
                                      arguments: [],typeOfAction: .create, updatedId: nil) { (_) in
            print("TABLE CUSTOMERS IS CREATED SUCCESSFULLY")
        } fail: { (error) in
            print(error)
        }
    }
    
    func insertCustomer(customer: Customer, success: @escaping(_ id: Int64) -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "customerName"      : customer.customerName,
            "address1"          : customer.billingAddress1,
            "address2"          : customer.billingAddress2,
            "city"              : customer.billingAddressCity,
            "state"             : customer.billingAddressState,
            "zip"               : customer.billingAddressZip,
            "contactName"       : customer.contactName,
            "contactPhone"      : customer.contactPhone,
            "contactEmail"      : customer.contactEmail,
            "removed"           : customer.removed ?? 0,
            "removeDate"        : DateManager.getStandardDateString(date: customer.removedDate),
            "mostRecentContact" : DateManager.getStandardDateString(date: customer.mostRecentContact)
            
        ]
        let sql = """
            INSERT INTO chg.\(tableName) (
                \(COLUMNS.CUSTOMER_NAME),
                \(COLUMNS.BILLING_ADDRESS_1),
                \(COLUMNS.BILLING_ADDRESS_2),
                \(COLUMNS.BILLING_ADDRESS_CITY),
                \(COLUMNS.BILLING_ADDRESS_STATE),
                \(COLUMNS.BILLING_ADDRESS_ZIP),
                \(COLUMNS.CONTACT_NAME),
                \(COLUMNS.CONTACT_PHONE),
                \(COLUMNS.CONTACT_EMAIL),
                \(COLUMNS.REMOVED),
                \(COLUMNS.REMOVED_DATE),
                \(COLUMNS.MOST_RECENT_COTACT)
            )

            VALUES (:customerName,
                    :address1,
                    :address2,
                    :city,
                    :state,
                    :zip,
                    :contactName,
                    :contactPhone,
                    :contactEmail,
                    :removed,
                    :removeDate,
                    :mostRecentContact
            )
            """
        AppDatabase.shared.executeSQL(sql: sql,
                                      arguments: arguments,
                                      typeOfAction: .insert, updatedId: nil,
                                      success: { id in
                                        success(id)
                                      },
                                      fail: failure)
    }
    
    func updateCustomer(customer: Customer, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        let arguments: StatementArguments = [
            "id"                : customer.customerID,
            "customerName"      : customer.customerName,
            "address1"          : customer.billingAddress1,
            "address2"          : customer.billingAddress2,
            "city"              : customer.billingAddressCity,
            "state"             : customer.billingAddressState,
            "zip"               : customer.billingAddressZip,
            "contactName"       : customer.contactName,
            "contactPhone"      : customer.contactPhone,
            "contactEmail"      : customer.contactEmail,
            "removed"           : customer.removed,
            "removeDate"        : DateManager.getStandardDateString(date: customer.removedDate),
            "mostRecentContact" : DateManager.getStandardDateString(date: customer.mostRecentContact)
        ]
        let sql = """
            UPDATE \(tableName) SET
                \(COLUMNS.CUSTOMER_NAME)            = :customerName,
                \(COLUMNS.BILLING_ADDRESS_1)        = :address1,
                \(COLUMNS.BILLING_ADDRESS_2)        = :address2,
                \(COLUMNS.BILLING_ADDRESS_CITY)     = :city,
                \(COLUMNS.BILLING_ADDRESS_STATE)    = :state,
                \(COLUMNS.BILLING_ADDRESS_ZIP)      = :zip,
                \(COLUMNS.CONTACT_NAME)             = :contactName,
                \(COLUMNS.CONTACT_PHONE)            = :contactPhone,
                \(COLUMNS.CONTACT_EMAIL)            = :contactEmail,
                \(COLUMNS.REMOVED)                  = :removed,
                \(COLUMNS.REMOVED_DATE)             = :removeDate,
                \(COLUMNS.MOST_RECENT_COTACT)       = :mostRecentContact
            WHERE \(tableName).\(setIdKey()) = :id;
            """
        
        AppDatabase.shared.executeSQL(sql: sql,
                                      arguments: arguments,
                                      typeOfAction: .update, updatedId: UInt64(customer.customerID!),
                                      success: { _ in
                                        success()
                                      },
                                      fail: failure)
    }
    
    func deleteCustomer(customer: Customer, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = customer.customerID else {
            return
        }
        softDelete(atId: id, success: success, fail: failure)
    }
    
    func restoreCustomer(customer: Customer, success: @escaping() -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let id = customer.customerID else {
            return
        }
        restoreItem(atId: id, success: success, fail: failure)
    }
    
    func fetchCustomer(customerId: Int, success: @escaping(_ user: Customer?) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        var sql = """
        SELECT * FROM main.\(tableName)
        WHERE main.(\(tableName).\(COLUMNS.REMOVED) = 0
                OR main.\(tableName).\(COLUMNS.REMOVED) is NULL)
        AND \(COLUMNS.CUSTOMER_ID) = ?;
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            let customer = try queue.read { (database) -> Customer? in
                if let row = try Row.fetchOne(database, sql: sql, arguments: [customerId,customerId]) {
                    return .init(row: row)
                }
                else {
                    return nil
                }
            }
            success(customer)
        }
        catch {
            failure(error)
        }
        
    }
    
    func fetchCustomers(showSelect: Bool, with key: String? = nil, offset: Int,success: @escaping(_ users: [Customer]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        let searchable = makeSearchableItems(key: key)
        
        let noSelectCondition = """
            main.\(tableName).\(COLUMNS.CUSTOMER_NAME) != '--SELECT--'
            """

        var condition = ""
        if showSelect {
            condition = (searchable.isEmpty) ? "" : "WHERE \(searchable)"
        }
        else {
            condition = (searchable.isEmpty) ? "WHERE \(noSelectCondition)" : """
                WHERE \(noSelectCondition)
                AND \(searchable)
            """
        }

        var sql = """
        SELECT * FROM main.\(tableName)
        \(condition)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        
//        sql += """
//                LIMIT \(LIMIT) OFFSET \(offset);
//        """

        
        do {
            let users = try queue.read({ (db) -> [Customer] in
                var users: [Customer] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    users.append(.init(row: row))
                }
                return users
            })
            success(users)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    
    func fetchCustomers(showRemoved: Bool ,with key: String? = nil, sortBy: CustomerField? = nil, sortType: SortType? = nil ,offset: Int,success: @escaping(_ users: [Customer]) -> (), failure: @escaping(_ error: Error) -> ()) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else { return }
        let searchable = makeSearchableItems(key: key)
        let condition = getShowRemoveCondition(showRemoved: showRemoved, searchable: searchable)
        var sql = """
        SELECT * FROM main.\(tableName)
        \(condition)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            let customers = try queue.read({ (db) -> [Customer] in
                var customers: [Customer] = []
                let rows = try Row.fetchAll(db,
                                            sql: sql,
                                            arguments: [])
                rows.forEach { (row) in
                    customers.append(.init(row: row))
                }
                return customers
            })
            success(customers)
        }
        catch {
            failure(error)
            print(error)
        }
    }
    
    private func makeSortableItems(sortBy: CustomerField?, sortType: SortType?) -> String {
        guard let sortBy = sortBy, let sortType = sortType else {
            return makeSortableCondition(key: COLUMNS.CUSTOMER_ID, sortType: .ASCENDING)
        }
        switch sortBy {
        
        case .CUSTOMER_ID:
            return makeSortableCondition(key: COLUMNS.CUSTOMER_ID, sortType: sortType)
        case .CUSTOMER_NAME:
            return makeSortableCondition(key: COLUMNS.CUSTOMER_NAME, sortType: sortType)
        case .CONTACT_PHONE:
            return makeSortableCondition(key: COLUMNS.CONTACT_PHONE, sortType: sortType)
        case .CONTACT_EMAIL:
            return makeSortableCondition(key: COLUMNS.CONTACT_EMAIL, sortType: sortType)
        case .BILLING_ADDRESS_ONE:
            return makeSortableCondition(key: COLUMNS.BILLING_ADDRESS_1, sortType: sortType)
        case .BILLING_ADDRESS_TWO:
            return makeSortableCondition(key: COLUMNS.BILLING_ADDRESS_2, sortType: sortType)
        case .CITY_STATE:
            return makeSortableCondition(key: COLUMNS.BILLING_ADDRESS_CITY, sortType: sortType)
        case .BILLING_ADDRESS_ZIP:
            return makeSortableCondition(key: COLUMNS.BILLING_ADDRESS_ZIP, sortType: sortType)
        }
    }
    
    private func makeSearchableItems(key: String?) -> String {
        guard let key = key else { return "" }
        return makeSearchableCondition(key: key,
                                       fields: [
                                        COLUMNS.CUSTOMER_ID,
                                        COLUMNS.CUSTOMER_NAME,
                                        COLUMNS.CONTACT_PHONE,
                                        COLUMNS.CONTACT_EMAIL,
                                        COLUMNS.BILLING_ADDRESS_1,
                                        COLUMNS.BILLING_ADDRESS_2,
                                        COLUMNS.BILLING_ADDRESS_STATE,
                                        COLUMNS.BILLING_ADDRESS_ZIP])
    }
}
