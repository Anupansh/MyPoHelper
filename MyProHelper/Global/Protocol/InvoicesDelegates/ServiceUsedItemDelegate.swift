//
//  ServiceUsedItemDelegate.swift
//  MyProHelper
//
//  Created by Deep on 2/8/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

protocol ServiceUsedItemDelegate {
    func didAddService(service: ServiceUsed)
    func didUpdateService(service: ServiceUsed)
}
