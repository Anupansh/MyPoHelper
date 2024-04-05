//
//  Constants.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 05/06/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation
import UIKit

///Constants
struct Constants {
    
    static let STANDARD_DATE                    = "yyyy-MM-dd HH:mm:ss"
    static let STANDARD_DATE_Z                  = "yyyy-MM-dd HH:mm:ssZ"
    static let STANDARD_DATE_WITHOUT_SECONDS    = "yyyy-MM-dd HH:mm"
    static let STANDARD_DATE_WITHOUT_HOURS      = "yyyy-MM-dd"
    static let DATE_FORMAT                      = "MM-dd-yyyy"
    static let TIME_FORMAT                      = "hh:mm a"
    static let TIME_FRAME_FORMAT                = "HH:mm:ss"
    static let DATA_OFFSET                      = 10
    static let COMPANY_TIME_FRAME               = "00:30:00"
    static let TIME_FORMAT_24                  = "HH:mm"
    
    enum Storyboard: String {
        case HOME                      = "Home"
        case AUTH                      = "Auth"
        case CUSTOMERS                 = "Customers"
        case VENDORS                   = "Vendors"
        case PART_LOCATION             = "PartLocation"
        case SUPPLY_LOCATION           = "SupplyLocation"
        case PART                      = "Part"
        case SUPPLY                    = "Supply"
        case SERVICE                   = "Service"
        case ASSET_TYPE                = "AssetType"
        case ASSET                     = "Asset"
        case WORKER                    = "WorkerList"
        case SCHEDULE_JOB              = "ScheduleJobs"
        case HELP                      = "Help"
        case DEVICES                   = "Devices"
        case HOLIDAYS                  = "Holidays"
        case JOB_HISTORY               = "JobHistory"
        case JOB_HISTORY_DETAILS_VIEW  = "JobHistoryDetailsView"
        case JOB_CONFIRMATION          = "JobConfirmation"
        case JOB_DECLINE               = "JobDecline"
        case QUOTES                    = "Quotes"
        case ESTIMATES                 = "Estimates"
        case CUSTOMER_JOB_HISTORY      = "CustomerJobHistoryView"
        case SHOW_JOB_HISTORY          = "ShowJobHistory"
        case QUOTES_ESTIMATES          = "QuotesEstimates"
        case INVOICE                   = "Invoice"
        case PAYMENT                   = "Payment"
        case RECEIPT                   = "Receipt"
        case ITEM_USED_CONFIRMATION    = "ItemUsedConfirmation"
        case JOB_DETAIL                = "JobDetail"
        case APPROVAL_LIST             = "ApprovalsList"
        case ADD_TIMEOFF               = "AddTimeOff"
        case ADDTIMEOFF                = "AddtimeShow"
        case APPROVEVIEW               = "ApproveView"
        case REJECTVIEW                = "rejectView"
        case INVOICEAPPROVAL           = "InvoiceApprovals"
        case WORKORDERAPPROVALS        = "WorkerOrderApprovals"
        case PURCHAGEORDERAPPROVALS    = "PurchaseOrderApprovals"
        case EXPENSESTATEMENTAPPROVALS = "ExpenseStatementApprovals"
        case PURCHASE_ORDER            = "PurchaseOrder"
        case WORK_ORDER                = "WorkOrder"
        case WAGES_VIEW                = "WagesView"
        case ROLE_GROUP                = "RoleGroup"
        case EXPENSE_STATEMENT         = "ExpenseStatement"
        case JOBS_TO_RESCHEDULE        = "JobsToReschedule"
        case PROFILE                   = "Profile"
    }
    
    struct magicValues {
        static var viewOffsetForKeyboard:CGFloat = 100
    }
    
    struct themeConfiguration {
        
        struct layer {
            static let theme:CGFloat = 10
            static let borderWidth:CGFloat = 1
            static let borderColor:CGColor = UIColor.lightGray.cgColor
        }
        
        struct textSize {
            static let small:CGFloat = 10
            static let medium:CGFloat = 12
            static let large:CGFloat = 18
        }
        
        struct font {
            static let smallFont = UIFont.systemFont(ofSize: textSize.small)
            static let mediumFont = UIFont.systemFont(ofSize: textSize.medium)
            static let largeFont = UIFont.systemFont(ofSize: textSize.large)
        }
        
    }
    
    struct Dimension {
        static let BUTTON_HEIGHT: CGFloat = 42
        static let TEXT_FIELD_BORDER_WIDTH: CGFloat = 0.5
    }

    struct  Colors {
        static let TEXT_FIELD_DEFAULT_COLOR     = UIColor(white: 0, alpha: 0.15)
        static let TEXT_FIELD_ERROR_COLOR       = UIColor.systemRed
        static let DARK_NAVIGATION              = UIColor(red: 31/255, green: 53/255, blue: 96/255, alpha: 1)
        static let NAVIGATION_BAR_TEXT_COLOR    = UIColor.white

    }
    
