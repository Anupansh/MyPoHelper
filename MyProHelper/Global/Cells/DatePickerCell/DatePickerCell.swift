//
//  DatePickerCell.swift
//  MyProHelper
//
//  Created by Samir on 25/01/2021.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit

protocol DatePickerCellDelegate {
    func didSelectDate(date: String?, date: TextFieldCellData)
}

class DatePickerCell: BaseFormCell {

    static let ID = String(describing: DatePickerCell.self)

    @IBOutlet weak private var dateTextField: AppTextField!
    private let datePicker = UIDatePicker()

    var delegate: DatePickerCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupTextField()
    }

    override func validateData() {
        guard let data = data else { return }
        setValidation(validation: data.validation)
    }

    private func setupTextField() {
        dateTextField.delegate = self
        dateTextField.clearButtonMode = .unlessEditing
        dateTextField.setInputView(view: datePicker)
    }

    private func setDatePick(with mode: UIDatePicker.Mode) {
        datePicker.addTarget(self, action: #selector(handleChooseDate), for: .valueChanged)
        datePicker.datePickerMode = mode
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        

    }

    @objc private func handleChooseDate() {
        guard let data = data else { return }
        let dateString = DateManager.getStandardDateString(date: datePicker.date)
        data.text = dateString
        if data.type == .Date {
            dateTextField.setText(text: DateManager.dateToString(date: datePicker.date))
        }
        else if data.type == .Time {
            dateTextField.setText(text: DateManager.timeToString(date: datePicker.date))
        }
        delegate?.didSelectDate(date: dateString, date: data)
        formCellDelegate?.didEndEditing(indexPath: indexPath)
    }

    private func setValidation(validation: ValidationResult) {
        guard showValidation else {
            dateTextField.hideError()
            return
        }
        switch validation {
        case .Valid:
            dateTextField.hideError()
        case .Invalid(let message):
            dateTextField.showError(message: message)
        }
    }

    private func clearDate() {
        guard let data = data else { return }
        data.text = nil
        dateTextField.setText(text: nil)
        delegate?.didSelectDate(date: nil, date: data)
    }

    func bindCell(data: TextFieldCellData) {
        self.data = data
        dateTextField.isRequired = data.isRequired
        dateTextField.isEditingEnabled = data.isActive
        dateTextField.setTitle(title: data.title)
        dateTextField.setText(text: data.text)

        if data.type == .Date {
//            dateTextField.setText(text: DateManager.dateToString(date: datePicker.date))
            setDatePick(with: .date)
        }
        else {
//            dateTextField.setText(text: DateManager.timeToString(date: datePicker.date))
            setDatePick(with: .time)
        }
    }
}

// MARK: - CONFORMING TO TEXTFIELD DELEGATE
extension DatePickerCell: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        handleChooseDate()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        handleChooseDate()
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        clearDate()
        return false
    }
}
