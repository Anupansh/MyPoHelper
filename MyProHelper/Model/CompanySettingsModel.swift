
import Foundation
import GRDB

class CompanySettingsModel {
    var companyId = ""
    var companyName = ""
    var companyTagline = ""
    var companyLogo = Data()
    var startOfTrial = Date()
    var endOfTrial = Date()
    var startOfSubscription = Date()
    var billingMode = ""
    var monthlyBillDate = ""
    var annualBillDate = ""
    var referredBy = ""
    var billingAddress = ""
    var billingAddress2 = ""
    var billingAddressCity = ""
    var billingAddressState = ""
    var billingAddressZip = ""
    var sampleCompany = false
    var borrowVacation = false
    var borrowSick = false
    var invoiceApproval = false
    var salesTextParts = false
    var salesTextServices = false
    var salesTaxSupplies = false
    var suppliesBeCharged = false
    var shippingTaxable = false
    var billAnnually = false
    var billMontly = false
    var minimumJobDuration = ""
    var workDayStartTime = ""
    var workDateEndTime = ""
    
    var isSalesTaxParts = ""        //Need to change Variable name once Karen will add the Column name in the DB
    var isSalesTextServices = ""    //Need to change Variable name once Karen will add the Column name in the DB
    var isSalesTaxSupplies = ""     //Need to change Variable name once Karen will add the Column name in the DB
    
    init() {}
    
    init(row: Row) {
        companyId = row[DataFeilds.companyId.rawValue.removeSpace()]
        companyName = row[DataFeilds.companyName.rawValue.removeSpace()]
        companyTagline = row[DataFeilds.companyTagline.rawValue.removeSpace()]
        companyLogo = row[DataFeilds.companyLogo.rawValue.removeSpace()]
        startOfTrial = row[DataFeilds.startOfTrial.rawValue.removeSpace()]
        endOfTrial = row[DataFeilds.endOfTrial.rawValue.removeSpace()]
        startOfSubscription = row[DataFeilds.startOfSubscription.rawValue.removeSpace()]
        billingMode = getBillingMode(row: row)
        monthlyBillDate = row[DataFeilds.monthlyBillDate.rawValue.removeSpace()]
        annualBillDate = row[DataFeilds.annualBillDate.rawValue.removeSpace()]
        referredBy = row[DataFeilds.referredBy.rawValue.removeSpace()]
        billingAddress = row[DataFeilds.billingAddress.rawValue.removeSpace()]
        billingAddress2 = row[DataFeilds.billingAddress2.rawValue.removeSpace()]
        billingAddressCity = row[DataFeilds.billingAddressCity.rawValue.removeSpace()]
        billingAddressState = row[DataFeilds.billingAddressState.rawValue.removeSpace()]
        billingAddressZip = row[DataFeilds.billingAddressZip.rawValue.removeSpace()]
        sampleCompany = row[DataFeilds.sampleCompany.rawValue.removeSpace()]
        borrowVacation = row[DataFeilds.borrowVacation.rawValue.removeSpace()]
        borrowSick = row[DataFeilds.borrowSick.rawValue.removeSpace()]
        invoiceApproval = row[DataFeilds.invoiceApproval.rawValue.removeSpace()]
        salesTextParts = row[DataFeilds.salesTextParts.rawValue.removeSpace()]
        salesTextServices = row[DataFeilds.salesTextServices.rawValue.removeSpace()]
//        salesTaxSupplies = row[DataFeilds.salesTaxSupplies.rawValue.removeSpace()]// Missing colom in database structure
        suppliesBeCharged = row[DataFeilds.suppliesBeCharged.rawValue.removeSpace()]
        shippingTaxable = row[DataFeilds.shippingTaxable.rawValue.removeSpace()]
        minimumJobDuration = row[DataFeilds.minimumJobDuration.rawValue.removeSpace()]
        workDayStartTime = row[DataFeilds.workDayStartTime.rawValue.removeSpace()]
        workDateEndTime = row[DataFeilds.workDayEndTime.rawValue.removeSpace()]
    }
    
    func getBillingMode(row: Row) -> String {
        billAnnually = row[DataFeilds.billAnnually.rawValue.removeSpace()]
        billMontly = row[DataFeilds.billMonthly.rawValue.removeSpace()]
        if billAnnually == true {
            return "Annually"
        }
        else if billMontly == true {
            return "Monthly"
        }
        else {
            return "Monthly"
        }
    }
}
