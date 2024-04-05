//
//  RevisitJobVC.swift
//  MyProHelper
//
//  Created by Anupansh on 10/05/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit
import GRDB

class RevisitJobVC: UIViewController {
    
     enum DataFields: String {
        case jobTitle = "Job Title"
        case customerName = "Customer Name"
        case jobDescription = "Job Description"
        case useDiffentAddress = "Use Different Address"
        case state = "State"
        case city = "City"
        case zip = "Zip"
        case address1 = "Address 1"
        case address2 = "Address 2"
        case scheduleJob = "Click Here to Schedule Job"
        case workerName = "Worker Name"
        case startTime = "Start Time"
        case endTime = "End Time"
        case jobDuration = "Job Duration"
    }

    @IBOutlet weak var tableview: UITableView! {
        didSet {
            tableview.delegate = self
            tableview.dataSource = self
            tableview.separatorStyle = .none
        }
    }
    
    var job = Job()
    var tempJob = Job()
    var useDifferentAddress = false
    let viewModel = CreateJobViewModel(attachmentSource: .SCHEDULED_JOB)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    @objc func backBtnPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func saveBtnPressed() {
        if useDifferentAddress {
            if tempJob.jobLocationAddress1 == "" || tempJob.jobLocationState == "" || tempJob.jobLocationCity == "" || tempJob.jobLocationZip == "" {
                CommonController.shared.showSnackBar(message: Constants.Message.ADDRESS_FIELDS_MANDATORY, view: self)
                return
            }
            else {
                job.jobLocationAddress1 = tempJob.jobLocationAddress1
                job.jobLocationAddress2 = tempJob.jobLocationAddress2
                job.jobLocationState = tempJob.jobLocationState
                job.jobLocationCity = tempJob.jobLocationCity
                job.jobLocationZip = tempJob.jobLocationZip
                self.executeRevisitQuery()
            }
        }
        else {
            if job.jobDescription == "" {
                CommonController.shared.showSnackBar(message: Constants.Message.DESCRIPTION_ERROR, view: self)
            }
            else if job.startDateTime == nil {
                CommonController.shared.showSnackBar(message: Constants.Message.JOB_START_TIME_ERROR, view: self)
                return
            }
            else if job.endDateTime == nil {
                CommonController.shared.showSnackBar(message: Constants.Message.JOB_END_TIME_ERROR, view: self)
                return
            }
            else if job.startDateTime! >= job.endDateTime! {
                CommonController.shared.showSnackBar(message: Constants.Message.END_DATE_LESS, view: self)
            }
            else {
                self.executeRevisitQuery()
            }
        }
    }
    
