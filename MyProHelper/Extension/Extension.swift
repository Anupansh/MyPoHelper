//
//  Extension.swift
//  MyProHelper
//
//  Created by Salman Khan on 01/11/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

extension UIView {
   
    func setEmptyMessage(show: Bool, message: String) {
        DispatchQueue.main.async {
            let tag = 808402
            if let indicator = self.viewWithTag(tag) as? UILabel {
                indicator.removeFromSuperview()
            }
            
            let messageLabel = UILabel(frame: CGRect(x: 0, y: (self.bounds.size.height / 2), width: self.bounds.size.width, height: 30))
            if show {
                messageLabel.text = message
                messageLabel.textColor = .darkGray
                messageLabel.numberOfLines = 0;
                messageLabel.textAlignment = .center;
                messageLabel.sizeToFit()
                messageLabel.center = CGPoint(x: self.bounds.size.width / 2, y: (self.bounds.size.height / 2))
                messageLabel.tag = tag
                self.addSubview(messageLabel)
               
            } else {
                if let indicator = self.viewWithTag(tag) as? UILabel {
                    indicator.removeFromSuperview()
                }
            }
            self.layoutIfNeeded()
        }
    }
    
    
}


