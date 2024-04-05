//
//  ScheduleJobModel.swift
//  MyProHelper
//
//  Created by Samir on 12/24/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

struct ScheduleJobModel {
    
    var worker      : Worker?
    var startTime   : Date?
    var endTime     : Date?
    var duration    : String?
    
    init() {
        
    }
}
