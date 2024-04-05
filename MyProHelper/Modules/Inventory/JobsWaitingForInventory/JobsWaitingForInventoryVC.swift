//
//  JobsWaitingForInventoryVC.swift
//  MyProHelper
//
//  Created by Anupansh on 03/08/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit
import SwiftDataTables

class JobsWaitingForInventoryVC: UIViewController {
    
    // MARK: - OUTLETS AND VARIABLES
    lazy var dataTable = getDataTable()
    var columnName = [String]()
    var partWaitingForInvoice = [PartWaitingForInvoice]()
    var filteredPartWaitingForInvoice = [PartWaitingForInvoice]()
    var isSearching = false

    //MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    //MARK: - HELPER FUNCTIONS
    func initialSetup() {
        title = partWaitingForInvoice[0].isPart ?"Jobs waiting for this part":"Jobs waiting for this supply"
        if partWaitingForInvoice[0].isPart {
            columnName = ["Invoice ID","Customer Name","Part Name","Count Waiting For"]
        }
        else {
            columnName = ["Invoice ID","Customer Name","Supply Name","Count Waiting For"]
        }
        let backBtn = UIBarButtonItem.init(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(backBtnPressed))
        navigationItem.leftBarButtonItem = backBtn
        view.addSubview(dataTable)
        setupConstraints()
        dataTable.reload()
    }
    
    @objc func backBtnPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - DATATABLE LIFECYCLE
    func setupConstraints() {
        NSLayoutConstraint.activate([
            dataTable.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            dataTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dataTable.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            dataTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    func getDataTable() -> SwiftDataTable {
        let dtb = SwiftDataTable(dataSource: self)
        dtb.translatesAutoresizingMaskIntoConstraints = false
        dtb.delegate = self
        return dtb
    }
    
    func tableValue(index: NSInteger) -> [DataTableValueType] {
        var data = [DataTableValueType]()
        let singleData = isSearching ? filteredPartWaitingForInvoice[index] : partWaitingForInvoice[index]
        data.append(DataTableValueType.string(String(singleData.invoiceId!)))
        data.append(DataTableValueType.string(singleData.customerName ?? "-"))
        data.append(DataTableValueType.string(singleData.partName ?? "-"))
        data.append(DataTableValueType.string(String(singleData.countWaitingFor!)))
        return data
    }
    
    //MARK: SEARCH FUNCTION
    func fetchList(key: String) {
        filteredPartWaitingForInvoice.removeAll()
        var tempArr = [PartWaitingForInvoice]()
        for request in partWaitingForInvoice {
            if ((String(request.invoiceId!).contains(key)) || (request.customerName!.contains(key)) || (request.partName!.contains(key)) || (String(request.countWaitingFor!).contains(key))) {
                tempArr.append(request)
            }
        }
        filteredPartWaitingForInvoice = tempArr
        dataTable.reload()
    }
    
    //MARK: PRESENTING ACTION SHEET
    func presentActionSheet(index: Int,indexpath: IndexPath) {
        let model = isSearching ?filteredPartWaitingForInvoice:partWaitingForInvoice
        ActionSheetManager.shared.showActionSheet(typeOfAction: [.viewInvoive,.callCustomer,.goToJob], presentingView: self.view, vc: self) { [unowned self] actionPerformed in
            if actionPerformed == .viewInvoive {
                let vc = CreateInvoiceView.instantiate(storyboard: .INVOICE)
                let invoice = DBHelper.fetchInvoice(invoiceID: model[index].invoiceId!)
                vc.viewModel = CreateInvoiceViewModel(attachmentSource: .INVOICE)
                vc.setViewMode(isEditingEnabled: false)
                vc.viewModel.setInvoice(invoice: invoice)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if actionPerformed == .callCustomer {
                if let phone = model[index].contactPhone {
                    if let url = URL(string: "tel://\(phone)"), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil) }
                }
                else {
                    GlobalFunction.showMessageAlert(fromView: self, title: AppLocals.appName, message: Constants.Message.MOBILE_NOT_AVAILABLE)
                }
            }
            else {
                let vc = AppStoryboards.home.instantiateViewController(withIdentifier: CurrentJobsVC.className) as! CurrentJobsVC
                let job = DBHelper.fetchJob(jobID: Int64(model[index].jobID!))
                vc.job = job
                self.navigationController?.pushViewController(vc, animated: true)
            }
            return nil
        }
    }

}

extension JobsWaitingForInventoryVC: SwiftDataTableDataSource, SwiftDataTableDelegate {
    func didTapSort(_ dataTable: SwiftDataTable, type: DataTableSortType, column: Int) {
        print(type)
    }
    
    func numberOfColumns(in: SwiftDataTable) -> Int {
        return columnName.count
    }
    
    func didSearchForKey(_ dataTable: SwiftDataTable, Key: String) {
        if Key.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            isSearching = false
            dataTable.reload()
        }
        else {
            isSearching = true
            fetchList(key: Key)
        }
    }
    
    func numberOfRows(in: SwiftDataTable) -> Int {
        isSearching ? filteredPartWaitingForInvoice.count : partWaitingForInvoice.count
    }
    
    func dataTable(_ dataTable: SwiftDataTable, dataForRowAt index: NSInteger) -> [DataTableValueType] {
        return tableValue(index: index)
    }
    
    func shouldContentWidthScaleToFillFrame(in dataTable: SwiftDataTable) -> Bool {
        return true
    }
    
    func dataTable(_ dataTable: SwiftDataTable, headerTitleForColumnAt columnIndex: NSInteger) -> String {
        return columnName[columnIndex]
    }
    
    func heightForSectionFooter(in dataTable: SwiftDataTable) -> CGFloat {
        return 0
    }
    
    func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
        presentActionSheet(index: indexPath.section, indexpath: indexPath)
    }
}
