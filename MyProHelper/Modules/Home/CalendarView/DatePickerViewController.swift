//
//  DatePickerViewController.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 30/06/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit

protocol DateViewDelegate: AnyObject {
    func dateView(controller: DateView, didSelect date: Date?)
}

class DateView: UIViewController, Storyboarded {
    
    @IBOutlet weak private var datePicker       : UIDatePicker!
    @IBOutlet weak private var doneButton       : UIButton!
    @IBOutlet weak private var backgroundView   : UIView!
    
    weak var delegate: DateViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDoneButton()
        setupTapGesture()
    }
    
    private func setupTapGesture() {
        let tapGesure = UITapGestureRecognizer(target: self, action: #selector(handleCloseView))
        backgroundView.addGestureRecognizer(tapGesure)
    }
    
    private func setupDoneButton() {
        doneButton.setTitle("CHOOSE_DATE".localize, for: .normal)
    }
    
    @IBAction private func doneButtonPressed(sender: UIButton) {
        delegate?.dateView(controller: self, didSelect: datePicker.date)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleCloseView() {
        dismiss(animated: true, completion: nil)
    }
}
