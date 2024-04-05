//
//  NSObject+Extensions.swift
//  MyProHelper
//
//  Created by Anupansh on 10/03/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//
import Foundation
import UIKit

extension NSObject {
    
    class var className: String {
        return String(describing: self)
    }
    
    var classNameString: String {
        return String(describing: self)
    }
}

extension UITextField {
    @IBInspectable var placeholderColor : UIColor {
        get {
            return self.placeholderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue])
        }
    }
}

extension String {
    func firstUppercased() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func firstUppercased() {
        self = self.firstUppercased()
    }
}

extension UICollectionView {
    func register(nib nibName:String) {
        
        let nib = UINib(nibName: nibName, bundle: nil)
        self.register(nib, forCellWithReuseIdentifier: nibName)
    }
    
    func registerMultiple(nibs arrayNibs:[String]) {
        
        for nibName in arrayNibs {
            register(nib: nibName)
        }
    }
}

extension UITableView {
    func register(nib nibName:String) {
        let nib = UINib(nibName: nibName, bundle: nil)
        self.register(nib, forCellReuseIdentifier: nibName)
    }
    
    func registerMultiple(nibs arrayNibs:[String]) {
        for nibName in arrayNibs {
            register(nib: nibName)
        }
    }
}
