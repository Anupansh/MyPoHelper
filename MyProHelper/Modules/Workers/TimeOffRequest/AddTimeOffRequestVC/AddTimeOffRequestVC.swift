//
//  AddTimeOffRequestVC.swift
//  MyProHelper
//
//  Created by Anupansh on 16/03/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit
import GRDB

class AddTimeOffRequestVC: UIViewController {

    //MARK: - OUTLETS AND VARIABLES
    @IBOutlet weak var tabelview: UITableView! {
        didSet {
            tabelview.delegate = self
            tabelview.dataSource = self
            tabelview.separatorStyle = .none
        }
    }
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    var typeOfLeave : String?
    var startDate : String?
    var endDate : String?
    var desc : String?
    var status = "Requested"
    var remarks = ""
    var workerId : Int?
    var workerName : String?
    var isEditable = true
    var toShowRemarks = true
    var toShowWorkerDropdown = false
    var viewOnlyMode = false
    var passDataClosure : ((Int,String,String,String,String,String,String) -> ())?
    var workerNameArray = [String]()
    var workerModel = [Worker]()
    var leaveArray = [String]()
    
    //MARK: VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    //MARK: IBACTIONS
    @IBAction func saveBtnPressed(_ sender: Any) {
        guard let workerId = workerId else {
            CommonController.shared.showSnackBar(message: "Please select a worker", view: self)
            return
        }
        guard let leave = typeOfLeave else {
            CommonController.shared.showSnackBar(message: "Please select type of leave.", view: self)
            return
        }
        guard let startDate = startDate else {
            CommonController.shared.showSnackBar(message: "Please select starting date for leave.", view: self)
            return
        }
        guard let endDate = endDate else {
            CommonController.shared.showSnackBar(message: "Please select end date for leave.", view: self)
            return
        }
        passDataClosure!(workerId,startDate,endDate,leave,status,desc ?? "",remarks)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func getWorkerList() {
        DBHelper.getWorkerList(workerId: self.workerId) { [weak self] (workerArray, nameArray, name) -> ()? in
            self?.workerModel = workerArray
            self?.workerNameArray = nameArray
            self?.workerName = name
            tabelview.reloadData()
            return nil
        }
    }
    
    func initialSetup() {
        self.getWorkerList()
        self.getLeaveArray()
        if isEditable {
            tabelview.isUserInteractionEnabled = true
        }
        else {
            tabelview.isUserInteractionEnabled = false
            saveBtn.isHidden = true
            cancelBtn.setTitle("Dismiss".localize, for: .normal)
        }
        if status == "Requested" {
            toShowRemarks = false
        }
        else {
            toShowRemarks = true
            isEditable = false
        }
        tabelview.registerMultiple(nibs: [ToFromDatePickerCell.className,TextViewCell.className,DropDownCell.className])
    }
    
    func getLeaveArray() {
        leaveArray = ["Voting","Jury Duty","Military"]
        if AppLocals.workerRole.role.canRequestSick! {
            leaveArray.append("Sick")
        }
        if AppLocals.workerRole.role.canRequestPersonalTime! {
            leaveArray.append("Personal")
        }
        if AppLocals.workerRole.role.canRequestVacation! {
            leaveArray.append("Vacation")
        }
    }
    
}


// MARK: - TABEVIEW DELEGATES AND DATASOURCES
extension AddTimeOffRequestVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tabelview.dequeueReusableCell(withIdentifier: DropDownCell.className) as! DropDownCell
            if AppLocals.workerRole.role.canAddWorkers! {
                if workerId == nil {
                    cell.dropdownView.isUserInteractionEnabled = true
                    cell.dropdownTextLbl.text = "Select Worker"
                }
                else {
                    cell.dropdownView.isUserInteractionEnabled = false
                    cell.dropdownTextLbl.text = workerName
                }
            }
            else {
                cell.dropdownView.isUserInteractionEnabled = false
                cell.dropdownTextLbl.text = AppLocals.worker.fullName           /* To edit after login flow*/
//                self.workerName = AppLocals.worker.fullName
//                self.workerId = AppLocals.worker.workerID
            }
//            if workerName! == "" {
//                cell.dropdownTextLbl.text = "Mary Smith"            /* To edit after login flow*/
//                self.workerName = "Mary Smith"
//                self.workerId = 2
//            }
//            else {
//                cell.dropdownTextLbl.text = workerName!
//            }
//            cell.dropdownView.isUserInteractionEnabled = false
            cell.titleLbl.text = "Worker Name"
            cell.generateDataSource(data: workerNameArray)
            cell.getDataClosure = { (value,index) in
                self.workerId = self.workerModel[index].workerID
                self.workerName = self.workerModel[index].fullName
            }
            return cell
        }
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ToFromDatePickerCell.className) as! ToFromDatePickerCell
            cell.changePickerMode(fromPickerMode: .date, toPickerMode: .date)
            if let startDate = self.startDate {
                cell.startDateTf.text = startDate
            }
            if let endDate = self.endDate {
                cell.endDateTf.text = endDate
            }
            cell.getDateClosure = { [weak self] (fromDate,toDate) in
                if let tempFromDate = fromDate {
                    self?.startDate = tempFromDate
                    print(tempFromDate)
                }
                if let tempToDate = toDate {
                    self?.endDate = tempToDate
                    print(tempToDate)
                }
            }
            return cell
        }
        else if indexPath.row == 2 {
            let cell = tabelview.dequeueReusableCell(withIdentifier: DropDownCell.className) as! DropDownCell
            if let leave = typeOfLeave {
                cell.dropdownTextLbl.text = leave
            }
            cell.generateDataSource(data: leaveArray)
            cell.getDataClosure = { [weak self] (value,index) in
                self?.typeOfLeave = value
                print(value)
            }
            return cell
        }
        else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: TextViewCell.className) as! TextViewCell
            cell.selectionStyle = .none
            if let description = desc {
                cell.textView.text = description
            }
            cell.requireSign.isHidden = true
            cell.getTextClosure = { [weak self]  text in
                self?.desc = text
                print(text)
            }
            return cell
        }
        else if indexPath.row == 4 {
            let cell = tabelview.dequeueReusableCell(withIdentifier: DropDownCell.className) as! DropDownCell
            cell.titleLbl.text = "Leave Status"
            cell.dropdownTextLbl.text = status
            cell.isUserInteractionEnabled = false
            cell.generateDataSource(data: ["Requested","Approved","Rejected"])
            cell.getDataClosure = { [weak self] (value,index) in
                self?.status = value
                if value == "Requested" {
                    self?.toShowRemarks = false
                }
                else {
                    self?.toShowRemarks = true
                }
                self?.tabelview.reloadData()
                print(value)
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TextViewCell.className) as! TextViewCell
            cell.selectionStyle = .none
            cell.titleLabel.text = "Remarks"
            cell.textView.text = remarks
            cell.requireSign.isHidden = true
            cell.getTextClosure = { [weak self]  text in
                self?.remarks = text
                print(text)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 5,!toShowRemarks {
            return 0
        }
        return 100
    }
    
}
