//
//  DevicesCell.swift
//  MyProHelper
//
//  Created by Samir on 12/30/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit
import SwiftDataTables

enum DeviceFields: String {
    case WORKER_NAME        = "WORKER_NAME"
    case DEVICE_NAME        = "DEVICE_NAME"
    case DEVICE_TYPE        = "DEVICE_TYPE"
    case DEVICE_CODE        = "DEVICE_CODE"
    case IS_DEVICE_SETUP    = "IS_DEVICE_SETUP"
    case CODE_EXPIRES       = "CODE_EXPIRES"
    
    func stringValue() -> String {
        return self.rawValue.localize
    }
}

class DevicesCell: UICollectionViewCell, SwiftDataTableDelegate {

    static let ID = String(describing: DevicesCell.self)
    
    @IBOutlet weak private var dataTableContainerView: UIView!
    private var dataTable: SwiftDataTable!
    
    private let dataTableFields: [DeviceFields] = [.WORKER_NAME,
                                           .DEVICE_NAME,
                                           .DEVICE_TYPE,
                                           .DEVICE_CODE,
                                           .IS_DEVICE_SETUP,
                                           .CODE_EXPIRES]
    private var searchKey: String?
    private var sortType: SortType?
    private var sortField: DeviceFields?
    var isShowingWorker: Bool = false
    var showViewDelegate: ShowViewDelegate?
    var isFilterDeviceSetup: Bool = false
    var toShowRemoved = false
    var isFromMaster:Bool = false
    
    var viewModel: CreateWorkerViewModel? {
        didSet {
            fetchDevices()
        }
    }
    
    var selectedTab: DeviceDetailTab = .UN_CONFIGURE_PANEL{
        didSet{
            self.dataTable.reload()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        initializeDataTable()
        setupDataTableLayout()
        self.showSnackbar()
    }

    private func initializeDataTable() {
        var option = DataTableConfiguration()
        option.shouldContentWidthScaleToFillFrame = true
        dataTable = SwiftDataTable(dataSource: self, options: option)
        dataTable.dataSource = self
        dataTable.delegate = self
        dataTable.backgroundColor = UIColor.init(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
    }
    
    private func setupDataTableLayout() {
        dataTable.translatesAutoresizingMaskIntoConstraints = false
        dataTableContainerView.backgroundColor = UIColor.white
        dataTableContainerView.addSubview(dataTable)
        
        NSLayoutConstraint.activate([
            dataTable.topAnchor.constraint(equalTo: dataTableContainerView.topAnchor),
            dataTable.leadingAnchor.constraint(equalTo: dataTableContainerView.leadingAnchor),
            dataTable.bottomAnchor.constraint(equalTo: dataTableContainerView.bottomAnchor),
            dataTable.trailingAnchor.constraint(equalTo: dataTableContainerView.trailingAnchor),
        ])
    }
    
    private func fetchDevices() {
        viewModel?.fetchDevices(showRemoved: toShowRemoved,
                                searchKey: searchKey,
                                isFilter: isFilterDeviceSetup,
                                isDeviceSetup: selectedTab == .ACTIVE_PANEL,
                                sortBy: sortField,
                                sortType: sortType,
                                completion: {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.dataTable.reload()
            }
        })
        
        self.showSnackbar()
    }
    
    private func fetchMoreDevices() {
        viewModel?.fetchMoreDevices(showRemoved: toShowRemoved,
                                    searchKey: searchKey,
                                    isFilter: isFilterDeviceSetup,
                                    isDeviceSetup: selectedTab == .ACTIVE_PANEL,
                                    sortBy: sortField,
                                    sortType: sortType,
                                    completion: {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.dataTable.reload()
            }
        })
        
        self.showSnackbar()
    }
    
    fileprivate func showSnackbar(){
       
        DispatchQueue.main.async {
            self.viewModel?.countDevices() == 0 ? self.dataTable.setEmptyMessage(show: true, message: Constants.Message.No_Data_To_Display) : self.dataTable.setEmptyMessage(show: false, message: "")
        }
        
    }
   
