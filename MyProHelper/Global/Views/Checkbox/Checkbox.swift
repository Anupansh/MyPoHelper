//
//  Checkbox.swift
//  MyProHelper
//
//  Created by Samir on 03/01/2021.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit
import M13Checkbox

class Checkbox: UIView {
    
    @IBOutlet weak private var checkboxStack    : UIStackView!
    @IBOutlet weak private var titleLabel       : UILabel!
    @IBOutlet weak private var checkBoxView     : UIView!
    
    private let checkboxButton = M13Checkbox(frame: CGRect(x: 0,
                                                        y: 0,
                                                        width: 20,
                                                        height: 20))
    let state = Box(false)
    var data: RadioButtonData?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib(nibName: String(describing: Checkbox.self))
        setupStackView()
        setupRadioButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStackView()
        setupRadioButton()
    }
    
    private func setupStackView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleChooseButton))
        checkboxStack.addGestureRecognizer(tapGesture)
        checkboxStack.isUserInteractionEnabled = true
    }
    
    @objc private func handleChooseButton() {
        state.value = !state.value
        data?.value = state.value
        checkboxButton.checkState = (state.value) ? .checked : .unchecked
    }
    
    private func setupRadioButton() {
        checkBoxView.addSubview(checkboxButton)
        checkboxButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            checkboxButton.centerYAnchor.constraint(equalTo: checkBoxView.centerYAnchor),
            checkboxButton.centerXAnchor.constraint(equalTo: checkBoxView.centerXAnchor),
            checkboxButton.heightAnchor.constraint(equalToConstant: 20),
            checkboxButton.widthAnchor.constraint(equalToConstant: 20)
        ])
        
        checkboxButton.boxType                     = .square
        checkboxButton.markType                    = .checkmark
        checkboxButton.stateChangeAnimation        = .fill
        checkboxButton.tintColor                   = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        checkboxButton.secondaryTintColor          = .gray
        checkboxButton.isUserInteractionEnabled    = false
    }
    
    func initializeRadioButton(data: RadioButtonData) {
        self.data = data
        state.value = data.value
        titleLabel.text = data.title
        titleLabel.numberOfLines = 0
        checkboxButton.checkState = (data.value) ? .checked : .unchecked
    }
}
