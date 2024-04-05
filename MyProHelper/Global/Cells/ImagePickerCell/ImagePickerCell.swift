//
//  ImagePickerCell.swift
//  MyProHelper
//
//  Created by Anupansh on 02/04/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit

class ImagePickerCell: UITableViewCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var titleImage: UIImageView!
    weak var vc: UIViewController?
    var imageStringClosure : ((Data) -> ()?)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func imageBtnPressed(_ sender: Any) {
        CommonController.shared.delegate = self
        CommonController.shared.openImagePicker(view: vc!)
    }
    
}

extension ImagePickerCell: CommonControllerDelegate {
    func pickedImage(image: UIImage) {
        self.titleImage.contentMode = .scaleAspectFit
        self.titleImage.image = image
        if titleImage.image != #imageLiteral(resourceName: "placeholder") {
            let imageData = titleImage.image?.jpegData(compressionQuality: 0.2)
            imageStringClosure!(imageData!)
        }
    }
}
