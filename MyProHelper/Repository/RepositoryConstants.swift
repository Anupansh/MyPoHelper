//
//  RepositoryConstants.swift
//  MyProHelper
//
//  Created by Samir on 12/2/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

struct RepositoryConstants {
    
    struct Tables {
        static let ASSETS                   = "Assets"
        static let ASSET_TYPES              = "AssetTypes"
        static let SUPPLY_LOCATIONS         = "SupplyLocations"
        static let PART_LOCATIONS           = "PartLocations"
        static let SERVICE_TYPES            = "ServiceTypes"
        static let VENDORS                  = "Vendors"
        static let CUSTOMERS                = "Customers"
        static let WORKERS                  = "Workers"
        static let ATTACHMENTS              = "Attachments"
        static let QOUTES                   = "Quotes"
        static let ESTIMATES                = "Estimates"
        static let EXPENSE_STATEMENTS       = "ExpenseStatements"
        static let EXPENSE_STATEMENTS_USED  = "ExpenseStatementUsed"
        static let INVOICES                 = "Invoices"
        static let PARTS                    = "Parts"
        static let PURCHASE_ORDERS          = "PurchaseOrders"
        static let RECEIPTS                 = "Receipts"
        static let SCHEDULED_JOBS           = "ScheduledJobs"
        static let SUPPLIES                 = "Supplies"
        static let WAGES                    = "Wages"
        static let PAYMENTS                 = "Payments"
        static let WORK_ORDERS              = "WorkOrders"
        static let WORK_ORDERS_Used         = "WorkOrderUsed"
        static let PART_FINDERS             = "PartFinders"
        static let JOBS_WORKERS             = "JobsWorkers"
        static let WORKER_HOME_ADDRESSES    = "WorkerHomeAddresses"
        static let DEVICES                  = "Devices"
        static let WORKER_ROLES             = "WorkerRoles"
        static let WORKER_ROLES_GROUPS      = "WorkerRolesGroups"
        static let HOLIDAYS                 = "Holidays"
        static let JOB_HISTORY              = "JobHistory"
        static let SERVICES_USED            = "ServicesUsed"
        static let PARTS_USED               = "PartsUsed"
        static let SUPPLIES_USED            = "SuppliesUsed"
        static let SUPPLY_FINDERS           = "SupplyFinders"
        static let JOB_DETAILS              = "JobDetails"
        static let TIME_OFF_REQUESTS        = "TimeOffRequests"
        static let CURRENT_TIME_SHEETS      = "TimeCards"
        static let COMPANY_SETTINGS         = "CompanySettings"
        //        static let APPROVAL                 = "TimeOffRequests"
        static let APPROVAL                 = "TimeOffRequests"
        
        static let PURCHASE_ORDERS_Used     = "PurchaseOrdersUsed"
        static let DBVersionChanges         = "DBVersionChanges"
    }
    
