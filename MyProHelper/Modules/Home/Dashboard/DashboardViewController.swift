//
//  DashboardViewController.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 05/04/1942 Saka.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit
import SideMenu
import GRDB
import Network

class GenericDataSource<T>:NSObject {
    var data: DynamicValue<[T]> = DynamicValue([])
    var dataCopy: DynamicValue<[T]> = DynamicValue([])
    var dataArray: DynamicValue<[[T]]> = DynamicValue([])
    var selectedItems: DynamicValue<[T]> = DynamicValue([])
}


class DashboardViewController: UIViewController {
    
    
    // MARK: - OUTLETS AND VARIABLES
    enum WidgetsData {
        case windowOnly
        case myJobsOnly
        case calenderOnly
        case myJobsAndCalender
        case none
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationView: NavigationView!
    @IBOutlet weak var noWidgetsLbl: UILabel!
    
    var widgetsData: WidgetsData = .myJobsOnly
    var boolArray = [true,false,false,false,false,false,false,false,false,false]
    let service = ScheduleJobService()
    var jobList = DBHelper.getScheduledJobs()
    var viewModel: DashboardViewModel = DashboardViewModel()
    let monitor = NWPathMonitor()
    var lastConnectionStatus: Int = -1
    var queue = DispatchQueue(label: "Monitor")
    
    // MARK: - VIEW LIFECYCLE
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.jobList = DBHelper.getScheduledJobs()
        self.tableView.reloadData()
    }
    
    // MARK: - HELPER FUNCTIONS
    private func initialSetup() {
//        runApi()
        fetchInitialData()
        setupUI()
        synchronizeNetwork()
    }
    
    func fetchInitialData() {
        DBHelper.fetchWorker()
        DBHelper.fetchWorkerRoles()
        DBHelper.fetchStartDay()
        DBHelper.fetchWorker()
    }
    
    func setupUI() {
        self.navigationView.setTitle("Dashboard")
        self.navigationView.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.registerMultiple(nibs: [HomeDataTableCell.className,CalenderTableViewCell.className,LatestInfoTableCell.className,MapOfWorkersCell.className])
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
    }
    
    func synchronizeNetwork() {
        SocketManager.shared.startSocket()
        SocketManager.shared.startLocationUpdates()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                if self.lastConnectionStatus != 1 {
                    self.lastConnectionStatus = 1
                    DispatchQueue.main.async {
                        let server = MyProHelperServer()
                        server.getDBChanges { (result) in
                            print(result)
                        }
                    }
                }
            }
            else {
                if self.lastConnectionStatus !=  0 {
                    self.lastConnectionStatus = 0
                    print("No connection.")
                }
            }
        }
        monitor.start(queue: queue)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: .serverChanges, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocationData), name: .locationDataChanged, object: nil)
    }
    
    func runApi() {
        let serverURL = ServerURL()
        let url   = URL(string: "https://myprohelper.com:5005/api/Postmail")
        let parameters = ["To": "anupanshaggarwal@gmail.com",
                          "CC": "",
                          "BCC": "",
                          "Subject": "",
                          "Body": "",
                          "Attachments": ""]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            print("Daman")
            return
        }
        var request = URLRequest(url: url!)
        request.httpMethod = "post"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        let myurlsession1 = appURLSessionNormal.shared
        myurlsession1.urlSession.dataTask(with: request) { (data, response, error) in
//                if let httpResponse = response as? HTTPURLResponse {
//                    print("statusCode: \(httpResponse.statusCode)")
//                    if httpResponse.statusCode != 200 {
//                        DispatchQueue.main.async {
//                            completionHandler(.failure(ConversionFailure.BadDeviceCode))
//                        }
//                        return
//                    }
//                }
//                if let error = error {
//                    print("error:", error)
//                    DispatchQueue.main.async {
//                        completionHandler(.failure(ConversionFailure.NoNetworkConnectivity))
//                    }
//                    return
//                }
//                guard let data = data else { return }
//                let decoder = JSONDecoder()
//                if let user = try? decoder.decode(DeviceToServerAccess.self, from: data) {
//                    print("after user = ")
//                    if let foo = user.SubDomain, !foo.isEmpty {
//                        print("have sub \(foo)")
//                    }
//                    else {
//                        print("no subdomain")
//                    }
//                    DispatchQueue.main.async {
//                        completionHandler(.success(user))
//                    }
//                }
//                else {
//                    DispatchQueue.main.async {
//                        completionHandler(.failure(ConversionFailure.invalidData))
//                }
//            }
        }.resume()
    }
    
    @objc func refreshData() {
        jobList = DBHelper.getScheduledJobs()
        tableView.reloadData()
    }
    
    @objc func updateLocationData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: - NAVIGATION DELEGATE ITEMS
extension DashboardViewController:NavigationViewDelegate {
    
    func menuButtonAction() {
        let sideMenuView = SideMenuView.instantiate(storyboard: .HOME)
        let menu = SideMenuNavigationController(rootViewController: sideMenuView)
        let screenWidth = UIScreen.main.bounds.width
        menu.leftSide = true
        menu.presentationStyle = .menuSlideIn
        menu.isNavigationBarHidden = true
        menu.menuWidth = (screenWidth > 400) ? 400 : screenWidth
        menu.sideMenuManager.addScreenEdgePanGesturesToPresent(toView: view)
        self.present(menu, animated: true, completion: nil)
    }
    
    func addButtonAction() {
        let createJob = CreateJobView.instantiate(storyboard: .SCHEDULE_JOB)
        createJob.viewModel = CreateJobViewModel(attachmentSource: .SCHEDULED_JOB)
        createJob.setViewMode(isEditingEnabled: true)
        createJob.cameFromHome = true
        navigationController?.pushViewController(createJob, animated: true)
    }
    
