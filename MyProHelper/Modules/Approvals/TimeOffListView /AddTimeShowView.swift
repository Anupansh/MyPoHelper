//
//  AddTimeShowView.swift
//  MyProHelper
//
//  Created by Sarvesh on 07/04/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import UIKit

class AddTimeShowView: UIViewController,Storyboarded {
    @IBOutlet weak var TitleLabel       : UILabel!
    @IBOutlet weak var JobDeclineTextView: UITextView!
    @IBOutlet weak var startDateTxtField: UITextField!
    @IBOutlet weak var endDateTxtField: UITextField!
    @IBOutlet weak var leaveTypeTxtField: UITextField!
    @IBOutlet weak var leaveStatusTxtField: UITextField!
    @IBOutlet weak var DiscardButton: UIButton!
    @IBOutlet weak var SaveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var backgroundViewContainer: UIView!
    @IBOutlet weak var remarksStackView: UIStackView!
    @IBOutlet weak var workerTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var remarksTextField: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    var HeightConstraint: NSLayoutConstraint?
    var workername = String()
    var startdate = Date()
    var enddate = Date()
    var leavetype = String()
    var leavestatus = String()
    var descriptiontext = String()
    var remark = String()
    let service = WorkersService()
    
    let timeOffApprovalservice = TimeOffApprovalService()
    
    var activePickerView: Int = 0
    var leavePickerDataSource = ["Personal","Sick","Vacation","Voting","Jury Duty","Military"]
    var leaveStatusPickerDataSource = ["Approved","Requested","Rejected"]
    var workersPickerDataSource: [Worker] = []
    var selectedWorker: Worker!
    var worrrr = Approval.self
    let datePicker = UIDatePicker()
    var selectedDatePicker = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTapGesture()
        backgroundViewContainer.cornerRadius = 15
        // Do any additional setup after loading the view.
        