    struct Columns {
        // GENERIC COLUMNS
        static let ATTACHMENTS_date              = "Attachments"
        static let REQUESTED_DATE              = "Requesteddate"
        static let TOTAL_AMOUNT              = "Totalamount"
        static let DESCRIPTION              = "Description"
        static let MODEL_INFO               = "ModelInfo"
        static let DATE_PURHCASED           = "DatePurchased"
        static let SERIAL_NUMBER            = "SerialNumber"
        static let DATE_CREATED             = "DateCreated"
        static let DATE_MODIFIED            = "DateModified"
        static let PURHCASE_PRICE           = "PurchasePrice"
        static let LATEST_MAINTENANCE_DATE  = "LatestMaintenanceDate"
        static let MILEAGE                  = "Mileage"
        static let HOURS_USED               = "HoursUsed"
        static let REMOVED                  = "Removed"
        static let REMOVED_DATE             = "RemovedDate"
        static let CREATED_DATE             = "CreatedDate"
        static let MODIFIED_DATE            = "ModifiedDate"
        static let NUMBER_OF_ATTACHMENTS    = "NumberOfAttachments"
        static let LOCATION_NAME            = "LocationName"
        static let LOCATION_DESCRIPTION     = "LocationDescription"
        static let PRICE_QUOTE              = "PriceQuote"
        static let PHONE                    = "Phone"
        static let EMAIL                    = "Email"
        static let CONTACT_NAME             = "ContactName"
        static let ACCOUNT_NUMBER           = "AccountNumber"
        static let MOST_RECENT_COTACT       = "MostRecentContact"
        static let BILLING_ADDRESS_1        = "BillingAddress1"
        static let BILLING_ADDRESS_2        = "BillingAddress2"
        static let BILLING_ADDRESS_CITY     = "BillingAddressCity"
        static let BILLING_ADDRESS_STATE    = "BillingAddressState"
        static let BILLING_ADDRESS_ZIP      = "BillingAddressZip"
        static let CONTACT_PHONE            = "ContactPhone"
        static let CONTACT_EMAIL            = "ContactEmail"
        static let FIRST_NAME               = "FirstName"
        static let MIDDLE_NAME              = "MiddleName"
        static let LAST_NAME                = "LastName"
        static let NICKNAME                 = "NickName"
        static let CELL_NUMBER              = "CellNumber"
        static let BACKGROUND_COLOR         = "BackgroundColor"
        static let FONT_COLOR               = "FontColor"
        static let START_DATE_TIME          = "StartDateTime"
        static let END_DATE_TIME            = "EndDateTime"
        static let ESTIMATED_TIME_DURATION  = "EstimateTimeDuration"
        static let QUANTITY                 = "Quantity"
        static let WHERE_PURCHASED          = "WherePurchased"
        static let LAST_PURHCASED           = "LastPurchased"
        static let PRICE_PAID               = "PricePaid"
        static let PRICE_TO_RESELL          = "PriceToResell"
        
        // ASSETS TABLE COLUMNS
        static let ASSET_ID                 = "AssetID"
        static let ASSET_NAME               = "AssetName"
        static let ASSET_TYPE               = "AssetType"
        static let SAMPLE_ASSET             = "SampleAsset"
        
        // ASSET_TYPES TABLE COLUMNS
        static let ASSET_TYPE_ID            = "AssetTypeID"
        static let TYPE_OF_ASSET            = "TypeOfAsset"
        static let SAMPLE_ASSET_TYPE        = "SampleAssetType"
        
        // SUPPLY LOCATIONS TABLE COLUMNS
        static let SUPPLY_LOCATION_ID       = "SupplyLocationID"
        static let SAMPLE_SUPPLY_LOCATION   = "SampleSupplyLocation"
        
        // PART LOCATIONS TABLE COLUMNS
        static let PART_LOCATION_ID         = "PartLocationID"
        static let SAMPLE_PART_LOCATION     = "SamplePartLocation"
        
        // SERVICE TYPES TABLE COLUMNS
        static let SERICE_TYPE_ID           = "ServiceTypeID"
        static let SAMPLE_SERVICE_TYPE      = "SampleServiceType"
        
        // VENDORS TABLE COLOUMNS
        static let VENDOR_ID                = "VendorID"
        static let VENDOR_NAME              = "VendorName"
        static let SAMPLE_VENDOR            = "SampleVendor"
        
        //CUSTOMERS TABLE COLUMNS
        static let CUSTOMER_ID              = "CustomerID"
        static let CUSTOMER_NAME            = "CustomerName"
        static let SAMPLE_CUSTOMER          = "SampleCustomer"
        
        //WORKER TABLE COLUMNS
        static let WORKER_ID                = "WorkerID"
        static let SAMPLE_WORKER            = "SampleWorker"
        static let WORKER_THEME             = "WorkerTheme"
        static let HOURLY_WORKER            = "HourlyWorker"
        static let CONTRACTOR               = "Contractor"
        static let SALARY                   = "Salary"
        static let WORKER_NAME              = "WorkerName"
        
