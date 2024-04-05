//
//  AttachmentItemCell.swift
//  MyProHelper
//
//  Created by Samir on 11/4/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit

class AttachmentItemCell: UITableViewCell {

    static let ID = "AttachmentItemCell"
    
    @IBOutlet weak private var attachmentNameLabel              : UILabel!
    @IBOutlet weak private var attachmentNameTextField          : UITextField!
    @IBOutlet weak private var attachmentDescriptionLabel       : UILabel!
    @IBOutlet weak private var attachmentDescriptionTextField   : UITextField!
    @IBOutlet weak private var attachmentDeleteButton           : UIButton!
    
    var updateAttachment: ((_ description: String?) -> ())?
    var tapAttachment: (() -> ())?
    var tapDeleteAttachment: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    private func setupCell() {
        attachmentNameLabel.text                            = "NAME".localize
        attachmentDescriptionLabel.text                     = "DESCRIPTION".localize
        attachmentNameTextField.delegate                    = self
        attachmentDescriptionTextField.delegate             = self
    }
    
    @IBAction private func deleteAttachmentPressed(sender: UIButton) {
        tapDeleteAttachment?()
    }
    
    func configureAttachment(name: String?, description: String?) {
        attachmentNameTextField.text         = name
        attachmentDescriptionTextField.text  = description
    }
    
    func disableEditing() {
        attachmentDeleteButton.isHidden = true
        attachmentDescriptionTextField.isUserInteractionEnabled = false
    }
}

extension AttachmentItemCell: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == attachmentNameTextField {
            if let text = textField.text, !text.isEmpty {
                tapAttachment?()
            }
            return false
        }
        else {
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateAttachment?(textField.text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
