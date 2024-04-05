//
//  AddTimeOffApprovalView.swift
//  MyProHelper
//
//  Created by Macbook pro on 16/03/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import UIKit
protocol ClassBDelegate {
    func dummyFunction()
    
}
class AddTimeOffApprovalView: UIViewController,Storyboarded,UITextFieldDelegate {
    var coddelegate: ClassBDelegate?
    
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
    var isFromBtnAction = ""
    let service = WorkersService()
    var workername = String()
    
    var leavetype = String()
    var leavestatus = String()
    var descriptiontext = String()
    var remark = String()
    var id = Int()
    let timeOffApprovalservice = TimeOffApprovalService()
    var timeOffReqID = 0
    var activePickerView: Int = 0
    var leavePickerDataSource = ["Personal","Sick","Vacation","Voting","Jury Duty","Military"]
    
    var leaveStatusPickerDataSource = ["Requested"]
    var workersPickerDataSource: [Worker] = []
    var selectedWorker: Worker!
    
    let datePicker = UIDatePicker()
    var selectedDatePicker = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startDateTxtField.delegate = self
        endDateTxtField.delegate = self
        setupTapGesture()
        backgroundViewContainer.cornerRadius = 15
        self.remarksStackView.isHidden = true
        self.fetchWorker()
        self.workerTextField.text = workername
        self.leaveTypeTxtField.text = leavetype
        self.descriptionTextField.text = descriptiontext
        self.remarksTextField.text = remark
        
    }
    @objc func dueDateChanged(sender:UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        startDateTxtField.text = formatter.string(from: sender.date)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == startDateTxtField  {
            self.selectedDatePicker = 1
            self.showDatePicker()
        }
        else if textField == endDateTxtField
            
            {
            self.selectedDatePicker = 2
            self.showDatePicker()
        }
        return true
    }
    private func setDatePick(with mode: UIDatePicker.Mode) {
            datePicker.addTarget(self, action: #selector(handleChooseDate), for: .valueChanged)
            datePicker.datePickerMode = mode
            if #available(iOS 13.4, *) {datePicker.preferredDatePickerStyle = .wheels}
            
        }
    
    @objc private func handleChooseDate() {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if selectedDatePicker == 1 // start
        {
            
            startDateTxtField.text = formatter.string(from: datePicker.date)
        }else if selectedDatePicker == 2
        {
            endDateTxtField.text = formatter.string(from: datePicker.date)
        }
        
        self.view.endEditing(true)
        
        
        
        }

    func showDatePicker(){
        //Formate Date
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {datePicker.preferredDatePickerStyle = .wheels}
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
           // startDateTxtField.accessibilityElements
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

    
    
//    @objc func donedatePicker(){
//
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        if selectedDatePicker == 1
//        {
//
//            startDateTxtField.text = formatter.string(from: datePicker.date)
//        }else if selectedDatePicker == 2
//        {
//            endDateTxtField.text = formatter.string(from: datePicker.date)
//        }
//
//        self.view.endEditing(true)
//    }
    
//    @objc func cancelDatePicker(){
//        self.view.endEditing(true)
//    }
    
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
        PickerVC.newpickerDelegate = self
        self.present(PickerVC, animated: true, completion: nil)
        
    }
    @IBAction func leaveStatusAction(_sender :UIButton){
        activePickerView = 2
        let PickerVC = EditPickerViewController.instantiate(storyboard: .ADD_TIMEOFF)
        PickerVC.datasourse = leaveStatusPickerDataSource
        PickerVC.newpickerDelegate = self
        self.present(PickerVC, animated: true, completion: nil)
    }
    @IBAction func workersNameAction(_sender :UIButton){
        activePickerView = 3
        let PickerVC = EditPickerViewController.instantiate(storyboard: .ADD_TIMEOFF)
        PickerVC.isWorkerData = true
        PickerVC.datasourse = workersPickerDataSource
        PickerVC.newpickerDelegate = self
        self.present(PickerVC, animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_sender :UIButton){
        if isFromBtnAction == "edit" {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            var approvaldata = Approval()
            approvaldata.approvedby = 0
            approvaldata.approveddate = Date()
            approvaldata.workername = workerTextField.text
            approvaldata.worker = selectedWorker
            approvaldata.startdate = startDateTxtField.text
            approvaldata.endDate = endDateTxtField.text
            approvaldata.typeofleave = leaveTypeTxtField.text
            approvaldata.status = leavestatus
            approvaldata.description = descriptionTextField.text
            approvaldata.remark = remarksTextField.text
            approvaldata.requesteddate = Date()
            approvaldata.removed = false
            approvaldata.TimeOffRequestsID = timeOffReqID
            approvaldata.removedDate = Date()
            timeOffApprovalservice.updateApproval(approvaldata, completion: { [weak self] (result) in
                guard let self = self else { return }
                
                switch result {
                case .success(_):
                   print("sucees while Fetching Workers")
                    self.coddelegate?.dummyFunction()
                    self.handleDismissView()
                    let alert = UIAlertController(title: "Leave", message: "ERROR while Fetching Workers", preferredStyle: UIAlertController.Style.alert)
                    
                case .failure( _):
                    self.handleDismissView()
                    print("ERROR while Fetching Workers")
                    let alert = UIAlertController(title: "Leave", message: "ERROR while Fetching Workers", preferredStyle: UIAlertController.Style.alert)
                }
//
            })
        }
        else{
            if (workerTextField.text == "") {
                //print("name")
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
            else{
                
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                var approvaldata = Approval()
                approvaldata.approvedby = 0
                approvaldata.approveddate = Date()
                approvaldata.workerID = selectedWorker.workerID
                approvaldata.workername = workerTextField.text
                approvaldata.worker = selectedWorker
                approvaldata.startdate = startDateTxtField.text
                approvaldata.endDate = endDateTxtField.text
                approvaldata.typeofleave = leaveTypeTxtField.text
                approvaldata.status = "Requested"
                approvaldata.description = descriptionTextField.text
                approvaldata.remark = remarksTextField.text
                approvaldata.requesteddate = Date()
                approvaldata.removed = false
                approvaldata.removedDate = Date()
                timeOffApprovalservice.createApproval(approvaldata, completion: { [weak self] (result) in
                    guard let self = self else { return }
                    
                    
                    switch result {
                    case .success(let Id):
                        print("Sucess for worker id createApproval: \(Id)")
                        self.coddelegate?.dummyFunction()
                        self.handleDismissView()
                    case .failure(let error):
                        print("ERROR while Fetching Workers")
                        let alert = UIAlertController(title: "Leave", message: "ERROR while Fetching Workers", preferredStyle: UIAlertController.Style.alert)
                    }
                
                    
                })
            }
        }

    }
}
extension AddTimeOffApprovalView: PickerDelegate {
    func pickerCancel(selecteditem: Int) {
        
    }
    func pickerDone(selecteditem: Int) {
        if activePickerView == 1{
            let item = leavePickerDataSource[selecteditem]
            leaveTypeTxtField.text = String(format: "%@", item)
        }
        
        else if activePickerView == 3 {
            let item = workersPickerDataSource[selecteditem]
            print("SELETED WORKER: \n \(item )\n\n")
            selectedWorker = item
            workerTextField.text = String(format: "%@", item.fullName!)
        }
    }
}
