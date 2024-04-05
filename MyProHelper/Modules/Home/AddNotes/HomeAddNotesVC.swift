//
//  HomeAddNotesVC.swift
//  MyProHelper
//
//  Created by Anupansh on 06/05/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit
import GRDB

class HomeAddNotesVC: UIViewController {
    
    
    // MARK: - OUTLETS AND VARIABLES
    @IBOutlet weak var tableview: UITableView! {
        didSet {
            tableview.delegate = self
            tableview.dataSource = self
            tableview.separatorStyle = .none
        }
    }
    
    var jobId : Int!
    var notes : String!
    var attachmentDescription : String!
    var customerId : Int!
    var imageData = Data()
    var customerName: String!
    
    // MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    // MARK: - HELPER FUNCTIONS
    func initialSetup() {
        self.navigationController?.isNavigationBarHidden = false
        let previousNotesBtn = UIBarButtonItem.init(title: "Previous Notes", style: .done, target: self, action: #selector(previousNotesBtnPressed))
        let saveBtn = UIBarButtonItem.init(barButtonSystemItem: .save, target: self, action: #selector(saveNotesBtnPressed))
        self.navigationItem.rightBarButtonItems = [saveBtn,previousNotesBtn]
        tableview.registerMultiple(nibs: [TextViewCell.className,ImagePickerCell.className,TextFieldCell.className,CheckboxCell.className])
    }
    
    // MARK: - OBJECTIVE C SELECTORS
    @objc func previousNotesBtnPressed() {
        let vc = AppStoryboards.home.instantiateViewController(withIdentifier: PreviousNotesVC.className) as! PreviousNotesVC
        vc.jobID = self.jobId
        vc.customerName = self.customerName
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func saveNotesBtnPressed() {
        if notes == nil {
            CommonController.shared.showSnackBar(message: "Please enter some note", view: self)
        }
        else {
            self.addNoteQuery()
        }
    }
    
    
    // MARK: - EXECUTING SQL QUERIES
    func addNoteQuery() {
        let arguments : StatementArguments = [
            "jobID" : self.jobId,
            "customerId" : self.customerId,
            "details" : self.notes,
            "createdBy" : AppLocals.worker.workerID,         // To edit after login flow
            "createdDate" : DateManager.dateToString(date: Date())
        ]
        let sql = """
            INSERT INTO chg.\(RepositoryConstants.Tables.JOB_DETAILS) (
                \(RepositoryConstants.Columns.JOB_ID),
                \(RepositoryConstants.Columns.CUSTOMER_ID),
                \(RepositoryConstants.Columns.DETAILS),
                \(RepositoryConstants.Columns.CREATED_BY),
                \(RepositoryConstants.Columns.CREATED_DATE)
            )
            VALUES (
                :jobID,
                :customerId,
                :details,
                :createdBy,
                :createdDate
            )
        """
        AppDatabase.shared.executeSQL(sql: sql, arguments: arguments,typeOfAction: .insert, updatedId: nil) { [weak self] (id) in
            if self?.imageData != Data() {
                // Update Attachments if any in Attahcments table
                self?.executeSaveAttaachmentQuery(jobDetailsId: id)
            }
            else {
//                CommonController.shared.showSnackBar(message: Constants.Message.UPDATE_NOTES_SUCCESS, view: self!)
                self?.navigationController?.popViewController(animated: true)
            }
        } fail: { (error) in
            print(error.localizedDescription)
        }
    }
    
    func executeSaveAttaachmentQuery(jobDetailsId: Int64) {
        let arguments : StatementArguments = [
            "jobDetailId" : jobDetailsId,
            "description" : self.attachmentDescription,
            "attachment" : self.imageData,
            "createdDate" : Date()
        ]
        let sql = """
            INSERT INTO chg.\(RepositoryConstants.Tables.ATTACHMENTS) (
                \(RepositoryConstants.Columns.JOB_DETAIL_ID),
                \(RepositoryConstants.Columns.DESCRIPTION),
                \(RepositoryConstants.Columns.PATH_TO_ATTACHMENT),
                \(RepositoryConstants.Columns.DATE_CREATED)
            )
            VALUES (
                :jobDetailId,
                :description,
                :attachment,
                :createdDate
            )
        """
        AppDatabase.shared.executeSQL(sql: sql, arguments: arguments,typeOfAction: .insert, updatedId: nil) { [weak self] (id) in
//            CommonController.shared.showSnackBar(message: Constants.Message.UPDATE_NOTES_SUCCESS, view: self!)
            self?.navigationController?.popViewController(animated: true)
        } fail: { (error) in
            print(error.localizedDescription)
        }
    }

}

// MARK: - TABLEVIEW DELEGATES AND DATASOURCES
extension HomeAddNotesVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableview.dequeueReusableCell(withIdentifier: TextViewCell.className) as! TextViewCell
            cell.bindTextView(data: .init(title: "Add Notes", key: "Add Notes", dataType: .Text, isRequired: false, isActive: true, keyboardType: .default, validation: ValidationResult.Valid, text: "", listData: []))
            cell.delegate = self
            return cell
        }
        else if indexPath.row == 1 {
            let cell = tableview.dequeueReusableCell(withIdentifier: ImagePickerCell.className) as! ImagePickerCell
            cell.vc = self
            cell.titleLbl.text = "Add Attachment"
            cell.imageStringClosure = { imageData in
                self.imageData = imageData
            }
            return cell
        }
        else if indexPath.row == 2 {
            let cell = tableview.dequeueReusableCell(withIdentifier: TextFieldCell.className) as! TextFieldCell
            cell.bindTextField(data: .init(title: "Attachment Description", key: "Attachment Description", dataType: .Text, isRequired: false, isActive: true, keyboardType: .default, validation: ValidationResult.Valid, text: "", listData: []))
            cell.delegate = self
            return cell
        }
        else {
            let cell = tableview.dequeueReusableCell(withIdentifier: CheckboxCell.className) as! CheckboxCell
            cell.bindCell(data: [.init(key: "Send Email", title: "Send Email", value: false)])
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 140
        }
        else if indexPath.row == 1 {
            return 180
        }
        else if indexPath.row == 2 {
            return 80
        }
        else {
            return 50
        }
    }
}

// MARK: - UIDELEGATES
extension HomeAddNotesVC: CheckboxCellDelegate, TextFieldCellDelegate {
    func didChangeValue(with data: RadioButtonData, isSelected: Bool) {
        if data.key == "Send Email" {
            if isSelected {
                // Send Mail
            }
        }
    }
    
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        if data.key == "Add Notes" {
            self.notes = text
        }
        else {
            self.attachmentDescription = text
        }
    }
}
