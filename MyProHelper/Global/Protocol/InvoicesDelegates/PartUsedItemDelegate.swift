//
//  PartUsedItemDelegate.swift
//  MyProHelper
//
//  Created by Deep on 2/9/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

protocol PartUsedItemDelegate {
    func didAddPart(part: PartUsed)
    func didUpdatePart(part: PartUsed)
}
