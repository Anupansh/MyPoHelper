//
//  RadioButton.swift
//  MyProHelper
//
//  Created by Samir on 12/30/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit
import M13Checkbox

class RadioButton: UIView {

    @IBOutlet weak private var radioStackView   : UIStackView!
    @IBOutlet weak private var titleLabel       : UILabel!
    @IBOutlet weak private var radioButtonView  : UIView!
    
    private let radioButton = M13Checkbox(frame: CGRect(x: 0,
                                                        y: 0,
                                                        width: 20,
                                                        height: 20))
    var didSelectButton: (()->())?
    var data: RadioButtonData?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib(nibName: String(describing: RadioButton.self))
        setupRadioButton()
        setupStackView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupRadioButton()
        setupStackView()
    }

    private func setupStackView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleChooseButton))
        radioStackView.addGestureRecognizer(tapGesture)
        radioStackView.isUserInteractionEnabled = true
    }
    
    private func setupRadioButton() {
        radioButtonView.addSubview(radioButton)
        radioButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            radioButton.centerYAnchor.constraint(equalTo: radioButtonView.centerYAnchor),
            radioButton.centerXAnchor.constraint(equalTo: radioButtonView.centerXAnchor),
            radioButton.heightAnchor.constraint(equalToConstant: 20),
            radioButton.widthAnchor.constraint(equalToConstant: 20)
        ])
        
        radioButton.boxType                     = .circle
        radioButton.markType                    = .radio
        radioButton.stateChangeAnimation        = .fill
        radioButton.tintColor                   = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        radioButton.secondaryTintColor          = .gray
        radioButton.isUserInteractionEnabled    = false
    }
    
    @objc private func handleChooseButton() {
        data?.value             = true
        radioButton.checkState  = .checked
        didSelectButton?()
    }
    
    func initializeRadioButton(data: RadioButtonData) {
        self.data = data
        titleLabel.text = data.title
        setRadioValue(isSelected: data.value)
    }
    
    func resetButtonData() {
        data?.value = false
        setRadioValue(isSelected: false)
    }
    
    func setRadioValue(isSelected: Bool) {
        radioButton.checkState = (isSelected) ? .checked : .unchecked
    }
    
    func setRadioButtonLeft(){
        radioStackView.addArrangedSubview(self.radioStackView.subviews[0])
    }
}
