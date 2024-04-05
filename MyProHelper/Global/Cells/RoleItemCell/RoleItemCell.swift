//
//  RoleItemCell.swift
//  MyProHelper
//
//  Created by Samir on 05/01/2021.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit

class RoleItemCell: BaseFormCell/*UITableViewCell*/ {

//    static let ID = String(describing: RoleItemCell.self)
    static let ID = "RoleItemCell"
    
    @IBOutlet weak private var roleTitleLabel   : UILabel!
    @IBOutlet weak private var roleSwitchButton : UISwitch!
    
    var didSetRole: ((_ role: Bool) -> ())?

    var isSelectionEnabled: Bool = true {
        didSet {
            roleSwitchButton.isEnabled = isSelectionEnabled
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupRoleSwitchButton()
    }
    
    private func setupRoleSwitchButton() {
        roleSwitchButton.addTarget(self, action: #selector(handleRoleSwitchChange), for: .valueChanged)
    }
    
    @objc private func handleRoleSwitchChange() {
        didSetRole?(roleSwitchButton.isOn)
    }
    
    func bindData(title: String, isOn: Bool) {
        roleTitleLabel.text     = title
        roleSwitchButton.isOn   = isOn
    }
}
