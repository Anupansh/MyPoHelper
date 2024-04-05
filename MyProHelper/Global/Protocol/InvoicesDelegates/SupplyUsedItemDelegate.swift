//
//  SupplyUsedItemDelegate.swift
//  MyProHelper
//
//  Created by Deep on 2/17/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

protocol SupplyUsedItemDelegate {
    func didAddSupply(supply: SupplyUsed)
    func didUpdateSupply(supply: SupplyUsed)
}
