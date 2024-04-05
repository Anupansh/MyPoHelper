//
//  CreatePartLocationView.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/22/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit

private enum PartLocationCell: String {
    case NAME           = "NAME"
    case DESCRIPTION    = "DESCRIPTION"
}

class CreatePartLocationView: BaseCreateItemView,Storyboarded {

    let viewModel = CreatePartLocationViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCellsData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    override func getCell(at indexPath: IndexPath) -> BaseFormCell {
        guard let cellType = PartLocationCell(rawValue: cellData[indexPath.row].key) else {
            return BaseFormCell()
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.ID) as? TextFieldCell else {
            return BaseFormCell()
        }
        if cellType == .DESCRIPTION {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TextViewCell.ID) as? TextViewCell else {
                return BaseFormCell()
            }
            cell.bindTextView(data: cellData[indexPath.row])
            cell.delegate = self
            return cell
        }
        cell.bindTextField(data: cellData[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    override func handleAddItem() {
        super.handleAddItem()
        setupCellsData()
        viewModel.savePartLocation { (error, isValidData) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let title = self.title ?? ""
                if let error = error {
                    GlobalFunction.showMessageAlert(fromView: self, title: title, message: error)
                }
                else if isValidData {
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func setupCellsData() {
        cellData = [
            .init(title: PartLocationCell.NAME.rawValue.localize,
                  key: PartLocationCell.NAME.rawValue,
                  dataType: .Text,isRequired: true,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateName(),
                  text: viewModel.getName()),
            
            .init(title: PartLocationCell.DESCRIPTION.rawValue.localize,
                  key: PartLocationCell.DESCRIPTION.rawValue,
                  dataType: .Text,isRequired: false,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateDescription(),
                  text: viewModel.getDescription())
            
            
        ]
    }
}

extension CreatePartLocationView: TextFieldCellDelegate {
    
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        guard let cell = PartLocationCell(rawValue: data.key) else {
            return
        }
        
        switch cell {
        case .NAME:
            viewModel.setName(name: text)
            
        case .DESCRIPTION:
            viewModel.setDescription(description: text)
            
            
        }
    }
}
