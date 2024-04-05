//
//  Reachability.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 05/06/20.
//  Copyright © 2020 Sourabh. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class Reachability: NSObject {
    static let shared = Reachability()
    private var manager: NetworkReachabilityManager
    
    private override init() {
        self.manager = NetworkReachabilityManager()!
        super.init()
        
    }
    
    var isConnected: Bool {
        return manager.isReachable
    }
    
}
