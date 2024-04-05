//
//  ActionSheetManager.swift
//  MyProHelper
//
//  Created by Anupansh on 23/03/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import UIKit

class ActionSheetManager {
    
    enum TypeOfAction {
        case viewAction
        case editAction
        case deleteAction
        case cancelAction
        case undeleteAction
        case showReaderAction
        case readerSettingsAction
        case approveAction
        case viewInvoive
        case callCustomer
        case goToJob
    }
    
    static let shared = ActionSheetManager()
    
    func showActionSheet(typeOfAction: [TypeOfAction],presentingView: UIView,vc: UIViewController,actionPerformed: @escaping (TypeOfAction) -> ()?) {
        let alert = UIAlertController(title: AppLocals.appName, message: "", preferredStyle: .actionSheet)
        if let popOverController = alert.popoverPresentationController {
            popOverController.sourceView = presentingView
            popOverController.sourceRect  = presentingView.bounds
        }
        for action in typeOfAction {
            switch action {
            
            case .viewAction:
                let viewAction = UIAlertAction(title: "View".localize, style: .default) { (alertAction) in
                    actionPerformed(.viewAction)
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(viewAction)
            case .editAction:
                let editAction = UIAlertAction(title: "Edit".localize, style: .default) { (alertAction) in
                    actionPerformed(.editAction)
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(editAction)
            case .deleteAction:
                let deleteAction = UIAlertAction(title: "Delete".localize, style: .default) { (alertAction) in
                    actionPerformed(.deleteAction)
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(deleteAction)
            case .cancelAction:
                let cancelAction = UIAlertAction(title: "Cancel".localize, style: .default) { (alertAction) in
                    actionPerformed(.cancelAction)
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(cancelAction)
            case .undeleteAction:
                let restoreAction = UIAlertAction(title: "Undelete".localize, style: .default) { (alertAction) in
                    actionPerformed(.undeleteAction)
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(restoreAction)
            case .showReaderAction:
                let showReaderAction = UIAlertAction(title: "Show Reader".localize, style: .default) { (alertAction) in
                    actionPerformed(.showReaderAction)
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(showReaderAction)
            case .readerSettingsAction:
                let readerSettingsAction = UIAlertAction(title: "Reader Settings".localize, style: .default) { (alertAction) in
                    actionPerformed(.readerSettingsAction)
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(readerSettingsAction)
            case .approveAction:
                let approveAction = UIAlertAction(title: "Approve".localize, style: .default) { (alertAction) in
                    actionPerformed(.approveAction)
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(approveAction)
            case .viewInvoive:
                let action = UIAlertAction(title: "View Invoice", style: .default) { alertAction in
                    actionPerformed(.viewInvoive)
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(action)
            case .callCustomer:
                let action = UIAlertAction(title: "Call Customer", style: .default) { alertAction in
                    actionPerformed(.callCustomer)
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(action)
            case .goToJob:
                let action = UIAlertAction(title: "Go To Scheduled Job", style: .default) { alertAction in
                    actionPerformed(.goToJob)
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(action)
            }
        }
        let cancelAlertAction = UIAlertAction(title: "Close".localize, style: .cancel, handler: nil)
        alert.addAction(cancelAlertAction)
        vc.present(alert, animated: true, completion: nil)
    }
}
