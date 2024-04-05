//
//  GenericViewController.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 01/07/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation
import UIKit

class GenericViewController {
    
    private var _viewController:UIViewController?
    private var _key:ControllerKeys?
    var data: [String] = []
    
    var viewController:UIViewController? {
        return _viewController
    }
    
    var key:ControllerKeys? {
        return _key
    }
    
    init(viewController:UIViewController,key:ControllerKeys) {
        self._viewController = viewController
        self._key = key
    }
    
}
