//
//  CompanyInformationVC.swift
//  MyProHelper
//
//  Created by Anupansh on 01/04/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit
import GRDB
import SideMenu
import DropDown

enum DataFeilds: String {
    case companyId = "Company ID"
    case companyName = "Company Name"
    case companyTagline = "Company Tag Line"
    case companyLogo = "Company Logo"
    case startOfTrial = "Start Of Trial"
    case endOfTrial = "End Of Trial"
    case startOfSubscription = "Start Of Subscription"
    case billingMode = "Billing Mode"
    case annualBillDate = "Annual Bill Date"
    case monthlyBillDate = "Monthly Bill Day"
    case referredBy = "Referred By"
    case billingAddress = "Bill Address 1"
    case billingAddress2 = "Bill Address 2"
    case billingAddressCity = "Bill Address City"
    case billingAddressState = "Bill Address State"
    case billingAddressZip = "Bill Address Zip"
    case sampleCompany = "Sample Company"
    case borrowVacation = "Allow To Borrow This Year Vacation"
    case borrowSick = "Allow To Borrow This Year Sick Leave"
    case invoiceApproval = "Approval Of Invoice Required Before Finalizing"
    case salesTextParts = "Sales Tax Same On All Parts"
    case salesTextServices = "Sales Tax Same On All Services"
    case salesTaxSupplies = "Sales Tax Same On All Supplies"
    case suppliesBeCharged = "Supplies To Be Charged To Customers On Invoice"
    case shippingTaxable = "Shipping Taxable In State"
    case billAnnually = "BillAnnually"
    case billMonthly = "BillMonthly"
    case minimumJobDuration = "Minimum Job Duration"
    case workDayStartTime = "Work Day Start Time"
    case workDayEndTime = "Work Day End Time"
    case salesTaxSameOnAllParts = "Sales Tax On Parts"
    case salesTaxSameOnAllServices = "Sales Tax On Services"
    case salesTaxSameOnAllSupplies = "Sales Tax On Supplies"
}

class CompanyInformationVC: UIViewController {

    @IBOutlet weak var tableview: UITableView! {
        didSet {
            tableview.delegate = self
            tableview.dataSource = self
            tableview.separatorStyle = .none
        }
    }
    var companyInformation = CompanySettingsModel()
    var isMonthlyBooking = true
    var userInteractionEnabled = false
    var dropdown = DropDown()
    
    var suppliyRowHeight:CGFloat = 58.0
    var partsRowHeight:CGFloat = 58.0
    var serviceRowHeight:CGFloat = 58.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    // MARK: -  NAVIGATION ITEMS
    @objc func sideMenuPressed() {
        let sideMenuView = SideMenuView.instantiate(storyboard: .HOME)
        let menu = SideMenuNavigationController(rootViewController: sideMenuView)
        let screenWidth = UIScreen.main.bounds.width
        menu.leftSide = true
        menu.statusBarEndAlpha = 0
        menu.presentationStyle = .menuSlideIn
        menu.isNavigationBarHidden = true
        menu.menuWidth = (screenWidth > 400) ? 400 : screenWidth
        menu.sideMenuManager.addScreenEdgePanGesturesToPresent(toView: view)
        self.present(menu, animated: true, completion: nil)
    }
    
    @objc func savePressed() {
        if companyInformation.companyName == "" {
            CommonController.shared.showSnackBar(message: "Please enter company name.", view: self)
        }
        else if companyInformation.companyTagline == "" {
            CommonController.shared.showSnackBar(message: "Please enter company tagline.", view: self)
        }
        else if companyInformation.companyLogo == Data() {
            CommonController.shared.showSnackBar(message: "Please select a logo for company.", view: self)
        }
        else if companyInformation.annualBillDate == "" {
            CommonController.shared.showSnackBar(message: "Please select annual bill date.", view: self)
        }
        else if companyInformation.billingAddress == "" {
            CommonController.shared.showSnackBar(message: "Please enter Billing Address name.", view: self)
        }
        else if companyInformation.billingAddressCity == "" {
            CommonController.shared.showSnackBar(message: "Please enter Billing Address city.", view: self)
        }
        else if companyInformation.billingAddressState == "" {
            CommonController.shared.showSnackBar(message: "Please enter Billing Address state.", view: self)
        }
        else if companyInformation.isSalesTaxSupplies == "" && companyInformation.salesTaxSupplies == true {
            CommonController.shared.showSnackBar(message: "Please enter Sales Tax On Supplies.", view: self)
        }
        
        else if companyInformation.isSalesTaxParts == "" && companyInformation.salesTextParts == true {
            CommonController.shared.showSnackBar(message: "Please enter Sales Tax On Parts.", view: self)
        }
        
        else if companyInformation.isSalesTextServices == "" && companyInformation.salesTextServices == true {
            CommonController.shared.showSnackBar(message: "Please enter Sales Tax On Services.", view: self)
        }
        else {
            executeUpdateQuery()
        }
    }
    
