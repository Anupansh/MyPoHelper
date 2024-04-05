//
//  GenericMenuSubmenuViewModel.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 16/04/1942 Saka.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation
import UIKit

struct GenericMenuSubmenuViewModel {
    
    let dataSource:GenericDataSource<String>?
    var key:ControllerKeys?
    
    init(dataSource:GenericDataSource<String>,key:ControllerKeys) {
        self.dataSource = dataSource
        self.key = key
    }
    
//    func customersViewModel() -> CustomerListViewModel {
//        let dataSource = 
//        
//        
//    }
    
    func genericSubMenuViewModal(key:ControllerKeys) -> GenericMenuSubmenuViewModel {
        let genericSubMenuDataSource = GenericMenuSubmenuDataSource()
        let genericSubMenuViewModal = GenericMenuSubmenuViewModel(dataSource: genericSubMenuDataSource,key: key)
        return genericSubMenuViewModal
    }
    
    subscript(index: Int) -> String? {
        get {
            guard dataSource?.data.value.count != 0 else {
                return nil
            }
            return dataSource?.data.value[index]
        }
        set(newValue) {
            if let string = newValue {
                dataSource?.data.value[index] = string
            }
        }
    }
    
}
