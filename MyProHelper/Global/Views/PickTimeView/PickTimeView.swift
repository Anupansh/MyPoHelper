//
//  PickTimeView.swift
//  MyProHelper
//
//  Created by Samir on 12/24/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit

class PickTimeView: UIViewController, Storyboarded {

    @IBOutlet weak private var viewTitleLabel           : UILabel!
    @IBOutlet weak private var timeFrameTitleLabel      : UILabel!
    @IBOutlet weak private var timeFrameTextField       : UITextField!
    @IBOutlet weak private var scheduleButton           : UIButton!
    @IBOutlet weak private var closeButton              : UIButton!
    @IBOutlet weak private var backgroundViewContainer  : UIView!
    
    private var datePicker = UIDatePicker()
    
    var timeFrame: Box<String?> = Box(nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTapGesture()
        setupViewText()
        setupTextField()
        setupDatePicker()
//        setInitialDate()
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDismissView))
        backgroundViewContainer.addGestureRecognizer(tapGesture)
    }

    private func setupViewText() {
        viewTitleLabel.text         = "PICK_TIME_SCREEN_TITLE".localize
        timeFrameTitleLabel.text    = "PICK_TIME_TEXT_FIELD_TITLE".localize
        
        scheduleButton.setTitle("PICK_TIME_SCHEDULE_BUTTON".localize, for: .normal)
        closeButton.setTitle("PICK_TIME_CLOSE_BUTTON".localize, for: .normal)
    }
    
    private func setupTextField() {
        timeFrameTextField.tintColor    = .clear
        timeFrameTextField.delegate     = self
        timeFrameTextField.tintColor    = .clear
        timeFrameTextField.inputView    = datePicker
        timeFrameTextField.text         = "00:30:00"
    }
    
    func setInitialDate() {
        let jobDuration = DBHelper.getCompanyInformation().minimumJobDuration
        let date = Calendar.current.date(bySettingHour: 0, minute: Int(jobDuration)!, second: 0, of: Date())
        let duration = DateManager.timeFrameToString(date: date)
        timeFrameTextField.text = duration
    }
    
    private func setupDatePicker() {
        let screenWidth = UIScreen.main.bounds.width
        datePicker = UIDatePicker.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 200))
        datePicker.datePickerMode           = .countDownTimer
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        datePicker.minuteInterval           = 30
        timeFrameTextField.inputView = datePicker
        let toolbar = UIToolbar(frame: CGRect(x: 200, y: 0, width: screenWidth, height: 44))
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleChangeDate))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPressed))
        toolbar.setItems([cancelButton,spaceButton,doneBtn], animated: true)
        timeFrameTextField.inputAccessoryView = toolbar
    
    }
    
    @objc private func handleChangeDate() {
        if DateManager.timeFrameToString(date: datePicker.date) == "00:00:00" {
            timeFrameTextField.text = "00:30:00"
            self.view.endEditing(true)
            return
        }
        timeFrameTextField.text = DateManager.timeFrameToString(date: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelPressed() {
        self.view.endEditing(true)
    }
    
    @objc private func handleDismissView() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func scheduleButtonPressed(sender: UIButton) {
        dismiss(animated: false, completion: { [weak self] in
            guard let self = self else { return }
            self.timeFrame.value = self.timeFrameTextField.text
        })
    }
    
    @IBAction private func closeButtonPressed(sender: UIButton) {
        handleDismissView()
    }
}

extension PickTimeView: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
}
