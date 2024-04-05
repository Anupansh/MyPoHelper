//
//  CreateSupplyLocationView.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/25/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit

private enum SupplyLocationCell: String {
    case NAME           = "NAME"
    case DESCRIPTION    = "DESCRIPTION"
}

class CreateSupplyLocationView: BaseCreateItemView,Storyboarded {

    let viewModel = CreateSupplyLocationViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCellsData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    override func getCell(at indexPath: IndexPath) -> BaseFormCell {
        guard let cellType = SupplyLocationCell(rawValue: cellData[indexPath.row].key) else {
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
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.ID) as? TextFieldCell else {
             return BaseFormCell()
         }
         cell.bindTextField(data: cellData[indexPath.row])
         cell.delegate = self
         return cell
    }
    
    override func handleAddItem() {
        super.handleAddItem()
        setupCellsData()
        viewModel.saveSupplyLocation { (error, isValidData) in
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
            .init(title: SupplyLocationCell.NAME.rawValue.localize,
                  key: SupplyLocationCell.NAME.rawValue,
                  dataType: .Text,
                  isRequired: true,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateName(),
                  text: viewModel.getName()),
            
            .init(title: SupplyLocationCell.DESCRIPTION.rawValue.localize,
                  key: SupplyLocationCell.DESCRIPTION.rawValue,
                  dataType: .Text,isRequired: false,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateDescription(),
                  text: viewModel.getDescription())
            
            
        ]
    }
}

extension CreateSupplyLocationView: TextFieldCellDelegate {
    
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        guard let cell = SupplyLocationCell(rawValue: data.key) else {
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
