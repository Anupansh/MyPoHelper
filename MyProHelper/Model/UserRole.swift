//
//  UserRole.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 04/04/1942 Saka.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation
import GRDB

struct Role {
    
    var admin                       : Bool?
    var owner                       : Bool?
    var techSupport                 : Bool?
    var canDoCompanySetup           : Bool?
    var canAddWorkers               : Bool?
    var canAddCustomers             : Bool?
    var canRunPayroll               : Bool?
    var canSeeWages                 : Bool?
//    var canSchedule                 : Bool?
    var canDoInventory              : Bool?
    var canRunReports               : Bool?
    var canAddRemoveInventoryItems  : Bool?
    var canEditTimeAlreadyEntered   : Bool?
    var canRequestVacation          : Bool?
    var canRequestSick              : Bool?
    var canRequestPersonalTime      : Bool?
    var canApproveTimeoff           : Bool?
    var canApprovePayroll           : Bool?
    var canEditJobHistory           : Bool?
    var canScheduleJobs             : Bool?
    var canApprovePurchaseOrders    : Bool?
    var canApproveWorkOrders        : Bool?
    var canApproveInvoices          : Bool?
    var receiveEmailForRejectedJobs : Bool?
    
    init() {
        
    }
    
    init(row: Row) {
        let column = RepositoryConstants.Columns.self
        admin                       = row[column.ADMIN]
        owner                       = row[column.MPH_XX_OWNERS]
        techSupport                 = row[column.MPH_XX_TECH_SUPPORT]
        canDoCompanySetup           = row[column.CAN_DO_COMPANY_SETUP]
        canAddWorkers               = row[column.CAN_ADD_WORKERS]
        canAddCustomers             = row[column.CAN_ADD_CUSTOMERS]
        canRunPayroll               = row[column.CAN_RUN_PAYROLL]
        canSeeWages                 = row[column.CAN_SEE_WAGES]
//        canSchedule                 = row[column.CAN_SCHEDULE]
        canDoInventory              = row[column.CAN_DO_INVENTORY]
        canRunReports               = row[column.CAN_RUN_REPORTS]
        canAddRemoveInventoryItems  = row[column.CAN_ADD_REMOVE_INVENTORY_ITEMS]
        canEditTimeAlreadyEntered   = row[column.CAN_EDIT_TIME_ALREADY_ENTERED]
        canRequestVacation          = row[column.CAN_REQUEST_VACATION]
        canRequestSick              = row[column.CAN_REQUEST_SICK]
        canRequestPersonalTime      = row[column.CAN_REQUEST_PERSONAL_TIME]
        canApproveTimeoff           = row[column.CAN_APPROVE_TIME_OFF]
        canApprovePayroll           = row[column.CAN_APPROVE_PAYROLL]
        canEditJobHistory           = row[column.CAN_EDIT_JOB_HISTORY]
        canScheduleJobs             = row[column.CAN_SCHEDULE_JOBS]
        canApprovePurchaseOrders    = row[column.CAN_APPROVE_PURCHASE_ORDERS]
        canApproveWorkOrders        = row[column.CAN_APPROVE_WORK_ORDERS]
        canApproveInvoices          = row[column.CAN_APPROVE_INVOICES]
        receiveEmailForRejectedJobs = row[column.RECEIVE_EMAILS_FOR_REJECTED_JOBS]
    }
}
