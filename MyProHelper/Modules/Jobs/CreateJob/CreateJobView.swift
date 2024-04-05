//
//  CreateJobView.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/28/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit
import SideMenu
import DropDown

private enum JobSection: String, CaseIterable {
    case JOB_INFORMATION    = "JOB_INFORMATION"
    case CONTACT_DETAILS    = "CONTACT_DETAILS"
    case ASSINGMENT_DETAILS = "ASSINGMENT_DETAILS"
    case SCHEDULE_JOB       = "SCHEDULE_JOB"
    case ATTACHMENTS        = "ATTACHMENTS"
}

private enum JobFields: String {
    case JOB_TITLE              = "JOB_TITLE"
    case CHOOSE_CUSTOMER        = "CHOOSE_CUSTOMER"
    case ENTER_YOUR_ISSUE       = "ENTER_YOUR_ISSUE"
    case YOUR_NAME              = "YOUR_NAME"
    case YOUR_PHONE             = "YOUR_PHONE"
    case YOUR_EMAIL             = "YOUR_EMAIL"
    case ADDRESS_ONE            = "ADDRESS_ONE"
    case ADDRESS_TWO            = "ADDRESS_TWO"
    case CITY                   = "CITY"
    case STATE                  = "STATE"
    case ZIP                    = "ZIP"
    case WORKER_NAME            = "WORKER_NAME"
    case START_DATE_TIME        = "START_DATE_TIME"
    case END_DATE_TIME          = "END_DATE_TIME"
    case ESTIMATE_TIME_DURATION = "ESTIMATE_TIME_DURATION"
    case JOB_STATUS             = "JOB_STATUS"
    case CHOOSE_FILE            = "CHOOSE_FILE"
    case USE_DIFFERENT_ADDRESS  = "USE_DIFFERENT_ADDRESS"
    case SCHEDULE_JOB           = "SCHEDULE_JOB"
}

class CreateJobView: BaseCreateWithAttachmentView<CreateJobViewModel>, Storyboarded {
    
