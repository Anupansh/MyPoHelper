//
//  LabelCell.swift
//  MyProHelper
//
//  Created by Anupansh on 22/03/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit

class LabelCell: UITableViewCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var bgView: UIView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
