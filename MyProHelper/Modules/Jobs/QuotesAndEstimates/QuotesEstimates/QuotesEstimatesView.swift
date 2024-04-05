//
//  QuotesEstimateView.swift
//  MyProHelper
//
//  Created by Deep on 2/3/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import UIKit

enum QuoteEstimateField: String {
    case CUSOTMER_NAME          = "CUSTOMER_NAME"
    case DESCRIPTION            = "DESCRIPTION"
    case PRICE_QUOTED           = "PRICE_QUOTED"
    case PRICE_ESTIMATE         = "PRICE_ESTIMATE"
    case FIXED_PRICE            = "FIXED_PRICE"
    case QUOTE_EXPIRATION       = "QUOTE_EXPIRATION"
    case ATTACHMENTS            = "ATTACHMENTS"
}

class QuotesEstimatesView: BaseDataTableView<QuoteEstimate, QuoteEstimateField>,Storyboarded {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Quotes/ Estimates"
        viewModel = QuotesEstimatesViewModel(delegate: self)
        showHideSegmentedControl(isShown: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.addShowRemovedButton()
    }
    
    @objc override func handleSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        guard let viewModel = viewModel as? QuotesEstimatesViewModel else { return }
        switch sender.selectedSegmentIndex {
        case 0:
            print("Quote Selected")
            viewModel.setIsQuote()
        case 1:
            print("Estimate Selected")
            viewModel.setIsEstimate()
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
        guard let viewModel = viewModel as? QuotesEstimatesViewModel else { return }
        if viewModel.getIsQuote() {
            showQuote(at: indexPath)
        }else {
            showEstimate(at: indexPath)
        }
    }
    private func showQuote(at indexPath: IndexPath){
        let createQuoteEstimateView = CreateQuoteEstimateView.instantiate(storyboard: .QUOTES)
        let  quote = viewModel.getItem(at: indexPath.section)
        createQuoteEstimateView.viewModel = CreateQuoteEstimateViewModel(attachmentSource: .QOUTE)
        createQuoteEstimateView.setViewMode(isEditingEnabled: false)
        createQuoteEstimateView.viewModel.setQuote(quote: quote)
        navigationController?.pushViewController(createQuoteEstimateView, animated: true)
    }
    
    private func showEstimate(at indexPath: IndexPath){
        let createQuoteEstimateView = CreateQuoteEstimateView.instantiate(storyboard: .QUOTES)
        let estimate = viewModel.getItem(at: indexPath.section)
        createQuoteEstimateView.viewModel = CreateQuoteEstimateViewModel(attachmentSource: .ESTIMATE)
        createQuoteEstimateView.setViewMode(isEditingEnabled: false)
        createQuoteEstimateView.viewModel.setEstimate(estimate: estimate)
        navigationController?.pushViewController(createQuoteEstimateView, animated: true)
    }
    
    override func editItem(at indexPath: IndexPath) {
        guard let viewModel = viewModel as? QuotesEstimatesViewModel else { return }
        if viewModel.getIsQuote() {
            editQuote(at: indexPath)
        }else {
            editEstimate(at: indexPath)
        }
    }
    
    private func editQuote(at indexPath: IndexPath){
        let createQuoteEstimateView = CreateQuoteEstimateView.instantiate(storyboard: .QUOTES)
        let  quote = viewModel.getItem(at: indexPath.section)
        createQuoteEstimateView.viewModel = CreateQuoteEstimateViewModel(attachmentSource: .QOUTE)
        createQuoteEstimateView.setViewMode(isEditingEnabled: true)
        createQuoteEstimateView.viewModel.setQuote(quote: quote)
        navigationController?.pushViewController(createQuoteEstimateView, animated: true)
    }
    
    private func editEstimate(at indexPath: IndexPath){
        let createQuoteEstimateView = CreateQuoteEstimateView.instantiate(storyboard: .QUOTES)
        let estimate = viewModel.getItem(at: indexPath.section)
        createQuoteEstimateView.viewModel = CreateQuoteEstimateViewModel(attachmentSource: .ESTIMATE)
        createQuoteEstimateView.setViewMode(isEditingEnabled: true)
        createQuoteEstimateView.viewModel.setEstimate(estimate: estimate)
        navigationController?.pushViewController(createQuoteEstimateView, animated: true)
    }
}
