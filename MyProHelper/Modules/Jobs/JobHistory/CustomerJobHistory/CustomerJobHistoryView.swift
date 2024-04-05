//
//  JobHistoryDetailsView.swift
//  MyProHelper
//
//  Created by Deep on 1/25/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import SwiftDataTables

enum CustomerJobHistoryField: String {
    case JOB_ID                     = "JOB_ID"
    case JOB_START_DATE             = "JOB_START_DATE"
    case JOB_LOCAION_ADDRESS        = "JOB_LOCAION_ADDRESS"
    case JOB_CONTACT_PERSON_NAME    = "JOB_CONTACT_PERSON_NAME"
    case JOB_CONTACT_PHONE          = "JOB_CONTACT_PHONE"
    case JOB_DESCRIPTION            = "JOB_DESCRIPTION"
    case JOB_PRICE                  = "JOB_PRICE"
    case SALES_TAX                  = "SALES_TAX"
    case JOB_STATUS                 = "JOB_STATUS"
    case PAID                       = "PAID"
}

class CustomerJobHistoryView: BaseDataTableView<CustomerJobHistory, CustomerJobHistoryField>, Storyboarded {
    
    var toShowBack = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func setDataTableFields() {
        dataTableFields = [
            .JOB_ID,
            .JOB_START_DATE,
            .JOB_LOCAION_ADDRESS,
            .JOB_CONTACT_PERSON_NAME,
            .JOB_CONTACT_PHONE,
            .JOB_DESCRIPTION,
            .JOB_PRICE,
            .SALES_TAX,
            .JOB_STATUS,
            .PAID
        ]
    }
    
    override func getHeader(for columnIndex: NSInteger) -> String {
        return dataTableFields[columnIndex].rawValue.localize
    }
    
    override func setupNavigationBar() {
    
    }
    
    override func showItem(at indexPath: IndexPath) {
        let showJobHistoryView = ShowJobHistoryView.instantiate(storyboard: .SHOW_JOB_HISTORY)
        let jobHistory = viewModel.getItem(at: indexPath.section)
        showJobHistoryView.viewModel = ShowJobHistoryViewModel(attachmentSource: .JOB_HISTORY)
        showJobHistoryView.setViewMode(isEditingEnabled: false)
        showJobHistoryView.viewModel.setJobHistory(jobHistory: jobHistory)
        navigationController?.pushViewController(showJobHistoryView, animated: true)
    }
    
    override func editItem(at indexPath: IndexPath) {
        let showJobHistoryView = ShowJobHistoryView.instantiate(storyboard: .SHOW_JOB_HISTORY)
        let jobHistory = viewModel.getItem(at: indexPath.section)
        showJobHistoryView.viewModel = ShowJobHistoryViewModel(attachmentSource: .JOB_HISTORY)
        showJobHistoryView.setViewMode(isEditingEnabled: true)
        showJobHistoryView.viewModel.setJobHistory(jobHistory: jobHistory)
        navigationController?.pushViewController(showJobHistoryView, animated: true)
    }
}
