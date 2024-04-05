//
//  SupplyListView.swift
//  MyProHelper
//
//  Created by sismac010 on 09/03/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit

enum SupplyField: String {
    case SUPPLY_NAME              = "SUPPLY_NAME"
    case DESCRIPTION            = "DESCRIPTION"
    case PURCHASED_FROM         = "PURCHASED_FROM"
    case SUPPLY_LOCATION          = "SUPPLY_LOCATION"
    case QUANTITY               = "QUANTITY"
    case PRICE_PAID             = "PRICE_PAID"
    case PRICE_TO_RESELL        = "PRICE_TO_RESELL"
//    case WAITING_COUNT          = "WAITING_COUNT"
    case PURCHASED_DATE         = "PURCHASED_DATE"
    case ATTACHMENTS            = "ATTACHMENTS"
}


class SupplyListView: BaseDataTableView<Supply, SupplyField>, Storyboarded {

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = SupplyListViewModel(delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "SUPPLIES".localize
        super.addShowRemovedButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        super.hideShowRemovedButton()
    }

    override func setDataTableFields() {
        dataTableFields = [
            .SUPPLY_NAME,
            .DESCRIPTION,
            .PURCHASED_FROM,
            .SUPPLY_LOCATION,
            .QUANTITY,
            .PRICE_PAID,
            .PRICE_TO_RESELL,
            .PURCHASED_DATE,
            .ATTACHMENTS
        ]
    }
    
    override func getHeader(for columnIndex: NSInteger) -> String {
        return dataTableFields[columnIndex].rawValue.localize
    }
    
    @objc override func handleAddItem() {
        let createSupplyView = CreateSupplyView.instantiate(storyboard: .SUPPLY)
        createSupplyView.viewModel = CreateSupplyViewModel(attachmentSource: .SUPPLY)
        createSupplyView.setViewMode(isEditingEnabled: true)
        navigationController?.pushViewController(createSupplyView, animated: true)
    }
    
    override func showItem(at indexPath: IndexPath) {
        let createSupplyView = CreateSupplyView.instantiate(storyboard: .SUPPLY)
        let supply = viewModel.getItem(at: indexPath.section)
        createSupplyView.viewModel = CreateSupplyViewModel(attachmentSource: .SUPPLY)
        createSupplyView.setViewMode(isEditingEnabled: false)
        createSupplyView.viewModel.setSupply(supply: supply)
        navigationController?.pushViewController(createSupplyView, animated: true)
    }
    
    override func editItem(at indexPath: IndexPath) {
        let createSupplyView = CreateSupplyView.instantiate(storyboard: .SUPPLY)
        let supply = viewModel.getItem(at: indexPath.section)
        createSupplyView.viewModel = CreateSupplyViewModel(attachmentSource: .SUPPLY)
        createSupplyView.setViewMode(isEditingEnabled: true)
        createSupplyView.viewModel.setSupply(supply: supply)
        navigationController?.pushViewController(createSupplyView, animated: true)
    }
    
    override func setMoreAction(at indexPath: IndexPath) -> [UIAlertAction] {
        if AppLocals.workerRole.role.canAddRemoveInventoryItems! {
            let addInventoryAction      = UIAlertAction(title: "ACTION_ADD_STOCK".localize, style: .default) { [unowned self] (action) in
                self.openInventoryAction(for: indexPath.section, with: .ADD_INVENTORY)
            }
            let removeInventoryAction   = UIAlertAction(title: "ACTION_REMOVE_INVENTORY".localize, style: .default) { [unowned self] (action) in
                self.openInventoryAction(for: indexPath.section, with: .REMOVE_INVENTORY)
            }
            let transferInventoryAction = UIAlertAction(title: "ACTION_TRANSFER_INVENTORY".localize, style: .default) { [unowned self] (action) in
                self.openInventoryAction(for: indexPath.section, with: .TRANSFER_INVENTORY)
            }
            let invoiceWaitingAction    = UIAlertAction(title: "ACTION_SHOW_INVOICES_WATING_FOR_SUPPLY".localize, style: .default) { [unowned self] (action) in
                self.showWaitingForPart(at: indexPath.section)
            }
            return [addInventoryAction, removeInventoryAction, transferInventoryAction,invoiceWaitingAction]
        }
        else {
            return []
        }
    }
    
    private func openInventoryAction(for index: Int, with action: InventoryAction) {
        guard let stock = viewModel.getItem(at: index).stock else { return }
        let supplyInventoryView = SupplyInventoryView.instantiate(storyboard: .SUPPLY)
        supplyInventoryView.isEditingEnabled = true
        supplyInventoryView.bindData(stock: stock, action: action)
        navigationController?.pushViewController(supplyInventoryView, animated: true)
    }
    
    private func showWaitingForPart(at index : Int) {
        guard let viewModel = viewModel as? SupplyListViewModel else { return }
        let supply = viewModel.getItem(at: index)
        let supplyWaiting = viewModel.getInvoiceWaitingForJob(partId: supply.supplyId!)
        if supplyWaiting.isEmpty {
            GlobalFunction.showMessageAlert(fromView: self, title: AppLocals.appName, message: Constants.Message.NO_JOBS_WAITING_SUPPLY)
        }
        else {
            let vc = AppStoryboards.part.instantiateViewController(withIdentifier: JobsWaitingForInventoryVC.className) as! JobsWaitingForInventoryVC
            vc.partWaitingForInvoice = supplyWaiting
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
}
