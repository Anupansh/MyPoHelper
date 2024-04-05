//
//  LatestInfoTableCell.swift
//  MyProHelper
//
//  Created by sismac010 on 19/10/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit
import SwiftDataTables
import GRDB

enum LatestInfoTab: String {
    case CALL_LIST          = "CALL_LIST"
    case QUOTES             = "QUOTES"
    case ESTIMATES          = "ESTIMATES"
    case BILLING_INVOICE    = "BILLING_INVOICE"
//    case REPORTS_TEST       = "REPORTS_TEST"
    case STOCKED_PARTS      = "STOCKED_PARTS"
    case TIME_SHEET         = "TIME_SHEETS"
    case PAYROLL            = "PAYROLL"
    
    func stringValue() -> String {
        return self.rawValue.localize
    }
}

class LatestInfoTableCell: UITableViewCell {
    
    @IBOutlet weak var dataTableView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak private var callListTabButton            : UIButton!
    @IBOutlet weak private var quotesTabButton              : UIButton!
    @IBOutlet weak private var estimatesTabButton           : UIButton!
    @IBOutlet weak private var billingAndInvoiceTabButton   : UIButton!
    @IBOutlet weak private var reportsTestTabButton         : UIButton!
    @IBOutlet weak private var timeSheetTabButton           : UIButton!
    @IBOutlet weak private var payrollTabButton             : UIButton!
    @IBOutlet weak private var collectionView               : UICollectionView!
    
    var vc: UIViewController?
    
//    private let latestInfoTabs: [LatestInfoTab] = [.CALL_LIST,
//                                                   .QUOTES,
//                                                   .ESTIMATES,
//                                                   .BILLING_INVOICE,
//                                                   .REPORTS_TEST]
    
    var selectedTab: LatestInfoTab  = .CALL_LIST
    
    private var latestInfoTabs: [LatestInfoTab] = []
    
    let createWorkerViewModel           = CreateWorkerViewModel()
    var isShowingWorker                 = false
    var isAdd        = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initialSetup()
        setupCollectionView()
        setupTabButtons()
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initialSetup() {
        titleLbl.text = selectedTab.stringValue()
        latestInfoTabs = [selectedTab]// For only one tab in a controller
//        dataTable = SwiftDataTable(dataSource: self)
//        dataTable.dataSource = self
//        dataTable.delegate = self
//        setupConstraints()
    }
    
    private func setupTabButtons() {
        callListTabButton.setTitle(LatestInfoTab.CALL_LIST.stringValue(), for: .normal)
        quotesTabButton.setTitle(LatestInfoTab.QUOTES.stringValue().localize, for: .normal)
        estimatesTabButton.setTitle(LatestInfoTab.ESTIMATES.stringValue().localize, for: .normal)
        billingAndInvoiceTabButton.setTitle(LatestInfoTab.BILLING_INVOICE.stringValue().localize, for: .normal)
        reportsTestTabButton.setTitle(LatestInfoTab.STOCKED_PARTS.stringValue().localize, for: .normal)
        timeSheetTabButton.setTitle(LatestInfoTab.TIME_SHEET.stringValue().localize, for: .normal)
        payrollTabButton.setTitle(LatestInfoTab.PAYROLL.stringValue().localize, for: .normal)
        
//        if isEditingEnabled/*createWorkerViewModel.isEditingWorker()*/ {
            selectTab(button: callListTabButton)
//        }
//        else {
//            disableTabButtons()
//        }
    }
    
