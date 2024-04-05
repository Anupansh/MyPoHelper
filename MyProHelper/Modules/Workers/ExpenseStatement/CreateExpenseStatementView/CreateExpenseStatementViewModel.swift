//
//  CreateExpenseStatementViewModel.swift
//  MyProHelper
//
//  Created by sismac010 on 12/05/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

class CreateExpenseStatementViewModel: BaseAttachmentViewModel {
    private var expenseStatements = ExpenseStatements()
    private var customers: [Customer] = []
    private var workers: [Worker] = []
    private var lineItems: [ExpenseStatementsUsed] = []
    private var isUpdatingExpenseStatements = false
    private var hasMoreStocks = false
    private var expenseStatementService = ExpenseStatementService()
    private var total:Double = 0.0
    private var isCanEditTimeAlreadyEntered:Bool = false
    private var isUpdatingWorkOrder = false
    
    func setExpenseStatement(expenseStatements: ExpenseStatements) {
        self.isUpdatingExpenseStatements = true
        self.expenseStatements = expenseStatements
        self.sourceId = expenseStatements.expenseStatementsId
        self.expenseStatements.updateModifyDate()
    }
    
    func setExpenseStatement(ExpenseStatement: ExpenseStatements) {
        self.isUpdatingWorkOrder = true
        self.expenseStatements = ExpenseStatement
        self.sourceId = ExpenseStatement.expenseStatementsId
        self.expenseStatements.updateModifyDate()
    }
    
    func getLineItems() -> [ExpenseStatementsUsed] {
        return lineItems
    }

    func getLineItem(at index: Int) -> ExpenseStatementsUsed? {
        guard lineItems.count > index else { return nil }
        return lineItems[index]
    }
    
