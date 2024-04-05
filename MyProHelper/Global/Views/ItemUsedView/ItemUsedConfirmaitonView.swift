//
//  PartUsedConfirmaitonView.swift
//  MyProHelper
//
//  Created by Deep on 2/16/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit

class ItemUsedConfirmaitonView: UIViewController, Storyboarded {

    @IBOutlet weak var backgroundViewContainer: UIView!
    
    @IBOutlet weak var firstOption: UIButton!
    @IBOutlet weak var secondOption: UIButton!
    
    
    @IBOutlet weak var firstOptionLabel: UILabel!
    @IBOutlet weak var secondOptionLabel: UILabel!
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var firstOptionSelected: ((_ option: Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTapGesture()
        firstOption.isSelected  = true
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDismissView))
        backgroundViewContainer.addGestureRecognizer(tapGesture)
    }
    
    func setFirstOptionLabel(label: String){
        firstOptionLabel.text = label
    }
    
    func setSecondOptionLabel(label: String) {
        secondOptionLabel.text = label
    }
    
    @IBAction func didSelectFirstOption(_ sender: UIButton) {
        setOptionSelected(isFirstOptionSelected: true)
    }
    
    @IBAction func didSelectSecondOption(_ sender: UIButton) {
        setOptionSelected(isFirstOptionSelected: false)
    }
    
    func setOptionSelected(isFirstOptionSelected: Bool) {
        if isFirstOptionSelected {
            firstOption.isSelected  = true
            secondOption.isSelected = false
        } else {
            firstOption.isSelected  = false
            secondOption.isSelected = true
        }
    }
    
    @IBAction func didConfirm(_ sender: UIButton) {
        dismiss(animated: false, completion: { [weak self] in
            guard let self = self else { return }
            let firstOptionValue = self.firstOption.isSelected
            self.firstOptionSelected?(firstOptionValue)
        })
    }
    
    @IBAction func CancelPressed(_ sender: Any) {
        handleDismissView()
    }
    
    @objc private func handleDismissView() {
        dismiss(animated: true, completion: nil)
    }
    
}
