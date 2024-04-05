//
//  JobHistoryView.swift
//  MyProHelper
//
//  Created by Deep on 1/18/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit
import SwiftDataTables

enum JobHistoryField: String {
    case CUSTOMER_NAME          = "CUSTOMER_NAME"
    case WORKER_NAME            = "WORKER_NAME"
    case SCHEDULED_DATE_TIME    = "SCHEDULED_DATE_TIME"
    case ADDRESS                = "ADDRESS"
    case CONTACT_PHONE          = "CONTACT_PHONE"
    case JOB_TITLE              = "JOB_TITLE"
    case DESCRIPTION            = "DESCRIPTION"
    case STATUS                 = "STATUS"
    case ATTACHMENTS            = "ATTACHMENTS"
}

class JobHistoryView: BaseDataTableView<JobHistory, JobHistoryField>, Storyboarded {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Job History"
        viewModel = JobHistoryViewModel(delegate: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func setDataTableFields() {
        dataTableFields = [
            .CUSTOMER_NAME,
            .WORKER_NAME,
            .SCHEDULED_DATE_TIME,
            .ADDRESS,
            .CONTACT_PHONE,
            .JOB_TITLE,
            .DESCRIPTION,
            .STATUS,
            .ATTACHMENTS
        ]
    }
    
    override func setupNavigationBar() {
        self.navigationItem.rightBarButtonItems = []
        let leftBarItem = UIBarButtonItem(image: #imageLiteral(resourceName: "menu"), style: .done, target: self, action: #selector(super.showSideMenu))
        self.navigationItem.leftBarButtonItem = leftBarItem
    }
    
    override func getHeader(for columnIndex: NSInteger) -> String {
        return dataTableFields[columnIndex].rawValue.localize
    }
    
    override func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
        if AppLocals.workerRole.role.canEditJobHistory! {
            ActionSheetManager.shared.showActionSheet(typeOfAction: [.viewAction,.editAction], presentingView: dataTable.collectionView.cellForItem(at: indexPath)!.contentView, vc: self) { [weak self] (actionPerformed) in
                if actionPerformed == .viewAction {
                    self?.showItem(at: indexPath)
                }
                else if actionPerformed == .editAction {
                    let alert = UIAlertController(title: AppLocals.appName, message: Constants.Message.JOB_HISTORY_EDIT, preferredStyle: .alert)
                    let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (alert) in
                        self?.editItem(at: indexPath)
                        self?.dismiss(animated: true, completion: nil)
                    }
                    let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
                    alert.addAction(confirmAction)
                    alert.addAction(cancelAction)
                    self?.present(alert, animated: true, completion: nil)
                }
                return nil
            }
        }
        else {
            ActionSheetManager.shared.showActionSheet(typeOfAction: [.viewAction], presentingView: dataTable.collectionView.cellForItem(at: indexPath)!.contentView, vc: self) { [weak self] (actionPerformed) in
                if actionPerformed == .viewAction {
                    self?.showItem(at: indexPath)
                }
                return nil
            }
        }
    }
    
    override func showItem(at indexPath: IndexPath) {
        let createJob = CreateJobView.instantiate(storyboard: .SCHEDULE_JOB)
        createJob.viewModel = CreateJobViewModel(attachmentSource: .SCHEDULED_JOB)
        let jobHistory = viewModel.getItem(at: indexPath.section)
        createJob.viewModel.setJob(job: getJobFromHistory(jobHistory: jobHistory))
        createJob.setViewMode(isEditingEnabled: false)
        navigationController?.pushViewController(createJob, animated: true)
    }
    
    override func editItem(at indexPath: IndexPath) {
        let createJob = CreateJobView.instantiate(storyboard: .SCHEDULE_JOB)
        createJob.viewModel = CreateJobViewModel(attachmentSource: .SCHEDULED_JOB)
        let jobHistory = viewModel.getItem(at: indexPath.section)
        createJob.viewModel.setJob(job: getJobFromHistory(jobHistory: jobHistory))
        createJob.setViewMode(isEditingEnabled: true)
        navigationController?.pushViewController(createJob, animated: true)
    }
    
    func getJobFromHistory(jobHistory: JobHistory) -> Job {
        var job = Job()
        job.jobID = jobHistory.jobID
        job.customerID              = jobHistory.customerID
        job.jobLocationAddress1     = jobHistory.jobLocationAddress1
        job.jobLocationAddress2     = jobHistory.jobLocationAddress2
        job.jobLocationCity         = jobHistory.jobLocationCity
        job.jobLocationState        = jobHistory.jobLocationState
        job.jobLocationZip          = jobHistory.jobLocationZip
        job.jobContactPersonName    = jobHistory.jobContactPersonName
        job.jobContactPhone         = jobHistory.jobContactPhone
        job.jobContactEmail         = jobHistory.jobContactEmail
        job.jobShortDescription     = jobHistory.jobShortDescription
        job.jobDescription          = jobHistory.jobDescription
        job.startDateTime           = jobHistory.startDateTime
        job.workerScheduled         = jobHistory.workerScheduled
        job.jobStatus               = jobHistory.jobStatus
        job.removed                 = jobHistory.removed
        job.numberOfAttachments     = jobHistory.numberOfAttachments
        job.worker                  = jobHistory.worker
        job.customer                = jobHistory.customer
        return job
    }
    

}
