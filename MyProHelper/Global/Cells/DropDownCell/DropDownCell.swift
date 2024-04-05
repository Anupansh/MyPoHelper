//
//  DropDownCell.swift
//  MyProHelper
//
//  Created by Anupansh on 16/03/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit
import DropDown

class DropDownCell: BaseFormCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var dropdownView: UIView!
    @IBOutlet weak var dropdownTextLbl: UILabel!
    @IBOutlet weak private var errorLabel: UILabel!
    @IBOutlet weak var errorHeightConstraint    : NSLayoutConstraint!
    @IBOutlet weak var listArrowImageView       : UIImageView!
    
    let dropdown = DropDown()
    var getDataClosure : ((String,Int) -> ())?
    private let errorHeight: CGFloat = 15
//    var showValidation: Bool = false
//    var data: TextFieldCellData?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupDropdown()
        configureTextField()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setupDropdown() {
        DropDown.startListeningToKeyboard()
        dropdown.anchorView = dropdownView
        dropdown.direction = .bottom
        dropdown.width = dropdownView.frame.width
    }
    
    private func configureTextField() {
//        textField.delegate = self
        dropdownView.layer.borderWidth = 0.5
        dropdownView.layer.cornerRadius = 4
        setValid()
    }
    
    func generateDataSource(data : [String]) {
        dropdown.dataSource = data
        dropdown.selectionAction = { (index: Int, item: String) in
            self.getDataClosure!(data[index],index)
            self.dropdownTextLbl.text = item
        }
    }
    func bindTextField(data: TextFieldCellData) {
        self.data = data
        titleLbl.text = data.title
        dropdownTextLbl.text = data.text
        
//        setRequire(isRequired: data.isRequired)
        disableCell(isDisabled: data.isActive)
        
//        if data.type == .ListView ||  data.type == .PickerView{
//            listArrowImageView.isHidden = false
//        }
//        else {
//            listArrowImageView.isHidden = true
//        }
        
        listArrowImageView.isHidden = !data.isActive
    }
    func disableCell(isDisabled: Bool) {
        dropdownView.isUserInteractionEnabled = isDisabled
    }
    
    override func validateData() {
        if let data = data {
            switch data.validation {
            case .Valid:
                setValid()
            case .Invalid(let message):
                setInvalid(message: message)
            }
        }
    }
    
    private func setValid() {
        errorLabel.isHidden = true
        errorHeightConstraint.constant = 0
        dropdownView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    private func setInvalid(message: String) {
        guard showValidation == true else { return }
        errorLabel.isHidden = false
        errorHeightConstraint.constant = errorHeight
        errorLabel.text = message
        dropdownView.layer.borderColor = UIColor.systemRed.cgColor
    }
    
    @IBAction func dropdownBtnPressed(_ sender: Any) {
        dropdown.show()
    }
    
    
}
