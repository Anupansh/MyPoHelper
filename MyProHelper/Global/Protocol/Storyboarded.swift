//
//  Storyboarded.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/1/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit

protocol Storyboarded: NSObject {
    
    static func instantiate(storyboard: Constants.Storyboard) -> Self
}

extension Storyboarded where Self: UIViewController {
    
    static func instantiate(storyboard: Constants.Storyboard) -> Self {
        let id = String(describing: self)
        let storyboard = UIStoryboard(name: storyboard.rawValue, bundle: .main)
        return storyboard.instantiateViewController(withIdentifier: id) as! Self
    }
}
