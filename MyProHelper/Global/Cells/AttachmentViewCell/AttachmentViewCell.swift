//
//  AttachmentViewCell.swift
//  MyProHelper
//
//  Created by Samir on 11/3/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit

protocol AttachmentViewDelegate {
    func addAttachment()
    func didEditDiscreption(at index: Int, description: String?)
    func didTapAttachment(at index: Int)
    func didDeleteAttachment(at index: Int)
}

class AttachmentViewCell: BaseFormCell {

    static let ID = "AttachmentViewCell"
    @IBOutlet weak private var attachmentLabel                      : UILabel!
    @IBOutlet weak private var attachmentTableView                  : UITableView!
    @IBOutlet weak private var addAttachmentButton                  : UIButton!
    @IBOutlet weak private var tableViewHeightConstraint            : NSLayoutConstraint!
    @IBOutlet weak private var addAttachmentButtonHeightConstraint  : NSLayoutConstraint!
    
    private var attachmentArray: [Attachment] = []
    private var isEditingEnabled: Bool = true
    
    var delegate: AttachmentViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupCellText()
        setupAttachmentTableView()
    }
    
    private func setupCellText() {
        attachmentLabel.text = "ATTACHMENTS".localize
        addAttachmentButton.setTitle("ADD_ATTACHMENT_BUTTON_TITLE".localize, for: .normal)
    }
    
    private func setupAttachmentTableView() {
        let attachmentItem = UINib(nibName: AttachmentItemCell.ID, bundle: nil)
        attachmentTableView.dataSource      = self
        attachmentTableView.delegate        = self
        attachmentTableView.allowsSelection = false
        attachmentTableView.separatorStyle  = .none
        attachmentTableView.isScrollEnabled = false
        attachmentTableView.register(attachmentItem, forCellReuseIdentifier: AttachmentItemCell.ID)
        
    }
    
    func hasAttachments() -> Bool {
        return !attachmentArray.isEmpty
    }
    
    func configureAttachments(attahments: [Attachment]) {
        attachmentArray = attahments
        attachmentTableView.reloadData()
        tableViewHeightConstraint.constant = attachmentTableView.contentSize.height
    }
    
    func setEditingCapability(isEditingEnabled: Bool) {
        if !isEditingEnabled {
            addAttachmentButton.isHidden = true
            addAttachmentButtonHeightConstraint.constant = 0
        }
        else {
            addAttachmentButtonHeightConstraint.constant = Constants.Dimension.BUTTON_HEIGHT
        }
        self.isEditingEnabled = isEditingEnabled
    }
    
    func setAttachmentTitle(title: String) {
        attachmentLabel.text = title
    }
    
    @IBAction private func addAttachmentPressed(sender: UIButton) {
        delegate?.addAttachment()
    }
}

extension AttachmentViewCell: UITableViewDelegate {

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension AttachmentViewCell: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attachmentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AttachmentItemCell.ID) as? AttachmentItemCell else {
            return UITableViewCell()
        }
        let attachment = attachmentArray[indexPath.row]
        cell.updateAttachment = { [unowned self] description in
            self.delegate?.didEditDiscreption(at: indexPath.row, description: description)
        }
        cell.tapAttachment = {
            self.delegate?.didTapAttachment(at: indexPath.row)
        }
        cell.tapDeleteAttachment = {
            self.delegate?.didDeleteAttachment(at: indexPath.row)
        }
        cell.configureAttachment(name: attachment.attachmentName, description: attachment.description)
        if !isEditingEnabled {
            cell.disableEditing()
        }
        return cell
    }
}
