//
//  AppConstants.swift
//  MyProHelper
//
//  Created by Anupansh on 10/03/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import UIKit

struct AppStoryboards {
    static let workers = UIStoryboard(name: "WorkerList", bundle: nil)
    static let companyInformation = UIStoryboard(name: "CompanyInformation", bundle: nil)
    static let home = UIStoryboard(name: "Home", bundle: nil)
    static let auth = UIStoryboard(name: "Auth", bundle: nil)
    static let payroll = UIStoryboard(name: "Payroll", bundle: nil)
    static let part = UIStoryboard(name: "Part", bundle: nil)
    static let timeSheets = UIStoryboard(name: "TimeSheets", bundle: nil)
    
}

struct AppLocals {
    static let appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
    static let googleApiKey = "AIzaSyA4XBuPLSMw92ULiPZ1BJIN-ofAnZLgb4U"
    static let squareApplicationId = "sq0idp-quOEFCpd1CevR8GKr9Ne4rrrrr"
    static let squareMobileAuthorisationKey = "sq0acp-ymHMFRwtFKlNSg66JK9wyEyL5VsH_A9E5El9Ea0X7XU"
    static var mapBoxKey = "sk.eyJ1IjoiYmVuY2hkIiwiYSI6ImNrdmdwMWI1YzFzdzMybnAxNXIwd3JvZzUifQ.q-N7mlvPpm9s_a6ogfaYmA"
    static var worker = Worker()
    static var workerRole = WorkerRoles()
    static var workerRolesGroup = WorkerRolesGroup()
    static var serverAccessCode: DeviceToServerAccess?
    static var currentTimeSheetId:Int64?
    static var startDateWorked:Date?
    static var isBreakRunning:Bool = false
    static var isLunchRunning:Bool = false
    static var isLunchEnd:Bool = false
    static var savedLocationData : [String: LocationData]?
//    AIzaSyCuUCjnhKKoaFXJ0DaZify8s5qzodYcR0I
    static var pickedJob: Job?
}

struct UserDefaultKeys {
    static let workerId = "workerId"
    static let userId = "userId"
    static let name = "name"
}
