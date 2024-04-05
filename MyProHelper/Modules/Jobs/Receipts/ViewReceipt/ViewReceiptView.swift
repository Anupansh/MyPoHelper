//
//  ViewReceiptView.swift
//  MyProHelper
//
//  Created by Deep on 2/15/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit

private enum ReceiptField: String {
    case INVOICE                = "INVOICE"
    case CUSTOMER_NAME          = "CUSTOMER_NAME"
    case AMOUNT                 = "AMOUNT"
    case PAID                   = "PAID"
    case PAYMENT_NOTE           = "PAYMENT_NOTE"
    case ATTACHMENTS            = "ATTACHMENTS"

    func getStringValue() -> String {
        return self.rawValue.localize
    }
}

private enum PaidCell: String {
    case FULL      = "FULL"
    case PARTIAL   = "PARTIAL"
    
    func stringValue() -> String {
        return self.rawValue.localize
    }
}

class ViewReceiptView: BaseCreateWithAttachmentView<ViewReceiptViewModel>, Storyboarded {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCellsData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func getCell(at indexPath: IndexPath) -> BaseFormCell {
        guard let cellType = ReceiptField(rawValue:  cellData[indexPath.row].key) else {
            return BaseFormCell()
        }

        switch cellType {
        case .INVOICE:
            return instantiateTextCell(at: indexPath.row)
        case .CUSTOMER_NAME:
            return instantiateTextCell(at: indexPath.row)
        case .AMOUNT:
            return instantiateTextCell(at: indexPath.row)
        case .PAID:
            return instantiateRadioButtonCell(at: indexPath.row)
        case .PAYMENT_NOTE:
            return instantiateTextViewCell(at: indexPath.row)
        case .ATTACHMENTS:
            return instantiateAttachmentCell()
        }
    }
    
    private func instantiateTextCell(at index: Int) -> TextFieldCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.ID) as? TextFieldCell else {
            return TextFieldCell()
        }
        cell.bindTextField(data: cellData[index])
        return cell
    }

    private func instantiateTextViewCell(at index: Int) -> TextViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TextViewCell.ID) as? TextViewCell else {
            return TextViewCell()
        }
        cell.bindTextView(data: cellData[index])
        return cell
    }
    
    private func instantiateRadioButtonCell (at index: Int) -> RadioButtonCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RadioButtonCell.ID) as? RadioButtonCell else {
            return RadioButtonCell()
        }
        cell.isSelectionEnabled = isEditingEnabled
        cell.setTitle(title: "Paid")
        cell.bindCell(data: [.init(key: PaidCell.FULL.rawValue,
                                   title: PaidCell.FULL.stringValue(),
                                   value: viewModel.getIsFull()),
                             .init(key: PaidCell.PARTIAL.rawValue,
                                   title: PaidCell.PARTIAL.stringValue(),
                                   value: viewModel.getIsPartial())])
        return cell
    }
    
    private func setupCellsData() {
        cellData = [
            .init(title: ReceiptField.INVOICE.getStringValue(),
                  key: ReceiptField.INVOICE.rawValue,
                  dataType: .Text,
                  isRequired: true,
                  isActive: isEditingEnabled,
                  keyboardType: .default,
                  validation: .Valid,
                  text: viewModel.getInvoice()),
            
            .init(title: ReceiptField.CUSTOMER_NAME.getStringValue(),
                  key: ReceiptField.CUSTOMER_NAME.rawValue,
                  dataType: .Text,
                  isRequired: true,
                  isActive: isEditingEnabled,
                  keyboardType: .default,
                  validation: .Valid,
                  text: viewModel.getCustomerName()),

            .init(title: ReceiptField.AMOUNT.getStringValue(),
                  key: ReceiptField.AMOUNT.rawValue,
                  dataType: .Text,
                  isRequired: true,
                  isActive: isEditingEnabled,
                  keyboardType: .default,
                  validation: .Valid,
                  text: viewModel.getAmount()),

            .init(title: ReceiptField.PAID.getStringValue(),
                  key: ReceiptField.PAID.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  keyboardType: .default,
                  validation: .Valid,
                  text: viewModel.getAmount()),
        
            .init(title: ReceiptField.PAYMENT_NOTE.getStringValue(),
                  key: ReceiptField.PAYMENT_NOTE.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: viewModel.getPaymentNote()),

            .init(title: ReceiptField.ATTACHMENTS.getStringValue(),
                  key: ReceiptField.ATTACHMENTS.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid)
        ]
    }
}
