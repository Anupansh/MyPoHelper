//
//  CustomerListVIew.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 9/30/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit
import SwiftDataTables

enum CustomerField: String {
    case CUSTOMER_ID            = "CUSTOMER_ID"
    case CUSTOMER_NAME          = "CUSTOMER_NAME"
    case CONTACT_PHONE          = "CONTACT_PHONE"
    case CONTACT_EMAIL          = "CONTACT_EMAIL"
    case BILLING_ADDRESS_ONE    = "BILLING_ADDRESS_ONE"
    case BILLING_ADDRESS_TWO    = "BILLING_ADDRESS_TWO"
    case CITY_STATE             = "CITY_STATE"
    case BILLING_ADDRESS_ZIP    = "BILLING_ADDRESS_ZIP"
}

class CustomerListView: BaseDataTableView<Customer,CustomerField>, Storyboarded {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Customer List"
        viewModel = CustomerListViewModel(delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.addShowRemovedButton()
    }
    
    /// generalize
    @objc override func handleAddItem() {
        if AppLocals.workerRole.role.canAddCustomers! {
            let createCustomerView = CreateCustomerView.instantiate(storyboard: .CUSTOMERS)
            createCustomerView.setViewMode(isEditingEnabled: true)
            navigationController?.pushViewController(createCustomerView, animated: true)
        }
        else {
            CommonController.shared.showSnackBar(message: Constants.Message.ALLOW_WORKER, view: self)
        }
    }
    
    override func setDataTableFields() {
        dataTableFields = [
            .CUSTOMER_ID,
            .CUSTOMER_NAME,
            .CONTACT_PHONE,
            .CONTACT_EMAIL,
            .BILLING_ADDRESS_ONE,
            .BILLING_ADDRESS_TWO,
            .CITY_STATE,
            .BILLING_ADDRESS_ZIP
        ]
    }
    
    override func getHeader(for columnIndex: NSInteger) -> String {
        return dataTableFields[columnIndex].rawValue.localize
    }
    
    override func showItem(at indexPath: IndexPath) {
        let createCustomerView = CreateCustomerView.instantiate(storyboard: .CUSTOMERS)
        let customer = viewModel.getItem(at: indexPath.section)
        createCustomerView.viewModel.setCustomer(customer: customer)
        createCustomerView.setViewMode(isEditingEnabled: false)
        navigationController?.pushViewController(createCustomerView, animated: true)
    }
    
    override func editItem(at indexPath: IndexPath) {
        let createCustomerView = CreateCustomerView.instantiate(storyboard: .CUSTOMERS)
        let customer = viewModel.getItem(at: indexPath.section)
        createCustomerView.viewModel.setCustomer(customer: customer)
        createCustomerView.setViewMode(isEditingEnabled: true)
        navigationController?.pushViewController(createCustomerView, animated: true)
    }
}
