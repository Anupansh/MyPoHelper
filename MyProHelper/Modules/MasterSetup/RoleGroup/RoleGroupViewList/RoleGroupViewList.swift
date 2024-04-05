//
//  RoleGroupViewList.swift
//  MyProHelper
//
//  Created by sismac010 on 29/07/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import IQKeyboardManager
import SideMenu

class RoleGroupViewList: BaseViewController, Storyboarded {
    
    @IBOutlet weak private var collectionView           : UICollectionView!
    
    var showRemovedSwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
    var showRemovedButton: UIBarButtonItem?
    private var addButton : UIBarButtonItem!
    var toShowRemoved = false
    let createWorkerViewModel           = CreateWorkerViewModel()
    let createWorkerViewModel2          = CreateWorkerViewModel2()
    
    //MARK:- View controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        setupCollectionView()
//        setupTabButtons()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "ROLES_GROUP".localize
        disableKeyboardViewScrolling()
        collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        enableKeyboardViewScrolling()
    }
    
    //MARK:- Custom methods
    
    func config(){
        let workerID = AppLocals.worker.workerID//UserDefaults.standard.value(forKey: UserDefaultKeys.userId) as? String
        if let workerID = workerID/*, !workerID.isEmpty*/{
            let id = workerID//Int(workerID)
            CommonController.shared.getWorker(workerId: id) { (worker) in
                if let worker = worker{
                    self.createWorkerViewModel2.createWorkerViewModel.setWorker(worker: worker)
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    
    private func enableKeyboardViewScrolling() {
        IQKeyboardManager.shared().isEnabled = true
    }
    
    private func disableKeyboardViewScrolling() {
        IQKeyboardManager.shared().isEnabled = false
    }
    
    private func setupCollectionView() {
        let devicesCell         = UINib(nibName: RoleGroupCell.ID, bundle: nil)
        let layout              = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        
        collectionView.collectionViewLayout = layout
        collectionView.dataSource           = self
        collectionView.delegate             = self
        collectionView.isPagingEnabled      = true
        collectionView.isScrollEnabled      = false
        
        collectionView.register(devicesCell, forCellWithReuseIdentifier: RoleGroupCell.ID)
    }
    
    private func setupNavigationBar() {
        addButton = UIBarButtonItem(barButtonSystemItem:.add,
                                          target: self,
                                          action: #selector(addButtonAction))
//        let showRemovedBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_hide_removed"), style: .done, target: self, action: #selector(handleShowRemoved))
        
        let sidemenuBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "menu"), style: .done, target: self, action: #selector(sideMenuPressed))
        showRemovedSwitch.cornerRadius = 15
        showRemovedSwitch.borderColor = .white
        showRemovedSwitch.onTintColor = .red
        showRemovedSwitch.borderWidth = 2
        showRemovedSwitch.addTarget(self, action: #selector(handleShowRemoved), for: .valueChanged)
        showRemovedButton = UIBarButtonItem(customView: showRemovedSwitch)
        self.navigationItem.leftBarButtonItem = sidemenuBtn
        navigationItem.rightBarButtonItems = [addButton,showRemovedButton!/*,showRemovedBtn*/]
    }
    
    
    @objc private func addButtonAction() {
        let createRoleGroup = CreateRoleGroup.instantiate(storyboard: .ROLE_GROUP)
        createRoleGroup.isEditingEnabled = true
//        createRoleGroup.viewModel = CreateRoleGroupModel()
        navigationController?.pushViewController(createRoleGroup,animated: true)
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
    

    @objc func handleShowRemoved() {
        if toShowRemoved == false {
            showRemovedSwitch.isOn = true
            toShowRemoved = true
//            let showRemovedBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_show_removed"), style: .done, target: self, action: #selector(handleShowRemoved))
        }
        else {
            showRemovedSwitch.isOn = false
            toShowRemoved = false
//            let showRemovedBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_hide_removed"), style: .done, target: self, action: #selector(handleShowRemoved))

        }
        self.navigationItem.rightBarButtonItems = [addButton,showRemovedButton!/*,showRemovedBtn*/]
        collectionView.reloadData()
    }

    private func showAddDeviceButton() {
        navigationItem.rightBarButtonItems = [addButton]
    }
    
    private func hideAddDeviceButton() {
//        guard isEditingEnabled else { return }
//        navigationItem.rightBarButtonItems = [saveButton]
    }

    
    
}

//MARK: - COLLECTION VIEW DATA SOURCE
extension RoleGroupViewList: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let deviceDetailTab = deviceDetailTabs[indexPath.section]
//        switch deviceDetailTab {
//        case .ACTIVE_PANEL:
            return instantiateDevicesCell(collectionView, cellForItemAt: indexPath)
//        case .UN_CONFIGURE_PANEL:
//            return instantiateDevicesCell(collectionView, cellForItemAt: indexPath)
//        }
    }
    
    
    private func instantiateDevicesCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RoleGroupCell.ID, for: indexPath) as? RoleGroupCell else {
            fatalError()
        }
//        cell.isShowingWorker = self.isShowingWorker
//        let deviceDetailTab = deviceDetailTabs[indexPath.section]
        cell.toShowRemoved = toShowRemoved
//        cell.isFilterDeviceSetup = true
//        cell.selectedTab = deviceDetailTab
//        cell.viewModel = createWorkerViewModel
        cell.viewModel = createWorkerViewModel2
        cell.showViewDelegate = self
        return cell
    }
    
    
}

//MARK: - COLLECTION VIEW DELEGATE FLOW LAYOUT
extension RoleGroupViewList: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width,
                      height: collectionView.frame.height)
    }
}

extension RoleGroupViewList: ShowViewDelegate {
    func presentView(view: UIViewController, completion: @escaping () -> ()) {
        present(view, animated: true, completion: completion)
    }

    func showAlert(alert: UIAlertController, sourceView: UIView) {
        presentAlert(alert: alert, sourceView: sourceView)
    }

    func pushView(view: UIViewController) {
        navigationController?.pushViewController(view, animated: true)
    }
}
