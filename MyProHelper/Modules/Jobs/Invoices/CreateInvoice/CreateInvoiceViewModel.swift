//
//  CreateInvoiceViewModel.swift
//  MyProHelper
//
//  Created by Deep on 2/4/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

class CreateInvoiceViewModel: BaseAttachmentViewModel {
    
    private var isUpdatingInvoice    = false
    private var hasMoreServiceUsed   = false
    private var hasMorePartUsed      = false
    private var hasMoreSuppliesUsed  = false
    
    var invoiceService = InvoiceService()
    var invoice: Box<Invoice>        = Box(Invoice())
    
    private var customers            : [Customer]    = []
    private var jobs                 : [Job]         = []
    
    private var serviceUsed          : [ServiceUsed] = []
    private var partsUsed            : [PartUsed]    = []
    private var suppliesUsed         : [SupplyUsed]  = []
    
    private var serviceTaxPercentage: Double = 0
    private var taxOnService = 0.00
    
    private var partTaxPercentage: Double = 0
    private var taxOnParts = 0.00
    
    private var supplyTaxPercentage: Double = 0
    private var taxOnSupply = 0.00

    
    //MARK: - SETTERS
    
    func setInvoice(invoice: Invoice) {
        self.isUpdatingInvoice = true
        self.invoice.value = invoice
        self.sourceId = invoice.invoiceID
        self.invoice.value.updateModifyDate()
        getServiceUsedItem {}
        getPartUsedItem {}
        getServiceUsedItem {}
    }
    
    func setDescription(description: String?) {
        invoice.value.description = description
    }
    
    func getIsUpdatingInvoice() -> Bool {
        return isUpdatingInvoice
    }
    
    func getInvoiceId() -> Int {
        return invoice.value.invoiceID!
    }
    
    func getServiceDates() -> String {
        var serviceDate = ""
        let job = invoice.value.job
        let currentServiceDate = "\(DateManager.dateToMonthFormat(date: job?.startDateTime))"
        let previousServiceDate = getPreviousServiceDates(job: job!)
        let nextServiceDate = getNextServiceDates(job: job!)
        serviceDate = "\(currentServiceDate),\(previousServiceDate.dropLast()),\(nextServiceDate.dropLast())"
        let lastTwoCharacters = serviceDate.suffix(2)
        if lastTwoCharacters == ",," || lastTwoCharacters == "," {
            return ""
        }
        return serviceDate
    }
    
    func getPreviousServiceDates(job: Job) -> String {
        if job.previousVisitJobId == nil || job.previousVisitJobId == 0 {
            return ""
        }
        let previousJob = DBHelper.fetchJob(jobID: job.previousVisitJobId!)
        return "\(DateManager.dateToMonthFormat(date: previousJob.startDateTime)),\(getPreviousServiceDates(job: previousJob))"
    }
    
    func getNextServiceDates(job: Job) -> String {
        if job.nextVisitJobId == nil || job.nextVisitJobId == 0 {
            return ""
        }
        let nextJob = DBHelper.fetchJob(jobID: job.nextVisitJobId!)
        return "\(DateManager.dateToMonthFormat(date: nextJob.startDateTime)),\(getNextServiceDates(job: nextJob))"
    }
    
    func setPriceQuoted(price: String?) {
        guard let priceQuoted = price else { return }
        invoice.value.priceQuoted = Float(priceQuoted) ?? 0.0
    }

    func setQuoteExpiration(date: String?) {
        guard let date = date else { return }
        invoice.value.priceExpires = DateManager.stringToDate(string: date)
    }
    
    func setCustomer(at index: Int) {
        let customer = customers[index]
        invoice.value.customerID = customer.customerID
        invoice.value.customer = customer
    }
    
    func setJob(at index: Int) {
        let job = jobs[index]
        invoice.value.jobID = job.jobID
        invoice.value.job = job
        invoice.value.status = job.jobStatus
    }
    
    func setInvoiceAdjustement(adjustement: String?) {
        guard let priceAdjustement = adjustement else { return }
        invoice.value.invoiceAdjustement = Float(priceAdjustement) ?? 0.0
    }
    
    func setCustomer(with customer: Customer) {
        invoice.value.customerID = customer.customerID
    }
    
