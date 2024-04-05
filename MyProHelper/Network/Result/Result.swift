//
//  Result.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 03/04/1942 Saka.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

enum Result<T,E:Error> {
    case success(T)
    case failure(E)
}
