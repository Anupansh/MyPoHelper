//
//  EditTimeSheetVC.swift
//  MyProHelper
//
//  Created by Anupansh on 24/03/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit

class EditTimeSheetVC: UIViewController {

    // MARK: - OUTLETS AND VARIABLES
    @IBOutlet weak var tableview: UITableView! {
        didSet {
            tableview.delegate = self
            tableview.dataSource = self
            tableview.separatorStyle = .none
        }
    }
    var timeSheet = CurrentTimeSheetModel()
    var tfData = [TextFieldCellData]()
    var workerNameArray = [String]()
    var workerModel = [Worker]()
    var workerId : Int?
    var workerName : String?
    var viewOnly = false
    var passDataClosure : ((CurrentTimeSheetModel) -> ())?
    var isAddPerformed = false
    var isSaveClicked:Bool = false
    
    // MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    // MARK: - NAVIGATION ITEMS
    @objc func backBtnPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func savePressed() {
//<<<<<<< HEAD
//        if timeSheet.workerId == nil {
//            CommonController.shared.showSnackBar(message: Constants.Message.SELECT_WORKER, view: self)
//        }
//        else if timeSheet.dateWorked == nil {
//            CommonController.shared.showSnackBar(message: Constants.Message.WORKED_DATE, view: self)
//        }
//        else {
//            passDataClosure!(timeSheet)
//            self.navigationController?.popViewController(animated: true)
//        }
//=======
        isSaveClicked = true
        if isValidData(){
            passDataClosure!(timeSheet)
            self.navigationController?.popViewController(animated: true)
        }
        else{
            reloadTable()
        }
//>>>>>>> vinson-dev
    }
    
    
    // MARK: - HELPER FUNCTIONS
    func initialSetup() {
        title = "Edit Time Sheet"
        self.navigationController?.isNavigationBarHidden = false
        let backBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .done, target: self, action: #selector(backBtnPressed))
        let saveBtn = UIBarButtonItem(title: "Save".localize, style: .done, target: self, action: #selector(savePressed))
        self.navigationItem.leftBarButtonItem = backBtn
        self.navigationItem.rightBarButtonItems = !viewOnly ? [saveBtn] : []
        self.setPayrolCondition()
        self.getWorkerList()
        generateTfData()
        tableview.registerMultiple(nibs: [TextViewCell.className,ToFromDatePickerCell.className,TextFieldCell.className,DropDownCell.className])
    }
    
    func getWorkerList() {
        if (timeSheet.timeCardId == nil){
            let workerID = UserDefaults.standard.value(forKey: UserDefaultKeys.userId) as? String ?? ""
            self.workerId = Int(workerID) ?? nil
        }
        DBHelper.getWorkerList(workerId: self.workerId) { [weak self] (workerArray, nameArray, name) -> ()? in
//        CommonController.shared.getWorkerList(workerId: self.workerId) { [weak self] (workerArray, nameArray, name) -> ()? in
            self?.workerModel = workerArray
            self?.workerNameArray = nameArray
            self?.workerName = name
            if (self?.timeSheet.timeCardId == nil){
                self?.timeSheet.workerName = name
                self?.timeSheet.workerId = self?.workerId
            }
            return nil
        }
        tableview.reloadData()
    }
    
    func setPayrolCondition() {
        if isAddPerformed {
//            if !AppLocals.workerRole.role.canRunPayroll! {
                timeSheet.workerId = AppLocals.worker.workerID!
                timeSheet.workerName = AppLocals.worker.fullName
                isAddPerformed = false
//            }
        }
    }
    
    func generateTfData() {
        let approvedBy = DBHelper.getApprovedBy(value: String(timeSheet.approvedBy ?? 0), tableName: RepositoryConstants.Tables.CURRENT_TIME_SHEETS, columnName: RepositoryConstants.Columns.TIME_CARD_ID)
        tfData.append(TextFieldCellData(title: "WORKED_DATE".localize,
                                        key: "WORKED_DATE".localize,
                                        dataType: (timeSheet.timeCardId == nil) ? .Date:.Text,
                                        isRequired: false,
                                        isActive: (timeSheet.timeCardId == nil),//false,
                                        keyboardType: .default,
                                        validation: ValidationResult.Valid,
                                        text: DateManager.standardDateToStringWithoutHours(date: timeSheet.dateWorked),
                                        listData: []))
        tfData.append(TextFieldCellData(title: "APPROVED_BY".localize,
                                        key: "APPROVED_BY".localize,
                                        dataType: .Text,
                                        isRequired: false,
                                        isActive: false,
                                        keyboardType: .default,
                                        validation: ValidationResult.Valid,
                                        text: approvedBy,
                                        listData: []))
        tfData.append(TextFieldCellData(title: "APPRROVED_DATE".localize,
                                        key: "APPRROVED_DATE".localize,
                                        dataType: .Date,
                                        isRequired: false,
                                        isActive: false,
                                        keyboardType: .default,
                                        validation: ValidationResult.Valid,
                                        text: DateManager.dateToString(date: timeSheet.approvedDate),
                                        listData: []))
    }
    
    func updateWorkedDateField(){
        tfData[0] = TextFieldCellData(title: "WORKED_DATE".localize,
                                        key: "WORKED_DATE".localize,
                                        dataType: (timeSheet.timeCardId == nil) ? .Date:.Text,
                                        isRequired: false,
                                        isActive: (timeSheet.timeCardId == nil),//false,
                                        keyboardType: .default,
                                        validation: ValidationResult.Valid,
                                        text: DateManager.standardDateToStringWithoutHours(date: timeSheet.dateWorked),
                                        listData: [])
    }
    
    
    func reloadTable(){
        tableview.reloadData()
    }
    
    func isValidData() -> Bool {
        return  //validateCustomer()          == .Valid &&
                validateWorker()            == .Valid &&
                validateDescription()       == .Valid
    }
    
    func validateWorker() -> ValidationResult {
        if timeSheet.timeCardId == nil && timeSheet.workerName == nil{
            return .Invalid(message: Constants.Message.NAME_SELECT_ERROR)
        }
        
        if let workerName = timeSheet.workerName , timeSheet.timeCardId == nil{
            if workerName == Constants.DefaultValue.SELECT_LIST  || workerName.isEmpty{

                return .Invalid(message: Constants.Message.NAME_SELECT_ERROR)
            }
            return .Valid
        }
        if let workerName = timeSheet.workerName{
            if workerName == Constants.DefaultValue.SELECT_LIST || workerName.isEmpty{

                return .Invalid(message: Constants.Message.NAME_SELECT_ERROR)
            }
            return .Valid
        }
        
        return .Valid
    }
    
    func validateDescription() -> ValidationResult {
        guard let description = timeSheet.description, !description.isEmpty else {
            return .Valid
        }
        return Validator.validateName(name: description)
    }
    
    func getDescription() -> String? {
        return timeSheet.description
    }
    
    func getWorker() -> String? {
        return self.timeSheet.workerName ?? ""//self.workerName ?? ""
    }
    
    func setDescription(description: String?) {
        timeSheet.description = description
    }
}

// MARK: - TABLEVIEW DELEGATES AND DATASOURCES
extension EditTimeSheetVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return dropdownCell(indexpath: indexPath)
        case 1,2,3:
            return textfeildCell(indexpath: indexPath)
        case 4:
            return textViewCell(indexpath: indexPath)
        case 5,6,7:
            return tofromDateCell(indexpath: indexPath)
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: - DEQUEUE REUSABLE CELLS
    func dropdownCell(indexpath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: DropDownCell.className) as! DropDownCell
        let isCanRunPayroll = AppLocals.workerRole.role.canRunPayroll!
//        let workerID = UserDefaults.standard.value(forKey: UserDefaultKeys.userId) as? String
//        if let workerID = workerID, !workerID.isEmpty{
//            isCanRunPayroll = CommonController.shared.getCanRunPayroll(workerId:workerID)
//        }
        cell.bindTextField(data: TextFieldCellData .init(title: "Worker Name",
                                                         key: "Worker Name",
                                                         dataType: .Text,
                                                         isRequired: true,
                                                         isActive: (timeSheet.timeCardId == nil) && isCanRunPayroll,
                                                         validation: validateWorker(),
                                                         text: getWorker(),
                                                         listData: workerNameArray))
//        if let workerName = workerName {
//            cell.dropdownTextLbl.text = workerName
//        }
//        cell.titleLbl.text = "Worker Name"
        cell.generateDataSource(data: workerNameArray)
        cell.getDataClosure = { (value,index) in
            self.workerId = self.workerModel[index].workerID
            self.timeSheet.workerId = self.workerId ?? AppLocals.worker.workerID!//2
            self.timeSheet.workerName = self.workerNameArray[index]
            
        }
//        cell.dropdownTextLbl.text = timeSheet.workerName
        cell.isUserInteractionEnabled = !viewOnly
        
        
        cell.showValidation = isSaveClicked
        if isSaveClicked{
            cell.validateData()
        }
        return cell
    }
    
    func textfeildCell(indexpath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: TextFieldCell.className) as! TextFieldCell
        cell.bindTextField(data: tfData[indexpath.row - 1])
        cell.selectionStyle = .none
        cell.delegate = self
        cell.textField.backgroundColor =  (timeSheet.timeCardId == nil && indexpath.row - 1 == 0) ? .clear : .lightGray
        cell.isUserInteractionEnabled = !viewOnly
        return cell
    }
    
    func textViewCell(indexpath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: TextViewCell.className) as! TextViewCell
        cell.selectionStyle = .none
        
