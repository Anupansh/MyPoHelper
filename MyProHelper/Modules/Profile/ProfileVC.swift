//
//  ProfileVC.swift
//  MyProHelper
//
//  Created by sismac010 on 05/10/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import UIKit
import SideMenu

class Profile:BaseViewController, Storyboarded{
    @IBOutlet weak private var listTableView    : UITableView!
    
    private var arrData: [String] =
        [ "PROFILE".localize,
          "CHANGE_PASSWORD".localize,
          "LOGOUT".localize
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupListTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupNavigationBar() {
        title = "PROFILE".localize
        navigationController?.navigationBar.isHidden = false
        let sidemenuBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "menu"), style: .done, target: self, action: #selector(sideMenuPressed))
        self.navigationItem.leftBarButtonItem = sidemenuBtn
    }
    
    private func setupListTableView() {
        let appListCell = UINib(nibName: AppListCell.cellId, bundle: nil)
        listTableView.delegate = self
        listTableView.dataSource = self
        listTableView.separatorStyle = .none
        listTableView.rowHeight = 50
        listTableView.register(appListCell, forCellReuseIdentifier: AppListCell.cellId)
        
    }
    
    // MARK: - NAVIGATION ITEMS
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
    
    func editItem(worker: Worker) {
        let createWorker = CreateWorkerView.instantiate(storyboard: .WORKER)
//        let worker = viewModel.getItem(at: indexPath.section)
        createWorker.createWorkerViewModel.setWorker(worker: worker)
        createWorker.setViewMode(isEditingEnabled: true)
        navigationController?.pushViewController(createWorker, animated: true)
    }

    func logout(){
        let settings:SavedSettings = SavedSettings()
        settings.removeSettingsTableRows()
        AppLocals.serverAccessCode = nil
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.workerId)
        UserDefaults.standard.synchronize()
        let vc = AppStoryboards.auth.instantiateViewController(withIdentifier: LoginVC.className)
        CommonController.shared.setRootVC(withController: vc)
    }
    
}

extension Profile: UITableViewDelegate {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if indexPath.row == filteredData.count - 1 {
//            delegate?.willShowLastItem()
//        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            var worker = AppLocals.worker
            worker.workerRoles = AppLocals.workerRole
            worker.workerRoles?.rolesGroup = AppLocals.workerRolesGroup
            editItem(worker: worker)
        case 1:break
        case 2:
            logout()
        default:break
        }
//        let item = filteredData[indexPath.row]
//        if let selectedItemRow = data.firstIndex(of: item) {
//            handleSelectItem(row: selectedItemRow)
//        }
        
    }
}

extension Profile: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AppListCell.cellId) as? AppListCell else {
            return UITableViewCell()
        }
        cell.setTitle(title: arrData[indexPath.row])
        cell.isLastCell(indexPath.row == arrData.count - 1)
        return cell
    }
    
}
