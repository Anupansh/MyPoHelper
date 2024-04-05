//
//  JobConfirmationView.swift
//  MyProHelper
//
//  Created by Deep on 1/20/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit
import SwiftDataTables

enum JobConfirmationField: String {
    case WORKER_NAME            = "WORKER_NAME"
    case SCHEDULED_DATE_TIME    = "SCHEDULED_DATE_TIME"
    case ADDRESS                = "ADDRESS"
    case CONTACT_PERSON_NAME    = "CONTACT_PERSON_NAME"
    case CONTACT_PHONE          = "CONTACT_PHONE"
    case JOB_TITLE              = "JOB_TITLE"
    case DESCRIPTION            = "DESCRIPTION"
    case STATUS                 = "STATUS"
    case ATTACHMENTS            = "ATTACHMENTS"
}

class JobConfirmationView: BaseDataTableView<Job, JobConfirmationField>, Storyboarded{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = JobConfirmationViewModel(delegate: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "JOB_CONFIRMATION".localize
    }
    
    @objc override func handleAddItem() {
        let createJob = CreateJobView.instantiate(storyboard: .SCHEDULE_JOB)
        createJob.viewModel = CreateJobViewModel(attachmentSource: .SCHEDULED_JOB)
        createJob.setViewMode(isEditingEnabled: true)
        navigationController?.pushViewController(createJob, animated: true)
    }
    
    override func setDataTableFields() {
        dataTableFields = [
            .WORKER_NAME,
            .SCHEDULED_DATE_TIME,
            .ADDRESS,
            .CONTACT_PERSON_NAME,
            .CONTACT_PHONE,
            .JOB_TITLE,
            .DESCRIPTION,
            .STATUS,
            .ATTACHMENTS
        ]
    }
    
    override func getHeader(for columnIndex: NSInteger) -> String {
        return dataTableFields[columnIndex].rawValue.localize
    }
    
    func acceptJob(for indexPath: Int) {
        guard let viewModel = viewModel as? JobConfirmationViewModel else {
            return
        }
        viewModel.acceptJob(for: indexPath)
    }
    
    func declineJob(for index: Int) {
        guard let viewModel = viewModel as? JobConfirmationViewModel else {
            return
        }
        let declineJobView = JobDeclineView.instantiate(storyboard: .JOB_DECLINE)
        declineJobView.didSetText = { text in
            if let messege = text {
                viewModel.declineJob(for: index, reason: messege)
            }
        }
        present(declineJobView, animated: true)
    }
    
    override func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
    
        /*
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let acceptJobAction  = UIAlertAction(title: "ACCEPT".localize, style: .default) { [unowned self] (action) in
            self.acceptJob(for: indexPath.section)
        }
        let declineJobAction  = UIAlertAction(title: "DECLINE".localize, style: .destructive) { [unowned self] (action) in
            self.declineJob(for: indexPath.section)
        }
        alert.addAction(acceptJobAction)
        alert.addAction(declineJobAction)
        if let cell = dataTable.collectionView.cellForItem(at: indexPath) {
            presentAlert(alert: alert, sourceView: cell.contentView)
        }
        */
        
        let actionSheet = GlobalFunction.showAcceptDeclineActionSheet(acceptHandler: {  [weak self] (acceptAction) in
            guard let self = self else { return }
            self.acceptJob(for: indexPath.section)
            
        }, declineHandler: { [weak self] (declineAction) in
            guard let self = self else { return }
            self.declineJob(for: indexPath.section)
            
        })
        
        if let cell = dataTable.collectionView.cellForItem(at: indexPath) {
            presentAlert(alert: actionSheet, sourceView: cell.contentView)
        }
    }
}
