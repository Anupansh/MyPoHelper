//
//  AttachmentCell.swift
//  MyProHelper
//
//  Created by Samir on 11/3/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit

class AttachmentViewCell: BaseFormCell {

    static let ID = "AttachmentCell"
    @IBOutlet weak private var attachmentTableView: UITableView!
    @IBOutlet weak private var addAttachmentButton: UIButton!
    var attachmentManager: AttachmentManager?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        attachmentTableView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction private func addAttachmentPressed(sender: UIButton) {
        attachmentManager?.showDocumentPicker()
    }
}

extension AttachmentViewCell: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .blue
        cell.tintColor = .cyan
        cell.textLabel?.text = "index = \(indexPath.row)"
        cell.textLabel?.textColor = .white
        return cell
    }
}
