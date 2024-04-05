//
//  RadioButtonData.swift
//  MyProHelper
//
//  Created by Samir on 12/31/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

class RadioButtonData {
    
    let key     : String
    let title   : String
    var value   : Bool

    init(key: String, title: String, value: Bool = false) {
        self.key    = key
        self.title  = title
        self.value  = value
    }
}
