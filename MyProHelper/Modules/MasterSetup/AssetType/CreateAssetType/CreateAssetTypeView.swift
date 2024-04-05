//
//  CreateAssetTypeView.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/26/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit

private enum AssetTypeCell: String {
    case TYPE_OF_ASSET = "TYPE_OF_ASSET"
}

class CreateAssetTypeView: BaseCreateItemView, Storyboarded {
    
    let viewModel = CreateAssetTypeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCellsData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func getCell(at indexPath: IndexPath) -> BaseFormCell {
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
        viewModel.saveAssetType { (error, isValidData) in
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
            .init(title: AssetTypeCell.TYPE_OF_ASSET.rawValue.localize,
                  key: AssetTypeCell.TYPE_OF_ASSET.rawValue,
                  dataType: .Text,isRequired: true,
                  isActive: isEditingEnabled,
                  validation: viewModel.validateTypeOfAsset(),
                  text: viewModel.getTypeOfAsset())
        ]
    }
}

extension CreateAssetTypeView: TextFieldCellDelegate {
    
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        guard let cell = AssetTypeCell(rawValue: data.key) else {
            return
        }
        
        switch cell {
        case .TYPE_OF_ASSET:
            viewModel.setTypeOfAsset(typeOfAsset: text)            
        }
    }
}
