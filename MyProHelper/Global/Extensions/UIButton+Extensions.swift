//
//  UIButton+Extensions.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 05/04/1942 Saka.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    enum FontSize {
        case small
        case medium
        case large
    }
    
    func setFont(with font:UIFont) {
        self.titleLabel?.font = font
    }
    
    func setTitle(title:String,fontSize:FontSize) {
        switch fontSize {
        case .small:
            self.setFont(with: Constants.themeConfiguration.font.smallFont)
        case .medium:
            self.setFont(with: Constants.themeConfiguration.font.mediumFont)
        case .large:
            self.setFont(with: Constants.themeConfiguration.font.largeFont)
        }
        
        self.setTitle(title, for: .normal)
    }
    
}
