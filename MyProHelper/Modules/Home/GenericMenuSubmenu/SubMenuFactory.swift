//
//  SubMenuFactory.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 16/04/1942 Saka.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
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
        case .quotesAndEstimates:
            return ["Quotes","Estimates"]
        case .sales:
            return ["Parts","Supplies","Invoice","Payment","Quotes/Estimates","Work Order"]
        case .masterSetup:
            return ["Adjust Company settings"]
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