    //Waiting for more detail to complete this
    func generateDeviceCode(_ deviceid : String, completionHandler: @escaping (Result<Int, ConversionFailure>) -> Void) {
//        let dbVersionBeforeRequest = DBHelper.getDBVersion()
        
//        let rr = DBHelper.getDatabaseChanges()
//        let chgs:[DatabaseChanges] = rr.0
//        let changeCountBeforeRequest = DBHelper.getChangesDBCount()
//        let dbVersion = DBHelper.getDBVersion()
        if let UPDBCode  = AppLocals.serverAccessCode?.UPDBCode1 {
        
        
        
//            if (try? JSONEncoder().encode(chgs)) != nil {
//                print("have changes \(chgs.count)")
                
//                let cc:DatabaseChanges2 = DatabaseChanges2(accesscode: UPDBCode, dbVersion: dbVersion, changes: chgs, Hash: "")
//                let encoder  = JSONEncoder()
//                if let jsonData1 = try? encoder.encode(cc) {
//                    print("Json Data",cc)
            let serverURL = ServerURL()
            let urlString = serverURL.getURL(ServerURL.apiName.GenerateDeviceCode).absoluteString+deviceid
            let url = URL(string: urlString)!
                    var request = URLRequest(url: url)
                    request.httpMethod = "GET"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//                    request.httpBody = jsonData1
//                    let hash1:String
//
//                    if chgs.count == 0 {
//                        hash1 = DBHash.getDBHash()
//                    }
//                    else {
//                        hash1 = ""
//                    }
                    request.allHTTPHeaderFields = ["UpDnCode" : "\(UPDBCode)"/*, "DBHash": hash1*/]
                    let myurlsession1 = appURLSessionNormal.shared
                    let task = myurlsession1.urlSession.dataTask(with: request) { (data, response, error) in
                        if let httpResponse = response as? HTTPURLResponse {
                            
                            print("statusCode: \(httpResponse.statusCode)")
                            if httpResponse.statusCode != 200 {
                                DispatchQueue.main.async {
                                    print("bad device code")
                                    //failure(ErrorReponseReason.BadDeviceCode)
                                }
                                return
        
                            }
                            
                            guard let data = data else {
                                print("MyProHelperServer.getDBChanges unable to get response data")
                                return
                                
                            }
                            do {
                                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                            } catch {
                                print("Something went wrong")
                            }
//                            let decoder = JSONDecoder()
//                            if let user = try? decoder.decode(DatabaseChanges2.self, from: data) {
//                                print("after user change count \(user.changes.count)")
//                                print("User",user)
//                                DispatchQueue.main.async {
//                                        let foo1 = DatabaseChangesWithOriginalChangesDBVersion(changes: user.changes, serverCurrentDBVersion: user.dbVersion, dbVersionBeforeRequest: dbVersionBeforeRequest, ChangesDBCount: changeCountBeforeRequest, UpdateTime: user.UpdateTime, hash: user.Hash)
//                                        DBHelper.installServerDBChanges(chg: foo1)
//                                    completionHandler(.success(user.changes.count))
//                                }
//                            }
//                            else {
//                                print("DevicesCell.generateDeviceCode can't decode json response")
//                            }

                        }
        
                        if let error = error {
                            print("error:", error)
                            DispatchQueue.main.async {
                                completionHandler(.failure(.NoNetworkConnectivity))
                                
                            }
                            return
                        }

  
                    }
                    task.resume()
//                }
//            }
//            else {
//                print("MyProHelperServer.getDBChanges couldn't  encode json encode db changes. Change count:  \(chgs.count)")

//            }
        }
        else {
            print("DevicesCell.generateDeviceCode couldn't  get serverAccessCode?.UPDBCode1")
        }
    }
    
    
    private func newDeviceCode(at index: Int) {
        guard let viewModel = viewModel else { return }
        let device = viewModel.getDevice(at: index)
        
        //Waiting for more detail to complete this
//        generateDeviceCode("\(device.deviceID ?? 0)") { (result) in
//            print(result)
            self.fetchDevices()
//        }
    }
    
    private func showDevice(at index: Int) {
        guard let viewModel = viewModel else { return }
        let createDeviceView = CreateDeviceView.instantiate(storyboard: .DEVICES)
        createDeviceView.isEditingEnabled = false
        createDeviceView.bindDevice(device: viewModel.getDevice(at: index))
        showViewDelegate?.pushView(view: createDeviceView)
    }
    