//        if let description = timeSheet.description {
//            cell.textView.text = description
//        }
        cell.bindTextView(data: TextFieldCellData(title: "Description",
                                                  key: "Description",
                                                  dataType: .Text,
                                                  isRequired: true,
                                                  isActive: !viewOnly,
                                                  validation: validateDescription(),
                                                  text: getDescription()))
        
        
        
        
        
        cell.requireSign.isHidden = true
        cell.getTextClosure = { text in
            self.timeSheet.description = text
            print(text)
        }
        cell.isUserInteractionEnabled = !viewOnly
        cell.showValidation = isSaveClicked
        if isSaveClicked{
            cell.validateData()
        }
        return cell
    }
    
    func tofromDateCell(indexpath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: ToFromDatePickerCell.className) as! ToFromDatePickerCell
        cell.changePickerMode(fromPickerMode: .time, toPickerMode: .time)
        switch indexpath.row {
        case 5:
            cell.startDateLbl.text = "Start Time"
            cell.endDateLbl.text = "End Time"
            cell.startDateTf.text = timeSheet.startTime
            cell.endDateTf.text = timeSheet.endTime
            cell.getDateClosure = { [weak self] (startTime,endTime) in
                if let startTime = startTime {
                    cell.startDateTf.text = startTime
                    self?.timeSheet.startTime = startTime
                }
                if let endTime = endTime {
                    cell.endDateTf.text = endTime
                    self?.timeSheet.endTime = endTime
                }
            }
        case 6:
            cell.startDateLbl.text = "Break Start"
            cell.endDateLbl.text = "Break End"
            cell.startDateTf.text = timeSheet.breakStart
            cell.endDateTf.text = timeSheet.breakStop
            cell.getDateClosure = { [weak self] (breakStart,breakEnd) in
                if let breakStart = breakStart {
                    cell.startDateTf.text = breakStart
                    self?.timeSheet.breakStart = breakStart
                }
                if let breakEnd = breakEnd {
                    cell.endDateTf.text = breakEnd
                    self?.timeSheet.breakStop = breakEnd
                }
            }
        default:
            cell.startDateLbl.text = "Lunch Start"
            cell.endDateLbl.text = "Lunch End"
            cell.startDateTf.text = timeSheet.lunchStart
            cell.endDateTf.text = timeSheet.lunchStop
            cell.getDateClosure = { [weak self] (lunchStart,lunchEnd) in
                if let lunchStart = lunchStart {
                    cell.startDateTf.text = lunchStart
                    self?.timeSheet.lunchStart = lunchStart
                }
                if let lunchEnd = lunchEnd {
                    cell.endDateTf.text = lunchEnd
                    self?.timeSheet.lunchStop = lunchEnd
                }
            }
        }
        cell.isUserInteractionEnabled = !viewOnly
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 87//100
        case 1,2,3:
            return 80
        case 4:
            return 100//130
        case 5,6,7:
            return 90//120
        default:
            return 80
        }
    }
}

// MARK: - TEXTFEILD DELEGATES
extension EditTimeSheetVC: TextFieldCellDelegate {
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        let key = data.key
        if key == "Worked Date" {
//            self.timeSheet.dateWorked = text ?? ""
            guard let date = text else { return }
            self.timeSheet.dateWorked = DateManager.stringToDate(string: date)
//            self.updateWorkedDateField()
//            self.reloadTable()
        }
        else if key == "Approved Date" {
//            self.timeSheet.approvedDate = text ?? ""
            guard let date = text else { return }
            self.timeSheet.approvedDate = DateManager.stringToDate(string: date)
        }
        else {
            let worker = workerModel.filter{$0.fullName == text}
            self.timeSheet.approvedBy = worker[0].workerID ?? 2
        }
    }

}
