//
//  UIScrollView+Extensions.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 30/06/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation
import UIKit

extension UIScrollView {
    
    func widthForMakingItemSquare(numberOfItems:CGFloat,edgeSpaces:CGFloat) -> CGFloat {
        let totalWidth = self.frame.width
        let availableWidth = totalWidth - ((numberOfItems + 1) * edgeSpaces)
        return availableWidth/numberOfItems
    }
}

extension UICollectionViewCell {
    func addShadow() {
        self.contentView.layer.cornerRadius = 16
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true

        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.layer.shadowRadius = 8.0
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }
}

extension UITableViewCell {
    func addShadow() {
        self.contentView.layer.cornerRadius = 16
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true

        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.layer.shadowRadius = 8.0
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }
}
