//
//  AppListCell.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/27/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit

class AppListCell: UITableViewCell {

    @IBOutlet weak private var titleLabel       : UILabel!
    @IBOutlet weak private var separatorLine    : UIView!
    static var cellId = "AppListCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func setTitle(title: String) {
        titleLabel.text = title
    }
    
    func isLastCell(_ isLast: Bool) {
        if isLast {
            separatorLine.isHidden = true
        }
        else {
            separatorLine.isHidden = false
        }
    }
    
}
