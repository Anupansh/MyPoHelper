//
//  QuoteListView.swift
//  MyProHelper
//
//  Created by Deep on 1/24/21.
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

class QuoteListView: BaseDataTableView<QuoteEstimate, QuoteEstimateField>,Storyboarded {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = QuotesListViewModel(delegate: self)
        showHideSegmentedControl(isShown: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.addShowRemovedButton()
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
        let  quote = viewModel.getItem(at: indexPath.section)
        createQuoteEstimateView.viewModel = CreateQuoteEstimateViewModel(attachmentSource: .QOUTE)
        createQuoteEstimateView.setViewMode(isEditingEnabled: false)
        createQuoteEstimateView.viewModel.setQuote(quote: quote)
        navigationController?.pushViewController(createQuoteEstimateView, animated: true)
    }
    
    override func editItem(at indexPath: IndexPath) {
        let createQuoteEstimateView = CreateQuoteEstimateView.instantiate(storyboard: .QUOTES)
        let  quote = viewModel.getItem(at: indexPath.section)
        createQuoteEstimateView.viewModel = CreateQuoteEstimateViewModel(attachmentSource: .QOUTE)
        createQuoteEstimateView.setViewMode(isEditingEnabled: true)
        createQuoteEstimateView.viewModel.setQuote(quote: quote)
        navigationController?.pushViewController(createQuoteEstimateView, animated: true)
    }
}
