//
//  DeviceDetailView.swift
//  MyProHelper
//
//  Created by sismac010 on 09/07/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import IQKeyboardManager
import SideMenu

enum DeviceDetailTab: String {
    case ACTIVE_PANEL       = "ACTIVE_PANEL"
    case UN_CONFIGURE_PANEL = "UN_CONFIGURE_PANEL"
    
    func stringValue() -> String {
        return self.rawValue.localize
    }
}



class DeviceDetailView: BaseViewController, Storyboarded {
    
    @IBOutlet weak private var activePanelTabButton     : UIButton!
    @IBOutlet weak private var UnConfigPanelTabButton   : UIButton!
    @IBOutlet weak private var collectionView           : UICollectionView!

    var toShowRemoved = false
    private var saveButton      : UIBarButtonItem!
    private var addDeviceButton : UIBarButtonItem!
    var showRemovedButton: UIBarButtonItem?
    var showRemovedSwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 40, height: 30))

    
    private let deviceDetailTabs: [DeviceDetailTab] = [.UN_CONFIGURE_PANEL,.ACTIVE_PANEL]
    private var isEditingEnabled        = false
    private var selectedTab: DeviceDetailTab  = .UN_CONFIGURE_PANEL
    let createWorkerViewModel           = CreateWorkerViewModel()
    
    //MARK:- View controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        setupCollectionView()
        setupTabButtons()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "DEVICE_DETAIL".localize
        disableKeyboardViewScrolling()
        collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        enableKeyboardViewScrolling()
    }
    
    //MARK:- Custom methods
    
    func config(){
        let workerID = AppLocals.worker.workerID!
        DBHelper.getWorker(workerId: workerID) { (worker) in
            if let worker = worker{
                self.createWorkerViewModel.setWorker(worker: worker)
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    private func enableKeyboardViewScrolling() {
        IQKeyboardManager.shared().isEnabled = true
    }
    
    private func disableKeyboardViewScrolling() {
        IQKeyboardManager.shared().isEnabled = false
    }
    
    private func setupTabButtons() {
        activePanelTabButton.setTitle(DeviceDetailTab.ACTIVE_PANEL.stringValue(), for: .normal)
        UnConfigPanelTabButton.setTitle(DeviceDetailTab.UN_CONFIGURE_PANEL.stringValue().localize, for: .normal)

//        if createWorkerViewModel.isEditingWorker() {
            selectTab(button: UnConfigPanelTabButton)
//        }
//        else {
//            disableTabButtons()
//        }
    }
    
    private func setupCollectionView() {
        let devicesCell         = UINib(nibName: DevicesCell.ID, bundle: nil)
        let layout              = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        
        collectionView.collectionViewLayout = layout
        collectionView.dataSource           = self
        collectionView.delegate             = self
        collectionView.isPagingEnabled      = true
        collectionView.isScrollEnabled      = false
        
        collectionView.register(devicesCell, forCellWithReuseIdentifier: DevicesCell.ID)
    }
    
    private func setupNavigationBar() {
        addDeviceButton = UIBarButtonItem(barButtonSystemItem:.add,
                                          target: self,
                                          action: #selector(addDevice))
//        let showRemovedBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_hide_removed"), style: .done, target: self, action: #selector(handleShowRemoved))
        let sidemenuBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "menu"), style: .done, target: self, action: #selector(sideMenuPressed))
        showRemovedSwitch.cornerRadius = 15
        showRemovedSwitch.borderColor = .white
        showRemovedSwitch.onTintColor = .red
        showRemovedSwitch.borderWidth = 2
        showRemovedSwitch.addTarget(self, action: #selector(handleShowRemoved), for: .valueChanged)
        showRemovedButton = UIBarButtonItem(customView: showRemovedSwitch)
        self.navigationItem.leftBarButtonItem = sidemenuBtn
        navigationItem.rightBarButtonItems = [addDeviceButton,showRemovedButton!/*,showRemovedBtn*/]
    }
    
    @objc private func addDevice() {
        let isCanRunPayroll = AppLocals.workerRole.role.canRunPayroll!
//        let workerID = UserDefaults.standard.value(forKey: UserDefaultKeys.userId) as? String
//        if let workerID = workerID, !workerID.isEmpty{
//            isCanRunPayroll = CommonController.shared.getCanRunPayroll(workerId:workerID)
//        }
        let createDeviceView = CreateDeviceView.instantiate(storyboard: .DEVICES)
        createDeviceView.isAdding = true
        createDeviceView.isEditingEnabled = true
        createDeviceView.bindDevice(device: nil,
                                    worker: createWorkerViewModel.getWorker(),
                                    canEditWorker: isCanRunPayroll)

        navigationController?.pushViewController(createDeviceView,
                                                 animated: true)
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
        self.navigationItem.rightBarButtonItems = [addDeviceButton,showRemovedButton!/*,showRemovedBtn*/]
        collectionView.reloadData()
    }
    
    
    private func showAddDeviceButton() {
//        guard isEditingEnabled else { return }
        navigationItem.rightBarButtonItems = [addDeviceButton]
    }
    
    private func hideAddDeviceButton() {
//        guard isEditingEnabled else { return }
        navigationItem.rightBarButtonItems = [saveButton]
    }

    
    private func configureTabSelection(tab: DeviceDetailTab) {
        deseletcTab(button: activePanelTabButton)
        deseletcTab(button: UnConfigPanelTabButton)
        selectedTab = tab
        
        switch tab {
        case .ACTIVE_PANEL:
            selectTab(button: activePanelTabButton)
            enableKeyboardViewScrolling()
//            hideAddDeviceButton()
        case .UN_CONFIGURE_PANEL:
            selectTab(button: UnConfigPanelTabButton)
            enableKeyboardViewScrolling()
//            hideAddDeviceButton()
        }
//        showAddDeviceButton()
    }
    
    private func selectTab(button: UIButton) {
        button.borderWidth      = 1
        button.borderColor      = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
        button.backgroundColor  = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        button.tintColor        = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        button.setTitleColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), for: .normal)
    }
    
    private func deseletcTab(button: UIButton) {
        button.borderWidth      = 0
        button.borderColor      = .clear
        button.backgroundColor  = .clear
        button.tintColor        = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        button.setTitleColor(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1), for: .normal)
    }
    
    @IBAction func tabButtonPressed(sender: UIButton) {
        guard let title = sender.title(for: .normal) else {
            return
        }
        guard let index = deviceDetailTabs.firstIndex(where: { $0.stringValue() == title}) else {
            return
        }
        let indexPath = IndexPath(item: 0, section: index)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        collectionView.reloadData()
        configureTabSelection(tab: deviceDetailTabs[index])
    }
    
    func setViewMode(isEditingEnabled: Bool) {
        self.isEditingEnabled = isEditingEnabled
    }
    
}

//MARK: - COLLECTION VIEW DATA SOURCE
extension DeviceDetailView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return deviceDetailTabs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let deviceDetailTab = deviceDetailTabs[indexPath.section]
        switch deviceDetailTab {
        case .ACTIVE_PANEL:
            return instantiateDevicesCell(collectionView, cellForItemAt: indexPath)
        case .UN_CONFIGURE_PANEL:
            return instantiateDevicesCell(collectionView, cellForItemAt: indexPath)
        }
    }
    
    
    private func instantiateDevicesCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DevicesCell.ID, for: indexPath) as? DevicesCell else {
            fatalError()
        }
//        cell.isShowingWorker = self.isShowingWorker
        let deviceDetailTab = deviceDetailTabs[indexPath.section]
        cell.isFromMaster = true
        cell.toShowRemoved = toShowRemoved
        cell.isFilterDeviceSetup = true
        cell.selectedTab = deviceDetailTab
        cell.viewModel = createWorkerViewModel
        cell.showViewDelegate = self
        return cell
    }
    
    
}

//MARK: - COLLECTION VIEW DELEGATE FLOW LAYOUT
extension DeviceDetailView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width,
                      height: collectionView.frame.height)
    }
}

extension DeviceDetailView: ShowViewDelegate {
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