    private func editDevice(at index: Int) {
        let isCanRunPayroll = AppLocals.workerRole.role.canRunPayroll!
//        let workerID = AppLocals.worker.workerID!//UserDefaults.standard.value(forKey: UserDefaultKeys.userId) as? String
//        if let workerID = workerID, !workerID.isEmpty{
//            isCanRunPayroll = CommonController.shared.getCanRunPayroll(workerId:workerID)
//        }
        guard let viewModel = viewModel else { return }
        let createDeviceView = CreateDeviceView.instantiate(storyboard: .DEVICES)
        createDeviceView.isEditingEnabled = true
        createDeviceView.bindDevice(device: viewModel.getDevice(at: index), canEditWorker: (isFromMaster ? isCanRunPayroll : false))
        showViewDelegate?.pushView(view: createDeviceView)
    }
    
    private func deleteDevice(at index: Int) {
        guard let viewModel = viewModel else { return }
        let deleteTitle = "DELETE_DEVICE_TITLE".localize
        let deleteMessage = "DELETE_DEVICE_MESSAGE".localize
        let deleteAlert = GlobalFunction.showDeleteAlert(title: deleteTitle, message: deleteMessage) {
            viewModel.deleteDeviceAt(at: index) { [weak self] in
                guard let self = self else { return }
                self.fetchDevices()
            }
        }
        
        if viewModel.isDeviceRemoved(at: index) {
            viewModel.restoreDeviceAt(at: index) { [weak self] in
                guard let self = self else { return }
                self.fetchDevices()
            }
        }
        else {
            showViewDelegate?.presentView(view: deleteAlert, completion: { })
        }
    }
    
    private func getHeader(for columnIndex: NSInteger) -> String {
        return dataTableFields[columnIndex].stringValue()
    }

    private func createData(at index: NSInteger) -> [DataTableValueType] {
        guard let viewModel = viewModel else { return [] }
        let device = ["⚙️"] + viewModel.getDevice(at: index).getDataArray()
        return device.compactMap(DataTableValueType.init)
    }
    
    //MARK: - Implement data table delegate methods
    func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
        guard !isShowingWorker else { return }
        guard let viewModel = viewModel else { return }
        guard let showViewDelegate = showViewDelegate else { return }
        let removeTitle = (viewModel.isDeviceRemoved(at: indexPath.section)) ? "UNDELETE".localize : "DELETE".localize
        
        let newCodeAction = UIAlertAction(title: "NEW_CODE".localize, style: .default) { [weak self] (_) in
            guard let self = self else { return }
            self.newDeviceCode(at: indexPath.section)
        }
        
        let actionSheet = GlobalFunction.showListActionSheet(deleteTitle: removeTitle,customActions: [newCodeAction]) { [weak self] (showAction) in
            guard let self = self else { return }
            self.showDevice(at: indexPath.section)
        }
        editHandler: { [weak self] (editAction) in
            guard let self = self else { return }
            self.editDevice(at: indexPath.section)
        }
        deleteHandler: { [weak self] (deleteAction) in
            guard let self = self else { return }
            self.deleteDevice(at: indexPath.section)
        }
        if let cell = dataTable.collectionView.cellForItem(at: indexPath) {
            showViewDelegate.showAlert?(alert: actionSheet, sourceView: cell)
        }

    }
    
    func didSearchForKey(_ dataTable: SwiftDataTable, Key: String) {
        searchKey = Key
        fetchDevices()
    }
    
    func willShowLastElement(_ collectionView: UICollectionView, indexPath: IndexPath) {
        fetchMoreDevices()
    }
    
    func heightForSectionFooter(in dataTable: SwiftDataTable) -> CGFloat {
        return 0
    }
}

//MARK: - Swift data source methods
extension DevicesCell: SwiftDataTableDataSource {

    func numberOfColumns(in: SwiftDataTable) -> Int {
        if viewModel?.countDevices() == 0 {
            return 0
        } else {
            return dataTableFields.count + 1
        }
    }

    func numberOfRows(in: SwiftDataTable) -> Int {
        return viewModel?.countDevices() ?? 0
    }

    func dataTable(_ dataTable: SwiftDataTable, dataForRowAt index: NSInteger) -> [DataTableValueType] {
        return createData(at: index)
    }

    func dataTable(_ dataTable: SwiftDataTable, headerTitleForColumnAt columnIndex: NSInteger) -> String {
        if columnIndex == 0 {
            return "ACTION".localize
        }
        return getHeader(for: columnIndex - 1)
    }

    func didTapSort(_ dataTable: SwiftDataTable, type: DataTableSortType, column: Int) {
        sortType  = (type == DataTableSortType.ascending) ? .ASCENDING : .DESCENDING
        sortField = dataTableFields[column - 1]
        fetchDevices()
        
    }
}
