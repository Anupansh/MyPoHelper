//
//  GenericMenuSubmenuTableViewCell.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 16/04/1942 Saka.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit

class GenericMenuSubmenuTableViewCell: UITableViewCell {

    @IBOutlet weak var submenuLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with name:String) {
        self.submenuLabel.text = name
    }
    
}