    private func setupCollectionView() {
        let callLogCell             = UINib(nibName: CallLogCollectionCell.ID, bundle: nil)
        let quotesListCell          = UINib(nibName: QuotesListCollectionCell.ID, bundle: nil)
        let estimatesListCell       = UINib(nibName: EstimatesListCollectionCell.ID, bundle: nil)
        let billingInvoiceListCell  = UINib(nibName: BillingInvoiceListCollectionCell.ID, bundle: nil)
        let stockedPartsListCell    = UINib(nibName: StockedPartsListCollectionCell.ID, bundle: nil)
        let timeSheetCell           = UINib(nibName: TimeSheetCollectionCell.ID, bundle: nil)
        let payrollCell             = UINib(nibName: PayrollCollectionCell.ID, bundle: nil)
        let layout                  = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        
        collectionView.collectionViewLayout = layout
        collectionView.dataSource           = self
        collectionView.delegate             = self
        collectionView.isPagingEnabled      = true
        collectionView.isScrollEnabled      = false
        
        collectionView.register(callLogCell, forCellWithReuseIdentifier: CallLogCollectionCell.ID)
        collectionView.register(quotesListCell, forCellWithReuseIdentifier: QuotesListCollectionCell.ID)
        collectionView.register(estimatesListCell, forCellWithReuseIdentifier: EstimatesListCollectionCell.ID)
        collectionView.register(billingInvoiceListCell, forCellWithReuseIdentifier: BillingInvoiceListCollectionCell.ID)
        collectionView.register(stockedPartsListCell, forCellWithReuseIdentifier: StockedPartsListCollectionCell.ID)
        collectionView.register(timeSheetCell, forCellWithReuseIdentifier: TimeSheetCollectionCell.ID)
        collectionView.register(payrollCell, forCellWithReuseIdentifier: PayrollCollectionCell.ID)
    }
    
    private func disableTabButtons() {
        callListTabButton.isEnabled             = false
        quotesTabButton.isEnabled               = false
        estimatesTabButton.isEnabled            = false
        billingAndInvoiceTabButton.isEnabled    = false
        reportsTestTabButton.isEnabled          = false
        timeSheetTabButton.isEnabled            = false
        payrollTabButton.isEnabled              = false
        
        selectTab(button: callListTabButton)
        selectTab(button: quotesTabButton)
        selectTab(button: estimatesTabButton)
        selectTab(button: billingAndInvoiceTabButton)
        selectTab(button: reportsTestTabButton)
        selectTab(button: timeSheetTabButton)
        selectTab(button: payrollTabButton)
    }
    
    private func enableTabButtons() {
        callListTabButton.isEnabled             = true
        quotesTabButton.isEnabled               = true
        estimatesTabButton.isEnabled            = true
        billingAndInvoiceTabButton.isEnabled    = true
        reportsTestTabButton.isEnabled          = true
        timeSheetTabButton.isEnabled            = true
        payrollTabButton.isEnabled              = true
        
        deseletcTab(button: callListTabButton)
        deseletcTab(button: quotesTabButton)
        deseletcTab(button: estimatesTabButton)
        deseletcTab(button: billingAndInvoiceTabButton)
        deseletcTab(button: reportsTestTabButton)
        deseletcTab(button: timeSheetTabButton)
        deseletcTab(button: payrollTabButton)
    }
    
