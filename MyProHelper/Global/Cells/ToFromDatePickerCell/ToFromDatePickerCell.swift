//
//  ToFromDatePickerCell.swift
//  MyProHelper
//
//  Created by Anupansh on 16/03/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit

class ToFromDatePickerCell: UITableViewCell {
    
    
    // MARK: - OUTLETS AND VARIABLES
    @IBOutlet weak var startDateTf: UITextField!
    @IBOutlet weak var endDateTf: UITextField!
    @IBOutlet weak var endDateLbl: UILabel!
    @IBOutlet weak var startDateLbl: UILabel!
    var toDatePicker = UIDatePicker()
    var fromDatePicker = UIDatePicker()
    var getDateClosure : ((String?,String?) -> ())?
    
    // MARK: - VIEW LIFECYCLE
    override func awakeFromNib() {
        super.awakeFromNib()
        setupToDatePicker()
        setupFromDatePicker()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - SETUP DATE PICKERS
    private func setupFromDatePicker() {
        let screenWidth = UIScreen.main.bounds.width
        fromDatePicker = UIDatePicker.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 200))
        fromDatePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {fromDatePicker.preferredDatePickerStyle = .wheels}
        startDateTf.inputView = fromDatePicker
        let toolbar = UIToolbar(frame: CGRect(x: 200, y: 0, width: screenWidth, height: 44))
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(fromDonePressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPressed))
        toolbar.setItems([cancelButton,spaceButton,doneBtn], animated: true)
        startDateTf.inputAccessoryView = toolbar
    }
    
    private func setupToDatePicker() {
        let screenWidth = UIScreen.main.bounds.width
        toDatePicker = UIDatePicker.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 200))
        toDatePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            toDatePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        
        endDateTf.inputView = toDatePicker
        let toolbar = UIToolbar(frame: CGRect(x: 200, y: 0, width: screenWidth, height: 44))
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(toDonePressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPressed))
        toolbar.setItems([cancelButton,spaceButton,doneBtn], animated: true)
        endDateTf.inputAccessoryView = toolbar
    }
    
    func changePickerMode(fromPickerMode: UIDatePicker.Mode, toPickerMode: UIDatePicker.Mode) {
        fromDatePicker.datePickerMode = fromPickerMode
        toDatePicker.datePickerMode = toPickerMode
    }
    
    @objc func fromDonePressed() {
        if fromDatePicker.datePickerMode == .time {
            startDateTf.text = DateManager.timeFrameToString(date: fromDatePicker.date)
            toDatePicker.minimumDate = fromDatePicker.date
            getDateClosure!(DateManager.timeFrameToString(date: fromDatePicker.date),nil)
        }
        else {
            startDateTf.text = DateManager.dateToString(date: fromDatePicker.date)
            toDatePicker.minimumDate = fromDatePicker.date
            getDateClosure!(DateManager.dateToString(date: fromDatePicker.date),nil)
        }
        endEditing(true)
    }
    
    @objc func toDonePressed() {
        if toDatePicker.datePickerMode == .time {
            endDateTf.text = DateManager.timeFrameToString(date: toDatePicker.date)
            getDateClosure!(nil,DateManager.timeFrameToString(date: toDatePicker.date))
        }
        else {
            endDateTf.text = DateManager.dateToString(date: toDatePicker.date)
            getDateClosure!(nil,DateManager.dateToString(date: toDatePicker.date))
        }
        fromDatePicker.maximumDate = toDatePicker.date
        endEditing(true)
    }
    
    @objc func cancelPressed() {
        endEditing(true)
    }
}
