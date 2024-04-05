//
//  RefreshDelegate.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/15/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

protocol RefreshDelegate {
    func reloadView()
    func showError(message: String)
}
