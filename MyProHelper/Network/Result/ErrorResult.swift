//
//  ErrorResult.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 03/04/1942 Saka.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

enum ErrorResult:Error {
    case network(string:String)
    case parser(string:String)
    case custom(string:String)
}
