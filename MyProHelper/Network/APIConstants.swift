//
//  APIConstants.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 16/07/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

enum HOST: String {
    case development = "https://myprohelper.com:5005/"
    var stringValue: String {
        return self.rawValue
    }
}

let selectedHost = HOST.development

enum EndPoint: String {
    case workers = "api/Workers"
    case jobs = "api/ScheduledJobs"
    case customers = "api/Customers"
    case jobHistory = "api/JobHistory"
    case estimates = "api/Estimates"
    case invoices = "api/invoices"
    case payments = "api/Payments"
    case toDoItem = "api/TODOITEMS"
    case auditTrail = "api/AuditTrail"
    case companySettings = "api/CompanySettings"
    case devices = "api/Devices"
    case expenseStatements = "api/ExpenseStatements"
    case partLocations = "api/PartLocations"
    case parts = "api/Parts"
    case payroll = "api/Payroll"
    case quotes = "api/Quotes"
    case reportTypes = "api/ReportTypes"
    case serviceTypes = "api/ServiceTypes"
    case supplies = "api/Supplies"
    case supplyLocations = "api/SupplyLocations"
    case timeCards = "api/TimeCards"
    case timeOffRequests = "api/TimeOffRequests"
    case wages = "api/Wages"
    case workerHomeAddresses = "api/WorkerHomeAddresses"
    case workerRoles = "api/WorkerRoles"
    case workerRolesGroup = "api/WorkerRolesGroups"
    case workerOrders = "api/WorkOrders"
    case getDeviceCode = "DeviceCode/deviceid"
    
    var url: String {
        return selectedHost.stringValue + self.rawValue
    }
}
