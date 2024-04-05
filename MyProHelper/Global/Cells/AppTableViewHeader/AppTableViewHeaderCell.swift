//
//  AppTableViewHeaderCell.swift
//  MyProHelper
//
//  Created by Samir on 12/15/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit

class AppTableViewHeaderCell: UITableViewCell {
    static let ID = String(describing: AppTableViewHeaderCell.self)
    
    @IBOutlet weak private var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setTitle(title: String) {
        titleLabel.text = title
    }
    
    func setTitleColor(color: UIColor) {
        titleLabel.textColor = color
    }
}
