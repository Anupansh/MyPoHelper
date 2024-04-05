//
//  RadioButtonCell.swift
//  MyProHelper
//
//  Created by Samir on 12/30/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit

protocol RadioButtonCellDelegate: NSObject {
    func didChooseButton(data: RadioButtonData)
}

class RadioButtonCell: BaseFormCell {

    static let ID = String(describing: RadioButtonCell.self)
    
    @IBOutlet weak private var titleLabel   : UILabel!
    @IBOutlet weak private var stackView    : UIStackView!
    
    private var isDataSet = false
    weak var delegate: RadioButtonCellDelegate?
    var isSelectionEnabled: Bool = false {
        didSet {
            stackView.isUserInteractionEnabled = isSelectionEnabled
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func addRadioButton(data: RadioButtonData, _ widthMargin:CGFloat = 100,_ isLeftSideButton:Bool) {
        let radioButton = RadioButton(frame: .zero)
        NSLayoutConstraint.activate([
            radioButton.heightAnchor.constraint(equalToConstant: 50),
            radioButton.widthAnchor.constraint(equalToConstant: data.title.width(withConstrainedHeight: 50) + widthMargin)
        ])
        
        radioButton.didSelectButton =  { [weak self] in
            guard let self = self else { return }
            self.resetRedioButtons()
            radioButton.setRadioValue(isSelected: true)
            self.delegate?.didChooseButton(data: data)
        }
        radioButton.initializeRadioButton(data: data)
        if isLeftSideButton{
            radioButton.setRadioButtonLeft()
        }
        stackView.addArrangedSubview(radioButton)
    }
    
    
    func setRadioButtonLeft(){
        stackView.addArrangedSubview(self.stackView.subviews[0])
    }

    
    private func resetRedioButtons() {
        stackView.subviews.forEach { (view) in
            if let radioButton = view as? RadioButton {
                radioButton.resetButtonData()
            }
        }
    }
    
    func bindCell(data: [RadioButtonData], _ widthMargin:CGFloat = 100,_ isLeftSideButton:Bool = false) {
        guard !isDataSet else { return }
        
        data.forEach { [weak self] (radioButtonData) in
            guard let self = self else { return }
            self.addRadioButton(data: radioButtonData, widthMargin, isLeftSideButton)
        }
        isDataSet = true
    }
    
    func setTitle(title: String) {
        titleLabel.text = title
    }
}