    struct Image {
        static let JOB_LIST             = "icons8-list-view-50"
        static let CALENDAR             = "icons8-person-calendar-50"
        static let CUSTOMERS            = "icons8-account-50"
        static let JOBS                 = "icons8-new-job-50"
        static let INVENTORY            = "icons8-warehouse-50"
        static let WORKERS              = "icons8-workers-50"
        static let PAYROLL              = "icons8-money-bag-50"
        static let APPROVALS            = "icons8-receipt-approved-50"
        static let REPORTS              = "icons8-pie-chart-50"
        static let MASTER_SETUP         = "icons8-phonelink-setup-50"
        static let HELP                 = "icons8-help-50"
        static let CIRCLE_CLOSE_BUTTON  = "icons8-macos-close-32"
        static let DASHBOARD            = "icons8-dashboard-64"
    }
    
    
    struct Message {
        static let PART_NAME_SELECT_ERROR   = "Please provide part"
        static let SUPPLY_NAME_SELECT_ERROR   = "Please provide supply"
        static let PART_SUPPLY_NAME_SELECT_ERROR   = "Please provide part or supply"
        static let NAME_SELECT_ERROR        = "Please provide a valid name"
        static let NAME_ERROR               = "Please enter a valid name"
        static let PHONE_ERROR              = "Please enter a valid phone number"
        static let EMAIL_ERROR              = "please enter a valid email"
        static let ADDRESS_ERROR            = "please enter a valid address"
        static let CITY_ERROR               = "please enter a valid city"
        static let STATE_ERROR              = "please enter a valid state"
        static let ZIP_CODE_ERROR           = "please enter a valid zip code"
        static let DATE_ERROR               = "please enter a valid date"
        static let END_DATE_SELECT        = "please select end date."
        static let END_DATE_LESS             = "End date can't be less than start date."
        static let DELETE_ROW               = "Are you sure you want to delete this row?"
        static let DELETE_CUSTOMER_ERROR    = "Failed to delete customer"
        static let DELETE_VENDOR            = "Are you sure you want to delete this vendor?"
        static let DELETE_VENDOR_ERROR      = "Failed to delete vendor"
        static let GENERIC_FIELD_ERROR      = "please enter a valid value"
        static let ACCOUNT_NUMBER_ERROR     = "please enter a valid account number"
        static let DESCRIPTION_ERROR        = "please enter a valid description"
        static let PRICE_ERROR              = "please enter a valid price"
        static let TYPE_ERRPR               = "please enter a valid type"
        static let INFO_ERROR               = "please enter a valid information"
        static let SERIAL_NUMBER_ERROR      = "please enter a valid serial number"
        static let TITLE_ERROR              = "Please provide title"
        static let SELECT_CUSTOMER          = "Please select customer"
        static let SALARY_PER_TIME_ERROR    = "Please provide salary per time"
        static let UPDATE_NOTES_SUCCESS     = "Notes saved successfully"
        static let ADDRESS_FIELDS_MANDATORY = "Address1, State, City and Zip are mandtory "
        static let JOB_START_TIME_ERROR     = "Please enter job start date and time"
        static let JOB_END_TIME_ERROR       = "Please enter job end date and time"
        static let ALLOW_LOCATION           = "Please allow location permission to fetch locations from Settings -> MyProHelper -> Locations"
        static let ALLOW_WORKER             = "You are not authorised to add workers."
        static let ALLOW_CUSTOMER           = "You are not authorised to add customers"
        static let JOB_HISTORY_EDIT         = "Be careful about changing job history."
        static let CREDIR_CARD_ERROR        = "Please enable microphone and location settings to proceed to Credit/Debit card payment."
        static let SELECT_WORKER            = "Please select a worker."
        static let WORKED_DATE              = "Please select a work date."
        static let TWO_MONTHS_TIMESHEET     = "You are about to edit a 2 months old timesheet. Be very careful while editing."
        static let NO_JOBS_WAITING          = "No jobs waiting for this part."
        static let NO_JOBS_WAITING_SUPPLY   = "No jobs waiting for this supply."
        static let MOBILE_NOT_AVAILABLE     = "Customer's mobile number is not available."
        static let INVOICE_FINAL            = "Can't edit invoice. Its already finalize."
        static let NO_NEXT_JOB              = "No next job. You can send estimated time to next customer once a job is allocated."
        static let LESS_BALANCE_AMOUNT      = "Amount Paying must be less or equal to Balance Amount."
        static let No_Data_To_Display       = "No Data to display."
    }
    
