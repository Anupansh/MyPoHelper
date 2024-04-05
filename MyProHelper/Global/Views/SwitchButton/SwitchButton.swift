//
//  SwitchButton.swift
//  MyProHelper
//
//  Created by Samir on 12/28/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit

class SwitchButton: UIView {
    
    @IBOutlet weak private var switchButton : UISwitch!
    @IBOutlet weak private var titleLabel   : UILabel!
    
    let buttonState = Box(false)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupSwitchButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSwitchButton()
    }
    
    private func setupView() {
        loadNib(nibName: String(describing: SwitchButton.self))
    }
    
    private func setupSwitchButton() {
        switchButton.setOn(false, animated: false)
        switchButton.addTarget(self, action: #selector(handleButtonChange), for: .valueChanged)
    }
    
    @objc private func handleButtonChange() {
        buttonState.value = switchButton.isOn
    }
    
    func setTitle(title: String, color: UIColor) {
        titleLabel.text = title
        titleLabel.textColor = color
    }

}
