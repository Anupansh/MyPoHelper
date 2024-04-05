//
//  TextField.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 03/04/1942 Saka.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation
import UIKit

class AppTextField: UIView {

    @IBOutlet weak private var titleLabel           : UILabel!
    @IBOutlet weak private var requireSign          : UILabel!
    @IBOutlet weak private var textField            : UITextField!
    @IBOutlet weak private var trailingImageImage   : UIImageView!
    @IBOutlet weak private var errorLabel           : UILabel!
    @IBOutlet weak private var textFieldContainer   : UIView!
    @IBOutlet weak private var errorHeight          : NSLayoutConstraint!

    var isRequired: Bool = false {
        didSet {
            configureRequiredState()
        }
    }

    var isEditingEnabled: Bool = true {
        didSet {
            textField.isUserInteractionEnabled = isEditingEnabled
        }
    }

    var delegate: UITextFieldDelegate? {
        didSet {
            textField.delegate = delegate
        }
    }

    var clearButtonMode: UITextField.ViewMode?  {
        didSet {
            textField.clearButtonMode = clearButtonMode ?? .never
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib(nibName: String(describing: AppTextField.self))
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib(nibName: String(describing: AppTextField.self))
    }

    func showError(message: String) {
        textFieldContainer.borderColor = Constants.Colors.TEXT_FIELD_ERROR_COLOR
        errorLabel.text = message
        errorHeight.constant = 15
    }

    func hideError() {
        errorLabel.text = nil
        errorHeight.constant = 0
        textFieldContainer.borderColor = Constants.Colors.TEXT_FIELD_DEFAULT_COLOR
    }

    func setTrailingImage(image: UIImage?) {
        trailingImageImage.image = image
    }

    func setText(text: String?) {
        textField.text = text
    }

    func setTitle(title: String?) {
        titleLabel.text = title
    }

    func setInputView(view: UIView?) {
        textField.inputView = view
        textField.tintColor = .clear
    }

    private func configureRequiredState() {
        if isRequired {
            requireSign.isHidden = false
        }
        else {
            requireSign.isHidden = true
        }
    }
}
