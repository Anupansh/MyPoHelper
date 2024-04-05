//
//  ButtonCell.swift
//  MyProHelper
//
//  Created by Samir on 12/20/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit

class ButtonCell: BaseFormCell {

    static let ID = String(describing: ButtonCell.self)
    
    @IBOutlet weak private var button: UIButton!
        
    var didClickButton: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        button.setTitle("", for: .normal)
    }
    
    func setButtonTitle(title: String) {
        button.setTitle(title, for: .normal)
    }
    
    @IBAction private func buttonPressed(sender: UIButton) {
        didClickButton?()
    }
    
    func changeButtonState(isEnabled: Bool) {
        if isEnabled {
            button.isUserInteractionEnabled = true
            button.backgroundColor = .systemBlue
        }
        else {
            button.isUserInteractionEnabled = false
            button.backgroundColor = .gray
        }
    }
    
}
