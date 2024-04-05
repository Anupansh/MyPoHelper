//
//  JobsToRescheduleView.swift
//  MyProHelper
//
//  Created by sismac010 on 16/08/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

enum JobsToRescheduleViewField: String {
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

class JobsToRescheduleView: BaseDataTableView<Job, JobsToRescheduleViewField>, Storyboarded{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = JobsToRescheduleViewModel(delegate: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.addShowRemovedButton()
        self.title = "JOBS_TO_RESCHEDULE".localize
        
        //showSnackbar()
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
