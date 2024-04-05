//
//  BaseCreateWithAttachmentView.swift
//  MyProHelper
//
//  Created by Samir on 11/5/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit


class BaseCreateWithAttachmentView<T: BaseAttachmentViewModel>: BaseCreateItemView {
    
    private var attachmentManager: AttachmentManager!
    var viewModel: T!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attachmentManager = AttachmentManager(presentingView: self, delegate: self)
        fetchAttachments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    func fetchAttachments() {
        self.viewModel.fetchAttachments {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.tableView.reloadData()
            }
        }
    }
    
    func instantiateAttachmentCell() -> AttachmentViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AttachmentViewCell.ID) as? AttachmentViewCell else {
            return AttachmentViewCell()
        }
        let attachments = viewModel.getAttachments()
        if !isEditingEnabled {
            cell.setEditingCapability(isEditingEnabled: isEditingEnabled)
        }
        cell.delegate = self
        cell.configureAttachments(attahments: attachments)
        
        return cell
    }
}

extension BaseCreateWithAttachmentView: AttachmentManagerDelegate {
    func didChooseAttachment(at url: URL) {
        self.viewModel.addAttachment(with: url) {
            DispatchQueue.main.async { [unowned self] in
                self.tableView.reloadData()
            }
        }
    }
}

extension BaseCreateWithAttachmentView: AttachmentViewDelegate {
    func addAttachment() {
        attachmentManager.showDocumentPicker()
    }
    
    func didEditDiscreption(at index: Int, description: String?) {
        self.viewModel.editAttachment(at: index, with: description)
    }
    
    func didTapAttachment(at index: Int) {
        if let url = viewModel.getAttchmentURL(at: index) {
            DispatchQueue.main.async { [unowned self] in
                self.attachmentManager.openDocument(with: url)
            }
        }
    }
    
    func didDeleteAttachment(at index: Int) {
        let title = self.title ?? ""
        let message = "DELETE_ATTACHMENT_MESSAGE".localize + (viewModel.getAttachmentName(at: index) ?? "")
        
       let deleteAlert = GlobalFunction.showDeleteAlert(title: title, message: message) { [unowned self] in
            self.viewModel.deleteAttahment(at: index) { [unowned self] error in
                if let error = error {
                    GlobalFunction.showMessageAlert(fromView: self, title: title, message: error)
                }
                else {
                    self.fetchAttachments()
                }
            }
        }
        present(deleteAlert, animated: true, completion: nil)
    }
}

