//
//  GenericMenuSubmenuViewController.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 16/04/1942 Saka.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit
import SideMenu

class GenericMenuSubmenuViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var viewModel:GenericMenuSubmenuViewModel?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUp()
        
    }
    
    fileprivate func showSnackbar(){
        
        DispatchQueue.main.async {
            self.viewModel == nil ? self.tableView.setEmptyMessage(show: true, message: Constants.Message.No_Data_To_Display) : self.tableView.setEmptyMessage(show: false, message: "")
        }
        
    }
    

    func setUp() {
        //title = "Customers"
        self.navigationController?.isNavigationBarHidden = false
        self.tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.register(UINib(nibName: "GenericMenuSubmenuTableViewCell", bundle: nil), forCellReuseIdentifier: "GenericMenuSubmenuTableViewCell")
        
        let backBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "menu"), style: .done, target: self, action: #selector(sideMenuPressed))
        self.navigationItem.leftBarButtonItem = backBtn
        showSnackbar()
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
    
}

