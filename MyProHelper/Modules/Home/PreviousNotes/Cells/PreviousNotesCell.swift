//
//  PreviousNotesCell.swift
//  MyProHelper
//
//  Created by Anupansh on 07/05/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit

class PreviousNotesCell: UITableViewCell {
    
    @IBOutlet weak var createdDateLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var viewAttachmentBtn: UIButton!
    @IBOutlet weak var attachmentTextLbl: UILabel!
    var viewAttachmentClosure : (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func viewAttachmentBtnPRessed(_ sender: Any) {
        viewAttachmentClosure!()
    }
    

}
