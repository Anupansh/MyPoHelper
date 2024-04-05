//
//  AttachmentManager.swift
//  MyProHelper
//
//  Created by Samir on 11/3/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit
import CoreServices

protocol AttachmentManagerDelegate {
    func didChooseAttachment(at url: URL)
}

class AttachmentManager: NSObject {
    
    let documentPickerView: UIDocumentPickerViewController
    let documentViewController: UIDocumentInteractionController
    let presentingView: UIViewController
    let delegate: AttachmentManagerDelegate
    
    init(presentingView: UIViewController, delegate: AttachmentManagerDelegate) {
        documentPickerView = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF), String(kUTTypeImage)], in: .import)
        documentViewController = UIDocumentInteractionController()
        self.presentingView = presentingView
        self.delegate = delegate
        super.init()
        
        documentPickerView.allowsMultipleSelection = false
        documentPickerView.modalPresentationStyle = .pageSheet
        documentPickerView.delegate = self
        
        documentViewController.delegate = self
        
    }
    
    func showDocumentPicker() {
        presentingView.present(documentPickerView, animated: true, completion: nil)
    }
    
    func openDocument(with url: URL) {
        documentViewController.url  = url
        documentViewController.uti  = url.typeIdentifier
        documentViewController.name = AppFileManager.getFileName(at: url)
        documentViewController.presentPreview(animated: true)
    }
}

extension AttachmentManager: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        delegate.didChooseAttachment(at: url)
    }
}

extension AttachmentManager: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        guard let navigationControler = presentingView.navigationController else {
            return presentingView
        }
        return navigationControler
    }
}
