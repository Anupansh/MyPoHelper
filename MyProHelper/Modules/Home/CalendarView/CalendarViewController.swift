//
//  CalendarViewController.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 30/06/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit
import SideMenu

class CalendarViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView! {
        didSet {
            tableview.delegate = self
            tableview.dataSource = self
            tableview.separatorStyle = .none
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Company Calendar"
        let leftBarItem = UIBarButtonItem(image: #imageLiteral(resourceName: "menu"), style: .done, target: self, action: #selector(showSideMenu))
        self.navigationItem.leftBarButtonItem = leftBarItem
        self.navigationController?.isNavigationBarHidden = false
        tableview.registerMultiple(nibs: [CalenderTableViewCell.className])
    }
    
    @objc func showSideMenu() {
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

extension CalendarViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Working on this now.")
        let cell = tableview.dequeueReusableCell(withIdentifier: CalenderTableViewCell.className) as! CalenderTableViewCell
        cell.vc = self
        cell.jobList = DBHelper.getScheduledJobsForAllWorkers()
        cell.dayView.reloadData()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableview.frame.height
    }
    
}

