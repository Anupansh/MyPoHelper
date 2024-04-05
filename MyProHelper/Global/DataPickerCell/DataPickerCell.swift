//
//  DataPickerCell.swift
//  MyProHelper
//
//  Created by Samir on 24/01/2021.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit

protocol PickerCellDelegate {
    func didPickItem(at index: Int, data: TextFieldCellData)
}

class DataPickerCell: BaseFormCell {

    static let ID = String(describing: DataPickerCell.self)

    @IBOutlet weak private var pickerTextField: AppTextField!
    private let pickerView = UIPickerView()

    var delegate: PickerCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupPickerView()
        setupTextField()
    }

    private func setupPickerView() {
        pickerView.delegate     = self
        pickerView.dataSource   = self

    }

    private func setupTextField() {
        pickerTextField.setInputView(view: pickerView)
        pickerTextField.setTrailingImage(image: nil)
        pickerTextField.delegate = self
    }

    private func setValidation(validation: ValidationResult) {
        guard showValidation else {
            pickerTextField.hideError()
            return
        }
        switch validation {
        case .Valid:
            pickerTextField.hideError()
        case .Invalid(let message):
            pickerTextField.showError(message: message)
        }
    }

    func bindCell(data: TextFieldCellData) {
        self.data = data
        pickerTextField.isRequired = data.isRequired
        pickerTextField.isEditingEnabled = data.isActive
        pickerTextField.setTitle(title: data.title)
        pickerTextField.setText(text: data.text)
        setValidation(validation: data.validation)
        pickerView.reloadAllComponents()
    }
}

// MARK: - CONFORMING TO TEXTFIELD DELEGATE
extension DataPickerCell: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let text = (data?.text != nil) ? data?.text : data?.listData.first
        pickerTextField.setText(text: text)
        return true
    }
}

// MARK:- CONFORMING TO PICKER VIEW DELEGATE
extension DataPickerCell: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let data = data else { return }
        data.text = data.listData[row]
        pickerTextField.setText(text: data.listData[row])
        delegate?.didPickItem(at: row, data: data)
    }
}

// MARK:- CONFROMING TO PICKER VIEW DATA SOURCE
extension DataPickerCell: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let data = data else { return 0 }
        return data.listData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let data = data else { return nil }
        return data.listData[row]
    }
}
