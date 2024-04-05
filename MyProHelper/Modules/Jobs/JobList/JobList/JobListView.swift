//
//  JobListView.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/28/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit

enum JobField: String {
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

class JobListView: BaseDataTableView<Job, JobField>, Storyboarded {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Job List"
        viewModel = JobListViewModel(delegate: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.addShowRemovedButton()
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
    
    override func showItem(at indexPath: IndexPath) {
        let createJob = CreateJobView.instantiate(storyboard: .SCHEDULE_JOB)
        createJob.viewModel = CreateJobViewModel(attachmentSource: .SCHEDULED_JOB)
        let job = viewModel.getItem(at: indexPath.section)
        createJob.viewModel.setJob(job: job)
        createJob.setViewMode(isEditingEnabled: false)
        navigationController?.pushViewController(createJob, animated: true)
    }
    
    override func editItem(at indexPath: IndexPath) {
        let createJob = CreateJobView.instantiate(storyboard: .SCHEDULE_JOB)
        createJob.viewModel = CreateJobViewModel(attachmentSource: .SCHEDULED_JOB)
        let job = viewModel.getItem(at: indexPath.section)
        createJob.viewModel.setJob(job: job)
        createJob.setViewMode(isEditingEnabled: true)
        navigationController?.pushViewController(createJob, animated: true)
    }
}
