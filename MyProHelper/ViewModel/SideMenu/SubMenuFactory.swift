//
//  SubMenuFactory.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 16/04/1942 Saka.
//  Copyright © 1942 Sourabh Nag. All rights reserved.
//

import Foundation
import UIKit

struct SubmenuFactory {
    
    let key:ControllerKeys?

    init(key:ControllerKeys?) {
        self.key = key
    }

    func getMenuItems() -> [String] {
        switch key {
<<<<<<< HEAD:MyProHelper/MyProHelper/ViewModel/SideMenu/SubMenuFactory.swift
        case .customers:
            return ["Customers List","Scheduled Jobs","Job History"]
        case .jobs:
            return ["Scheduled Jobs","Job History","Quotes/Estimates","Invoices","Payments","Receipts"]
=======
>>>>>>> Remove some extra folders and files from the project.:MyProHelper/MyProHelper/Modules/Home/GenericMenuSubmenu/SubMenuFactory.swift
        case .quotesAndEstimates:
            return ["Quotes","Estimates"]
        case .inventory:
            return ["Parts","Supplies","Purchase Orders","Work Orders"]
        case .sales:
            return ["Parts","Supplies","Invoice","Payment","Quotes/Estimates","Work Order"]
        case .workers:
            return ["Workers List","Expense Statements","Current Time Sheet","Time Sheet History","Time off Request","Wages"]
        case .payroll:
            return ["Create Payroll","Time Sheets"]
        case .masterSetup:
            return ["Adjust Company settings"]
        case .approvals:
            return ["Time-Off Approvals","Invoice Approvals","Work-Order Approvals","Purchase Order Approvals","Expense Statement Approvals"]
        case .reports:
            return ["Jobs","Scheduled Jobs","Unscheduled Jobs","Balance Amount","Received Amount"]
        case .help:
            return ["Technical Support","Contact Us","Audit Trail","Refer a Friend to Us","About this program."]
        case .technicalSupport:
            return ["Call us","Email to request help","Text to request help"]
        case .contactUs:
            return ["Phone","Email","Text","Address"]
        case .adjustCompanySettings:
            return ["Company Information","Asset Types","Assets","Services","Roles Group","Devices","Part Locations","Supply Locations","Vendors","Time-Off Rules","Payroll Rules","Holidays"]
        case .worker:
            return ["Personal Info","Address","Roles Group","Devices","Wage"]
        default:
            return ["Customers List","Scheduled Jobs","Job History"]
        }
    }
    
}