    struct DefaultValue {
        static let SELECT_LIST = "--SELECT--"
    }
}
let arrStatesListGlobal:[[String:Any]] =
    [
        [
            "StateNickName": "NE",
            "FullStateName" : "Nebraska"
        ],
        [
            "StateNickName": "DE",
            "FullStateName" : "Deleware"
        ],
        [
            "StateNickName": "OH",
            "FullStateName" : "Ohio"
        ],
        [
            "StateNickName": "IO",
            "FullStateName" : "Iowa"
        ],
        [
            "StateNickName": "WI",
            "FullStateName" : "Wisconsin"
        ],
        [
            "StateNickName": "MN",
            "FullStateName" : "Minnesota"
        ],
        [
            "StateNickName": "AR",
            "FullStateName" : "Arkansas"
        ],
        [
            "StateNickName": "UT",
            "FullStateName" : "Utah"
        ],
        [
            "StateNickName": "CT",
            "FullStateName" : "Connecticut"
        ],
        [
            "StateNickName": "HA",
            "FullStateName" : "Hawaii"
        ],
        [
            "StateNickName": "AK",
            "FullStateName" : "Alaska"
        ],
        [
            "StateNickName": "OR",
            "FullStateName" : "Oregan"
        ],
        [
            "StateNickName": "MS",
            "FullStateName" : "Mississippi"
        ],
        [
            "StateNickName": "NM",
            "FullStateName" : "New Mexico"
        ],
        [
            "StateNickName": "CA",
            "FullStateName" : "California"
        ],
        [
            "StateNickName": "WA",
            "FullStateName" : "Washington"
        ],
        [
            "StateNickName": "ID",
            "FullStateName" : "Idaho"
        ],
        [
            "StateNickName": "MT",
            "FullStateName" : "Montana"
        ],
        [
            "StateNickName": "WY",
            "FullStateName" : "Wyoming"
        ],
        [
            "StateNickName": "CO",
            "FullStateName" : "Colorado"
        ],
        [
            "StateNickName": "MD",
            "FullStateName" : "Maryland"
        ],
        [
            "StateNickName": "SD",
            "FullStateName" : "South Dakota"
        ],
        [
            "StateNickName": "ND",
            "FullStateName" : "North Dakota"
        ],
        [
            "StateNickName": "MI",
            "FullStateName" : "Michigan"
        ],
        [
            "StateNickName": "KS",
            "FullStateName" : "Kansas"
        ],
        [
            "StateNickName": "OK",
            "FullStateName" : "Oklahoma"
        ],
        [
            "StateNickName": "NV",
            "FullStateName" : "Nevada"
        ],
        [
            "StateNickName": "MO",
            "FullStateName" : "Missouri"
        ],
        [
            "StateNickName": "IN",
            "FullStateName" : "Indiana"
        ],
        [
            "StateNickName": "IL",
            "FullStateName" : "Illinois"
        ],
        [
            "StateNickName": "TX",
            "FullStateName" : "Texas"
        ],
        [
            "StateNickName": "NJ",
            "FullStateName" : "New Jersey"
        ],
        [
            "StateNickName": "ME",
            "FullStateName" : "Maine"
        ],
        [
            "StateNickName": "NH",
            "FullStateName" : "New Hampshire"
        ],
        [
            "StateNickName": "VT",
            "FullStateName" : "Vermont"
        ],
        [
            "StateNickName": "NY",
            "FullStateName" : "New York"
        ],
        [
            "StateNickName": "RI",
            "FullStateName" : "Rhode Island"
        ],
        [
            "StateNickName": "MA",
            "FullStateName" : "Massachusetts"
        ],
        [
            "StateNickName": "PA",
            "FullStateName" : "Pennsylvania"
        ],
        [
            "StateNickName": "WV",
            "FullStateName" : "West Virginia"
        ],
        [
            "StateNickName": "VA",
            "FullStateName" : "Virginia"
        ],
        [
            "StateNickName": "KY",
            "FullStateName" : "Kentucky"
        ],
        [
            "StateNickName": "SC",
            "FullStateName" : "South Carolina"
        ],
        [
            "StateNickName": "LA",
            "FullStateName" : "Lousiana"
        ],
        [
            "StateNickName": "GA",
            "FullStateName" : "Georgia"
        ],
        [
            "StateNickName": "FL",
            "FullStateName" : "Florida"
        ],
        [
            "StateNickName": "NC",
            "FullStateName" : "North Carolina"
        ],
        [
            "StateNickName": "TN",
            "FullStateName" : "Tennessee"
        ],
        [
            "StateNickName": "AR",
            "FullStateName" : "Arizona"
        ],
        [
            "StateNickName": "AL",
            "FullStateName" : "Alabama"
        ],
        [
            "StateNickName": "DC",
            "FullStateName" : "District of Columbia"
        ],
        

    ]
