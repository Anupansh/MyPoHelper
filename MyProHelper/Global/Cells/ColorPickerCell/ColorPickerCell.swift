//
//  ColorPickerCell.swift
//  MyProHelper
//
//  Created by Samir on 12/30/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit
import FlexColorPicker

protocol ColorPickerCellDelegate {
    func willChooseColor(colorPicker: UIViewController)
    func didChooseColor(color: String, key: String)
}

class ColorPickerCell: UITableViewCell {
    
    static let ID = String(describing: ColorPickerCell.self)
    
    @IBOutlet weak private var colorPickerTitleLabel    : UILabel!
    @IBOutlet weak private var colorPickerTextField     : UITextField!
    @IBOutlet weak private var contrastViewContainer    : UIView!
    @IBOutlet weak private var constrastImageView       : UIImageView!
    
    private var key: String?
    var delegate: ColorPickerCellDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTextFiled()
    }
    
    private func setupTextFiled() {
        colorPickerTextField.delegate = self
    }
    
    private func openColorPicker() {
        if #available(iOS 14.0, *) {
            openNativeColorPicker()
        }
        else {
            openFlexColorPicker()
        }
    }
    
    @available(iOS 14.0, *)
    private func openNativeColorPicker() {
        let colorPicker = UIColorPickerViewController()
        colorPicker.delegate = self
        delegate?.willChooseColor(colorPicker: colorPicker)
    }
    
    private func openFlexColorPicker() {
        let colorPicker = DefaultColorPickerViewController()
        colorPicker.delegate = self
        delegate?.willChooseColor(colorPicker: colorPicker)
    }
        
    func bindData(data: ColorPickerData) {
        colorPickerTitleLabel.text  = data.title
        colorPickerTextField.text   = data.value
        key                         = data.Key
        colorPickerTextField.isEnabled = data.isActive ?? true
        
        if let color = data.backgroundColor {
            contrastViewContainer.backgroundColor = UIColor(hex: color)
        }
        if let color = data.foregroundColor {
            constrastImageView.tintColor = UIColor(hex: color)
        }
    }
}

extension ColorPickerCell: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        openColorPicker()
        return false
    }
}

extension ColorPickerCell: UIColorPickerViewControllerDelegate {
    @available(iOS 14.0, *)
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        guard let color = viewController.selectedColor.toHex(alpha: true) else { return }
        guard let key = key else { return }
        delegate?.didChooseColor(color: color, key: key)
        colorPickerTextField.text = color
    }
}

extension ColorPickerCell: ColorPickerDelegate {
    func colorPicker(_ colorPicker: ColorPickerController, confirmedColor: UIColor, usingControl: ColorControl) {
        guard let color = confirmedColor.toHex(alpha: true) else { return }
        guard let key = key else { return }
        delegate?.didChooseColor(color: color, key: key)
        colorPickerTextField.text = color
    }
}