    func setPriceEstimate() {
        invoice.value.priceEstimate = true
        invoice.value.priceFixedPrice = false
    }
    
    func setFixedPrice() {
        invoice.value.priceEstimate = false
        invoice.value.priceFixedPrice = true
    }
    
    func addServiceUsed(service: ServiceUsed) {
        serviceUsed.append(service)
    }
    
    func updateServiceUsed(service: ServiceUsed){
        if let index = serviceUsed.firstIndex(where: { $0.serviceUsedId == service.serviceUsedId}) {
            serviceUsed[index] = service
        }
    }
    
    func addPartUsed(part: PartUsed) {
        partsUsed.append(part)
    }
    
    func addSupplyUsed(supply: SupplyUsed) {
        suppliesUsed.append(supply)
    }
    
    func updatePartUsed(part: PartUsed) {
        if let index = partsUsed.firstIndex(where: { $0.partUsedId == part.partUsedId}) {
            partsUsed[index] = part
        }
    }
    
    func updateSupplyUsed(supply: SupplyUsed) {
        if let index = suppliesUsed.firstIndex(where: { $0.supplyUsedId == supply.supplyUsedId }){
            suppliesUsed[index] = supply
        }
    }
    
    func setServiceTaxPercentage(tax: String?) {
        guard let tax = tax else { return }
        serviceTaxPercentage = Double(tax) ?? 0.0
    }
    
    func setPartTaxPercentage(tax: String?) {
        guard let tax = tax else { return }
        partTaxPercentage = Double(tax) ?? 0.0
    }
    
    func setSupplyTaxPercentage(tax: String?) {
        guard let tax = tax else { return }
        supplyTaxPercentage = Double(tax) ?? 0.0
    }
    
    func setDiscountPercentage(discount: String?) {
        guard let discountPercent = discount else { return }
        invoice.value.percentDiscount = Float(discountPercent) ?? 0.0
    }
    
    func setCompletedDate(date: String?) {
        guard let date = date else { return }
        invoice.value.dateCompleted = DateManager.stringToDate(string: date)
    }
    
    //MARK: - Getters

    func getCustomers() -> [String] {
        return customers.compactMap({ $0.customerName })
    }
    
    func getCustomerName() -> String? {
        return invoice.value.customer?.customerName
    }
    
    func getJobTitle() -> String? {
        guard let jobTitle = invoice.value.job?.jobShortDescription  else {
            return nil
        }
        return jobTitle
    }
    
    func getJobs() -> [String] {
        return jobs.compactMap({ $0.jobShortDescription })
    }

    func getDescription() -> String? {
        return invoice.value.description
    }
    
    func getPriceQuoted() -> String? {
        return String(invoice.value.priceQuoted ?? 0.0)
    }

    func getQuoteExpirationDate() -> String? {
        return DateManager.dateToString(date: invoice.value.priceExpires)
    }
    
    func getInvoiceAdjustement() -> String? {
        return String(invoice.value.invoiceAdjustement ?? 0.0)
    }
    
    func isPriceEstimate() -> Bool {
        return invoice.value.priceEstimate ?? false
    }
    
    func isPriceFixed() -> Bool {
        return invoice.value.priceFixedPrice ?? true
    }
    
    func getServiceUsedItems() -> [ServiceUsed] {
        return serviceUsed
    }
    
    func getSupplyUsedItems() -> [SupplyUsed] {
        return suppliesUsed
    }
    
    func getServiceItem(at index: Int) -> ServiceUsed? {
        guard  serviceUsed.count > index else {
            return nil
        }
        return serviceUsed[index]
    }
    
    func getPartUsedItems() -> [PartUsed] {
        return partsUsed
    }
    
    func getPartItem(at index: Int) -> PartUsed? {
        guard  partsUsed.count > index else {
            return nil
        }
        return partsUsed[index]
    }
    
    func getSupplyItem(at index: Int) -> SupplyUsed? {
        guard  suppliesUsed.count > index else {
            return nil
        }
        return suppliesUsed[index]
    }
    
    // TAX PERCENTAGE VALUE WILL BE MODIFIED LATER
    func getTaxPercentage() -> String? {
        return String(serviceTaxPercentage)
    }
    
