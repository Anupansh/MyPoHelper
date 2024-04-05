//
//  CheckBoxTableViewCell.swift
//  MyProHelper
//
//  Created by Salman Khan on 18/10/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit

protocol CheckboxCellDelegates: NSObject {
    func didChangeValue(with tag: Int, isSelected: Bool)
}

class CheckBoxTableViewCell: UITableViewCell {

    static let cellIdentifier = "checkboxCell"
    static let xibName = "checkboxCell"
    
    weak var delegate: CheckboxCellDelegates?
    var celltag: Int?
    
    @IBOutlet weak var cehckboxImg: UIImageView!
    @IBOutlet weak var checkboxBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        checkboxBtn.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
        self.isChecked = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    // Images
    var checkedImage = UIImage(named: "check_ic")! as UIImage
    let uncheckedImage = UIImage(named: "uncheck_ic")! as UIImage
    
    // Bool property
    var isChecked: Bool = false {
        didSet {
            if isChecked == true {
                cehckboxImg.image = checkedImage
            } else {
                cehckboxImg.image = uncheckedImage
            }
        }
    }

    @objc func buttonClicked(sender: UIButton) {
        isChecked = !isChecked
        self.delegate?.didChangeValue(with: self.celltag!, isSelected: isChecked)
    }
    
}
