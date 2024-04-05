//
//  CreatePaymentView.swift
//  MyProHelper
//
//  Created by Samir on 07/02/2021.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit
import SquareReaderSDK
import CoreLocation
import AVFoundation

private enum PaymentField: String {
    case CUSTOMER_NAME          = "CUSTOMER_NAME"
    case INVOICE                = "INVOICE"
    case DESCRIPTION            = "DESCRIPTION"
    case TOTAL_INVOICE_AMOUNT   = "TOTAL_INVOICE_AMOUNT"
    case AMOUNT_PAID            = "AMOUNT_PAYING"
    case PAYMENT_TYPE           = "PAYMENT_TYPE"
    case TRANSACTION_ID         = "TRANSACTION_ID"
    case PAYMENT_NOTE           = "PAYMENT_NOTE"
    case ATTACHMENTS            = "ATTACHMENTS"
    case BALANCE_AMOUNT         = "BALANCE_AMOUNT"

    func getStringValue() -> String {
        return self.rawValue.localize
    }
}

class CreatePaymentView: BaseCreateWithAttachmentView<CreatePaymentViewModel>, Storyboarded {
    
    var paymentType : [PaymentType] = [.cash,.cheque,.creditCard]
    var selectedPayment : PaymentType = .cash
    var locationManager = CLLocationManager()
    var locationPermissionEnabled = false
    var microphonePermissionEnabled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.setPaymentType(with: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLocationPermissions()
        setMicrophonePermissions()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.fetchCustomers()
            self.fetchInvoices()
        }
    }

    override func getCell(at indexPath: IndexPath) -> BaseFormCell {
        guard let cellType = PaymentField(rawValue:  cellData[indexPath.row].key) else {
            return BaseFormCell()
        }

        switch cellType {
        case .CUSTOMER_NAME:
            return instantiateTextCell(at: indexPath.row)
        case .INVOICE:
            return instantiateTextCell(at: indexPath.row)
        case .DESCRIPTION:
            return instantiateTextViewCell(at: indexPath.row)
        case .TOTAL_INVOICE_AMOUNT:
            return instantiateTextCell(at: indexPath.row)
        case .AMOUNT_PAID:
            return instantiateTextCell(at: indexPath.row)
        case .PAYMENT_TYPE:
            return instantiateDropDownCell(at: indexPath.row)
        case .TRANSACTION_ID:
            return instantiateTextCell(at: indexPath.row)
        case .PAYMENT_NOTE:
            return instantiateTextViewCell(at: indexPath.row)
        case .ATTACHMENTS:
            return instantiateAttachmentCell()
        case .BALANCE_AMOUNT:
            return instantiateTextCell(at: indexPath.row)
        }
    }
    
    private func instantiateDropDownCell(at index: Int) -> DropDownCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DropDownCell.className) as! DropDownCell
        cell.titleLbl.text = "Payment Type"
        cell.dropdownTextLbl.text = selectedPayment.rawValue
        var titleArray = [String]()
        for type in paymentType {
            titleArray.append(type.rawValue)
        }
        cell.generateDataSource(data: titleArray)
        cell.getDataClosure = { [weak self] (value,index) in
            self?.paymentTypeSelected(index: index)
        }
        return cell
    }

    private func instantiateTextCell(at index: Int) -> TextFieldCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.ID) as? TextFieldCell else {
            return TextFieldCell()
        }
        cell.bindTextField(data: cellData[index])
        cell.delegate       = self
        cell.listDelegate   = self
        return cell
    }

    private func instantiateDataPickerCell(at index: Int) -> DataPickerCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DataPickerCell.ID) as? DataPickerCell else {
            return DataPickerCell()
        }
        cell.bindCell(data: cellData[index])
        cell.delegate = self
        return cell
    }

    private func instantiateTextViewCell(at index: Int) -> TextViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TextViewCell.ID) as? TextViewCell else {
            return TextViewCell()
        }
        cell.delegate = self
        cell.bindTextView(data: cellData[index])
        return cell
    }

    override func handleAddItem() {
        super.handleAddItem()
        setupCellsData()
        viewModel.savePayment { (error, isValidData) in
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

    func fetchCustomers() {
        viewModel.fetchCustomers {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.setupCellsData()
                self.tableView.reloadData()
            }
        }
    }

    func fetchInvoices() {
        viewModel.fetchInvoices {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.setupCellsData()
                self.tableView.reloadData()
            }
        }
    }
    
    func paymentTypeSelected(index: Int) {
        viewModel.setPaymentType(with: index)
        selectedPayment = paymentType[index]
        if selectedPayment == .creditCard {
            let isCustomerValid = viewModel.validateCustomer()
            let isInvoiceValid = viewModel.validateInvoice()
            let isAmountValid = viewModel.validateAmountPaid()
            if isCustomerValid == .Valid && isInvoiceValid == .Valid && isAmountValid == .Valid {
                self.setupCellsData()
                self.tableView.reloadData()
                if locationPermissionEnabled  && microphonePermissionEnabled {
                    ActionSheetManager.shared.showActionSheet(typeOfAction: [.showReaderAction,.readerSettingsAction], presentingView: self.view, vc: self) { (typeOfAction) in
                        if typeOfAction == .readerSettingsAction {
                            self.callSquareSettingsController()
                        }
                        else {
                            self.callSquareReadersSDK()
                        }
                        return nil
                    }
                }
                else {
                    self.showSettingsAlert()
                }
            }
            else {
                handleAddItem()
            }
        }
    }
    
    func callSquareSettingsController() {
        if SQRDReaderSDK.shared.isAuthorized {
            let readerController = SQRDReaderSettingsController(delegate: self)
            readerController.present(from: self)
        }
        else {
            let authCode = AppLocals.squareMobileAuthorisationKey
            SQRDReaderSDK.shared.authorize(withCode: authCode) { (_, error) in
                if let authError = error {
                    print(authError)
                }
                else {
                    let readerController = SQRDReaderSettingsController(delegate: self)
                    readerController.present(from: self)
                }
            }
        }
    }
    
    func callSquareReadersSDK() {
        let intAmountPaying = Int(self.viewModel.payment.value.amountPaid ?? 0 * 100)
        if SQRDReaderSDK.shared.isAuthorized {
            let amountMoney = SQRDMoney(amount: intAmountPaying)
            let params = SQRDCheckoutParameters(amountMoney: amountMoney)
            params.additionalPaymentTypes = [.cash, .manualCardEntry]
            let checkoutController = SQRDCheckoutController (
                parameters: params,
                delegate: self
            )
            checkoutController.present(from: self)
        }
        else {
            let authCode = AppLocals.squareMobileAuthorisationKey     /* This is the mobile authorisation key.*/
            SQRDReaderSDK.shared.authorize(withCode: authCode) { _, error in
                    if let authError = error {
                        print(authError)
                    }
                    else {
                        let amountMoney = SQRDMoney(amount: intAmountPaying)
                        let params = SQRDCheckoutParameters(amountMoney: amountMoney)
                        params.additionalPaymentTypes = [.cash, .manualCardEntry]
                        let checkoutController = SQRDCheckoutController (
                            parameters: params,
                            delegate: self
                        )
                        checkoutController.present(from: self)
                    }
                }
            }
    }
    
    func setMicrophonePermissions() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] (authorized) in
            if authorized {
                self?.microphonePermissionEnabled = true
            }
            else {
                self?.microphonePermissionEnabled = false
            }
        }
    }
    
    func setLocationPermissions() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
        case .restricted, .denied:
            locationPermissionEnabled = false
        case .authorizedAlways, .authorizedWhenInUse:
            locationPermissionEnabled =  true
        @unknown default:
            fatalError()
        }
    }
    
    func showSettingsAlert() {
        let alert = UIAlertController(title: AppLocals.appName, message: Constants.Message.CREDIR_CARD_ERROR, preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (alert) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }

    private func setupCellsData() {
        cellData = [
            .init(title: PaymentField.CUSTOMER_NAME.getStringValue(),
                  key: PaymentField.CUSTOMER_NAME.rawValue,
                  dataType: .ListView,
                  isRequired: true,
                  isActive: isEditingEnabled,
                  keyboardType: .default,
                  validation: viewModel.validateCustomer(),
                  text: viewModel.getCustomerName(),
                  listData: viewModel.getCustomers()),

            .init(title: PaymentField.INVOICE.getStringValue(),
                  key: PaymentField.INVOICE.rawValue,
                  dataType: .ListView,
                  isRequired: true,
                  isActive: isEditingEnabled,
                  keyboardType: .default,
                  validation: viewModel.validateInvoice(),
                  text: viewModel.getInvoice(),
                  listData: viewModel.getInvoices()),

            .init(title: PaymentField.DESCRIPTION.getStringValue(),
                  key: PaymentField.DESCRIPTION.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  keyboardType: .default,
                  validation: .Valid,
                  text: viewModel.getDescription()),

            .init(title: PaymentField.TOTAL_INVOICE_AMOUNT.getStringValue(),
                  key: PaymentField.TOTAL_INVOICE_AMOUNT.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: false,
                  keyboardType: .default,
                  validation: .Valid,
                  text: viewModel.getTotalAmount()),
            .init(title: PaymentField.BALANCE_AMOUNT.getStringValue(),
                  key: PaymentField.BALANCE_AMOUNT.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: true,
                  keyboardType: .default,
                  validation: .Valid,
                  text: viewModel.getAmountLeft(),
                  listData: []),
            .init(title: PaymentField.AMOUNT_PAID.getStringValue(),
                  key: PaymentField.AMOUNT_PAID.rawValue,
                  dataType: .Text,
                  isRequired: true,
                  isActive: isEditingEnabled,
                  keyboardType: .decimalPad,
                  validation: viewModel.validateAmountPaid(),
                  text: viewModel.getAmountPaid()),

            .init(title: PaymentField.PAYMENT_TYPE.getStringValue(),
                  key: PaymentField.PAYMENT_TYPE.rawValue,
                  dataType: .Text,
                  isRequired: true,
                  isActive: isEditingEnabled,
                  keyboardType: .default,
                  validation: viewModel.validatePaymentType(),
                  text: viewModel.getPaymentType(),
                  listData: viewModel.getPaymentTypes()),

            .init(title: PaymentField.TRANSACTION_ID.getStringValue(),
                  key: PaymentField.TRANSACTION_ID.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  keyboardType: .default,
                  validation: .Valid,
                  text: viewModel.getTransactionId()),

            .init(title: PaymentField.PAYMENT_NOTE.getStringValue(),
                  key: PaymentField.PAYMENT_NOTE.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  keyboardType: .default,
                  validation: .Valid,
                  text: viewModel.getPaymentNote()),

            .init(title: PaymentField.ATTACHMENTS.getStringValue(),
                  key: PaymentField.ATTACHMENTS.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid)
        ]
    }
}

