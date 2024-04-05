//
//  ShowViewDelegate.swift
//  MyProHelper
//
//  Created by Samir on 05/01/2021.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit

@objc protocol ShowViewDelegate {
    func presentView(view: UIViewController,completion: @escaping ()->())
    @objc optional func showAlert(alert: UIAlertController,sourceView: UIView)
    func pushView(view: UIViewController)
}