        //ATTACHMENTS TABLE COLUMNS
        static let ATTACHMENT_ID            = "AttachmentID"
        static let PATH_TO_ATTACHMENT       = "PathToAttachment"
        static let SAMPLE_ATTACHMENT        = "SampleAttachment"
        static let SCHEDULED_JOB_ID         = "ScheduledJobID"
        
        // PART FINDERS TABLE COLUMNS
        static let PART_FINDER_ID           = "PartFinderID"
        static let SAMPLE_PART_FINDER       = "SamplePartFinder"
        
        // PARTS TABLE COLUMNS
        static let PART_ID                  = "PartID"
        static let PART_NAME                = "PartName"
        static let SAMPLE_PART              = "SAMPLE_PART"
        
        // INVOICES TABLE COLUMNS
        static let INVOICE_ID               = "InvoiceID"
        
        // SUPPLIES TABLE COLUMNS
        static let SUPPLY_ID                = "SupplyID"
        
        // QOUTES TABLE COLUMNS
        static let QOUTE_ID                 = "QuoteID"
     
        // WORK ORDERS TABLE COLUMNS
        static let WORK_ORDER_ID            = "WorkOrderID"
        static let SAMPLE_WORK_ORDER        = "SampleWorkOrder"
        static let SAMPLE_WORK_ORDER_USED   = "SampleWorkOrderUsed"
        
        // WORK ORDER USED TABLE COLUMNS
        static let WORK_ORDER_USED_ID       = "WorkOrderUsedID"
        static let NON_STOCKABLE            = "NonStockable"
        
        // PAYMENTS TABLE COLUMNS
        static let PAYMENT_ID               = "PaymentID"
        static let AMOUNT_PAID              = "AmountPaid"
        static let TRANSACTION_ID           = "TransactionID"
        static let PAYMENT_TYPE             = "PaymentType"
        static let NOTE_ABOUT_PAYMENT       = "NoteAboutPayment"
        static let SAMPLE_PAYMENT           = "SamplePayment"
        
        // ESTIMATE STATEMETNS TABLE COLUMNS
        static let ESTIMATE_ID              = "EstimateID"
        
        // EXPENSE STATEMENTS TABLE COLUMNS
        static let EXPENSE_STATEMENT_ID     = "ExpenseStatementID"
        static let AMOUNT_TO_REIMBURSE      = "AmountToReimburse"
        static let DATE_PAID                = "DatePaid"
        static let SAMPLE_EXPENSE_STATEMENT = "sampleExpenseStatement"
        
        // EXPENSE STATEMENTS USED TABLE COLUMNS
        static let EXPENSE_STATEMENT_USED_ID  = "ExpenseStatementUsedID"
        static let SAMPLE_EXPENSE_STATEMENT_USED = "sampleExpenseStatementUsed"
        
        // PURCHASE ORDERS TABLE COLUMNS
        static let PURCHASE_ORDER_ID        = "PurchaseOrderID"
        
        // ScheduledJobs TABLES COLUMNS
        static let JOB_ID                       = "JobID"
        static let JOB_LOCATION_ADDRESS_1       = "JobLocationAddress1"
        static let JOB_LOCATION_ADDRESS_2       = "JobLocationAddress2"
        static let JOB_LOCATION_CITY            = "JobLocationCity"
        static let JOB_LOCATION_STATE           = "JobLocationState"
        static let JobLocationZIP               = "JobLocationZip"
        static let JOB_CONTACT_PERSON_NAME      = "JobContactPersonName"
        static let JOB_CONTACT_PHONE            = "JobContactPhone"
        static let JOB_CONTACT_EMAIL            = "JobContactEmail"
        static let JOB_SHORT_DESCRIPTION        = "JobShortDescription"
        static let JOB_DESCRIPTION              = "JobDescription"
        static let WORKER_SCHEDULED             = "WorkerScheduled"
        static let JOB_STATUS                   = "JobStatus"
        static let PREVIOUS_VISIT_ON_THIS_JOB   = "PreviousVisitOnThisJob"
        static let NEXT_VISIT_ON_THIS_JOB       = "NextVisitOnThisJob"
        static let SAMPLE_SCHEDULED_JOB         = "SampleScheduledJob"
        static let REJECTED                     = "Rejected"
        static let REJECTED_REASON              = "RejectedReason"
        
