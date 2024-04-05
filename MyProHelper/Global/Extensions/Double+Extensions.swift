//
//  Double+Extensions.swift
//  MyProHelper
//
//  Created by Samir on 11/15/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

extension Double {
    var stringValue: String {
        get {
            return String(format: "%.2f", self)
        }
    }
}