extension CreatePaymentView: TextFieldCellDelegate {
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        guard let cellType = PaymentField(rawValue: data.key) else {
            return
        }
        switch cellType {
        case .DESCRIPTION:
            viewModel.setDescription(description: text)
        case .AMOUNT_PAID:
            viewModel.setAmountPaid(amount: text)
        case .TRANSACTION_ID:
            viewModel.setTransactionId(id: text)
        case .PAYMENT_NOTE:
            viewModel.setPaymentNote(note: text)
        default:
            break
        }
    }
}

extension CreatePaymentView: TextFieldListDelegate {
    func willAddItem(data: TextFieldCellData) {
        guard let cellType = PaymentField(rawValue: data.key) else {
            return
        }
        switch cellType {
        case .CUSTOMER_NAME:
            createCustomer()
        case .INVOICE:
            createInvoice()
        default:
            break
        }
    }

    func didChooseItem(at row: Int?, data: TextFieldCellData) {
        guard let cellType = PaymentField(rawValue: data.key) else {
            return
        }
        guard let row = row else { return }

        switch cellType {
        case .CUSTOMER_NAME:
            viewModel.setCustomer(at: row)
            viewModel.removeInvoice()
            fetchInvoices()
        case .INVOICE:
            viewModel.setInvoice(at: row)
            setupCellsData()
            tableView.reloadData()
        default:
            break
        }
    }

