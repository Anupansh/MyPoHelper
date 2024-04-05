//
//  CreateQuoteAndEstimateViewModel.swift
//  MyProHelper
//
//  Created by Deep on 2/1/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

// TBD CREATE ENUM INSTEAD OF IF ELSE STATEMENT
//private enum Type: String {
//    case QUOTE     = "QUOTE"
//    case ESTIMATE  = "ESTIMATE"
//}

class CreateQuoteEstimateViewModel: BaseAttachmentViewModel {
    
    private var isUpdatingQuoteEstimate = false
    private let quoteDbService    = QuoteService()
    private var estimateDBService = EstimateService()
    
    var quote     : Box<QuoteEstimate>     = Box(QuoteEstimate())
    var estimate  : Box<QuoteEstimate>     = Box(QuoteEstimate())
    
    private var customers: [Customer] = []
    
    private var isQuote: Bool = true
    private var isEstimate: Bool = false
    
    //MARK: - Setters
    func setQuote(quote: QuoteEstimate) {
        self.quote.value = quote
        self.isUpdatingQuoteEstimate = true
        self.sourceId = quote.quoteId
        isQuote = true
        isEstimate = false
    }
    
    func setEstimate(estimate: QuoteEstimate) {
        self.estimate.value = estimate
        self.isUpdatingQuoteEstimate = true
        self.sourceId = estimate.estimateId
        isQuote = false
        isEstimate = true
    }
    
    func setDescription(description: String?) {
        quote.value.description = description
        estimate.value.description = description
    }
    
    func setPriceQuoted(price: String?) {
        guard let priceQuoted = price else { return }
        quote.value.priceQuoted = Float(priceQuoted) ?? 0.0
        estimate.value.priceQuoted = Float(priceQuoted) ?? 0.0
    }

    func setQuoteExpiration(date: String?) {
        guard let date = date else { return }
        quote.value.priceExpires = DateManager.stringToDate(string: date)
        estimate.value.priceExpires = DateManager.stringToDate(string: date)
    }
    
    func setCustomer(at index: Int) {
        let customer = customers[index]
        quote.value.customer = customer
        estimate.value.customer = customer
        quote.value.customerID = customer.customerID
        estimate.value.customerID = customer.customerID
        quote.value.customer = customer
        estimate.value.customer = customer
    }
    
    func setCustomer(with customer: Customer) {
        quote.value.customer = customer
        estimate.value.customer = customer
        quote.value.customerID = customer.customerID
        estimate.value.customerID = customer.customerID
        quote.value.customer = customer
        estimate.value.customer = customer
    }
    
    func setIsQuote() {
        isQuote = true
        isEstimate = false
    }
    
    func setIsEstimate() {
        isQuote = false
        isEstimate = true
    }
    
    func setPriceEstimate() {
        quote.value.priceEstimate = true
        quote.value.priceFixedPrice = false
        
        estimate.value.priceEstimate = true
        estimate.value.priceFixedPrice = false
        
    }
    
    func setFixedPrice() {
        quote.value.priceEstimate = false
        quote.value.priceFixedPrice = true
        
        estimate.value.priceEstimate = false
        estimate.value.priceFixedPrice = true
    }
    
    //MARK: - Getters
    
    func getIsQuote () -> Bool {
        return isQuote
    }
    func getIsEsttimate() -> Bool {
        return isEstimate
    }

    func getCustomers() -> [String] {
        return customers.compactMap({ $0.customerName })
    }
    
    func getCustomerName() -> String? {
        if isQuote {
            return quote.value.customer?.customerName
        }else {
            return estimate.value.customer?.customerName
        }
       
    }
    
    func getDescription() -> String? {
        if isQuote {
            return quote.value.description
        }else {
            return estimate.value.description
        }
    }
    
    func getPriceQuoted() -> String? {
        if isQuote {
            return String(quote.value.priceQuoted ?? 0.0)
        }else {
            return String(estimate.value.priceQuoted ?? 0.0)
        }
    }

    func getQuoteExpirationDate() -> String? {
        if isQuote {
            return DateManager.getStandardDateString(date: quote.value.priceExpires)
        }else {
            return DateManager.getStandardDateString(date: estimate.value.priceExpires)
        }
    }
    
    func isPriceEstimate() -> Bool {
        if isQuote {
            return quote.value.priceEstimate ?? false
        }else {
            return estimate.value.priceEstimate ?? false
        }
       
    }
    
    func isPriceFixed() -> Bool {
        if isQuote {
            return quote.value.priceFixedPrice ?? false
        }else {
            return estimate.value.priceFixedPrice ?? false
        }
    }
    
    //MARK: - Validations
    func validatePriceQuoted() -> ValidationResult {
        guard let price = getPriceQuoted() else {
            return .Invalid(message: "INVALID PRICE")
        }
        return Validator.validatePrice(price: Double(price) ?? 0.0)
    }
    
    func validateDescription() -> ValidationResult {
        guard let description = getDescription(), !description.isEmpty else {
            return .Valid
        }
        return Validator.validateDescription(description: description)
    }
    
    func validateCustomer() -> ValidationResult {
        guard  let customerName = getCustomerName() else {
            return .Invalid(message: "Please Select a Customer")
        }
        return Validator.validateName(name: customerName)
    }

    func isValidData() -> Bool {
        return
            validatePriceQuoted()             == .Valid &&
            validateDescription()             == .Valid &&
            validateCustomer()                == .Valid
    }


    
    //MARK: - Data Base service
    
    func fetchCustomers(completion: @escaping ()->()) {
        let customerService = CustomersService()
        customerService.fetchCustomers(offset: 0) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let customers):
                self.customers = customers
                completion()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func saveItem(completion: @escaping (_ error: String?, _ isValidData: Bool) -> ()) {
        if !isValidData() {
            completion(nil, false)
            return
        }
        quote.value.numberOfAttachments    = numberOfAttachment
        estimate.value.numberOfAttachments = numberOfAttachment
        if isUpdatingQuoteEstimate {
            if isQuote{
                updateQuote { (error) in
                    completion(error, true)
                }
            }else {
                updateEstimate { (error) in
                    completion(error, true)
                }
            }
        } else {
            if isQuote {
                createQuote { (error) in
                    completion(error, true)
                }
            }else {
                createEstimate { (error) in
                    completion(error, true)
                }
            }
        }
    }
    
    private func updateQuote(completion: @escaping (_ error: String?)->()) {
        quoteDbService.updateQuote(quote: quote.value) { [unowned self] (result) in
            switch result {
            case .success(_):
                if let quoteId = self.quote.value.quoteId {
                    self.saveAttachment(id: quoteId)
                }
                completion(nil)
                
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    private func updateEstimate(completion: @escaping (_ error: String?)->()) {
        estimateDBService.updateEstimate(estimate: estimate.value) { [unowned self] (result) in
            switch result {
            case .success(_):
                if let estimateId = self.estimate.value.estimateId {
                    self.saveAttachment(id: estimateId)
                }
                completion(nil)
                
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    private func createQuote(completion: @escaping (_ error: String?)->()) {
        quoteDbService.createQuote(quote: quote.value) { (result) in
            switch result {
            case .success(let quoteID):
                self.quote.value.quoteId = Int(quoteID)
                self.saveAttachment(id: Int(quoteID))
                completion(nil)

            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    private func createEstimate(completion: @escaping (_ error: String?)-> ()){
        estimateDBService.createEstimate(estimate: estimate.value) { (result) in
            switch result{
            case .success(let estimateID):
                self.estimate.value.estimateId = Int(estimateID)
                self.saveAttachment(id: Int(estimateID))
                completion(nil)
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
}

