//
//  DashboardViewModel.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 29/06/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation
import UIKit

struct DashboardViewModel {
    
    var onErrorHandling:((ErrorResult?) -> Void)?
    
    func fetchControllers(with layoutModels:[LayoutModel] = []) -> [GenericViewController] {
        var keys = [ControllerKeys]()
        for model in layoutModels {
            guard let key = model.key else {
                continue
            }
            keys.append(key)
        }
        let controllerFactory = ControllerFactory(keys: keys)
        let controllers = controllerFactory.instantiateControllers()
        return controllers
    }
    
    
    func defaultLayoutModels() -> [LayoutModel] {
        return LayoutModel.defaultLayoutModels()
    }
    
    func updateLayout(onCompletion:([GenericViewController]) -> (Bool)) {

    }
    
}