    private func createCustomer() {
        let createCustomerView = CreateCustomerView.instantiate(storyboard: .CUSTOMERS)
        createCustomerView.setViewMode(isEditingEnabled: true)
        createCustomerView.viewModel.customer.bind { [weak self] customer in
            guard let self = self else { return }
            self.viewModel.setCustomer(with: customer)
            self.tableView.reloadData()
        }
        self.navigationController?.pushViewController(createCustomerView, animated: true)
    }

    private func createInvoice() {
        let createInvoiceView = CreateInvoiceView.instantiate(storyboard: .INVOICE)
        createInvoiceView.viewModel = CreateInvoiceViewModel(attachmentSource: .INVOICE)
        createInvoiceView.cameFromPayments = true
        createInvoiceView.setViewMode(isEditingEnabled: true)
        createInvoiceView.viewModel.invoice.bind { [weak self] invoice in
            guard let self = self else { return }
            self.viewModel.setInvoice(with: invoice)
            self.tableView.reloadData()
        }
        if let customer = self.viewModel.payment.value.customer {
            createInvoiceView.viewModel.invoice.value.customer = customer
            createInvoiceView.viewModel.fetchCustomerJobs {
                print("Fetched")
            }
        }
        self.navigationController?.pushViewController(createInvoiceView, animated: true)
    }
}

extension CreatePaymentView: PickerCellDelegate, SQRDCheckoutControllerDelegate, CLLocationManagerDelegate, SQRDReaderSettingsControllerDelegate {
    func readerSettingsControllerDidPresent(_ readerSettingsController: SQRDReaderSettingsController) {
       print("Presented")
    }
    
    func readerSettingsController(_ readerSettingsController: SQRDReaderSettingsController, didFailToPresentWith error: Error) {
        print(error.localizedDescription)
    }
    
    func checkoutController(_ checkoutController: SQRDCheckoutController, didFinishCheckoutWith result: SQRDCheckoutResult) {
        viewModel.setTransactionId(id: result.transactionID)
        handleAddItem()
    }
    
    func checkoutController(_ checkoutController: SQRDCheckoutController, didFailWith error: Error) {
        print(error.localizedDescription)
        dismiss(animated: true, completion: nil)
    }
    
    func checkoutControllerDidCancel(_ checkoutController: SQRDCheckoutController) {
        dismiss(animated: true, completion: nil)
    }
    

    func didPickItem(at index: Int, data: TextFieldCellData) {
        viewModel.setPaymentType(with: index)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
        case .restricted, .denied:
            locationPermissionEnabled = false
        case .authorizedAlways, .authorizedWhenInUse:
            locationPermissionEnabled =  true
        @unknown default:
            fatalError()
        }
    }

}
