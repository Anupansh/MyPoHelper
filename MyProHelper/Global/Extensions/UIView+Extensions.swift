//
//  UIView+Extensions.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 04/04/1942 Saka.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func dropShadow(cornerRadius:CGFloat = 5) {
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.masksToBounds = true

        self.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.4).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.layer.shadowRadius = 8
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
    }
    
    func dropShadowWithoutCaching(cornerRadius:CGFloat = 5) {
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 2
    }
    
    func themeConfiguration() {
        self.layer.cornerRadius = Constants.themeConfiguration.layer.theme
        self.layer.borderWidth = Constants.themeConfiguration.layer.borderWidth
        self.layer.borderColor = Constants.themeConfiguration.layer.borderColor
        self.layer.cornerRadius = Constants.themeConfiguration.layer.theme
        self.layer.borderWidth = Constants.themeConfiguration.layer.borderWidth
        self.layer.borderColor = Constants.themeConfiguration.layer.borderColor
    }
    
    @IBInspectable var shadowRadius : CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.masksToBounds = false
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.3
            layer.shadowRadius = newValue
            layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
            layer.shouldRasterize = true
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set { layer.cornerRadius = newValue}
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
    
    @IBInspectable var borderColor: UIColor {
        get {
            guard let color = layer.borderColor else {
                return .clear
            }
            return UIColor(cgColor: color)
        }
        set { layer.borderColor = newValue.cgColor}
    }
    
    func loadNib(nibName: String) {
        guard let view: UIView = Bundle.main.loadNibNamed(nibName, owner: self, options: nil)?.first as? UIView else {
            print("CAN NOT LOAD NIB: \(nibName)")
            return
        }
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(view)
    }
} 