        // JOBS WORKERS TABLES COLUMNS
        static let JOBS_WORKER_ID               = "JobsWorkersID"
        static let SAMPLE_JOBS_WORKERS          = "SampleJobsWorkers"
        
        // WORKER HOME ADDRESS COLUMNS
        static let THID                         = "THID"
        static let STREET_ADDRESS_ONE           = "StreetAddress1"
        static let STREET_ADDRESS_TWO           = "StreetAddress2"
        static let CITY                         = "City"
        static let STATE                        = "State"
        static let ZIP                          = "Zip"
        static let SAMPLE_WORKER_ADDRESS        = "SampleWorkerAddress"
        
        // WAGE COLUMNS
        static let WAGE_ID                      = "WageID"
        static let SALARY_RATE                  = "SalaryRate"
        static let SALARY_PER_TIME              = "SalaryPerTime"
        static let HOURLY_RATE                  = "HourlyRate"
        static let W4WH                         = "W4WH"
        static let W4_EXEPMTIONS                = "W4Exemptions"
        static let NEEDS_1099                   = "Needs1099"
        static let GARNISHMENTS                 = "Garnishments"
        static let GARNISHMENT_AMOUNT           = "GarnishmentAmount"
        static let FED_TAX_WH                   = "FedTaxWH"
        static let STATE_TAX_WH                 = "StateTaxWH"
        static let START_EMPLOYMENT_DATE        = "StartEmploymentDate"
        static let END_EMPLOYMENT_DATE          = "EndEmploymentDate"
        static let CURRENT_VACATION_AMOUNT      = "CurrentVacationAmount"
        static let VACATION_ACCRUAL_IN_HOURS    = "VacationAccrualRateInHours"
        static let VACATION_HOURS_PER_YEAR      = "VacationHoursPerYear"
        static let IS_FIXED_CONTRACT_PRICE      = "IsFixedContractPrice"
        static let CONTRACT_PRICE               = "ContractPrice"
        static let SAMPLE_WAGE                  = "SampleWage"
        
        // DEVICES COLUMNS
        static let DEVICE_ID                    = "DeviceID"
        static let DEVICE_GUID                  = "DeviceGUID"
        static let DEVICE_NAME                  = "DeviceName"
        static let DEVICE_TYPE                  = "DeviceType"
        static let DEVICE_CODE                  = "DeviceCode"
        static let DEVICE_CODE_EXPIRATION       = "DeviceCodeExpiration"
        static let IS_DEVICE_SETUP              = "IsDeviceSetup"
        static let SAMPLE_DEVICE                = "SampleDevice"
        
        //ROLES COLUMNS
        static let ADMIN                            = "Admin"
        static let MPH_XX_TECH_SUPPORT              = "MPHxxTechSupport"
        static let MPH_XX_OWNERS                    = "MPHxxOwners"
        static let CAN_DO_COMPANY_SETUP             = "CanDoCompanySetup"
        static let CAN_ADD_WORKERS                  = "CanAddWorkers"
        static let CAN_ADD_CUSTOMERS                = "CanAddCustomers"
        static let CAN_RUN_PAYROLL                  = "CanRunPayroll"
        static let CAN_SEE_WAGES                    = "CanSeeWages"
        static let CAN_SCHEDULE                     = "CanSchedule"
        static let CAN_DO_INVENTORY                 = "CanDoInventory"
        static let CAN_RUN_REPORTS                  = "CanRunReports"
        static let CAN_ADD_REMOVE_INVENTORY_ITEMS   = "CanAddRemoveInventoryItems"
        static let CAN_EDIT_TIME_ALREADY_ENTERED    = "CanEditTimeAlreadyEntered"
        static let CAN_REQUEST_VACATION             = "CanRequestVacation"
        static let CAN_REQUEST_SICK                 = "CanRequestSick"
        static let CAN_REQUEST_PERSONAL_TIME        = "CanRequestPersonalTime"
        static let CAN_APPROVE_TIME_OFF             = "CanApproveTimeoff"
        static let CAN_APPROVE_PAYROLL              = "CanApprovePayroll"
        static let CAN_EDIT_JOB_HISTORY             = "CanEditJobHistory"
        static let CAN_SCHEDULE_JOBS                = "CanScheduleJobs"
        static let CAN_APPROVE_PURCHASE_ORDERS      = "CanApprovePurchaseOrders"
        static let CAN_APPROVE_WORK_ORDERS          = "CanApproveWorkOrders"
        static let CAN_APPROVE_INVOICES             = "CanApproveInvoices"
        static let RECEIVE_EMAILS_FOR_REJECTED_JOBS = "ReceiveEmailsForRejectedJobs"
        
