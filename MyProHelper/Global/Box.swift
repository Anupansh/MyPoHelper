//
//  Box.swift
//  MyProHelper
//
//  Created by Samir on 12/21/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

class Box<T> {
    
    typealias Listener = (T) -> ()
    
    var listener: Listener?
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
}
