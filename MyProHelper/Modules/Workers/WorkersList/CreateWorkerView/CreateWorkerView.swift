//
//  CreateWorkerView.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/28/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit
import IQKeyboardManager

enum WorkerTab: String {
    case PERSONAL_INFO  = "PERSONAL_INFO"
    case ADDRESS        = "ADDRESS"
    case ROLES          = "ROLES"
    case DEVICES        = "DEVICES"
    case WAGES          = "WAGES"
    
    func stringValue() -> String {
        return self.rawValue.localize
    }
}

class CreateWorkerView: BaseViewController, Storyboarded {
    
    @IBOutlet weak private var personalInfoTabButton   : UIButton!
    @IBOutlet weak private var addressTabButton        : UIButton!
    @IBOutlet weak private var roleTabButton           : UIButton!
    @IBOutlet weak private var deviceTabButton         : UIButton!
    @IBOutlet weak private var wageTabButton           : UIButton!
    @IBOutlet weak private var collectionView          : UICollectionView!

    private var saveButton      : UIBarButtonItem!
    private var addDeviceButton : UIBarButtonItem!
    private var addRoleGroupButton : UIBarButtonItem!
    var showRemovedButton: UIBarButtonItem!
    var showRemovedSwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
    var toShowRemoved = false

    private let workerTabs: [WorkerTab] = [.PERSONAL_INFO,
                                           .ADDRESS,
                                           .ROLES,
                                           .DEVICES,
                                           .WAGES]
    private var isEditingEnabled        = false
    private var selectedTab: WorkerTab  = .PERSONAL_INFO
    let createWorkerViewModel           = CreateWorkerViewModel()
    var isShowingWorker                 = false
    var isAdd        = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupTabButtons()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        disableKeyboardViewScrolling()
        collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        enableKeyboardViewScrolling()
    }
    
    private func enableKeyboardViewScrolling() {
        IQKeyboardManager.shared().isEnabled = true
    }
    
    private func disableKeyboardViewScrolling() {
        IQKeyboardManager.shared().isEnabled = false
    }
    
    private func setupNavigationBar() {
        saveButton = UIBarButtonItem(barButtonSystemItem: .save,
                                     target: self,
                                     action: #selector(handleSaveButton))

        addDeviceButton = //UIBarButtonItem(title: "Add Device",
                                        //style: .plain,
                            UIBarButtonItem(barButtonSystemItem: .add,
                                          target: self,
                                          action: #selector(addDevice))
        
        addRoleGroupButton = //UIBarButtonItem(title: "Add Role Group",
                                            //style: .plain,
            UIBarButtonItem(barButtonSystemItem: .add,
                                          target: self,
                                          action: #selector(addRoleGroup))
        
        showRemovedSwitch.cornerRadius = 15
        showRemovedSwitch.borderColor = .white
        showRemovedSwitch.onTintColor = .red
        showRemovedSwitch.borderWidth = 2
        showRemovedSwitch.addTarget(self, action: #selector(handleShowRemoved), for: .valueChanged)
        showRemovedButton = UIBarButtonItem(customView: showRemovedSwitch)
        
        
        
        if isEditingEnabled {
            self.navigationItem.rightBarButtonItems = [saveButton]
        }
    }
    
    private func setupTabButtons() {
        personalInfoTabButton.setTitle(WorkerTab.PERSONAL_INFO.stringValue(), for: .normal)
        addressTabButton.setTitle(WorkerTab.ADDRESS.stringValue().localize, for: .normal)
        roleTabButton.setTitle(WorkerTab.ROLES.stringValue().localize, for: .normal)
        deviceTabButton.setTitle(WorkerTab.DEVICES.stringValue().localize, for: .normal)
        wageTabButton.setTitle(WorkerTab.WAGES.stringValue().localize, for: .normal)
        
//        if isEditingEnabled/*createWorkerViewModel.isEditingWorker()*/ {
            selectTab(button: personalInfoTabButton)
//        }
//        else {
//            disableTabButtons()
//        }
    }
    
    private func disableTabButtons() {
        personalInfoTabButton.isEnabled = false
        addressTabButton.isEnabled      = false
        roleTabButton.isEnabled         = false
        deviceTabButton.isEnabled       = false
        wageTabButton.isEnabled         = false
        
        selectTab(button: personalInfoTabButton)
        selectTab(button: addressTabButton)
        selectTab(button: roleTabButton)
        selectTab(button: deviceTabButton)
        selectTab(button: wageTabButton)
    }
    
    private func enableTabButtons() {
        personalInfoTabButton.isEnabled = true
        addressTabButton.isEnabled      = true
        roleTabButton.isEnabled         = true
        deviceTabButton.isEnabled       = true
        wageTabButton.isEnabled         = true
        
        deseletcTab(button: personalInfoTabButton)
        deseletcTab(button: addressTabButton)
        deseletcTab(button: roleTabButton)
        deseletcTab(button: deviceTabButton)
        deseletcTab(button: wageTabButton)
    }

    private func showAddDeviceButton() {
        guard isEditingEnabled else { return }
        navigationItem.rightBarButtonItems = [saveButton, addDeviceButton]
    }

    private func hideAddDeviceButton() {
        guard isEditingEnabled else { return }
        navigationItem.rightBarButtonItems = [saveButton]
    }

    @objc private func addDevice() {
        let createDeviceView = CreateDeviceView.instantiate(storyboard: .DEVICES)
        createDeviceView.isEditingEnabled = true
        createDeviceView.bindDevice(device: nil,
                                    worker: createWorkerViewModel.getWorker(),
                                    canEditWorker: false)

        navigationController?.pushViewController(createDeviceView,animated: true)
    }
    
    private func showAddRoleGroupButton() {
        guard isEditingEnabled else { return }
        navigationItem.rightBarButtonItems = [saveButton, addRoleGroupButton]
    }

    private func hideAddRoleGroupButton() {
        guard isEditingEnabled else { return }
        navigationItem.rightBarButtonItems = [saveButton]
    }

    
    @objc private func addRoleGroup() {
        let createRoleGroup = CreateRoleGroup.instantiate(storyboard: .ROLE_GROUP)
        createRoleGroup.isEditingEnabled = true
//        createRoleGroup.viewModel = CreateRoleGroupModel()
        navigationController?.pushViewController(createRoleGroup,animated: true)
    }
    
    
    private func showDeviceTabButton() {
        guard isEditingEnabled else {
            navigationItem.rightBarButtonItems = [showRemovedButton]
            return
        }
        navigationItem.rightBarButtonItems = [saveButton, addDeviceButton, showRemovedButton]
    }
    
    private func hideDeviceTabButton() {
        guard isEditingEnabled else {
            navigationItem.rightBarButtonItems = []
            return
        }
        navigationItem.rightBarButtonItems = [saveButton]
    }
    
    @objc func handleShowRemoved() {
        if toShowRemoved == false {
            showRemovedSwitch.isOn = true
            toShowRemoved = true
        }
        else {
            showRemovedSwitch.isOn = false
            toShowRemoved = false
        }
        
        collectionView.reloadData()
    }
    

    @objc private func handleSaveButton() {
        collectionView.endEditing(true)
        switch selectedTab {
        case .PERSONAL_INFO:
            saveWorker()
        case .ADDRESS:
            saveAddress()
        case .ROLES:
            saveRoles()
        case .DEVICES:
            break
        case .WAGES:
            saveWages()
        }
    }
    
    private func saveWorker() {
        createWorkerViewModel.saveWorker { (error, isValidData) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if error == nil && isValidData {
                    self.enableTabButtons()
                    self.tabButtonPressed(sender: self.isAdd ? self.addressTabButton : self.personalInfoTabButton)
//                    self.selectTab(button: self.isAdd ? self.addressTabButton : self.personalInfoTabButton)
                    if self.createWorkerViewModel.getWorker().workerID == AppLocals.worker.workerID{
                        DBHelper.fetchWorker()
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                }
                self.handleDatebaseResponse(error: error, isValidData: isValidData)
            }
        }
    }
    
    private func saveAddress() {
        createWorkerViewModel.saveAddress { (error, isValidData) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if error == nil && isValidData{
                    self.tabButtonPressed(sender: self.isAdd ? self.roleTabButton : self.addressTabButton)
                    
                    if self.createWorkerViewModel.getWorker().workerID == AppLocals.worker.workerID{
                        DBHelper.fetchWorker()
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                self.handleDatebaseResponse(error: error, isValidData: isValidData)
            }
        }
    }
    
    private func saveRoles() {
        createWorkerViewModel.saveRoles { (error, isValidData) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if error == nil && isValidData{
                    self.tabButtonPressed(sender: self.deviceTabButton/*!self.isAdd ? self.deviceTabButton : self.roleTabButton*/)
                    
                    if self.createWorkerViewModel.getWorker().workerID == AppLocals.worker.workerID{
                        DBHelper.fetchWorkerRolesGroup()
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                self.handleDatebaseResponse(error: error, isValidData: isValidData)
                if error == nil && isValidData && self.isAdd{
                    self.navigationController?.popViewController(animated: false)
                    return
                }
                
            }
        }
    }
    
    private func saveWages() {
        createWorkerViewModel.saveWage { (error, isValidData) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.handleDatebaseResponse(error: error, isValidData: isValidData)
                if error == nil && isValidData{
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    private func handleDatebaseResponse(error: String?, isValidData: Bool) {
        let title = self.title ?? ""
        if let error = error {
            GlobalFunction.showMessageAlert(fromView: self, title: title, message: error)
        }
        self.collectionView.reloadData()
    }
    
    private func setupCollectionView() {
        let personalInfoCell    = UINib(nibName: PersonalInfoCell.ID, bundle: nil)
        let addressCell         = UINib(nibName: AddressCell.ID, bundle: nil)
        let rolesCell           = UINib(nibName: RolesCell.ID, bundle: nil)
        let devicesCell         = UINib(nibName: DevicesCell.ID, bundle: nil)
        let wagesCell           = UINib(nibName: WagesCell.ID, bundle: nil)
        let layout              = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        
        collectionView.collectionViewLayout = layout
        collectionView.dataSource           = self
        collectionView.delegate             = self
        collectionView.isPagingEnabled      = true
        collectionView.isScrollEnabled      = false
        
        collectionView.register(personalInfoCell, forCellWithReuseIdentifier: PersonalInfoCell.ID)
        collectionView.register(addressCell, forCellWithReuseIdentifier: AddressCell.ID)
        collectionView.register(rolesCell, forCellWithReuseIdentifier: RolesCell.ID)
        collectionView.register(devicesCell, forCellWithReuseIdentifier: DevicesCell.ID)
        collectionView.register(wagesCell, forCellWithReuseIdentifier: WagesCell.ID)
    }
    
    private func configureTabSelection(tab: WorkerTab) {
        deseletcTab(button: personalInfoTabButton)
        deseletcTab(button: addressTabButton)
        deseletcTab(button: roleTabButton)
        deseletcTab(button: deviceTabButton)
        deseletcTab(button: wageTabButton)
        selectedTab = tab
        
        switch tab {
        case .PERSONAL_INFO:
            selectTab(button: personalInfoTabButton)
            enableKeyboardViewScrolling()
            hideDeviceTabButton()
            hideAddRoleGroupButton()
        case .ADDRESS:
            selectTab(button: addressTabButton)
            enableKeyboardViewScrolling()
            hideDeviceTabButton()
            hideAddRoleGroupButton()
        case .ROLES:
            selectTab(button: roleTabButton)
            disableKeyboardViewScrolling()
            hideDeviceTabButton()
            showAddRoleGroupButton()
        case .DEVICES:
            selectTab(button: deviceTabButton)
            disableKeyboardViewScrolling()
            hideAddRoleGroupButton()
            showDeviceTabButton()
        case .WAGES:
            selectTab(button: wageTabButton)
            enableKeyboardViewScrolling()
            hideDeviceTabButton()
            hideAddRoleGroupButton()
        }
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
        if isAdd && !createWorkerViewModel.isSavedInitialData(){return}
        
        guard let title = sender.title(for: .normal) else {
            return
        }
        guard let index = workerTabs.firstIndex(where: { $0.stringValue() == title}) else {
            return
        }
        let indexPath = IndexPath(item: 0, section: index)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        collectionView.reloadData()
        configureTabSelection(tab: workerTabs[index])
    }
    
    func setViewMode(isEditingEnabled: Bool) {
        self.isEditingEnabled = isEditingEnabled
    }
    
}

//MARK: - COLLECTION VIEW DATA SOURCE
extension CreateWorkerView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return workerTabs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let workerTab = workerTabs[indexPath.section]
        switch workerTab {
        case .PERSONAL_INFO:
            return instantiatePersonalInfoCell(collectionView, cellForItemAt: indexPath)
        case .ADDRESS:
            return instantiateAddressCell(collectionView, cellForItemAt: indexPath)
        case .ROLES:
            return instantiateRolesCell(collectionView, cellForItemAt: indexPath)
        case .DEVICES:
            return instantiateDevicesCell(collectionView, cellForItemAt: indexPath)
        case .WAGES:
            return instantiateWagesCell(collectionView, cellForItemAt: indexPath)
        }
    }
    
    private func instantiatePersonalInfoCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PersonalInfoCell.ID, for: indexPath) as? PersonalInfoCell else {
            fatalError()
        }
        cell.showViewDelegate = self
        cell.isEditingEnabled = !isShowingWorker
        cell.viewModel = createWorkerViewModel
        return cell
    }
    
    private func instantiateAddressCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddressCell.ID, for: indexPath) as? AddressCell else {
            fatalError()
        }
        cell.isEditingEnabled = !isShowingWorker
        cell.viewModel = createWorkerViewModel
        return cell
    }
    
    private func instantiateRolesCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RolesCell.ID, for: indexPath) as? RolesCell else {
            fatalError()
        }
        cell.isEditingEnabled = !isShowingWorker
        cell.viewModel = createWorkerViewModel
        return cell
    }
    
    private func instantiateDevicesCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DevicesCell.ID, for: indexPath) as? DevicesCell else {
            fatalError()
        }
        cell.isShowingWorker = false//self.isShowingWorker
        cell.toShowRemoved = toShowRemoved
        cell.viewModel = createWorkerViewModel
        cell.showViewDelegate = self
        return cell
    }
    
    private func instantiateWagesCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WagesCell.ID, for: indexPath) as? WagesCell else {
            fatalError()
        }
        cell.isEditingEnabled = !isShowingWorker
        cell.viewModel = createWorkerViewModel
        return cell
    }
}

//MARK: - COLLECTION VIEW DELEGATE FLOW LAYOUT
extension CreateWorkerView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width,
                      height: collectionView.frame.height)
    }
}

extension CreateWorkerView: ShowViewDelegate {
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
