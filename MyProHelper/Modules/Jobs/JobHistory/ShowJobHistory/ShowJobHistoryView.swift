//
//  ShowJobHistoryView.swift
//  MyProHelper
//
//  Created by Deep on 1/27/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit

private enum JobHistoryCell: String {
    case CUSTOMER_NAME                = "CUSTOMER_NAME"
    case JOB_LOCATION_ADDRESS_1       = "JOB_LOCATION_ADDRESS_1"
    case JOB_LOCATION_ADDRESS_2       = "JOB_LOCATION_ADDRESS_2"
    case JOB_LOCATION_CITY            = "JOB_LOCATION_CITY"
    case JOB_LOCATION_STATE           = "JOB_LOCATION_STATE"
    case JOB_LOCATION_ZIP             = "JOB_LOCATION_ZIP"
    case JOB_CONTACT_PERSON_NAME      = "JOB_CONTACT_PERSON_NAME"
    case JOB_CONTACT_PHONE            = "JOB_CONTACT_PHONE"
    case JOB_CONTACT_EMAIL            = "JOB_CONTACT_EMAIL"
    case JOB_SHORT_DESCRIPTION        = "JOB_SHORT_DESCRIPTION"
    case JOB_DESCRIPTION              = "JOB_DESCRIPTION"
    case JOB_START_DATE_TIME          = "JOB_START_DATE_TIME"
    case WORKER_SCHEDULED             = "WORKER_SCHEDULED"
    case STATUS                       = "STATUS"
    case JOB_PRICE                    = "JOB_PRICE"
    case SALES_TAX                    = "SALES_TAX"
    case PAID                         = "PAID"
    case ATTACHMENTS                  = "Attachments"
}

class ShowJobHistoryView: BaseCreateWithAttachmentView<ShowJobHistoryViewModel>, Storyboarded {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCellsData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func getCell(at indexPath: IndexPath) -> BaseFormCell {
        if let cellType = JobHistoryCell(rawValue:  cellData[indexPath.row].key), cellType == .ATTACHMENTS {
            return instantiateAttachmentCell()
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.ID) as? TextFieldCell else {
             return BaseFormCell()
         }
         cell.bindTextField(data: cellData[indexPath.row])
         cell.delegate = self
         return cell
    }
    
