//
//  CheckboxCell.swift
//  MyProHelper
//
//  Created by Samir on 12/20/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit
import M13Checkbox

class CheckboxHeaderCell: BaseFormCell {

    static let ID = String(describing: CheckboxHeaderCell.self)
    
    @IBOutlet weak private var cellTitleLabel       : UILabel!
    @IBOutlet weak private var checkboxContainer    : UIView!
    
    private let checkboxDimention: CGFloat = 20
    private var checkBox: M13Checkbox!
    
    var valueChanged: ((_ isChecked: Bool)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCheckBox()
    }
    
    private func configureCheckBox(){
        checkBox = M13Checkbox(frame: CGRect(x: 0,
                                             y: 0,
                                             width: checkboxDimention,
                                             height: checkboxDimention))
        checkboxContainer.addSubview(checkBox)
        checkBox.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            checkBox.trailingAnchor.constraint(equalTo: checkboxContainer.trailingAnchor),
            checkBox.topAnchor.constraint(equalTo: checkboxContainer.topAnchor),
            checkBox.heightAnchor.constraint(equalToConstant: checkboxDimention),
            checkBox.widthAnchor.constraint(equalToConstant: checkboxDimention)
        ])
        checkBox.boxType = .circle
        checkBox.markType = .checkmark
        checkBox.stateChangeAnimation = .fill
        checkBox.tintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        checkBox.secondaryTintColor = .gray
        checkBox.secondaryCheckmarkTintColor = UIColor.white
        checkBox.isUserInteractionEnabled = true
        checkBox.addTarget(self, action: #selector(handleCheckboxChange), for: .valueChanged)
    }
    
    @objc private func handleCheckboxChange() {
        valueChanged?(checkBox.checkState == .checked)
    }
    
    func setTitle(title: String) {
        cellTitleLabel.text = title
    }
    
    func bindData(value: Bool) {
        checkBox.checkState = value ? .checked : .unchecked
    }
}