        // WORKER ROLES
        static let SAMPLE_ROLE                  = "SampleRole"
        
        // WORKER ROLES GROUPS
        static let WORKER_ROLES_GROUP_ID        = "WorkerRolesGroupID"
        static let GROUP_NAME                   = "GroupName"
        static let SAMPLE_WORKER_ROLES_GROUP    = "SampleWorkerRolesGroup"
        static let REMOVED_BY                   = "RemovedBy"

        // HOLIDAYS COLUMNS
        static let HOLIDAY_ID                    = "HolidayID"
        static let HOLIDAY_NAME                  = "HolidayName"
        static let YEAR                          = "Year"
        static let ACTUAL_DATE                   = "ActualDate"
        static let DATE_CELEBRATED               = "DateCelebrated"
        static let SAMPLE_HOLIDAY                = "SampleHoliday"
        
        // JOB HISTORY COLUMN
        static let JOB_PRICE                     = "JobPrice"
        static let SALES_TAX                     = "SalesTax"
        static let PAID                          = "Paid"
        static let SAMPLE_JOB_HISTORY            = "sampleJobHistory"
        static let JOB_DETAIL_ID                 = "JobDetailID"
        
        //JOB DETAIL
        static let SAMPLE_JOB_DETAIL             = "SampleJobDetail"
        
        // QUOTES COLUMN
        
        static let QUOTE_ID                     = "QuoteID"
        static let PRICE_QUOTED                 = "PriceQuoted"
        static let PRICE_ESTIMATE               = "PriceEstimate"
        static let PRICE_FIXED_PRICE            = "PriceFixedPrice"
        static let PRICE_EXPIRES                = "PriceExpires"
        static let SAMPLE_QOUTE                 = "SampleQuote"
        
        // ESTIMATE COLUMN
        static let SAMPLE_ESTIMATE              = "SampleEstimate"
        
        // INVOICE COLUMN
        static let INVOICE_ADJUSTEMENT          = "InvoiceAdjustment"
        static let TOTAL_INVOICE_AMOUNT         = "TotalInvoiceAmount"
        static let PERCENT_DISCOUNT             = "PercentDiscount"
        static let DATE_COMPLETED               = "DateCompleted"
        
        static let STATUS                       = "Status"
        static let IS_INVOICE_COMPLETED         = "IsInvoiceCompleted"
        static let IS_INVOICE_FINAL             = "IsInvoiceFinal"
        static let DATE_APPROVED                = "DateApproved"
//        static let DATE_APPROVED                = "DateAPPROVED"
        
        static let APPROVED_BY                  = "ApprovedBy"
        static let SAMPLE_INVOICE               = "SampleInvoice"
        static let IS_INVOICE_CREATED           = "IsInvoiceCreated"
        
        //
        static let SERVICE_USED_ID             = "ServiceUsedID"
        static let SERVICE_TYPE_ID             = "ServiceTypeID"
        
