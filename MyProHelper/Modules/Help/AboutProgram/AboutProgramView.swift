//
//  AboutProgramView.swift
//  MyProHelper
//
//  Created by Samir on 11/15/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit
import SideMenu

class AboutProgramView: UIViewController, Storyboarded {

    @IBOutlet weak private var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
   
    func setUp() {
        let appVersion = GlobalFunction.getAppVersion() ?? ""
        versionLabel.text = "APP VERSION " + appVersion
        self.navigationController?.isNavigationBarHidden = false
        let backBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "menu"), style: .done, target: self, action: #selector(sideMenuPressed))
        self.navigationItem.leftBarButtonItem = backBtn
        self.title = "App Version"
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