        self.remarksStackView.isHidden = true
        self.fetchWorker()
        startDatePicker.minimumDate = Date()
        endDatePicker.minimumDate = Date()
    }
    @objc func dueDateChanged(sender:UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        startDateTxtField.text = formatter.string(from: sender.date)//dobButton.setTitle(dateFormatter.string(from: sender.date), for: .normal)
    }
    
    @IBAction func startDateAction(sender: UIButton) -> Void
    {
        self.selectedDatePicker = 1
        
        self.showDatePicker()
        self.view.addSubview(datePicker)
    }
    
    @IBAction func endDateAction(sender: UIButton) -> Void
    {
        self.selectedDatePicker = 2
        
        self.showDatePicker()
    }
    
    func showDatePicker(){
        //Formate Date
        datePicker.datePickerMode = .date
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        if selectedDatePicker == 1
        {
            startDateTxtField.inputAccessoryView = toolbar
            startDateTxtField.inputView = datePicker
        }else if selectedDatePicker == 2
        {
            endDateTxtField.inputAccessoryView = toolbar
            endDateTxtField.inputView = datePicker
        }
        
    }
    
    @objc func donedatePicker(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if selectedDatePicker == 1
        {
            startDateTxtField.text = formatter.string(from: datePicker.date)
        }else if selectedDatePicker == 2
        {
            endDateTxtField.text = formatter.string(from: datePicker.date)
        }
        
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    private func fetchWorker() {
        service.fetchWorkers(showRemoved: false, key: nil, sortBy: nil, sortType: nil, offset: 0) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let workers):
                self.workersPickerDataSource = workers
            case .failure(let error):
                print("ERROR while Fetching Workers")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.workerTextField.text = workername
        self.leaveStatusTxtField.text = leavestatus
        self.leaveTypeTxtField.text = leavetype
        self.descriptionTextField.text = descriptiontext
        self.remarksTextField.text = remark
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDismissView))
        backgroundViewContainer.addGestureRecognizer(tapGesture)
    }
    @objc private func handleDismissView() {
        dismiss(animated: true, completion: nil)
        //self.viewModel.fetchMoreData()
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        handleDismissView()
    }
    @IBAction func leaveTypeAction(_sender :UIButton){
        activePickerView = 1
        let PickerVC = EditPickerViewController.instantiate(storyboard: .ADD_TIMEOFF)
        PickerVC.datasourse = leavePickerDataSource
        //   PickerVC.newpickerDelegate = self
        self.present(PickerVC, animated: true, completion: nil)
        
    }
    @IBAction func leaveStatusAction(_sender :UIButton){
        activePickerView = 2
        let PickerVC = EditPickerViewController.instantiate(storyboard: .ADD_TIMEOFF)
        PickerVC.datasourse = leaveStatusPickerDataSource
        //  PickerVC.newpickerDelegate = self
        self.present(PickerVC, animated: true, completion: nil)
    }
    @IBAction func workersNameAction(_sender :UIButton){
        activePickerView = 3
        let PickerVC = EditPickerViewController.instantiate(storyboard: .ADD_TIMEOFF)
        PickerVC.isWorkerData = true
        PickerVC.datasourse = workersPickerDataSource
        // PickerVC.newpickerDelegate = self
        self.present(PickerVC, animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_sender :UIButton){
        if (workerTextField.text == "") {
            print("name")
            // create the alert
            let alert = UIAlertController(title: "Worker Name", message: "Please fill the worker name", preferredStyle: UIAlertController.Style.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
        else if(leaveTypeTxtField.text == ""){
            print("leaveTypeTxtField")
            // create the alert
            let alert = UIAlertController(title: "Leave", message: "Please fill the leave", preferredStyle: UIAlertController.Style.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
        else if(leaveStatusTxtField.text == ""){
            print("leaveStatusTxtField")
            // create the alert
            let alert = UIAlertController(title: "Leave Status", message: "Please fill the leave status", preferredStyle: UIAlertController.Style.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
        else{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            var approvaldata = Approval()
            approvaldata.approvedby = AppLocals.worker.workerID
            approvaldata.approveddate = Date()
            approvaldata.workerID = selectedWorker.workerID
            approvaldata.workername = selectedWorker.fullName
            approvaldata.worker = selectedWorker
            approvaldata.startdate = startDateTxtField.text
            approvaldata.endDate = endDateTxtField.text
            approvaldata.typeofleave = leaveTypeTxtField.text
            approvaldata.status = leaveStatusTxtField.text
            approvaldata.description = descriptionTextField.text
            approvaldata.remark = remarksTextField.text
            approvaldata.requesteddate = Date()
            approvaldata.removed = false
            approvaldata.removedDate = Date()
            timeOffApprovalservice.createApproval(approvaldata, completion: { [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success(let workerId):
                    print("Sucess for worker id createApproval: \(workerId)")
                    //self.coddelegate.dummyFunction()
                    self.handleDismissView()
                case .failure(let error):
                    print("ERROR while Fetching Workers")
                }
            })
        }
    }
}
extension AddTimeShowView: PickerDelegate {
    func pickerCancel(selecteditem: Int) {
        
    }
    func pickerDone(selecteditem: Int) {
        if activePickerView == 1{
            let item = leavePickerDataSource[selecteditem]
            leaveTypeTxtField.text = String(format: "%@", item)
        }
        else if activePickerView == 2 {
            let item = leaveStatusPickerDataSource[selecteditem]
            if item == "Approved" ||  item == "Rejected"
            {
                self.remarksStackView.isHidden = false
                
            }else
            {
                self.remarksStackView.isHidden = true
            }
            leaveStatusTxtField.text = String(format: "%@", item)
        }
        else if activePickerView == 3 {
            let item = workersPickerDataSource[selecteditem]
            print("SELETED WORKER: \n \(item )\n\n")
            selectedWorker = item
            workerTextField.text = String(format: "%@", item.fullName!)
        }
    }
}
