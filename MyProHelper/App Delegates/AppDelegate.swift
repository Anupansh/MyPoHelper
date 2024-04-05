//
//  AppDelegate.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 05/06/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManager
import SideMenu
import GooglePlaces
import SquareReaderSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - OUTLETS AND VARIBALES
    var window: UIWindow?

    // MARK: - APPLICATION LIFECYCLE
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.overrideUserInterfaceStyle = .light
        SQRDReaderSDK.initialize(applicationLaunchOptions: launchOptions)
        self.setupApplication()
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        SocketManager.shared.stopSocketServer()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        SocketManager.shared.startSocket()
    }
    
    // MARK: - SETUP APPLICATION
    func setupApplication() {
        IQKeyboardManager.shared().isEnabled = true
        GMSPlacesClient.provideAPIKey(AppLocals.googleApiKey)
        self.setupNavigationBar()
        self.checkLogin()
    }
    
    // MARK: - SETUP NAVIGATION BAR
    func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Constants.Colors.DARK_NAVIGATION
        appearance.titleTextAttributes = [.font: UIFont.boldSystemFont(ofSize: 18.0),.foregroundColor: UIColor.white]
        UINavigationBar.appearance().tintColor = Constants.Colors.NAVIGATION_BAR_TEXT_COLOR
        if #available(iOS 11.0, *) {
            UINavigationBar.appearance(whenContainedInInstancesOf: [UIDocumentBrowserViewController.self]).tintColor = nil
        }
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    // MARK: - Check Login
    func checkLogin() {
        let settings:SavedSettings = SavedSettings()
        settings.incrementAppRunCount()
        if let foo22 = settings.getDeviceToServerAccess() {
            AppLocals.serverAccessCode = foo22
            
            let databaseVersion = DBHelper.getDBVersion()
            if databaseVersion > 0 {
                CommonController.shared.setRootVC(withController: DashboardViewController())
            }
            else {
                let vc = AppStoryboards.auth.instantiateViewController(withIdentifier: DownloadDatabaseVC.className)
                CommonController.shared.setRootVC(withController: vc)
            }
        }
        else {
            let vc = AppStoryboards.auth.instantiateViewController(withIdentifier: LoginVC.className)
            CommonController.shared.setRootVC(withController: vc)
        }

    }
}

