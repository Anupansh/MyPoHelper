//
//  UIDevice+Extension.swift
//  MyProHelper
//
//  Created by sismac010 on 04/10/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import UIKit

struct DeviceType {
    static let IS_IPAD = UIDevice.current.userInterfaceIdiom == .pad
    static let IS_IPHONE = UIDevice.current.userInterfaceIdiom == .phone
}
