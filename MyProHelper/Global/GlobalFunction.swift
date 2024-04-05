//
//  GlobalMethods.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/14/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit

struct GlobalFunction {
    
    public static func getDeviceInfo() -> [String : String] {
        
        let udid = UIDevice.current.identifierForVendor?.uuidString
        let name = UIDevice.current.name
        let version = UIDevice.current.systemVersion
        let modelName = UIDevice.current.model
        let osVersion = UIDevice.current.systemVersion

        let parameters = ["DeviceName": name,
                          "ModelName": modelName,
                          "OSVersion": osVersion]
        return parameters
        
    }
    
    static func showListActionSheet(deleteTitle: String? = nil ,customActions: [UIAlertAction] = [], showHandler: @escaping (UIAlertAction)->(), editHandler: @escaping (UIAlertAction)->(), deleteHandler: @escaping (UIAlertAction)->()) -> UIAlertController{
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let showAction = UIAlertAction(title: "VIEW".localize,
                                       style: .default,
                                       handler: showHandler)
        let editAction = UIAlertAction(title: "EDIT".localize,
                                       style: .default,
                                       handler: editHandler)
        let deleteAction = UIAlertAction(title: deleteTitle ?? "DELETE".localize,
                                         style: .destructive, handler: deleteHandler)
        let closeAction = UIAlertAction(title: "CLOSE".localize,
                                        style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        })
        
        for action in customActions {
            alert.addAction(action)
        }
        
        alert.addAction(showAction)
        alert.addAction(editAction)
        alert.addAction(deleteAction)
        alert.addAction(closeAction)
        return alert
    }
    
    static func showViewAndEditActionSheet(showHandler: @escaping (UIAlertAction)->(),
                                           editHandler: @escaping (UIAlertAction)->()) -> UIAlertController{
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let showAction = UIAlertAction(title: "VIEW".localize,
                                       style: .default,
                                       handler: showHandler)
        let editAction = UIAlertAction(title: "EDIT".localize,
                                       style: .default,
                                       handler: editHandler)
        let closeAction = UIAlertAction(title: "CLOSE".localize,
                                        style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        })
        
        alert.addAction(showAction)
        alert.addAction(editAction)
        alert.addAction(closeAction)
        return alert
    }
    
    static func showDeleteAlert(title: String, message: String, deleteAction: @escaping () -> ()) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "DELETE".localize, style: .destructive) { (_) in
            deleteAction()
        }
        let cancelAction = UIAlertAction(title: "CLOSE".localize, style: .cancel) { (_) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        return alert
    }
    
    static func showMessageAlert(fromView: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK".localize, style: .default) { (_) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        fromView.present(alert, animated: true, completion: nil)
    }
    
    static func getAppVersion() -> String? {
        let object: AnyObject = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as AnyObject
        guard let version = object as? String else {
            return nil
        }
        return version
    }
    
    public static func getofflineDBFullFileName() -> URL {
        
        let nameForFile = "offline"
        let extForFile = "db"
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let destURL = documentsURL!.appendingPathComponent(nameForFile).appendingPathExtension(extForFile)
        return destURL

    }

    public static func getofflineDBFullFileNameString() -> String {
        let url = getofflineDBFullFileName();
        return url.path
        

    }
    
    public static func getCompanyDBNameNoPath() -> String {
        return AppLocals.serverAccessCode?.CompanyID.appending(".db") ?? "0.db"
    }
    
    static func showAcceptDeclineActionSheet(acceptHandler: @escaping (UIAlertAction)->(), declineHandler: @escaping (UIAlertAction)->()) -> UIAlertController{
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let acceptAction = UIAlertAction(title: "ACCEPT".localize,
                                           style: .default,
                                           handler: acceptHandler)
            let declineAction = UIAlertAction(title: "DECLINE".localize,
                                             style: .destructive, handler: declineHandler)
            let closeAction = UIAlertAction(title: "CLOSE".localize,
                                            style: .cancel, handler: { _ in
                alert.dismiss(animated: true, completion: nil)
            })

            alert.addAction(acceptAction)
            alert.addAction(declineAction)
            alert.addAction(closeAction)
            return alert
        }

}