    private func selectTab(button: UIButton) {
        button.borderWidth      = 1
        button.borderColor      = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
        button.backgroundColor  = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        button.tintColor        = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        button.setTitleColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), for: .normal)
    }
    
    private func deseletcTab(button: UIButton) {
        button.borderWidth      = 0
        button.borderColor      = .clear
        button.backgroundColor  = .clear
        button.tintColor        = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        button.setTitleColor(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1), for: .normal)
    }
    
    func reload(){
        titleLbl.text = selectedTab.stringValue()
        latestInfoTabs = [selectedTab]
        configureTabSelection(tab: latestInfoTabs.first!)
        collectionView.reloadData()
    }
    
    
    private func configureTabSelection(tab: LatestInfoTab) {
        deseletcTab(button: callListTabButton)
        deseletcTab(button: quotesTabButton)
        deseletcTab(button: estimatesTabButton)
        deseletcTab(button: billingAndInvoiceTabButton)
        deseletcTab(button: reportsTestTabButton)
        deseletcTab(button: timeSheetTabButton)
        deseletcTab(button: payrollTabButton)
        selectedTab = tab
        
        switch tab {
        case .CALL_LIST:
            selectTab(button: callListTabButton)
//            enableKeyboardViewScrolling()
//            hideDeviceTabButton()
//            hideAddRoleGroupButton()
        case .QUOTES:
            selectTab(button: quotesTabButton)
//            enableKeyboardViewScrolling()
//            hideDeviceTabButton()
//            hideAddRoleGroupButton()
        case .ESTIMATES:
            selectTab(button: estimatesTabButton)
//            disableKeyboardViewScrolling()
//            hideDeviceTabButton()
//            showAddRoleGroupButton()
        case .BILLING_INVOICE:
            selectTab(button: billingAndInvoiceTabButton)
//            disableKeyboardViewScrolling()
//            hideAddRoleGroupButton()
//            showDeviceTabButton()
        case .STOCKED_PARTS:
            selectTab(button: reportsTestTabButton)
//            enableKeyboardViewScrolling()
//            hideDeviceTabButton()
//            hideAddRoleGroupButton()
        case .TIME_SHEET:
            selectTab(button: timeSheetTabButton)
        case .PAYROLL:
            selectTab(button: payrollTabButton)
        }
    }
    
    @IBAction func tabButtonPressed(sender: UIButton) {
//        if isAdd && !createWorkerViewModel.isSavedInitialData(){return}
        
        guard let title = sender.title(for: .normal) else {
            return
        }
        guard let index = latestInfoTabs.firstIndex(where: { $0.stringValue() == title}) else {
            return
        }
        let indexPath = IndexPath(item: 0, section: index)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        collectionView.reloadData()
        configureTabSelection(tab: latestInfoTabs[index])
    }
    
}

//MARK: - COLLECTION VIEW DATA SOURCE
extension LatestInfoTableCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return latestInfoTabs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let workerTab = latestInfoTabs[indexPath.section]
        switch workerTab {
        case .CALL_LIST:
            return instantiateCallLogCell(collectionView, cellForItemAt: indexPath)
        case .QUOTES:
            return instantiateQuotesListCell(collectionView, cellForItemAt: indexPath)
        case .ESTIMATES:
            return instantiateEstimatesListCell(collectionView, cellForItemAt: indexPath)
        case .BILLING_INVOICE:
            return instantiateBillingInvoiceListCell(collectionView, cellForItemAt: indexPath)
        case .STOCKED_PARTS:
            return instantiateStockedPartsListCell(collectionView, cellForItemAt: indexPath)
        case .TIME_SHEET:
            return instantiateTimeSheetCell(collectionView, cellForItemAt: indexPath)
        case .PAYROLL:
            return instantiatePayrollCell(collectionView, cellForItemAt: indexPath)
        }
    }
    
    private func instantiateCallLogCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CallLogCollectionCell.ID, for: indexPath) as? CallLogCollectionCell else {
            fatalError()
        }
        return cell
    }
    
    private func instantiateQuotesListCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QuotesListCollectionCell.ID, for: indexPath) as? QuotesListCollectionCell else {
            fatalError()
        }
        return cell
    }
    
    private func instantiateEstimatesListCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EstimatesListCollectionCell.ID, for: indexPath) as? EstimatesListCollectionCell else {
            fatalError()
        }
        return cell
    }
    
    private func instantiateBillingInvoiceListCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BillingInvoiceListCollectionCell.ID, for: indexPath) as? BillingInvoiceListCollectionCell else {
            fatalError()
        }
        return cell
    }
    
    private func instantiateStockedPartsListCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StockedPartsListCollectionCell.ID, for: indexPath) as? StockedPartsListCollectionCell else {
            fatalError()
        }
//        cell.isEditingEnabled = !isShowingWorker
//        cell.viewModel = createWorkerViewModel
        return cell
    }
    
    private func instantiateTimeSheetCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimeSheetCollectionCell.ID, for: indexPath) as? TimeSheetCollectionCell else {
            fatalError()
        }
        return cell
    }
    
    private func instantiatePayrollCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PayrollCollectionCell.ID, for: indexPath) as? PayrollCollectionCell else {
            fatalError()
        }
        return cell
    }
}

//MARK: - COLLECTION VIEW DELEGATE FLOW LAYOUT
extension LatestInfoTableCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width,
                      height: collectionView.frame.height)
    }
}