    func getCustomers(completion: @escaping () -> ()) {
        let customersService = CustomersService()
        customersService.fetchCustomers(showSelect: true,offset: 0) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let customers):
                // Local added because values is not stored in db
                var customer = Customer()
                customer.customerName = Constants.DefaultValue.SELECT_LIST
                self.customers.removeAll()
                self.customers.append(customer)
                self.customers.append(contentsOf: customers)
                
//                self.customers = customers
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getCanEditTimeAlreadyEntered(workerID:String, completion: @escaping () -> ()) {
        let workersService = WorkersService()
        workersService.fetchWorkerCanEditTimeAlreadyEntered(workerID:workerID) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                self.isCanEditTimeAlreadyEntered = value
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func canEditWorker() -> Bool {
        return expenseStatements.expenseStatementsId == nil || expenseStatements.expenseStatementsId != nil && self.isCanEditTimeAlreadyEntered
    }
    
    
    
    func getWorkers(completion: @escaping () -> ()) {
        let workersService = WorkersService()
        workersService.fetchWorkers(showSelect: true,offset: 0) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let workers):
                self.workers = workers
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func setWorker(at index: Int?) {
        guard let index = index, index < workers.count else {return}
        if index == 0{
            let worker = workers[index]
            expenseStatements.workerName = worker.firstName!
            return
        }
        expenseStatements.worker = workers[index]
        expenseStatements.workerId = expenseStatements.worker?.workerID
        expenseStatements.workerName = expenseStatements.worker!.firstName! + " " + expenseStatements.worker!.lastName!
        
    }
    
    func setCustomer(at index: Int?) {
        guard let index = index, index < customers.count else { return }
        if index == 0{
            let customer = customers[index]
            expenseStatements.customerName = customer.customerName
            return
        }
        expenseStatements.customer = customers[index]
        expenseStatements.customerId = expenseStatements.customer?.customerID
        expenseStatements.customerName = expenseStatements.customer?.customerName
    }
    
    func getCustomers() -> [String] {
        return customers.compactMap({ $0.customerName })
    }
    
    func getWorkers() -> [String] {
        return workers.compactMap({ ($0.firstName! + " " + $0.lastName!)})
    }
    
    func getCustomer() -> String? {
        return expenseStatements.customer?.customerName
    }
    
    func getWorker() -> String? {
        return expenseStatements.workerName
    }
    
    func isValidData() -> Bool {
        return  validateCustomer()          == .Valid &&
                validateWorker()            == .Valid &&
                validateDescription()       == .Valid
    }
    
    func validateDescription() -> ValidationResult {
        guard let description = expenseStatements.description, !description.isEmpty else {
            return .Valid
        }
        return Validator.validateName(name: description)
    }
    
    func validateWorker() -> ValidationResult {
        if expenseStatements.workerId == nil && expenseStatements.workerName == nil{
            return .Invalid(message: Constants.Message.NAME_SELECT_ERROR)
        }
        
        if let workerName = expenseStatements.workerName , expenseStatements.workerId == nil{
            if workerName == Constants.DefaultValue.SELECT_LIST{

                return .Invalid(message: Constants.Message.NAME_SELECT_ERROR)
            }
            return .Valid
        }
        if let workerName = expenseStatements.workerName{
            if workerName == Constants.DefaultValue.SELECT_LIST{

                return .Invalid(message: Constants.Message.NAME_SELECT_ERROR)
            }
            return .Valid
        }
        
        return .Valid
    }
    
    func validateCustomer() -> ValidationResult {
        guard let customerName = expenseStatements.customerName, !customerName.isEmpty else {
            return .Valid
        }
        /*
        if expenseStatements.customerId == nil && expenseStatements.customerName == nil{
            return .Invalid(message: Constants.Message.NAME_SELECT_ERROR)
        }
        
        if let customerName = expenseStatements.customerName , expenseStatements.customerId == nil{
            if customerName == Constants.DefaultValue.SELECT_LIST{

                return .Invalid(message: Constants.Message.NAME_SELECT_ERROR)
            }
            return .Valid
        }
        if let customerName = expenseStatements.customerName{
            if customerName == Constants.DefaultValue.SELECT_LIST{

                return .Invalid(message: Constants.Message.NAME_SELECT_ERROR)
            }
            return .Valid
        }
        */
        return .Valid
    }

    func setDescription(description: String?) {
        expenseStatements.description = description
    }
    
    func getDescription() -> String? {
        return expenseStatements.description
    }
    
    func validateSalesTax() -> ValidationResult {
        guard let salesTax = expenseStatements.salesTax else {
            return .Valid
        }
        return Validator.validatePrice(price: salesTax)
    }
    
    func validateShipping() -> ValidationResult {
        guard let shipping = expenseStatements.shipping else {
            return .Valid
        }
        return Validator.validatePrice(price: shipping)
    }
    
    func setSalesTax(price: String?) {
        guard let price = price else { return }
        expenseStatements.salesTax = Double(price)
    }
    
    func setShipping(price: String?) {
        guard let price = price else { return }
        expenseStatements.shipping = Double(price)
    }
    
    func setTotal() {
        var sum:Double = 0.0
        for item in lineItems {
            sum += (item.pricePerItem ?? 0) * Double(item.quantity ?? 0)
        }
        sum += expenseStatements.salesTax ?? 0
        sum += expenseStatements.shipping ?? 0
        total = sum
    }
    
    func getTotal() -> String? {
        return total.stringValue
    }
    
    
    func getSalesTax() -> String? {
        return expenseStatements.salesTax?.stringValue
    }
    
    func getShipping() -> String? {
        return expenseStatements.shipping?.stringValue
    }
    
    func addLineItem(lineItem: ExpenseStatementsUsed) {
        
        if let index = lineItems.firstIndex(of: lineItem) {
            lineItems[index].increaseQuantity(by: lineItem.quantity)
        }
        else {
            lineItems.append(lineItem)
        }
    }
    
    func updateLineItem(lineItem: ExpenseStatementsUsed) {
        if let index = lineItems.firstIndex(where: { $0.expenseStatementsUsedId == lineItem.expenseStatementsUsedId && $0.lineItemId == lineItem.lineItemId}) {
            lineItems[index] = lineItem
        }
    }
    
    func getMaxLineItemId(completion: @escaping (_ ID:Int?) -> ()){
        let expenseStatementsUsedRepository = ExpenseStatementsLineItemService()
        expenseStatementsUsedRepository.fetchMaxExpenseStatementsUsedID { (result) in
            switch result {
            case .success(let ID):
                completion(ID)
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }
    
    func getExpenseStatementsLineItems(isReload: Bool = true, showRemoved:Bool, completion: @escaping () -> ()) {
        if !isReload && !hasMoreStocks {
            return
        }
        guard let expenseStatementsId = expenseStatements.expenseStatementsId else {
            return
        }
        
        let offset = (isReload) ? 0 : lineItems.count
        let expenseStatementsLineItemService = ExpenseStatementsLineItemService()

        expenseStatementsLineItemService.fetchLineItem(lineItemID: expenseStatementsId,showRemoved: showRemoved, offset: offset) { (result) in
            switch result {

            case .success(let lineItems):
                self.hasMoreStocks = lineItems.count == Constants.DATA_OFFSET
                if isReload {
                    self.lineItems = lineItems
                }
                else {
                    self.lineItems.append(contentsOf: lineItems)
                }

                completion()
            case .failure(let error):
                print(error)
                completion()
            }
        }
    }
    
    func addExpenseStatements(completion: @escaping (_ error: String?, _ isValidData: Bool) -> ()) {
        if !isValidData() {
            completion(nil,false)
            return
        }
        expenseStatements.numberOfAttachments = numberOfAttachment
        expenseStatements.dateCreated = Date()
        if isUpdatingExpenseStatements {
            updateExpenseStatements { (error) in
                completion(error,true)
            }
        }
        else {
            saveExpenseStatements { (error) in
                completion(error,true)
            }
        }
        
    }
    
    private func updateExpenseStatements(completion: @escaping (_ error: String?) -> ()) {
        guard let expenseStatementsId = expenseStatements.expenseStatementsId else {
            completion("an error has occurred")
            return
        }
        
        expenseStatementService.updateExpenseStatements(expenseStatements: expenseStatements) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.saveAttachment(id: Int(expenseStatementsId))
                self.saveLineItem(for: Int(expenseStatementsId)) { error in
                    completion(error)
                }
                break
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    private func saveExpenseStatements(completion: @escaping (_ error: String?) -> ()) {
        expenseStatementService.createExpenseStatements(expenseStatements: expenseStatements) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let expenseStatementsId):
                self.saveAttachment(id: Int(expenseStatementsId))
                self.saveLineItem(for: Int(expenseStatementsId)) { error in
                    completion(error)
                }
                
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    private func saveLineItem(for expenseStatementsId: Int, completion: @escaping (_ error: String?)->()) {
//        let workOrderLineItemService = WorkOrderLineItemService()
        let expenseStatementsLineItemService = ExpenseStatementsLineItemService()
        var numberOfLineItems = lineItems.count

        if numberOfLineItems == 0 {
            completion(nil)
            return
        }

        for var lineItem in lineItems {
            lineItem.expenseStatementsId = expenseStatementsId
            expenseStatementsLineItemService.addLineItem(lineItem: lineItem) { (result) in
                switch result {
                case .success(_):
                    numberOfLineItems -= 1
                    if numberOfLineItems == 0 {
                        completion(nil)
                    }
                case .failure(let error):
                    completion(error.localizedDescription)
                }
            }
        }
        
    }
    
    func deleteLineItem(lineItem: ExpenseStatementsUsed, completion: @escaping (_ error: String?)->()) {
        let expenseStatementsLineItemService = ExpenseStatementsLineItemService()
        expenseStatementsLineItemService.delete(lineItem: lineItem) { (result) in
            switch result {
            case .success(_):
                completion(nil)
                
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    func undeleteLineItem(lineItem: ExpenseStatementsUsed, completion: @escaping (_ error: String?)->()) {
        let expenseStatementsLineItemService = ExpenseStatementsLineItemService()
        expenseStatementsLineItemService.undelete(lineItem: lineItem) { (result) in
            switch result {
            case .success(_):
                completion(nil)
                
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    func removeLineItem(lineItem: ExpenseStatementsUsed) {
        if let index = lineItems.firstIndex(of: lineItem) {
            lineItems.remove(at: index)
        }
    }
    
    
    
    
}
