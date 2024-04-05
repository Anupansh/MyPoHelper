//
//  Estimates.swift
//  MyProHelper
//
//  Created by Deep on 1/31/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import UIKit

//enum QuoteEstimateField: String {
//    case CUSOTMER_NAME          = "CUSTOMER_NAME"
//    case DESCRIPTION            = "DESCRIPTION"
//    case PRICE_QUOTED           = "PRICE_QUOTED"
//    case PRICE_ESTIMATE         = "PRICE_ESTIMATE"
//    case FIXED_PRICE            = "FIXED_PRICE"
//    case QUOTE_EXPIRATION       = "QUOTE_EXPIRATION"
//    case ATTACHMENTS            = "ATTACHMENTS"
//}

class EstimateListView: BaseDataTableView<QuoteEstimate, QuoteEstimateField>,Storyboarded {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = EstimateListViewModel(delegate: self)
        showHideSegmentedControl(isShown: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.addShowRemovedButton()
    }
    
    @objc override func handleSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            print("Quote Selected")
            let QuoteView = QuoteListView.instantiate(storyboard: .QUOTES)
            navigationController?.pushViewController(QuoteView, animated: false)
        case 1:
            print("Estimate Selected")
            let estimateView = EstimateListView.instantiate(storyboard: .ESTIMATES)
            navigationController?.pushViewController(estimateView, animated: false)
        //GenericViewController(viewController: estimateView, key: .quotesAndEstimates)
        default:
            print("default value")
        }
    }
    
    @objc override func handleAddItem() {
        let createQuoteEstimateView = CreateQuoteEstimateView.instantiate(storyboard: .QUOTES)
        createQuoteEstimateView.viewModel = CreateQuoteEstimateViewModel(attachmentSource: .QOUTE)
        createQuoteEstimateView.setViewMode(isEditingEnabled: true)
        navigationController?.pushViewController(createQuoteEstimateView, animated: true)
    }
    
    override func setDataTableFields() {
        dataTableFields = [
            .CUSOTMER_NAME,
            .DESCRIPTION,
            .PRICE_QUOTED,
            .PRICE_ESTIMATE,
            .FIXED_PRICE,
            .QUOTE_EXPIRATION,
            .ATTACHMENTS
        ]
    }
    
    override func getHeader(for columnIndex: NSInteger) -> String {
        return dataTableFields[columnIndex].rawValue.localize
    }
    
    override func showItem(at indexPath: IndexPath) {
        let createQuoteEstimateView = CreateQuoteEstimateView.instantiate(storyboard: .QUOTES)
        let estimate = viewModel.getItem(at: indexPath.section)
        createQuoteEstimateView.viewModel = CreateQuoteEstimateViewModel(attachmentSource: .ESTIMATE)
        createQuoteEstimateView.setViewMode(isEditingEnabled: false)
        createQuoteEstimateView.viewModel.setEstimate(estimate: estimate)
        navigationController?.pushViewController(createQuoteEstimateView, animated: true)
    }
    
    override func editItem(at indexPath: IndexPath) {
        let createQuoteEstimateView = CreateQuoteEstimateView.instantiate(storyboard: .QUOTES)
        let estimate = viewModel.getItem(at: indexPath.section)
        createQuoteEstimateView.viewModel = CreateQuoteEstimateViewModel(attachmentSource: .ESTIMATE)
        createQuoteEstimateView.setViewMode(isEditingEnabled: true)
        createQuoteEstimateView.viewModel.setEstimate(estimate: estimate)
        navigationController?.pushViewController(createQuoteEstimateView, animated: true)
    }
    
}