    override func handleAddItem() {
        super.handleAddItem()
        setupCellsData()
        viewModel.saveJobHistory { (error, isValidData) in
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
    
    private func setupCellsData() {
        cellData = [
            .init(title: JobHistoryCell.CUSTOMER_NAME.rawValue.localize,
                  key: JobHistoryCell.CUSTOMER_NAME.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: false,
                  validation: viewModel.validateCustomerName(),
                  text: viewModel.getCustomerName()),
            
            
            .init(title: JobHistoryCell.JOB_LOCATION_ADDRESS_1.rawValue.localize,
                  key:  JobHistoryCell.JOB_LOCATION_ADDRESS_1.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateAddress1(),
                  text: viewModel.getJobLocationAddress1()),
            
            .init(title: JobHistoryCell.JOB_LOCATION_ADDRESS_2.rawValue.localize,
                  key:  JobHistoryCell.JOB_LOCATION_ADDRESS_2.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateAddress2(),
                  text: viewModel.getJobLocationAddress2()),
            
            .init(title: JobHistoryCell.JOB_LOCATION_STATE.rawValue.localize,
                  key:  JobHistoryCell.JOB_LOCATION_STATE.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateState(),
                  text: viewModel.getJobLocationState()),
            
            .init(title: JobHistoryCell.JOB_LOCATION_CITY.rawValue.localize,
                  key:  JobHistoryCell.JOB_LOCATION_CITY.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateCity(),
                  text: viewModel.getJobLocationCity()),
            
            .init(title: JobHistoryCell.JOB_LOCATION_ZIP.rawValue.localize,
                  key: JobHistoryCell.JOB_LOCATION_ZIP.rawValue,
                  dataType: .ZipCode,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateZip(),
                  text: viewModel.getJobLocationZip()),
            
            .init(title: JobHistoryCell.JOB_CONTACT_PERSON_NAME.rawValue.localize,
                  key: JobHistoryCell.JOB_CONTACT_PERSON_NAME.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateContactPersonName(),
                  text: viewModel.getContactPersonName()),
            
            .init(title: JobHistoryCell.JOB_CONTACT_PHONE.rawValue.localize,
                  key: JobHistoryCell.JOB_CONTACT_PHONE.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateContactPhone(),
                  text: viewModel.getJobContactPhone()),

            .init(title: JobHistoryCell.JOB_CONTACT_EMAIL.rawValue.localize,
                  key: JobHistoryCell.JOB_CONTACT_EMAIL.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: viewModel.validatePersonEmail(),
                  text: viewModel.getJobContactEmail()),
            
            .init(title: JobHistoryCell.JOB_SHORT_DESCRIPTION.rawValue.localize,
                  key: JobHistoryCell.JOB_SHORT_DESCRIPTION.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: viewModel.getJobShortDescription()),
            
            .init(title: JobHistoryCell.JOB_DESCRIPTION.rawValue.localize,
                  key: JobHistoryCell.JOB_DESCRIPTION.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: viewModel.getJobDescription()),
            
            .init(title: JobHistoryCell.JOB_START_DATE_TIME.rawValue.localize,
                  key: JobHistoryCell.JOB_START_DATE_TIME.rawValue,
                  dataType: .Date,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: viewModel.getJobStartDate()),
            
            .init(title: JobHistoryCell.WORKER_SCHEDULED.rawValue.localize,
                  key: JobHistoryCell.WORKER_SCHEDULED.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: viewModel.getSheduledWorker()),
            
            .init(title: JobHistoryCell.STATUS.rawValue.localize,
                  key: JobHistoryCell.STATUS.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: false,
                  validation: .Valid,
                  text: viewModel.getStatus()),
            
            .init(title: JobHistoryCell.JOB_PRICE.rawValue.localize,
                  key: JobHistoryCell.JOB_PRICE.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: false,
                  validation: .Valid,
                  text: viewModel.getJobPrice()),
            
            .init(title: JobHistoryCell.SALES_TAX.rawValue.localize,
                  key: JobHistoryCell.SALES_TAX.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: false,
                  validation: .Valid,
                  text: viewModel.getSalesTax()),

            .init(title: JobHistoryCell.PAID.rawValue.localize,
                  key: JobHistoryCell.PAID.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: viewModel.getPaid()),
            
            .init(title: JobHistoryCell.ATTACHMENTS.rawValue.localize,
                  key: JobHistoryCell.ATTACHMENTS.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: "")
        ]
    }
}

extension ShowJobHistoryView: TextFieldCellDelegate {
    
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        guard let cell = JobHistoryCell(rawValue: data.key) else {
            return
        }
        
        switch cell {
        case .CUSTOMER_NAME:
            viewModel.setCustomerName(name: text)
        case .JOB_LOCATION_ADDRESS_1:
            viewModel.setJobLocationAddress1(address: text)
        case .JOB_LOCATION_ADDRESS_2:
            viewModel.setJobLocationAddress2(address: text)
        case .JOB_LOCATION_CITY :
            viewModel.setJobLocationCity(city: text)
        case .JOB_LOCATION_STATE:
            viewModel.setJobLocationState(state: text)
        case .JOB_LOCATION_ZIP:
            viewModel.setJobLocationZip(LocationZip: text)
        case .JOB_CONTACT_PERSON_NAME:
            viewModel.setContactPersonName(name: text)
        case .JOB_CONTACT_PHONE:
            viewModel.setJobContactPhone(phone: text)
        case .JOB_CONTACT_EMAIL:
            viewModel.setJobContactEmail(email: text)
        case .JOB_SHORT_DESCRIPTION:
            viewModel.setJobShortDescription(description: text)
        case .JOB_DESCRIPTION:
            viewModel.setJobDescription(description: text)
        case .JOB_START_DATE_TIME:
            viewModel.setJobStartDate(date: text)
        case .WORKER_SCHEDULED:
            viewModel.setSheduledWorker(worker: text)
        case .STATUS:
            viewModel.setStatus(status: text)
        case .JOB_PRICE:
            viewModel.setJobPrice(price: text)
        case .SALES_TAX:
            viewModel.setSalesTax(tax: text)
        case .PAID:
            viewModel.setPaid(paid: text)
        case .ATTACHMENTS:
            break
        }
    }
}
