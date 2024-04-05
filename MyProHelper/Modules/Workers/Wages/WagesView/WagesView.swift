//
//  WagesView.swift
//  MyProHelper
//
//  Created by sismac010 on 04/06/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

enum WagesField: String {
    case WORKER_NAME                    = "WORKER_NAME"
    case SALARY_RATE                    = "SALARY_RATE"
    case SALART_PER_TIME                = "SALART_PER_TIME"
    case HOURLY_RATE                    = "HOURLY_RATE"
    case W4WH                           = "W4WH  "
    case W4EXEMPTIONS                   = "W4_EXEMPTIONS"
    case GARNISHMENTS                   = "GARNISHMENTS"
    case GARNISHMENT_AMOUNT             = "GARNISHMENT_AMOUNT"
    case NEEDS_1099                     = "NEEDS_1099"
    case ATTACHMENTS                    = "ATTACHMENTS"
    case START_EMPLOYMENT_DATE          = "START_EMPLOYMENT_DATE"
    case FED_TAX_WH                     = "FED_TAX_WH"
    case STATE_TAX_WH                   = "STATE_TAX_WH"
    case END_EMPLOYMENT_DATE            = "END_EMPLOYMENT_DATE"
    case CURRENT_VACATION_AMOUNT        = "CURRENT_VACATION_AMOUNT"
    case VACATION_ACCRUAL_RATE_IN_HOURS = "VACATION_ACCRUAL_RATE_IN_HOURS"
    case VACATION_HOURS_PER_YEAR        = "VACATION_HOURS_PER_YEAR"
    case CONTRACT_PRICE                 = "CONTRACT_PRICE"
    case CHECKBOX                       = "CHECKBOX"
    case Attachments                    = "Attachments"
    
    func stringValue() -> String {
        return self.rawValue.localize
    }
}

enum WagesField2: String {
    case WORKER_NAME            = "WORKER_NAME"
    func stringValue() -> String {
        return self.rawValue.localize
    }
}

private enum WageCheckboxField: String {
    case NEEDS_1099              = "NEEDS_1099"
    case IS_FIXED_CONTRACT_PRICE = "IS_FIXED_CONTRACT_PRICE"
    
    func stringValue() -> String {
        return self.rawValue.localize
    }
}


class WagesView: BaseDataTableView<Wage, WagesField>, Storyboarded {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = WagesViewModel(delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "WAGES".localize
        super.addShowRemovedButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        super.hideShowRemovedButton()
    }
    
    override func setDataTableFields() {
        dataTableFields = [.WORKER_NAME,
                           .SALARY_RATE,
                           .SALART_PER_TIME,
                           .HOURLY_RATE,
                           .W4WH,
                           .W4EXEMPTIONS,
                           .GARNISHMENTS,
                           .GARNISHMENT_AMOUNT,
                           .NEEDS_1099,
                           .ATTACHMENTS,
                           .START_EMPLOYMENT_DATE,
//                           .FED_TAX_WH,
//                           .STATE_TAX_WH,
//                           .END_EMPLOYMENT_DATE,
//                           .CURRENT_VACATION_AMOUNT,
//                           .VACATION_ACCRUAL_RATE_IN_HOURS,
//                           .VACATION_HOURS_PER_YEAR,
//                           .CONTRACT_PRICE,
//                           .CHECKBOX
                        ]
    }
    
    override func getHeader(for columnIndex: NSInteger) -> String {
        return dataTableFields[columnIndex].rawValue.localize
    }
    
    @objc override func handleAddItem() {
        let createWagesView = CreateWagesView.instantiate(storyboard: .WAGES_VIEW)
        createWagesView.viewModel = CreateWagesViewModel(attachmentSource: .WAGE)
        createWagesView.setViewMode(isEditingEnabled: true)
        navigationController?.pushViewController(createWagesView, animated: true)
    }
    
    override func showItem(at indexPath: IndexPath) {
        let createWagesView = CreateWagesView.instantiate(storyboard: .WAGES_VIEW)
        let wage = viewModel.getItem(at: indexPath.section)
        createWagesView.viewModel = CreateWagesViewModel(attachmentSource: .WAGE)
        createWagesView.setViewMode(isEditingEnabled: false)
        createWagesView.viewModel.setWage(wage: wage)
        navigationController?.pushViewController(createWagesView, animated: true)
    }

    override func editItem(at indexPath: IndexPath) {
        
        let createWagesView = CreateWagesView.instantiate(storyboard: .WAGES_VIEW)
        let wage = viewModel.getItem(at: indexPath.section)
        createWagesView.viewModel = CreateWagesViewModel(attachmentSource: .WAGE)
        createWagesView.setViewMode(isEditingEnabled: true)
        createWagesView.viewModel.setWage(wage: wage)
        navigationController?.pushViewController(createWagesView, animated: true)
    }

    

}