    func executeFetchQuery() {
        guard let queue = AppDatabase.shared.attachDababaseQueue else {return}
        let companyID = AppLocals.serverAccessCode?.CompanyID
        var sql = """
            Select * from main.\(RepositoryConstants.Tables.COMPANY_SETTINGS)
            WHERE main.\(RepositoryConstants.Tables.COMPANY_SETTINGS).\(DataFeilds.companyId.rawValue.removeSpace()) = \(companyID ?? "299")
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            try queue.read { (database) in
                let rows = try Row.fetchCursor(database, sql: sql)
                while let row = try rows.next() {
                    print(row)
                    self.companyInformation = CompanySettingsModel.init(row: row)
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
        tableview.reloadData()
    }
    
    func executeUpdateQuery() {
        let companyId = AppLocals.serverAccessCode?.CompanyID
        let arguments : StatementArguments = [
            "id" : companyId!,
            "name" : companyInformation.companyName,
            "tagline" : companyInformation.companyTagline,
            "logo" : companyInformation.companyLogo,
            "startOfTrial" : companyInformation.startOfTrial,
            "endOfTrial" : companyInformation.endOfTrial,
            "subscriptionStart" : companyInformation.startOfSubscription,
            "billAnually" : companyInformation.billAnnually,
            "billMonthly" : companyInformation.billMontly,
            "monthlyBillDay" : companyInformation.monthlyBillDate,
            "annualBillDate" : companyInformation.annualBillDate,
            "referredBy" : companyInformation.referredBy,
            "billAddress1" : companyInformation.billingAddress,
            "billAddress2" : companyInformation.billingAddress2,
            "billAddressCity" : companyInformation.billingAddressCity,
            "billAddressState" : companyInformation.billingAddressState,
            "billAddressZip" : companyInformation.billingAddressZip,
            "salesTaxSupplies" : companyInformation.salesTaxSupplies,
            "borrowVacation" : companyInformation.borrowVacation,
            "borrowSickLeave" : companyInformation.borrowSick,
            "invoiceApproval" : companyInformation.invoiceApproval,
            "salesTaxPart" : companyInformation.salesTextParts,
            "salesTaxServices" : companyInformation.salesTextServices,
            "suppliesBeCharged" : companyInformation.suppliesBeCharged,
            "shippingTaxable" : companyInformation.shippingTaxable
        ]
        let sql = """
            UPDATE \(RepositoryConstants.Tables.COMPANY_SETTINGS) SET
                \(DataFeilds.companyName.rawValue.removeSpace())                    =  :name,
                \(DataFeilds.companyTagline.rawValue.removeSpace())                 =  :tagline,
                \(DataFeilds.companyLogo.rawValue.removeSpace())                    =  :logo,
                \(DataFeilds.startOfTrial.rawValue.removeSpace())                   =  :startOfTrial,
                \(DataFeilds.endOfTrial.rawValue.removeSpace())                     =  :endOfTrial,
                \(DataFeilds.startOfSubscription.rawValue.removeSpace())            =  :subscriptionStart,
                \(DataFeilds.monthlyBillDate.rawValue.removeSpace())                =  :monthlyBillDay,
                \(DataFeilds.annualBillDate.rawValue.removeSpace())                 =  :annualBillDate,
                \(DataFeilds.referredBy.rawValue.removeSpace())                     =  :referredBy,
                \(DataFeilds.billingAddress.rawValue.removeSpace())                 =  :billAddress1,
                \(DataFeilds.billingAddress2.rawValue.removeSpace())                =  :billAddress2,
                \(DataFeilds.billingAddressCity.rawValue.removeSpace())             =  :billAddressCity,
                \(DataFeilds.billingAddressState.rawValue.removeSpace())            =  :billAddressState,
                \(DataFeilds.billingAddressZip.rawValue.removeSpace())              =  :billAddressZip,
                \(DataFeilds.salesTaxSupplies.rawValue.removeSpace())                  =  :salesTaxSupplies,
                \(DataFeilds.borrowVacation.rawValue.removeSpace())                 =  :borrowVacation,
                \(DataFeilds.borrowSick.rawValue.removeSpace())                     =  :borrowSickLeave,
                \(DataFeilds.invoiceApproval.rawValue.removeSpace())                =  :invoiceApproval,
                \(DataFeilds.salesTextParts.rawValue.removeSpace())                 =  :salesTaxPart,
                \(DataFeilds.salesTextServices.rawValue.removeSpace())              =  :salesTaxServices,
                \(DataFeilds.suppliesBeCharged.rawValue.removeSpace())              =  :suppliesBeCharged,
                \(DataFeilds.shippingTaxable.rawValue.removeSpace())                =  :shippingTaxable,
                \(DataFeilds.billAnnually.rawValue.removeSpace())                   =  :billAnually,
                \(DataFeilds.billMonthly.rawValue.removeSpace())                    =  :billMonthly
            WHERE \(RepositoryConstants.Tables.COMPANY_SETTINGS).\(DataFeilds.companyId.rawValue.removeSpace()) = :id
        """
        AppDatabase.shared.executeSQL(sql: sql, arguments: arguments,typeOfAction: .update, updatedId: UInt64(companyId!)) { (id) in
            CommonController.shared.showSnackBar(message: "Saved Successfully", view: self)
        } fail: { (error) in
            print(error.localizedDescription)
        }
    }
    
    func addSalesTaxSuppliesColumn() {
        let sql = """
            ALTER TABLE \(RepositoryConstants.Tables.COMPANY_SETTINGS)
            ADD \(DataFeilds.salesTaxSupplies.rawValue.removeSpace()) BOOLEAN DEFAULT \(false)
        """
        AppDatabase.shared.executeSQL(sql: sql, arguments: [],typeOfAction: .alter, updatedId: nil) { (id) in
            print("Success")
        } fail: { (error) in
            print(error.localizedDescription)
        }

    }

    func initialSetup() {
        title = "Company Information".localize
        self.navigationController?.isNavigationBarHidden = false
        let backBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "menu"), style: .done, target: self, action: #selector(sideMenuPressed))
        self.navigationItem.leftBarButtonItem = backBtn
//        self.addSalesTaxSuppliesColumn()
        if AppLocals.workerRole.role.canDoCompanySetup! {
            let saveBtn = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(savePressed))
            self.navigationItem.rightBarButtonItem = saveBtn
            self.userInteractionEnabled = true
        }
        self.executeFetchQuery()
        tableview.registerMultiple(nibs: [TextFieldCell.className,DropDownCell.className,ImagePickerCell.className,CheckBoxTableViewCell.className]) //,CheckboxCell.className
    }
}

extension CompanyInformationVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 25
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0,1,3,4,5,7,8,9,10,11,12,13,18,20,22:
            return textfeildCell(indexpath: indexPath)
        case 2:
            return imagePickerCell(indexpath: indexPath)
        case 6:
            return dropdownCell(indexpath: indexPath)
        default:
            return checkboxCell(indexpath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0,1,3,4,5,7,8,9,10,11,12,13:
            return 80
        case 18:
            if indexPath.row == 18{
                if companyInformation.salesTaxSupplies == true {
                    return suppliyRowHeight
                } else{
                    return 0.0
                }
            } else{
                return 80
            }
        case 20:
            if indexPath.row == 20{
                if companyInformation.salesTextParts == true {
                    return partsRowHeight
                } else{
                    return 0.0
                }
            } else{
                return 80
            }
        case 22:
            if indexPath.row == 22{
                if companyInformation.salesTextServices == true {
                    return serviceRowHeight
                } else{
                    return 0.0
                }
            } else{
                return 80
            }
        case 2:
            return 180
        case 6:
            return 100
        default:
            return 50
        }
    }
    
    func textfeildCell(indexpath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: TextFieldCell.className) as! TextFieldCell
        cell.delegate = self
        cell.isUserInteractionEnabled = userInteractionEnabled
        switch indexpath.row {
        case 0:
            cell.bindTextField(data: .init(title: DataFeilds.companyName.rawValue, key: DataFeilds.companyName.rawValue, dataType: .Text, isRequired: false, isActive: !inTrialPeriod(), keyboardType: .default, validation: ValidationResult.Valid, text: companyInformation.companyName, listData: []))
            cell.titleStackView.isHidden = false
            cell.textField.placeholder = "Company Name"
            self.view.layoutIfNeeded()
            
        case 1:
            cell.bindTextField(data: .init(title: DataFeilds.companyTagline.rawValue, key: DataFeilds.companyTagline.rawValue, dataType: .Text, isRequired: false, isActive: true, keyboardType: .default, validation: ValidationResult.Valid, text: companyInformation.companyTagline, listData: []))
            cell.titleStackView.isHidden = false
            cell.textField.placeholder = "Company Tag Line"
            self.view.layoutIfNeeded()
            
        case 3:
            cell.bindTextField(data: .init(title: DataFeilds.startOfTrial.rawValue, key: DataFeilds.startOfTrial.rawValue, dataType: .Date, isRequired: false, isActive: true, keyboardType: .default, validation: ValidationResult.Valid, text: DateManager.dateToString(date: companyInformation.startOfTrial), listData: []))
            cell.titleStackView.isHidden = false
            cell.textField.placeholder = "Start Of Trial"
            self.view.layoutIfNeeded()
            
        case 4:
            cell.bindTextField(data: .init(title: DataFeilds.endOfTrial.rawValue, key: DataFeilds.endOfTrial.rawValue, dataType: .Date, isRequired: false, isActive: true, keyboardType: .default, validation: ValidationResult.Valid, text: DateManager.dateToString(date: companyInformation.endOfTrial), listData: []))
            cell.titleStackView.isHidden = false
            cell.textField.placeholder = "End Of Trial"
            self.view.layoutIfNeeded()
            
        case 5:
            cell.bindTextField(data: .init(title: DataFeilds.startOfSubscription.rawValue, key: DataFeilds.startOfSubscription.rawValue, dataType: .Date, isRequired: false, isActive: true, keyboardType: .default, validation: ValidationResult.Valid, text: DateManager.dateToString(date: companyInformation.startOfSubscription), listData: []))
            cell.titleStackView.isHidden = false
            cell.textField.placeholder = "Start Of Subscription"
            self.view.layoutIfNeeded()
            
        case 7:
            let billDay = isMonthlyBooking ? DateManager.getMonthlyBillDay(): DateManager.getAnnualBillDate()
            cell.bindTextField(data: .init(title: (isMonthlyBooking ? DataFeilds.monthlyBillDate.rawValue: DataFeilds.annualBillDate.rawValue), key: DataFeilds.annualBillDate.rawValue, dataType: .Text, isRequired: false, isActive: false, keyboardType: .default, validation: ValidationResult.Valid, text: billDay, listData: []))
            cell.titleStackView.isHidden = false
            cell.textField.placeholder = "Monthly Bill Day"
            self.view.layoutIfNeeded()
            
        case 8:
            cell.bindTextField(data: .init(title: DataFeilds.referredBy.rawValue, key: DataFeilds.referredBy.rawValue, dataType: .Text, isRequired: false, isActive: true, keyboardType: .default, validation: ValidationResult.Valid, text: companyInformation.referredBy, listData: []))
            cell.titleStackView.isHidden = false
            cell.textField.placeholder = "Referred By"
            self.view.layoutIfNeeded()
            
        case 9:
            cell.bindTextField(data: .init(title: DataFeilds.billingAddress.rawValue, key: DataFeilds.billingAddress.rawValue, dataType: .Text, isRequired: false, isActive: !inTrialPeriod(), keyboardType: .default, validation: ValidationResult.Valid, text: companyInformation.billingAddress, listData: []))
            cell.titleStackView.isHidden = false
            cell.textField.placeholder = "Bill Address 1"
            self.view.layoutIfNeeded()
            
        case 10:
            cell.bindTextField(data: .init(title: DataFeilds.billingAddress2.rawValue, key: DataFeilds.billingAddress2.rawValue, dataType: .Text, isRequired: false, isActive: !inTrialPeriod(), keyboardType: .default, validation: ValidationResult.Valid, text: companyInformation.billingAddress2, listData: []))
            cell.titleStackView.isHidden = false
            cell.textField.placeholder = "Bill Address 2"
            self.view.layoutIfNeeded()
            
        case 11:
            cell.bindTextField(data: .init(title: DataFeilds.billingAddressCity.rawValue, key: DataFeilds.billingAddressCity.rawValue, dataType: .Text, isRequired: false, isActive: !inTrialPeriod(), keyboardType: .default, validation: ValidationResult.Valid, text: companyInformation.billingAddressCity, listData: []))
            cell.titleStackView.isHidden = false
            cell.textField.placeholder = "Bill Address City"
            self.view.layoutIfNeeded()
            
        case 12:
            cell.bindTextField(data: .init(title: DataFeilds.billingAddressState.rawValue, key: DataFeilds.billingAddressState.rawValue, dataType: .Text, isRequired: false, isActive: !inTrialPeriod(), keyboardType: .default, validation: ValidationResult.Valid, text: companyInformation.billingAddressState, listData: []))
            cell.titleStackView.isHidden = false
            cell.textField.placeholder = "Bill Address State"
            self.view.layoutIfNeeded()
            
        case 13:
            cell.bindTextField(data: .init(title: DataFeilds.billingAddressZip.rawValue, key: DataFeilds.billingAddressZip.rawValue, dataType: .Text, isRequired: false, isActive: !inTrialPeriod(), keyboardType: .default, validation: ValidationResult.Valid, text: companyInformation.billingAddressZip, listData: []))
            cell.titleStackView.isHidden = false
            cell.textField.placeholder = "Bill Address Zip"
            self.view.layoutIfNeeded()
            
        case 18:
            cell.bindTextField(data: .init(title: DataFeilds.salesTaxSameOnAllSupplies.rawValue, key: DataFeilds.salesTaxSameOnAllSupplies.rawValue, dataType: .Text, isRequired: false, isActive: true, keyboardType: .numbersAndPunctuation, validation: ValidationResult.Valid, text: companyInformation.isSalesTaxSupplies, listData: []))
            
            cell.titleStackView.isHidden = true
            cell.textField.placeholder = "Sales Tax On Supplies"
            self.view.layoutIfNeeded()
            
        case 20:
            cell.bindTextField(data: .init(title: DataFeilds.salesTaxSameOnAllParts.rawValue, key: DataFeilds.salesTaxSameOnAllParts.rawValue, dataType: .Text, isRequired: false, isActive: true, keyboardType: .numbersAndPunctuation, validation: ValidationResult.Valid, text: companyInformation.isSalesTaxParts, listData: []))
            
            cell.titleStackView.isHidden = true
            cell.textField.placeholder = "Sales Tax On Parts"
            self.view.layoutIfNeeded()
            
        case 22:
            cell.bindTextField(data: .init(title: DataFeilds.salesTaxSameOnAllServices.rawValue, key: DataFeilds.salesTaxSameOnAllServices.rawValue, dataType: .Text, isRequired: false, isActive: true, keyboardType: .numbersAndPunctuation, validation: ValidationResult.Valid, text: companyInformation.isSalesTextServices, listData: []))
            
            cell.titleStackView.isHidden = true
            cell.textField.placeholder = "Sales Tax On Services"
            self.view.layoutIfNeeded()
        
        default:
            break
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func imagePickerCell(indexpath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: ImagePickerCell.className) as! ImagePickerCell
        cell.isUserInteractionEnabled = userInteractionEnabled
        cell.vc = self
        if companyInformation.companyLogo == Data() {
            cell.titleImage.image = #imageLiteral(resourceName: "placeholder")
            cell.titleImage.contentMode = .scaleAspectFill
        }
        else {
            cell.titleImage.image = UIImage(data: companyInformation.companyLogo)
            cell.titleImage.contentMode = .scaleAspectFit
        }
        
        cell.imageStringClosure = { [weak self] imageData in
            self?.companyInformation.companyLogo = imageData
            return nil
        }
        cell.titleLbl.text = DataFeilds.companyLogo.rawValue
        return cell
    }
    
    func dropdownCell(indexpath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: DropDownCell.className) as! DropDownCell
        cell.isUserInteractionEnabled = userInteractionEnabled
        cell.titleLbl.text = DataFeilds.billingMode.rawValue
        cell.dropdownTextLbl.text = companyInformation.billingMode
        cell.generateDataSource(data: ["Annually","Monthly"])
        cell.getDataClosure = { (value,index) in
            if index == 0 {
                self.isMonthlyBooking = false
                self.companyInformation.billAnnually = true
                self.companyInformation.billMontly = false
            }
            else {
                self.isMonthlyBooking = true
                self.companyInformation.billAnnually = false
                self.companyInformation.billMontly = true
                
            }
            self.tableview.reloadRows(at: [IndexPath.init(row: 7, section: 0)], with: .right)
        }
        return cell
    }
    
    
    
    func checkboxCell(indexpath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: CheckBoxTableViewCell.className) as! CheckBoxTableViewCell
        cell.isUserInteractionEnabled = userInteractionEnabled
        
        switch indexpath.row {
        case 14:
            cell.titleLbl.text = DataFeilds.invoiceApproval.rawValue
            cell.isChecked = companyInformation.invoiceApproval
            cell.celltag = 100
            
        case 15:
            cell.titleLbl.text = "Allow to borrow this year's Sick Leave"
            cell.isChecked = companyInformation.borrowSick
            cell.celltag = 101
            
        case 16:
            cell.titleLbl.text = "Allow to borrow this year's vacation days"
            cell.isChecked = companyInformation.borrowVacation
            cell.celltag = 102
            
        case 17:
            cell.titleLbl.text = DataFeilds.salesTaxSupplies.rawValue
            cell.isChecked = companyInformation.salesTaxSupplies
            cell.celltag = 103
            
        case 19:
            cell.titleLbl.text = DataFeilds.salesTextParts.rawValue
            cell.isChecked = companyInformation.salesTextParts
            cell.celltag = 104
            
        case 21:
            cell.titleLbl.text = DataFeilds.salesTextServices.rawValue
            cell.isChecked = companyInformation.salesTextServices
            cell.celltag = 105
            
        case 23:
            cell.titleLbl.text = DataFeilds.shippingTaxable.rawValue
            cell.isChecked = companyInformation.shippingTaxable
            cell.celltag = 106
            
        default:
            cell.titleLbl.text = DataFeilds.suppliesBeCharged.rawValue
            cell.isChecked = companyInformation.suppliesBeCharged
            cell.celltag = 107
            
        }
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    func inTrialPeriod() -> Bool {
        if companyInformation.startOfTrial <= Date() && Date() <= companyInformation.endOfTrial {
            return true
        }
        else {
            return false
        }
    }
    
}

extension CompanyInformationVC: TextFieldCellDelegate/*, CheckboxCellDelegate*/, CheckboxCellDelegates {
    
    func didChangeValue(with tag: Int, isSelected: Bool) {
        
        switch tag {
        case 100:
            companyInformation.invoiceApproval = isSelected
            break
            
        case 101:
            companyInformation.borrowSick = isSelected
            break
            
        case 102:
            companyInformation.borrowVacation = isSelected
            break
            
        case 103:
            companyInformation.salesTaxSupplies = isSelected
            if isSelected == true{
                self.suppliyRowHeight = 58.0
            }else{
                self.suppliyRowHeight = 0.0
            }
            self.tableview.reloadRows(at: [IndexPath.init(row: 18, section: 0)], with: .right)
            break
            
        case 104:
            companyInformation.salesTextParts = isSelected
            if isSelected == true{
                self.partsRowHeight = 58.0
            }else{
                self.partsRowHeight = 0.0
            }
            self.tableview.reloadRows(at: [IndexPath.init(row: 20, section: 0)], with: .right)
            break
            
        case 105:
            companyInformation.salesTextServices = isSelected
            if isSelected == true{
                self.serviceRowHeight = 58.0
            }else{
                self.serviceRowHeight = 0.0
            }
            self.tableview.reloadRows(at: [IndexPath.init(row: 22, section: 0)], with: .right)
            break
            
        case 106:
            companyInformation.shippingTaxable = isSelected
            break
            
        case 107:
            companyInformation.suppliesBeCharged = isSelected
            break
            
        default:
            break
        }
        
    }
    
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        if data.key == DataFeilds.companyName.rawValue {
            companyInformation.companyName = text ?? ""
        }
        else if data.key == DataFeilds.companyTagline.rawValue {
            companyInformation.companyTagline = text ?? ""
        }
        else if data.key == DataFeilds.startOfTrial.rawValue {
            companyInformation.startOfTrial = DateManager.stringToDate(string: text ?? "1900-01-01 00:00:00")!
        }
        else if data.key == DataFeilds.endOfTrial.rawValue {
            companyInformation.endOfTrial = DateManager.stringToDate(string: text ?? "1900-01-01 00:00:00")!
        }
        else if data.key == DataFeilds.startOfSubscription.rawValue {
            companyInformation.startOfSubscription = DateManager.stringToDate(string: text ?? "1900-01-01 00:00:00")!
        }
        else if data.key == DataFeilds.annualBillDate.rawValue {
            if isMonthlyBooking {
                companyInformation.monthlyBillDate = text ?? ""
            }
            else {
                companyInformation.annualBillDate = text ?? ""
            }
        }
        else if data.key == DataFeilds.referredBy.rawValue {
            companyInformation.referredBy = text ?? ""
        }
        else if data.key == DataFeilds.billingAddress.rawValue {
            companyInformation.billingAddress = text ?? ""
        }
        else if data.key == DataFeilds.billingAddress2.rawValue {
            companyInformation.billingAddress2 = text ?? ""
        }
        else if data.key == DataFeilds.billingAddressCity.rawValue {
            companyInformation.billingAddressCity = text ?? ""
        }
        else if data.key == DataFeilds.billingAddressState.rawValue {
            companyInformation.billingAddressState = text ?? ""
        }
        else if data.key == DataFeilds.billingAddressZip.rawValue {
            companyInformation.billingAddressZip = text ?? ""
        }
        else if data.key == DataFeilds.salesTaxSameOnAllParts.rawValue {
            companyInformation.isSalesTaxParts = text ?? ""
        }
        else if data.key == DataFeilds.salesTaxSameOnAllServices.rawValue {
            companyInformation.isSalesTextServices = text ?? ""
        }
        else if data.key == DataFeilds.salesTaxSameOnAllSupplies.rawValue {
            companyInformation.isSalesTaxSupplies = text ?? ""
        }
        tableview.reloadData()
    }
    
    func didChangeTextField(text: String?, data: TextFieldCellData) {
        let finalText = text ?? ""
        if data.key == DataFeilds.billingAddressState.rawValue {
            let indexpath = IndexPath(row: 12, column: 0)
            if let cell = tableview.cellForRow(at: indexpath) as? TextFieldCell{
                
                let arrResult = arrStatesListGlobal
                    .filter { NSPredicate(format: "(StateNickName contains[c] %@)", finalText).evaluate(with: $0) }
                    
                
                let arr = arrResult.map({$0["StateNickName"] as! String}) // For Select Item from list
                let arr2 = arrResult.map({"\($0["StateNickName"] as! String)" + " (\($0["FullStateName"] as! String))"})  // For Show list
                
                dropdown.anchorView = cell //5
                dropdown.direction = .any
                dropdown.width = cell.frame.width
                dropdown.dataSource = arr2
                dropdown.show()
                dropdown.bottomOffset = CGPoint(x: 0, y: cell.frame.size.height)
                dropdown.selectionAction = { [weak self] (index: Int, item: String) in //8
                  guard let self = self else { return }
                    print("Selected Item:\(item)")
                    self.companyInformation.billingAddressState = arr[index]
                    data.text = arr[index]
                    self.tableview.reloadData()
                }
            }
        }
    }
    
}
