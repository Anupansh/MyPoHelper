//
//  CreateServiceView.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/26/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit

private enum ServiceCell: String {
    case DESCRIPTION = "DESCRIPTION"
    case PRICE_QUOTE = "PRICE_QUOTE"
}

class CreateServiceView: BaseCreateItemView, Storyboarded {
    
    let viewModel = CreateServiceViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCellsData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func getCell(at indexPath: IndexPath) -> BaseFormCell {
        guard let cellType = ServiceCell(rawValue: cellData[indexPath.row].key) else {
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
        viewModel.saveServiceType { (error, isValidData) in
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
            
            .init(title: ServiceCell.DESCRIPTION.rawValue.localize,
                  key: ServiceCell.DESCRIPTION.rawValue,
                  dataType: .Text,
                  isRequired: true,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateDescription(),
                  text: viewModel.getDescription()),
            
            .init(title: ServiceCell.PRICE_QUOTE.rawValue.localize,
                  key: ServiceCell.PRICE_QUOTE.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: viewModel.validatePriceQuote(),
                  text: viewModel.getPriceQuote())
        ]
    }
}

extension CreateServiceView: TextFieldCellDelegate {
    
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        guard let cell = ServiceCell(rawValue: data.key) else {
            return
        }
        
        switch cell {
        case .PRICE_QUOTE:
            viewModel.setPriceQuote(price: text)
            
        case .DESCRIPTION:
            viewModel.setDescription(description: text)
            
            
        }
    }
}