    func getTaxOnService() -> String? {
        var totalPriceToresell = 0.0
        serviceUsed.forEach {
            guard let price = $0.priceToResell else{
                return
            }
            totalPriceToresell += price
        }
        let serviceTax = totalPriceToresell * (serviceTaxPercentage / 100)
        taxOnService = serviceTax
        return serviceTax.stringValue
    }
    
    // PART TAX PERCENTAGE VALUE WILL BE MODIFIED LATER
    func getPartTaxPercentage() -> String? {
        return String(partTaxPercentage)
    }
    
    func getTaxOnParts() -> String? {
        var totalPriceToresell = 0.0
        partsUsed.forEach{
            guard let price = $0.priceToResell else { return }
            totalPriceToresell += price
        }
        
        let taxOnParts = totalPriceToresell * (partTaxPercentage / 100)
        return taxOnParts.stringValue
    }
    
    func getSupplyTaxPercentage() -> String? {
        return String(supplyTaxPercentage)
    }
    
    func getTaxOnSupplies() -> String? {
        var totalPriceToresell = 0.0
        suppliesUsed.forEach{
            guard let price = $0.priceToResell else { return }
            totalPriceToresell += price
        }
        
        let taxOnSupplies = totalPriceToresell * (supplyTaxPercentage / 100)
        return taxOnSupplies.stringValue
    }
    
    func getDiscountPercentage() -> String? {
        guard let discount = invoice.value.percentDiscount  else {
            return nil
        }
        return String(discount)
    }
    
    func getInvoiceCompletedDate() -> String? {
        return DateManager.getStandardDateString(date: invoice.value.dateCompleted)
    }
    
    func getTotaInvoiceAmount() -> String? {
        guard let amountTotal = invoice.value.totalInvoiceAmount else {
            return nil
        }
        return String(amountTotal)
    }

    func calculateTotalInvoiceAmount() {
        invoice.value.totalInvoiceAmount = 0.0
        var totalInvoiceAmount = 0.0
        
        var totalPriceToresellServices = 0.0
        serviceUsed.forEach{
            guard let price = $0.priceToResell else { return }
            totalPriceToresellServices += price
        }
        totalInvoiceAmount += totalPriceToresellServices
        
        var totalPriceToresellParts = 0.0
        partsUsed.forEach{
            guard let price = $0.priceToResell else { return }
            totalPriceToresellParts += price
        }
        totalInvoiceAmount += totalPriceToresellParts
        
        var totalPriceToresellSupplies = 0.0
        suppliesUsed.forEach{
            guard let price = $0.priceToResell else { return }
            totalPriceToresellSupplies += price
        }
        totalInvoiceAmount += totalPriceToresellSupplies
        
        totalInvoiceAmount += taxOnService + taxOnSupply + taxOnParts + Double(invoice.value.invoiceAdjustement ?? 0)
        
        invoice.value.totalInvoiceAmount = Float(totalInvoiceAmount)
    }
        
    //MARK: - Validations
    
    func validatePriceQuoted() -> ValidationResult {
        guard let price = getPriceQuoted() else {
            return .Invalid(message: "INVALID PRICE")
        }
        return Validator.validatePrice(price: Double(price) ?? 0.0)
    }
    
    func validateDescription() -> ValidationResult {
        return Validator.validateDescription(description: invoice.value.description)
    }
    
    func validateInvoiceAdjustement() -> ValidationResult {
        guard let priceAdjustemnt = getInvoiceAdjustement() else {
            return .Invalid(message: "INVALID PRICE")
        }
        return Validator.validatePrice(price: Double(priceAdjustemnt) ?? 0.0)
    }
    
    func validateCustomer() -> ValidationResult {
        guard  let customerName = getCustomerName() else {
            return .Invalid(message: "Please Select a Customer")
        }
        return Validator.validateName(name: customerName)
    }
    
    func validateJob() -> ValidationResult {
        guard let customerName = getJobTitle() else {
            return .Invalid(message: "Please Select a job")
        }
        return Validator.validateName(name: customerName)
    }

    func validateQuoteExpiration() -> ValidationResult {
        return Validator.validateDate(date: invoice.value.priceExpires)
    }
    