        // PARTS USED COLUMN
        static let PART_USED_ID                = "PartUsedID"
        static let WAITING_FOR_PART            = "WaitingForPart"
        static let COUNT_WAITING_FOR           = "CountWaitingFor"
        static let DATE_ADDED                  = "DateAdded"
        
        // SUPPLIES USED COLUMN
        static let SUPPLY_USED_ID                = "SupplyUsedID"
        static let SUPPLY_NAME                   = "SupplyName"
        static let SUPPLY_LOCATION_NAME          = "SupplyLocationName"
        static let WAITING_FOR_SUPPLY            = "WaitingForSupply"
        
        // SUPPLIES FINDER COLUMN
        static let SUPPLY_FINDER_ID              = "SupplyFinderID"
        
        // JOB DETAILS COLUMN
        static let DETAILS                      = "Details"
        static let CREATED_BY                   = "CreatedBy"
        static let MODIFIED_BY                  = "ModifiedBy"
        
        // RECEIPTS TABLE COLUMNS
        static let RECEIPT_ID                 = "ReceiptID"
        static let AMOUNT                     = "Amount"
        static let PAID_IN_FULL               = "PaidInFull"
        static let PARTIAL_PAYMENT            = "PartialPayment"
        static let PAYMENT_NOTE               = "PaymentNote"
        
        // TIME OFF REQUESTS
        static let TimeOffRequestsID          = "TimeOffRequestID"
        static let StartDate                  = "StartDate"
        static let EndDate                    = "EndDate"
        static let TypeOfLeave                = "TypeOfLeave"
        static let DateRequested              = "DateRequested"
        static let Remarks                    = "Remarks"
        static let SampleTimeOffRequest       = "SampleTimeOffRequest"
        static let DateApproved               = "DateApproved"
        
        
        // Current Time Sheet
        static let TIME_CARD_ID               = "TimeCardID"
        static let DateWorked                 = "DateWorked"
        static let StartTime                  = "StartTime"
        static let EndTime                    = "EndTime"
        static let BreakStart                 = "BreakStart"
        static let BreakStop                  = "BreakStop"
        static let LunchStart                 = "LunchStart"
        static let LunchStop                  = "LunchStop"
        static let WorkTime                   = "WorkTime"
        static let BreakTime                  = "BreakTime"
        static let LunchTime                  = "LunchTime"
        static let IsPayrollCreated           = "IsPayrollCreated"
        static let SampleTimeCard             = "SampleTimeCard"
        static let DATE_ENTERED               = "DateEntered"
        
        // TIMEOFF TABLE COLUMNS
       
        static let START_DATE              = "StartDate"
        static let END_DATE                = "EndDate"
        static let TYPEOF_LEAVE            = "TypeOfLeave"
        static let REMARK                  = "Remarks"
        static let APPROVED_DATE           = "DateApproved"
        static let APPROVER_NAME           = "ApproverName"
        static let DATE_REQUESTED          = "DateRequested"
        static let TIME_OFF_REQUEST_ID     = "TimeOffRequestID"
        
        // PURCHASE ORDER COLUMN
        static let SHIPPING                     = "Shipping"
        static let ENTERED_DATE                 = "EnteredDate"
        static let ORDERED_DATE                 = "OrderedDate"
        static let EXPECTED_DATE                = "ExpectedDate"
        static let SAMPLE_PURCHASE_ORDER        = "SamplePurchaseOrder"
        static let DATE_RECEIVED                = "DateReceived"
        
        // PURCHASE ORDERS USED TABLE COLUMNS
        static let PURCHASE_ORDER_USED_ID   = "PurchaseOrderUsedID"
        static let VENDOR_PART_NUMBER       = "VendorPartNumber"
        static let PRICE_PER_ITEM           = "PricePerItem"
        
        // PURCHASE ORDERS USED TABLE COLUMNS
        static let AMOUNT_OF_LINE_ITEM      = "AmountOfLineItem"
        
        
        static let REMARKS                   = "Remarks"
        
    }
}
