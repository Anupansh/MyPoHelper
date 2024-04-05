//
//  BaseFormCell.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/25/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit

protocol FormCellDelegate {
    func didEndEditing(indexPath: IndexPath?)
}

class BaseFormCell: UITableViewCell {

    var indexPath: IndexPath?
    var formCellDelegate: FormCellDelegate?
    var showValidation: Bool = false
    var data: TextFieldCellData?
    var showViewDelegate: ShowViewDelegate?

    func bindData() {}
    func validateData() {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
