//
//  SideMenuSubCell.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/11/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit

class SideMenuSubCell: UITableViewCell {

    static let ID = String(describing: SideMenuSubCell.self)
    
    @IBOutlet weak private var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func setTitle(title: String) {
        titleLabel.text = title
    }
    
}
