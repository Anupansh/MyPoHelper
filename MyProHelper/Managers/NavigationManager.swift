//
//  RouteManager.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 04/04/1942 Saka.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation
import UIKit


class NavigationManager {
    
    static var shared = NavigationManager()
    
    func setRootVC(withController:UIViewController,window:UIWindow) -> UIWindow {
        let navigationController = UINavigationController(rootViewController: withController)
        navigationController.isNavigationBarHidden = true
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        return window
    }
    
//    func updateRootVC(withController:UIViewController) {
//        let navigationController = UINavigationController(rootViewController: withController)
//        navigationController.isNavigationBarHidden = true
//        guard let window = self.getRootWindow() else {return}
//        window.rootViewController = navigationController
//        window.makeKeyAndVisible()
//    }
    
//    func getRootWindow() -> UIWindow? {
//        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//          let sceneDelegate = windowScene.delegate as? SceneDelegate
//        else {
//          return nil
//        }
//        return sceneDelegate.window
//    }
    
}