    func initialSetup() {
        title = "Revisit Job"
        self.navigationController?.isNavigationBarHidden = false
        let backBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .done, target: self, action: #selector(backBtnPressed))
        let saveBtn = UIBarButtonItem.init(barButtonSystemItem: .save, target: self, action: #selector(saveBtnPressed))
        self.navigationItem.leftBarButtonItem = backBtn
        self.navigationItem.rightBarButtonItem = saveBtn
        job.startDateTime = nil
        job.endDateTime = nil
        viewModel.fetchWorkers {}
        tableview.registerMultiple(nibs: [LabelCell.className,TextViewCell.className,TextFieldCell.className,ToFromDatePickerCell.className,CheckboxCell.className,ButtonCell.className])
    }
    
    func executeRevisitQuery() {
        let arguments : StatementArguments = [
            "customerId" : job.customerID,
            "address1" : job.jobLocationAddress1,
            "address2" : job.jobLocationAddress2,
            "state" : job.jobLocationState,
            "city" : job.jobLocationCity,
            "zip" : job.jobLocationZip,
            "name" : job.jobContactPersonName,
            "phone" : job.jobContactPhone,
            "email" : job.jobContactEmail,
            "shortDescription" : job.jobShortDescription,
            "longDescription"    : job.jobDescription,
            "startTime" : DateManager.dateToString(date: job.startDateTime),
            "endTime" : DateManager.dateToString(date: job.endDateTime),
            "duration" : job.estimateTimeDuration,
            "worker" : job.workerScheduled,
            "status" : "Scheduled",
            "previous" : job.jobID,
            "next" : 0,
            "sample" : 0,
            "removed" : 0,
            "removedDate" : "1900-01-01 00:00:00",
            "attachment"    : 0,
            "rejected"    : 0,
            "rejectedReason"    : "",
        ]
        let sql = """
            INSERT INTO chg.\(RepositoryConstants.Tables.SCHEDULED_JOBS) (
                \(RepositoryConstants.Columns.CUSTOMER_ID),
                \(RepositoryConstants.Columns.JOB_LOCATION_ADDRESS_1),
                \(RepositoryConstants.Columns.JOB_LOCATION_ADDRESS_2),
                \(RepositoryConstants.Columns.JOB_LOCATION_STATE),
                \(RepositoryConstants.Columns.JOB_LOCATION_CITY),
                \(RepositoryConstants.Columns.JobLocationZIP),
                \(RepositoryConstants.Columns.JOB_CONTACT_PERSON_NAME),
                \(RepositoryConstants.Columns.JOB_CONTACT_PHONE),
                \(RepositoryConstants.Columns.JOB_CONTACT_EMAIL),
                \(RepositoryConstants.Columns.JOB_SHORT_DESCRIPTION),
                \(RepositoryConstants.Columns.JOB_DESCRIPTION),
                \(RepositoryConstants.Columns.START_DATE_TIME),
                \(RepositoryConstants.Columns.END_DATE_TIME),
                \(RepositoryConstants.Columns.ESTIMATED_TIME_DURATION),
                \(RepositoryConstants.Columns.WORKER_SCHEDULED),
                \(RepositoryConstants.Columns.JOB_STATUS),
                \(RepositoryConstants.Columns.PREVIOUS_VISIT_ON_THIS_JOB),
                \(RepositoryConstants.Columns.NEXT_VISIT_ON_THIS_JOB),
                \(RepositoryConstants.Columns.SAMPLE_SCHEDULED_JOB),
                \(RepositoryConstants.Columns.REMOVED),
                \(RepositoryConstants.Columns.REMOVED_DATE),
                \(RepositoryConstants.Columns.NUMBER_OF_ATTACHMENTS),
                \(RepositoryConstants.Columns.REJECTED),
                \(RepositoryConstants.Columns.REJECTED_REASON)
            )
            VALUES (
                :customerId,
                :address1,
                :address2,
                :state,
                :city,
                :zip,
                :name,
                :phone,
                :email,
                :shortDescription,
                :longDescription,
                :startTime,
                :endTime,
                :duration,
                :worker,
                :status,
                :previous,
                :next,
                :sample,
                :removed,
                :removedDate,
                :attachment,
                :rejected,
                :rejectedReason
            )
        """
        AppDatabase.shared.executeSQL(sql: sql, arguments: arguments,typeOfAction: .insert, updatedId: nil) { (id) in
//            self.changeChangeNextVisit(jobID: id)
            NotificationCenter.default.addObserver(self, selector: #selector(self.changeNextVisit), name: .serverChanges, object: nil)
        } fail: { (error) in
            print(error)
        }
        
    }
    
    @objc func changeNextVisit() {
        let maxScheduleJob = DBHelper.getMaxRowId(columnName: RepositoryConstants.Columns.JOB_ID, tablename: RepositoryConstants.Tables.SCHEDULED_JOBS)
        if job.nextVisitJobId! != maxScheduleJob {
            let arguments : StatementArguments = [
                "jobID" : maxScheduleJob
            ]
            let sql = """
                UPDATE \(RepositoryConstants.Tables.SCHEDULED_JOBS) SET
                    \(RepositoryConstants.Columns.NEXT_VISIT_ON_THIS_JOB)         =  :jobID
                WHERE \(RepositoryConstants.Tables.SCHEDULED_JOBS).\(RepositoryConstants.Columns.JOB_ID)  =   \(job.jobID!)
            """
            AppDatabase.shared.executeSQL(sql: sql, arguments: arguments,typeOfAction: .update, updatedId: UInt64(maxScheduleJob)) { (id) in
                for controller in (self.navigationController?.viewControllers ?? []) as Array {
                    if controller.isKind(of: DashboardViewController.self) {
                        self.navigationController?.popToViewController(controller, animated: true)
                        self.job.nextVisitJobId = Int64(maxScheduleJob)
                    }
                }
            } fail: { (error) in
                print(error.localizedDescription)
            }

        }
    }
    
    // MARK: - OPEN SCHEDULE JOB
    func openScheduleJob() {
        let scheduleJob = ScheduleJobView.instantiate(storyboard: .SCHEDULE_JOB)
        scheduleJob.scheduleJobViewModel.scheduleJobModel.bind { [weak self] (scheduleJob) in
            guard let self = self else { return }
            guard let worker = scheduleJob.worker else { return }
            self.job.workerScheduled = worker.workerID
            self.job.worker = worker
            self.job.startDateTime = scheduleJob.startTime
            self.job.endDateTime = scheduleJob.endTime
            self.job.estimateTimeDuration = scheduleJob.duration
            self.tableview.reloadData()
        }
        navigationController?.pushViewController(scheduleJob, animated: true)
    }

}

extension RevisitJobVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 13
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0,1:
            return labelCell(indexpath: indexPath)
        case 2:
            return textViewCell(indexpath: indexPath)
        case 3:
            return checkboxCell(indexpath: indexPath)
        case 9:
            return buttonCell(indexpath: indexPath)
        case 11:
            return toFromDateCell(indexpath: indexPath)
        default:
            return textfeildCell(indexpath: indexPath)
        }
    }
    
    func labelCell(indexpath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: LabelCell.className) as! LabelCell
        if indexpath.row == 0 {
            cell.titleLbl.text = "\(DataFields.jobTitle.rawValue): \(job.jobShortDescription ?? "")"
            cell.titleLbl.font = UIFont.boldSystemFont(ofSize: 18)
        }
        else {
            cell.titleLbl.text = "\(DataFields.customerName.rawValue): \(job.customer?.customerName ?? "")"
            cell.titleLbl.font = UIFont.systemFont(ofSize: 16)
        }
        return cell
    }
    
    func textViewCell(indexpath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: TextViewCell.className) as! TextViewCell
        cell.selectionStyle = .none
        cell.bindTextView(data: .init(title: DataFields.jobDescription.rawValue, key: DataFields.jobDescription.rawValue, dataType: .Text, isRequired: false, isActive: true, keyboardType: .default, validation: ValidationResult.Valid, text: self.job.jobDescription, listData: []))
        cell.delegate = self
        return cell
    }
    
    func buttonCell(indexpath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: ButtonCell.ID) as! ButtonCell
        cell.setButtonTitle(title: DataFields.scheduleJob.rawValue)
        if AppLocals.workerRole.role.canScheduleJobs! {
            cell.changeButtonState(isEnabled: true)
        }
        else {
            cell.changeButtonState(isEnabled: false)
        }
        cell.didClickButton = { [weak self] in
            guard let self = self else { return }
            self.openScheduleJob()
        }
        return cell
    }
    
    func checkboxCell(indexpath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: CheckboxCell.className) as! CheckboxCell
        cell.selectionStyle = .none
        cell.bindCell(data: [.init(key: DataFields.useDiffentAddress.rawValue, title: DataFields.useDiffentAddress.rawValue, value: useDifferentAddress)])
        cell.delegate = self
        return cell
    }
    
    func toFromDateCell(indexpath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: ToFromDatePickerCell.className) as! ToFromDatePickerCell
        if let startTime = job.startDateTime {
            if let endTime = job.endDateTime {
                cell.endDateTf.text = DateManager.timeToString(date: endTime)
            }
            cell.startDateTf.text = DateManager.timeToString(date: startTime)
        }
        cell.changePickerMode(fromPickerMode: .dateAndTime, toPickerMode: .dateAndTime)
        cell.getDateClosure = { [weak self] (startDate,endDate) in
            if let _ = startDate {
                self?.job.startDateTime = DateManager.stringToDate(string: startDate!)
                if self?.job.endDateTime != nil {
                    self?.tableview.reloadRows(at: [IndexPath.init(row: 12, section: 0)], with: .left)
                }
            }
            if let _ = endDate {
                self?.job.endDateTime = DateManager.stringToDate(string: endDate!)
                if self?.job.startDateTime != nil {
                    self?.tableview.reloadRows(at: [IndexPath.init(row: 12, section: 0)], with: .left)
                }
            }
        }
        return cell
    }
    
    func textfeildCell(indexpath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: TextFieldCell.className) as! TextFieldCell
        cell.selectionStyle = .none
        cell.vc = self
        cell.textField.autocapitalizationType = .sentences
        cell.listDelegate = self
        cell.showViewDelegate = self
        switch indexpath.row {
        case 4:
            cell.bindTextField(data: .init(title: DataFields.address1.rawValue, key: DataFields.address1.rawValue, dataType: .Autocomplete, isRequired: false, isActive: useDifferentAddress, keyboardType: .default, validation: ValidationResult.Valid, text: useDifferentAddress ?"":job.jobLocationAddress1, listData: []))
        case 5:
            cell.bindTextField(data: .init(title: DataFields.address2.rawValue, key: DataFields.address2.rawValue, dataType: .Autocomplete, isRequired: false, isActive: useDifferentAddress, keyboardType: .default, validation: ValidationResult.Valid, text: useDifferentAddress ?"":job.jobLocationAddress2, listData: []))
        case 6:
            cell.bindTextField(data: .init(title: DataFields.state.rawValue, key: DataFields.state.rawValue, dataType: .Text, isRequired: false, isActive: useDifferentAddress, keyboardType: .default, validation: ValidationResult.Valid, text: useDifferentAddress ?"":job.jobLocationState, listData: []))
        case 7:
            cell.bindTextField(data: .init(title: DataFields.city.rawValue, key: DataFields.city.rawValue, dataType: .Text, isRequired: false, isActive: useDifferentAddress, keyboardType: .default, validation: ValidationResult.Valid, text: useDifferentAddress ?"":job.jobLocationCity, listData: []))
        case 8:
            cell.bindTextField(data: .init(title: DataFields.zip.rawValue, key: DataFields.zip.rawValue, dataType: .Text, isRequired: false, isActive: useDifferentAddress, keyboardType: .numberPad, validation: ValidationResult.Valid, text: useDifferentAddress ?"":job.jobLocationZip, listData: []))
        case 10:
            let canScheduleJob = AppLocals.workerRole.role.canScheduleJobs!
            cell.showViewDelegate = self
            cell.bindTextField(data: .init(title: DataFields.workerName.rawValue, key: DataFields.workerName.rawValue, dataType: canScheduleJob ?.ListView:.Text, isRequired: false, isActive: canScheduleJob ?true:false, keyboardType: .default, validation: ValidationResult.Valid, text: job.worker!.fullName, listData: canScheduleJob ?viewModel.getWorkers():[]))
        default:
            var durationText = ""
            if let _ = job.startDateTime, let _ = job.endDateTime {
                durationText = DateManager.getDateDifference(startDate: job.startDateTime!, endDate: job.endDateTime!)
                job.estimateTimeDuration = durationText
            }
            cell.bindTextField(data: .init(title: DataFields.jobDuration.rawValue, key: DataFields.jobDuration.rawValue, dataType: .TimeFrame, isRequired: false, isActive: true, keyboardType: .default, validation: ValidationResult.Valid, text: durationText, listData: []))
        }
        cell.delegate = self
        return cell
    }
    
}

