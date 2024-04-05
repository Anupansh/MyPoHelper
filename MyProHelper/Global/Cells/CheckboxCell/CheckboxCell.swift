//
//  CheckboxCell.swift
//  MyProHelper
//
//  Created by Samir on 03/01/2021.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit

protocol CheckboxCellDelegate: NSObject {
    func didChangeValue(with data: RadioButtonData, isSelected: Bool)
}

class CheckboxCell: BaseFormCell {
    
    static let ID = String(describing: CheckboxCell.self)
    
    @IBOutlet weak private var stackView: UIStackView!
    private var isDataSet = false
    weak var delegate: CheckboxCellDelegate?
    var isSelectionEnabled: Bool = false {
        didSet {
            stackView.isUserInteractionEnabled = isSelectionEnabled
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func addRadioButton(data: RadioButtonData) {
        let checkbox = Checkbox(frame: .zero)
        NSLayoutConstraint.activate([
            checkbox.heightAnchor.constraint(equalToConstant: 50),
            checkbox.widthAnchor.constraint(equalToConstant: data.title.width(withConstrainedHeight: 50) + 100)
        ])
        
        checkbox.state.bind(listener: { [weak self] isSelected in
            guard let self = self else { return }
            self.delegate?.didChangeValue(with: data, isSelected: isSelected)
        })
        checkbox.initializeRadioButton(data: data)
        stackView.addArrangedSubview(checkbox)
    }
    
    func bindCell(data: [RadioButtonData]) {
        guard !isDataSet else { return }
        guard !data.isEmpty else { return }
        
        data.forEach { [weak self] (radioButtonData) in
            guard let self = self else { return }
            self.addRadioButton(data: radioButtonData)
        }
        isDataSet = true
    }
}