    func layoutButtonAction() {
        DispatchQueue.main.async {
            let layoutVC = DashboardLayoutViewController()
            layoutVC.modalPresentationStyle = .fullScreen
            layoutVC.layoutDelegate = self
            layoutVC.boolArray = self.boolArray
            self.present(layoutVC, animated: true, completion: nil)
        }
    }
}

// MARK: - TABLEVIEW DELEGATES AND DATASOURCE
extension DashboardViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 10//boolArray.filter({$0 == true}).count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return boolArray[section] == true ? 1 : 0//boolArray.filter({$0 == true}).count
//        switch widgetsData {
//        case .none:
//            return 0
//        case .calenderOnly,.myJobsOnly,.windowOnly:
//            return 1
//        case .myJobsAndCalender:
//            return 2
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            return dequeueMyJobsCell(indexPath: indexPath)
        case 1:
            return dequeCalenderCell(indexPath: indexPath)
        case 2,3,4,5,6,7,8:
            return dequeLatestInfoCell(indexPath: indexPath)
        case 9:
            return dequeMapOfWorkersCell(indexPath: indexPath)
        default:
            return UITableViewCell()
        }
//        switch widgetsData {
//        case .none:
//            return UITableViewCell()
//        case .windowOnly:
//            return dequeLatestInfoCell(indexPath: indexPath)
//        case .myJobsOnly:
//            return dequeueMyJobsCell(indexPath: indexPath)
//        case .calenderOnly:
//            return dequeCalenderCell(indexPath: indexPath)
//        case .myJobsAndCalender:
//            if indexPath.row == 0 {
//                return dequeueMyJobsCell(indexPath: indexPath)
//            }
//            else {
//                return dequeCalenderCell(indexPath: indexPath)
//            }
//        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let count = boolArray.filter({$0 == true}).count
        if count == 1{
            return tableView.frame.height
        }
        switch indexPath.section {
        case 0:
            if count == 0{
                return 0
            }
            else if count == 1{
                return tableView.frame.height * 1
            }
//            else if count == 2 {
//                return tableView.frame.height * 0.6
//            }
//            else if count == 3 {
//                return tableView.frame.height * 0.6
//            }
            else{
                return tableView.frame.height * 0.6
            }
//        case 1:
//            if count == 0{
//                return 0
//            }
//            else if count == 1{
//                return tableView.frame.height * 1
//            }
//            else if count == 2 {
//                return tableView.frame.height * 0.6
//            }
//            else if count == 3 {
//                return tableView.frame.height * 0.6
//            }
//        case 2:
//            if count == 0{
//                return 0
//            }
//            else if count == 1{
//                return tableView.frame.height * 1
//            }
//            else if count == 2 {
//                return tableView.frame.height * 0.6
//            }
//            else if count == 3 {
//                return tableView.frame.height * 1
//            }
        default:
//            if count-1 == indexPath.section{
//                return tableView.frame.height
//            }
//            else{
                return tableView.frame.height * 0.6
//            }
        }
        return 0
//        switch widgetsData {
//        case .none:
//            return 0
//        case .myJobsOnly,.calenderOnly,.windowOnly:
//            return tableView.frame.height
//        case .myJobsAndCalender:
//            if indexPath.row == 0 {
//                return tableView.frame.height * 0.6
//            }
//            else {
//                return tableView.frame.height
//            }
//        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func dequeueMyJobsCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HomeDataTableCell.className) as! HomeDataTableCell
        let filteredJobList = (jobList.filter({$0.startDateTime! >= Date()})).sorted { (job1, job2) -> Bool in
            job1.startDateTime! < job2.startDateTime!
        }
        if let pickedJob = AppLocals.pickedJob {
            let lastFilteredJobList = filteredJobList.filter({$0.jobID != pickedJob.jobID})
            cell.jobList = lastFilteredJobList
        }
        else {
            cell.jobList = filteredJobList
        }
        cell.vc = self
        cell.dataTable.reload()
        return cell
    }
    
    func dequeCalenderCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CalenderTableViewCell.className) as! CalenderTableViewCell
        cell.jobList = self.jobList
        cell.vc = self
        cell.dayView.reloadData()
        return cell
    }
    
    func dequeLatestInfoCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LatestInfoTableCell.className) as! LatestInfoTableCell
//        cell.jobList = self.jobList
        cell.vc = self
        switch indexPath.section {
        case 2:
            cell.selectedTab = .CALL_LIST
        case 3:
            cell.selectedTab = .QUOTES
        case 4:
            cell.selectedTab = .ESTIMATES
        case 5:
            cell.selectedTab = .BILLING_INVOICE
        case 6:
            cell.selectedTab = .STOCKED_PARTS
        case 7:
            cell.selectedTab = .TIME_SHEET
        case 8:
            cell.selectedTab = .PAYROLL
        
        default:
            cell.selectedTab = .CALL_LIST
        }
        cell.reload()
//        cell.dayView.reloadData()
        return cell
    }
    
    func dequeMapOfWorkersCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MapOfWorkersCell.className) as! MapOfWorkersCell
        cell.locationData = AppLocals.savedLocationData
        cell.updateMap()
        return cell
    }
}

// MARK: - DASHBOARD LAYOUT VIEW CONTROLLER DELEGATES
extension DashboardViewController: DashboardLayoutViewControllerDelegate{
    func updateLayout(boolArr: [Bool]) {
        self.boolArray = boolArr
        noWidgetsLbl.isHidden = boolArray.filter({$0 == true}).count > 0
        tableView.reloadData()
    }
}
