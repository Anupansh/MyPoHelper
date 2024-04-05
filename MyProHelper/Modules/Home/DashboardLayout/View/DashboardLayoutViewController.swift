//
//  DashboardLayoutViewController.swift
//  MyProHelper
//
//  Created by Sourabh Nag on 01/07/20.
//  Copyright © 2020 Sourabh Nag. All rights reserved.
//

import UIKit

protocol DashboardLayoutViewControllerDelegate:AnyObject {
    func updateLayout(boolArr: [Bool])
}

class DashboardLayoutViewController: UIViewController {

    @IBOutlet weak var navigationView: PresentationNavigationView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    weak var layoutDelegate:DashboardLayoutViewControllerDelegate?
    var boolArray = [true,false,false,false,false,false,false,false,false,false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUp()
    }
    
    func setUp() {
        self.navigationView.delegate = self
        let header = DashboardLayoutTableHeader()
        header.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height*0.15)
        tableView.tableHeaderView = header
        tableView.registerMultiple(nibs: [CheckboxCell.className])
    }

}

extension DashboardLayoutViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CheckboxCell.className) as! CheckboxCell
        
        var title = ""
        var key = ""
        
        switch indexPath.row {
        case 0:
            key = "MyJobs"
            title = "My Jobs"
        case 1:
            key = "Calender"
            title = "Calender"
        case 2:
            key = "CallList"
            title = "Call List"
        case 3:
            key = "Quotes"
            title = "Quotes"
        case 4:
            key = "Estimates"
            title = "Estimates"
        case 5:
            key = "BillingInvoice"
            title = "Billing/Invoice"
        case 6:
            key = "StockedParts"
            title = "Stocked Parts"
        case 7:
            key = "TimeSheet"
            title = "Time Sheet"
        case 8:
            key = "Payroll"
            title = "Payroll"
        case 9:
            key = "MapOfWorkers"
            title = "Map Of Workers"
        default:
            break
        }
        /*
        if indexPath.row == 0 {
            cell.bindCell(data: [.init(key: "MyJobs", title: "My Jobs", value: boolArray[0])])
        }
        else if indexPath.row == 1{
            cell.bindCell(data: [.init(key: "Calender", title: "Calender", value: boolArray[1])])
        }
        else if indexPath.row == 2{
            cell.bindCell(data: [.init(key: "CallList", title: "Call List", value: boolArray[2])])
        }
        else if indexPath.row == 3{
            cell.bindCell(data: [.init(key: "Quotes", title: "Quotes", value: boolArray[3])])
        }
        else if indexPath.row == 4{
            cell.bindCell(data: [.init(key: "Estimates", title: "Estimates", value: boolArray[4])])
        }
        else if indexPath.row == 5{
            cell.bindCell(data: [.init(key: "BillingInvoice", title: "Billing/Invoice", value: boolArray[5])])
        }
        */
        cell.bindCell(data: [.init(key: key, title: title, value: boolArray[indexPath.row])])
        cell.delegate = self
        return cell
    }
    
    
}

extension DashboardLayoutViewController:PresentationNavigationViewDelegate, CheckboxCellDelegate {
    func didChangeValue(with data: RadioButtonData, isSelected: Bool) {
        if data.key == "MyJobs" {
            boolArray[0] = isSelected
        }
        else if data.key == "Calender" {
            boolArray[1] = isSelected
        }
        else if data.key == "CallList"{
            boolArray[2] = isSelected
        }
        else if data.key == "Quotes"{
            boolArray[3] = isSelected
        }
        else if data.key == "Estimates"{
            boolArray[4] = isSelected
        }
        else if data.key == "BillingInvoice"{
            boolArray[5] = isSelected
        }
        else if data.key == "StockedParts"{
            boolArray[6] = isSelected
        }
        else if data.key == "TimeSheet"{
            boolArray[7] = isSelected
        }
        else if data.key == "Payroll" {
            boolArray[8] = isSelected
        }
        else if data.key == "MapOfWorkers" {
            boolArray[9] = isSelected
            if isSelected {
                CommonController.shared.setLocationData()
            }
        }
    }
    
    func cancelButtonAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonAction() {
        self.layoutDelegate?.updateLayout(boolArr: boolArray)
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