extension RevisitJobVC:TextFieldCellDelegate, UITextViewDelegate, CheckboxCellDelegate, TextFieldListDelegate, ShowViewDelegate {
    
    // MARK: - SHOW LISTVIEW DELEGATE
    func presentView(view: UIViewController, completion: @escaping () -> ()) {
        present(view, animated: true, completion: completion)
    }

    func showAlert(alert: UIAlertController, sourceView: UIView) {
        presentAlert(alert: alert, sourceView: sourceView)
    }

    func pushView(view: UIViewController) {
        navigationController?.pushViewController(view, animated: true)
    }
    
    // MARK: - TEXTFEILD LIST DELEGATE
    func willAddItem(data: TextFieldCellData) {
        openCreateWorker()
    }
    
    func didChooseItem(at row: Int?, data: TextFieldCellData) {
        let worker = viewModel.getWorker(atIndex: row!)
        job.workerScheduled = worker.workerID
        job.worker = worker
        tableview.reloadData()
    }
    
    // MARK: - TEXTFEILD CELL DELEGATE
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        if data.key == DataFields.address1.rawValue {
            tempJob.jobLocationAddress1 = text
        }
        if data.key == DataFields.address2.rawValue {
            tempJob.jobLocationAddress2 = text
        }
        if data.key == DataFields.state.rawValue {
            tempJob.jobLocationState = text
        }
        if data.key == DataFields.city.rawValue {
            tempJob.jobLocationCity = text
        }
        if data.key == DataFields.zip.rawValue {
            tempJob.jobLocationZip = text
        }
        if data.key == DataFields.jobDescription.rawValue {
            job.jobDescription = text
        }
        if data.key == DataFields.jobDuration.rawValue {
            if let startTime = job.startDateTime {
                let arr = text?.components(separatedBy: ":")
                var dateComponent = DateComponents()
                dateComponent.hour = Int(arr![0])
                dateComponent.minute = Int(arr![1])
                dateComponent.second = Int(arr![2])
                var calendar = Calendar.current
                calendar.timeZone = TimeZone(secondsFromGMT: 0)!
                let endDate = calendar.date(byAdding: dateComponent, to: startTime)
                job.endDateTime = endDate
            }
            job.estimateTimeDuration = text
            tableview.reloadData()
        }
    }
    
    // MARK: - RADIO BUTTON CELL DELEGATE
    func didChangeValue(with data: RadioButtonData, isSelected: Bool) {
        if isSelected {
            useDifferentAddress = true
        }
        else {
            useDifferentAddress = false
        }
        tableview.reloadRows(at: [.init(row: 4, section: 0),.init(row: 5, section: 0),.init(row: 6, section: 0),.init(row: 7, section: 0),.init(row: 8, section: 0)], with: .right)
    }
    
    // MARK: - CUSTOM METHOD
    func presentAlert(alert: UIAlertController, sourceView: UIView) {
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = sourceView
            popoverPresentationController.sourceRect = sourceView.bounds
            popoverPresentationController.permittedArrowDirections = [.any]
        }
        present(alert, animated: true, completion: nil)
    }
    
    func openCreateWorker() {
        let createWorker = CreateWorkerView.instantiate(storyboard: .WORKER)
        createWorker.setViewMode(isEditingEnabled: true)
        createWorker.createWorkerViewModel.worker.bind { [weak self] (worker) in
            guard let self = self else { return }
            self.job.workerScheduled = worker.workerID
            self.job.worker = worker
            self.tableview.reloadData()
        }
        navigationController?.pushViewController(createWorker, animated: true)
    }
    
}