    func validateCompletedDate() -> ValidationResult {
        return Validator.validateDate(date: invoice.value.dateCompleted)
    }
    
    func isValidData() -> Bool {
        return
            validatePriceQuoted()             == .Valid &&
            validateDescription()             == .Valid &&
            validateInvoiceAdjustement()      == .Valid &&
            validateCustomer()                == .Valid &&
            validateJob()                     == .Valid &&
            validateCompletedDate()           == .Valid &&
            validateQuoteExpiration()         == .Valid
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
    
    func fetchCustomerJobs(completion: @escaping ()->()) {
        let customerJobsService = CustomerJobsService()
        guard let customer = invoice.value.customer  else {
            return
        }
        
        customerJobsService.fetchJobs(for: customer, offset: 0) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let jobs):
                self.jobs = jobs
                completion()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getServiceUsedItem(isReload: Bool = true, completion: @escaping () -> ()) {
        if !isReload && !hasMoreServiceUsed { return }
        guard let invoiceId = invoice.value.invoiceID else { return }
        let offset = (isReload) ? 0 : serviceUsed.count
        let serviceUsedService = ServiceUsedService()
        serviceUsedService.fetchServiceUsed(invoiceId: invoiceId, offset: offset) { (result) in
            switch result {
            case .success(let serviceItems):
                self.hasMoreServiceUsed = serviceItems.count == Constants.DATA_OFFSET
                if isReload {
                    self.serviceUsed = serviceItems
                }
                else {
                    self.serviceUsed.append(contentsOf: serviceItems)
                }
                completion()
            case .failure(let error):
                print(error)
                completion()
            }
        }
    }
    
    func getPartUsedItem(isReload: Bool = true, completion: @escaping () -> ()) {
        if !isReload && !hasMorePartUsed { return }
        guard let invoiceId = invoice.value.invoiceID else { return }
        let offset = (isReload) ? 0 : partsUsed.count
        let partUsedService = PartsUsedService()
        partUsedService.fetchPartUsed(invoiceId: invoiceId, offset: offset) { (result) in
            switch result {
            case .success(let partItems):
                self.hasMorePartUsed = partItems.count == Constants.DATA_OFFSET
                if isReload {
                    self.partsUsed = partItems
                }
                else {
                    self.partsUsed.append(contentsOf: partItems)
                }
                
                completion()
            case .failure(let error):
                print(error)
                completion()
            }
        }
    }
    
    func getSupplyUsedItem(isReload: Bool = true, completion: @escaping () -> ()) {
        if !isReload && !hasMoreSuppliesUsed { return }
        guard let invoiceId = invoice.value.invoiceID else { return }
        let offset = (isReload) ? 0 : suppliesUsed.count
        let supplyUsedService = SupplyUsedService()
        supplyUsedService.fetchSupplyUsed(invoiceId: invoiceId, offset: offset) { (result) in
            switch result {
            case .success(let suppliesUsed):
                self.hasMoreSuppliesUsed = suppliesUsed.count == Constants.DATA_OFFSET
                if isReload {
                    self.suppliesUsed = suppliesUsed
                }
                else {
                    self.suppliesUsed.append(contentsOf: suppliesUsed)
                }
                
                completion()
            case .failure(let error):
                print(error)
                completion()
            }
        }
    }
    
    func removeServiceUsedItemFromArray(service: ServiceUsed? , index: Int) {
          serviceUsed.remove(at: index)
    }
    
    func removePartUsedItemFromArray(part: PartUsed? , index: Int) {
        partsUsed.remove(at: index)
    }
    
    func removeSupplyUsedItemFromArray(supply: SupplyUsed? , index: Int) {
        suppliesUsed.remove(at: index)
    }
    
    //MARK: - Save Invoice, Service Used, Part Used and Supply Used
    
    func saveItem(completion: @escaping (_ error: String?, _ isValidData: Bool) -> ()) {
        if !isValidData() {
            completion(nil,false)
            return
        }
        invoice.value.numberOfAttachments = numberOfAttachment
        if isUpdatingInvoice {
            updateInvoice { (error) in
                completion(error,true)
            }
        }
        else {
            saveInvoice { (error) in
                completion(error,true)
            }
        }
    }
    
    private func saveInvoice(completion: @escaping (_ error: String?) -> ()) {
        invoiceService.createInvoice(invoice: invoice.value) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let invoiceId):
                self.saveAttachment(id: Int(invoiceId))
                
                self.saveServices(for: Int(invoiceId)) { error in
                    self.saveParts(for: Int(invoiceId)) { error in
                        self.saveSupplies(for: Int(invoiceId)) { error in
                            completion(error)
                        }
                    }
                }
                
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    private func updateInvoice(completion: @escaping (_ error: String?) -> ()) {
        guard let invoiceId = invoice.value.invoiceID else {
            completion("an error has occurred")
            return
        }
        
        invoiceService.updateInvoice(invoice: invoice.value) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.saveAttachment(id: invoiceId)
                
                self.saveServices(for: Int(invoiceId)) { error in
                    completion(error)
                }
                self.saveParts(for: Int(invoiceId)) { error in
                    completion(error)
                }
            
                self.saveSupplies(for: Int(invoiceId)) { error in
                    completion(error)
                }
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    private func saveServices(for invoiceId: Int, completion: @escaping (_ error: String?)->()) {
        let serviceUsedService = ServiceUsedService()
        var numberOfServices = serviceUsed.count
        
        if numberOfServices == 0 {
           completion(nil)
           return
        }
        
        for var service in serviceUsed {
            service.invoiceId = invoiceId
            serviceUsedService.addServiceUsed(service: service) { (result) in
                switch result {
                case .success(_):
                    numberOfServices -= 1
                    if numberOfServices == 0 {
                        completion(nil)
                    }
                case .failure(let error):
                    completion(error.localizedDescription)
                }
            }
        }
    }
    
    private func saveParts(for invoiceId: Int, completion: @escaping (_ error: String?)->()) {
        let partUsedService = PartsUsedService()
        var numberOfParts = partsUsed.count
        
        if numberOfParts == 0 {
           completion(nil)
           return
        }
        
        for var part in partsUsed {
            part.InvoiceId = invoiceId
            partUsedService.addPartUsed(part: part) { (result) in
                switch result {
                case .success(_):
                    numberOfParts -= 1
                    if numberOfParts == 0 {
                        completion(nil)
                    }
                case .failure(let error):
                    completion(error.localizedDescription)
                }
            }
        }
    }
    
    private func saveSupplies(for invoiceId: Int, completion: @escaping (_ error: String?)->()) {
        let supplyUsedService = SupplyUsedService()
        var numberOfSupplies = suppliesUsed.count
        
        if numberOfSupplies == 0 {
           completion(nil)
           return
        }
        
        for var supply in suppliesUsed {
            supply.InvoiceId = invoiceId
            supplyUsedService.addSupplyUsed(supplyUsed: supply) { (result) in
                switch result {
                case .success(_):
                    numberOfSupplies -= 1
                    if numberOfSupplies == 0 {
                        completion(nil)
                    }
                case .failure(let error):
                    completion(error.localizedDescription)
                }
            }
        }
    }
    
    func deleteServiceUsed(service: ServiceUsed, completion: @escaping (_ error: String?)->()) {
        let serviceUsedService = ServiceUsedService()
        serviceUsedService.delete(service: service) { (result) in
            switch result {
                case .success(_):
                    completion(nil)
               case .failure(let error):
                    completion(error.localizedDescription)
            }
        }
    }
    
    func deletePartUsed(part: PartUsed, completion: @escaping (_ error: String?)->()) {
        let partUsedService = PartsUsedService()
        partUsedService.delete(part: part) { (result) in
            switch result {
                case .success(_):
                    completion(nil)
               case .failure(let error):
                    completion(error.localizedDescription)
            }
        }
    }
    
    func deleteSupplyUsed(supply: SupplyUsed, completion: @escaping (_ error: String?)->()) {
        let supplyUsedService = SupplyUsedService()
        supplyUsedService.deleteSupplyUsed(supply: supply) { (result) in
            switch result {
                case .success(_):
                    completion(nil)
               case .failure(let error):
                    completion(error.localizedDescription)
            }
        }
    }
}

