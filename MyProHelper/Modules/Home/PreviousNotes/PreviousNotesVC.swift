//
//  PreviousNotesVC.swift
//  MyProHelper
//
//  Created by Anupansh on 07/05/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit
import GRDB
import DTPhotoViewerController

class PreviousNotesVC: UIViewController {
    
    @IBOutlet weak var tableview: UITableView! {
        didSet {
            tableview.delegate = self
            tableview.dataSource = self
            tableview.separatorStyle = .none
        }
    }
    var jobID: Int!
    var customerName: String!
    var notesModel = [PreviousNotesModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }

    func initialSetup() {
        title = customerName
        fetchNotesData()
    }
    
    func fetchNotesData() {
        guard let queue = AppDatabase.shared.attachDababaseQueue else {return}
        var sql = """
            Select * from main.\(RepositoryConstants.Tables.JOB_DETAILS)
            LEFT JOIN main.\(RepositoryConstants.Tables.ATTACHMENTS) ON main.\(RepositoryConstants.Tables.JOB_DETAILS).\(RepositoryConstants.Columns.JOB_DETAIL_ID) =
                main.\(RepositoryConstants.Tables.ATTACHMENTS).\(RepositoryConstants.Columns.JOB_DETAIL_ID)
            WHERE main.\(RepositoryConstants.Tables.JOB_DETAILS).\(RepositoryConstants.Columns.JOB_ID) = \(self.jobID!)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        print(sql)
        do {
            try queue.read { (database) in
                let rows = try Row.fetchCursor(database, sql: sql)
                while let row = try rows.next() {
                    let singleNote = PreviousNotesModel.init(row: row)
                    self.notesModel.append(singleNote)
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
        tableview.reloadData()
    }
}

extension PreviousNotesVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: PreviousNotesCell.className) as! PreviousNotesCell
        cell.descriptionLbl.text =  notesModel[indexPath.row].notesDescription
        cell.createdDateLbl.text = notesModel[indexPath.row].createdDate
        if let imageData = notesModel[indexPath.row].pathToAttachment {
            cell.attachmentTextLbl.text = notesModel[indexPath.row].attachmentDescription
            cell.viewAttachmentBtn.setTitle("View Attachment", for: .normal)
            cell.viewAttachmentBtn.setTitleColor(.systemBlue, for: .normal)
            cell.viewAttachmentBtn.isEnabled = true
            let image = UIImage(data: imageData)
            cell.viewAttachmentClosure = { [weak self] in
                let vc = DTPhotoViewerController(referencedView: self?.view, image: image)
                self?.present(vc, animated: true, completion: nil)
            }
        }
        else {
            cell.attachmentTextLbl.isHidden = true
            cell.viewAttachmentBtn.setTitle("No Attachment", for: .normal)
            cell.viewAttachmentBtn.setTitleColor(.black, for: .normal)
            cell.viewAttachmentBtn.isEnabled = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

class PreviousNotesModel {
    
    var notesDescription: String?
    var createdDate: String?
    var pathToAttachment: Data?
    var attachmentDescription: String?
    
    init() {}
    
    init(row: Row) {
        notesDescription = row["Details"]
        createdDate = row["CreatedDate"]
        pathToAttachment = row["PathToAttachment"]
        attachmentDescription = row["Description"]
    }
}