    private let sections: [JobSection] = [.JOB_INFORMATION,
                                          .CONTACT_DETAILS,
                                          .SCHEDULE_JOB,
                                          .ASSINGMENT_DETAILS,
                                          .ATTACHMENTS]
    var cameFromSideMenu = false
    var dropDown:DropDown = DropDown() //2
    var cameFromHome = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        fetchWorkers()
        fetchCustomers()
    }
    
    @objc func showSideMenu() {
        let sideMenuView = SideMenuView.instantiate(storyboard: .HOME)
        let menu = SideMenuNavigationController(rootViewController: sideMenuView)
        let screenWidth = UIScreen.main.bounds.width
        menu.leftSide = true
        menu.statusBarEndAlpha = 0
        menu.presentationStyle = .menuSlideIn
        menu.isNavigationBarHidden = true
        menu.menuWidth = (screenWidth > 400) ? 400 : screenWidth
        menu.sideMenuManager.addScreenEdgePanGesturesToPresent(toView: view)
        self.present(menu, animated: true, completion: nil)
    }
    
    func initialSetup() {
        viewModel.setJobStatus(status: "Waiting")
        viewModel.setInitialDuration()
        if cameFromSideMenu {
            let leftBarItem = UIBarButtonItem(image: #imageLiteral(resourceName: "menu"), style: .done, target: self, action: #selector(showSideMenu))
            self.navigationItem.leftBarButtonItem = leftBarItem
        }
        if cameFromHome {
            title = "Quick Schedule Job"
        }
        else {
            title = "Schedule A Job"
        }
        if !AppLocals.workerRole.role.canScheduleJobs! {
            viewModel.setWorker(with: AppLocals.worker)
        }
    }
    
    func bindCreateJob(scheduledJob: ScheduleJobModel) {
        viewModel.syncScheduleJob(scheduledJob: scheduledJob)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionType = sections[section]
        let fields = getFieldsForSection(at: sectionType)
        return fields.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if sections[section] == .SCHEDULE_JOB {
            let view = UIView()
            view.backgroundColor = .white
            return view
        }
        guard let header = tableView.dequeueReusableCell(withIdentifier: AppTableViewHeaderCell.ID) as? AppTableViewHeaderCell else {
            return nil
        }
        let sectionType = sections[section]
        header.setTitle(title: sectionType.rawValue.localize)
        return header
    }
    
    override func getCell(at indexPath: IndexPath) -> BaseFormCell {
        let sectionType = sections[indexPath.section]
        let fields = getFieldsForSection(at: sectionType)
        guard let field = JobFields(rawValue: fields[indexPath.row].key) else {
            return BaseFormCell()
        }
        
        if sections[indexPath.section] == .SCHEDULE_JOB {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ButtonCell.ID) as? ButtonCell else {
                return BaseFormCell()
            }
            
            cell.setButtonTitle(title: "Click Here to Schedule Job")
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
        
        if field == .CHOOSE_FILE {
            let attachmentsCell = instantiateAttachmentCell()
            attachmentsCell.setAttachmentTitle(title: "")
            return attachmentsCell
        }
        else if field == .ENTER_YOUR_ISSUE {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TextViewCell.ID) as? TextViewCell else {
                return BaseFormCell()
            }
            cell.bindTextView(data: fields[indexPath.row])
            cell.delegate = self
            return cell
        }
        else if field == .USE_DIFFERENT_ADDRESS {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CheckboxHeaderCell.ID) as? CheckboxHeaderCell else {
                return BaseFormCell()
            }
            
            cell.setTitle(title: field.rawValue.localize)
            cell.valueChanged = { [unowned self] isChecked in
                self.viewModel.setUseDifferentAddress(isDifferent: isChecked)
                self.tableView.reloadData()
            }
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.ID) as? TextFieldCell else {
            return BaseFormCell()
        }
        cell.bindTextField(data: fields[indexPath.row])
        cell.delegate = self
        cell.listDelegate = self
        return cell
    }
    
    override func handleAddItem() {
        super.handleAddItem()
        viewModel.saveJob { (error, isValidData) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let title = self.title ?? ""
                if let error = error {
                    GlobalFunction.showMessageAlert(fromView: self, title: title, message: error)
                }
                else if isValidData {
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func openCreateCustomer() {
        let createCustomerView = CreateCustomerView.instantiate(storyboard: .CUSTOMERS)
        createCustomerView.setViewMode(isEditingEnabled: true)
        createCustomerView.viewModel.customer.bind { [weak self] customer in
            guard let self = self else { return }
            self.viewModel.setCustomer(with: customer)
            self.tableView.reloadData()
        }
        navigationController?.pushViewController(createCustomerView, animated: false)
    }
    
    private func openCreateWorker() {
        let createWorker = CreateWorkerView.instantiate(storyboard: .WORKER)
        createWorker.setViewMode(isEditingEnabled: true)
        createWorker.createWorkerViewModel.worker.bind { [weak self] (worker) in
            guard let self = self else { return }
            self.viewModel.setWorker(with: worker)
            self.tableView.reloadData()
        }
        navigationController?.pushViewController(createWorker, animated: true)
    }
    
    private func openScheduleJob() {
        let scheduleJob = ScheduleJobView.instantiate(storyboard: .SCHEDULE_JOB)
        scheduleJob.scheduleJobViewModel.scheduleJobModel.bind { [weak self] (scheduleJob) in
            guard let self = self else { return }
            self.viewModel.syncScheduleJob(scheduledJob: scheduleJob)
            self.tableView.reloadData()
        }
        navigationController?.pushViewController(scheduleJob, animated: true)
    }
    
    private func fetchWorkers() {
        viewModel.fetchWorkers { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    private func fetchCustomers() {
        viewModel.fetchCustomers { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    private func getFieldsForSection(at section: JobSection) -> [TextFieldCellData] {
        switch section {
        case .JOB_INFORMATION:
            return [.init(title: JobFields.JOB_TITLE.rawValue.localize,
                          key: JobFields.JOB_TITLE.rawValue,
                          dataType: .Text,
                          isRequired: true,
                          isActive: isEditingEnabled,
                          keyboardType: .default,
                          validation: viewModel.validateJobTitle(),
                          text: viewModel.getJobTitle()),
                    
                    .init(title: JobFields.CHOOSE_CUSTOMER.rawValue.localize,
                          key: JobFields.CHOOSE_CUSTOMER.rawValue,
                          dataType: .ListView,
                          isRequired: true,
                          isActive: isEditingEnabled,
                          keyboardType: .default,
                          validation: viewModel.validateCustomer(),
                          text: viewModel.getCustomerName(),
                          listData: viewModel.getCustomers()),
                    
                    .init(title: JobFields.ENTER_YOUR_ISSUE.rawValue.localize,
                          key: JobFields.ENTER_YOUR_ISSUE.rawValue,
                          dataType: .Text,
                          isRequired: true,
                          isActive: isEditingEnabled,
                          keyboardType: .default,
                          validation: viewModel.validateIsssueDescription(),
                          text: viewModel.getIssueDescription())
            ]
        case .CONTACT_DETAILS:
            return [
                
                .init(title: JobFields.YOUR_NAME.rawValue.localize,
                          key: JobFields.YOUR_NAME.rawValue,
                          dataType: .Text,
                          isRequired: true,
                          isActive: isEditingEnabled,
                          keyboardType: .default,
                          validation: viewModel.validatePersonName(),
                          text: viewModel.getContactName()),
                    
                    .init(title: JobFields.YOUR_PHONE.rawValue.localize,
                          key: JobFields.YOUR_PHONE.rawValue,
                          dataType: .Mobile,
                          isRequired: true,
                          isActive: isEditingEnabled,
                          keyboardType: .asciiCapableNumberPad,
                          validation: viewModel.validatePersonPhone(),
                          text: viewModel.getContactPhone()),
                    
                    .init(title: JobFields.YOUR_EMAIL.rawValue.localize,
                          key: JobFields.YOUR_EMAIL.rawValue,
                          dataType: .Text,
                          isRequired: false,
                          isActive: isEditingEnabled,
                          keyboardType: .emailAddress,
                          validation: viewModel.validatePersonEmail(),
                          text: viewModel.getContactEmail()),
                
                    .init(title: JobFields.USE_DIFFERENT_ADDRESS.rawValue.localize,
                          key: JobFields.USE_DIFFERENT_ADDRESS.rawValue,
                          dataType: .Text,
                          validation: .Valid),
                    
                    .init(title: JobFields.ADDRESS_ONE.rawValue.localize,
                          key: JobFields.ADDRESS_ONE.rawValue,
                          dataType: .Text,
                          isRequired: true,
                          isActive: isEditingEnabled,
                          keyboardType: .default,
                          validation: viewModel.validateAddressOne(),
                          text: viewModel.getContactAddressOne()),
                    
                    .init(title: JobFields.ADDRESS_TWO.rawValue.localize,
                          key: JobFields.ADDRESS_TWO.rawValue,
                          dataType: .Text,
                          isRequired: false,
                          isActive: isEditingEnabled,
                          keyboardType: .default,
                          validation: viewModel.validateAddressTwo(),
                          text: viewModel.getContactAddressTwo()),
                    
                    .init(title: JobFields.CITY.rawValue.localize,
                          key: JobFields.CITY.rawValue,
                          dataType: .Text,
                          isRequired: true,
                          isActive: isEditingEnabled,
                          keyboardType: .default,
                          validation: viewModel.validateCity(),
                          text: viewModel.getContactCity()),
                    
                    .init(title: JobFields.STATE.rawValue.localize,
                          key: JobFields.STATE.rawValue,
                          dataType: .Text,
                          isRequired: true,
                          isActive: isEditingEnabled,
                          keyboardType: .default,
                          validation: viewModel.validateState(),
                          text: viewModel.getContactState()),
                    
                    .init(title: JobFields.ZIP.rawValue.localize,
                          key: JobFields.ZIP.rawValue,
                          dataType: .ZipCode,
                          isRequired: true,
                          isActive: isEditingEnabled,
                          keyboardType: .asciiCapableNumberPad,
                          validation: viewModel.validateZip(),
                          text: viewModel.getContactZip()),
            ]
        case .ASSINGMENT_DETAILS:
            return [.init(title: JobFields.WORKER_NAME.rawValue.localize,
                          key: JobFields.WORKER_NAME.rawValue,
                          dataType: .ListView,
                          isRequired: true,
                          isActive: AppLocals.workerRole.role.canScheduleJobs! ? isEditingEnabled:false,
                          keyboardType: .default,
                          validation: viewModel.validateWorkerName(),
                          text: viewModel.getWorkerName(),
                          listData: viewModel.getWorkers()),
                    
                    .init(title: JobFields.START_DATE_TIME.rawValue.localize,
                          key: JobFields.START_DATE_TIME.rawValue,
                          dataType: .Time,
                          isRequired: true,
                          isActive: isEditingEnabled,
                          keyboardType: .default,
                          validation: viewModel.validateStartTime(),
                          text: viewModel.getStartTime()),
                    
                    .init(title: JobFields.END_DATE_TIME.rawValue.localize,
                          key: JobFields.END_DATE_TIME.rawValue,
                          dataType: .Time,
                          isRequired: true,
                          isActive: isEditingEnabled,
                          keyboardType: .default,
                          validation: viewModel.validateEndTime(),
                          text: viewModel.getEndTime()),
                    
                    .init(title: JobFields.ESTIMATE_TIME_DURATION.rawValue.localize,
                          key: JobFields.ESTIMATE_TIME_DURATION.rawValue,
                          dataType: .TimeFrame,
                          isRequired: false,
                          isActive: viewModel.canEditDuration() && isEditingEnabled,
                          keyboardType: .default,
                          validation: .Valid,
                          text: viewModel.getEstimateDuration()),
                    
                    .init(title: JobFields.JOB_STATUS.rawValue.localize,
                          key: JobFields.JOB_STATUS.rawValue,
                          dataType: .ListView,
                          isRequired: false,
                          isActive: isEditingEnabled,
                          keyboardType: .default,
                          validation: .Valid,
                          text: viewModel.getJobStatus(),
                          listData: viewModel.getAllJobStatus())]
        case .ATTACHMENTS:
            return [.init(title: JobFields.CHOOSE_FILE.rawValue.localize,
                          key: JobFields.CHOOSE_FILE.rawValue,
                          dataType: .Text,
                          isRequired: false,
                          isActive: isEditingEnabled,
                          validation: .Valid)]
        case .SCHEDULE_JOB:
            return [.init(title: JobFields.SCHEDULE_JOB.rawValue.localize,
                   key: JobFields.SCHEDULE_JOB.rawValue,
                   dataType: .Text,
                   validation: .Valid)]
        }
    }
}

extension CreateJobView: TextFieldCellDelegate {
    
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        guard let field = JobFields(rawValue: data.key) else {
            return
        }
        switch field {
        
        case .JOB_TITLE:
            viewModel.setJobTitle(title: text)
            
        case .ENTER_YOUR_ISSUE:
            viewModel.setIssueDescription(description: text)
            
        case .YOUR_NAME:
            viewModel.setPersonName(name: text)
            
        case .YOUR_PHONE:
            viewModel.setPhone(phone: text)
            
        case .YOUR_EMAIL:
            viewModel.setEmail(email: text)
            
        case .ADDRESS_ONE:
            viewModel.setAddressOne(address: text)
            
        case .ADDRESS_TWO:
            viewModel.setAddressTwo(address: text)
            
        case .CITY:
            viewModel.setCity(city: text)
            
        case .STATE:break
//            viewModel.setState(state: text)
            
        case .ZIP:
            viewModel.setZip(zip: text)
            
        case .START_DATE_TIME:
            viewModel.setStartTimeDate(time: text)
            
        case .END_DATE_TIME:
            viewModel.setEndTimeDate(time: text)
            
        case .ESTIMATE_TIME_DURATION:
            viewModel.setEstimateDuration(duration: text)
        default:
            break
        }
    }
    
    func didChangeTextField(text: String?, data: TextFieldCellData) {
        guard let field = JobFields(rawValue: data.key) else {
            return
        }
        
        let finalText = text ?? ""
        print("Changed text:\(finalText)")
        
        switch field {
        case .STATE:
            let fields = getFieldsForSection(at: .CONTACT_DETAILS)
            
            let i = fields.firstIndex(where: {JobFields.init(rawValue: $0.key) == .STATE}) ?? -1
            if i != -1{
                let indexPath = IndexPath(row: i, section: 1)
                if let cell = tableView.cellForRow(at: indexPath) as? TextFieldCell{
                    
                    let arrResult = arrStatesListGlobal
                        .filter { NSPredicate(format: "(StateNickName contains[c] %@)", finalText).evaluate(with: $0) }
                        
                    
                    let arr = arrResult.map({$0["StateNickName"] as! String}) // For Select Item from list
                    let arr2 = arrResult.map({"\($0["StateNickName"] as! String)" + " (\($0["FullStateName"] as! String))"})  // For Show list
                    
                    dropDown.anchorView = cell //5
                    dropDown.direction = .any
                    dropDown.width = cell.frame.width
                    dropDown.dataSource = arr2
                    dropDown.show()
                    dropDown.bottomOffset = CGPoint(x: 0, y: cell.frame.size.height)
                    
                    dropDown.selectionAction = { [weak self] (index: Int, item: String) in //8
                      guard let self = self else { return }
                        print("Selected Item:\(item)")
                        self.viewModel.setState(state: arr[index])
                        data.text = arr[index]
//                        self.setupCellsData()
                        self.tableView.reloadData()
                    }
                }
            }
            break
        default:break
        }
    }
}

extension CreateJobView: TextFieldListDelegate {
    
    func willAddItem(data: TextFieldCellData) {
        guard let field = JobFields(rawValue: data.key) else {
            return
        }
        
        switch field {
        case .CHOOSE_CUSTOMER:
            openCreateCustomer()
        case .WORKER_NAME:
            openCreateWorker()
        case .JOB_STATUS:
            print("open create job status")
        default:
            break
        }
    }
    
    func didChooseItem(at row: Int?, data: TextFieldCellData) {
        guard let row = row else { return }
        guard let field = JobFields(rawValue: data.key) else {
            return
        }
        switch field {
        case .CHOOSE_CUSTOMER:
            viewModel.setCustomer(at: row)
            tableView.reloadData()
        case .WORKER_NAME:
            viewModel.setWorker(at: row)
        case .JOB_STATUS:
            viewModel.setStatus(at: row)
        default:
            break
        }
    }
}
