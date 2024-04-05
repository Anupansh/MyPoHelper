//
//  CreateAssetView.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/27/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit
private enum AssetCell: String {
    case ASSET_NAME                 = "ASSET_NAME"
    case DESCRIPTION                = "DESCRIPTION"
    case MODEL_INFO                 = "MODEL_INFO"
    case ASSET_TYPE                 = "ASSET_TYPE"
    case SERIAL_NUMBER              = "SERIAL_NUMBER"
    case PURCHASE_PRICE             = "PURCHASE_PRICE"
    case MILEAGE                    = "MILEAGE"
    case HOURS_USED                 = "HOURS_USED"
    case PURCHASED_DATE             = "PURCHASED_DATE"
    case LATEST_MAINTENANCE_DATE    = "LATEST_MAINTENANCE_DATE"
    case ATTACHMENTS                = "ATTACHMENTS"
}

class CreateAssetView: BaseCreateWithAttachmentView<CreateAssetViewModel>, Storyboarded {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAssetTypes()
    }
    
    override func getCell(at indexPath: IndexPath) -> BaseFormCell {
        guard let cellType = AssetCell(rawValue:  cellData[indexPath.row].key) else {
            return BaseFormCell()
        }
        if cellType == .ATTACHMENTS {
            return instantiateAttachmentCell()
        }
        else if cellType == .DESCRIPTION {
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
        cell.listDelegate = self
        return cell
    }
    
    override func handleAddItem() {
        super.handleAddItem()
        setupCellsData()
        viewModel.saveAsset { (error, isValidData) in
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
    
    private func fetchAssetTypes() {
        viewModel.fetchAssetType {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.setupCellsData()
                self.tableView.reloadData()
            }
        }
    }
    
    private func setupCellsData() {
        cellData = [
            .init(title: AssetCell.ASSET_NAME.rawValue.localize,
                  key: AssetCell.ASSET_NAME.rawValue,
                  dataType: .Text, isRequired: true,
                  isActive: isEditingEnabled,
                  keyboardType: .default,
                  validation: viewModel.validateName(),
                  text: viewModel.getAssetName()),
            
            .init(title: AssetCell.DESCRIPTION.rawValue.localize,
                  key: AssetCell.DESCRIPTION.rawValue,
                  dataType: .Text, isRequired: false,
                  isActive: isEditingEnabled,
                  keyboardType: .default,
                  validation: viewModel.validateDescription(),
                  text: viewModel.getDescription()),
            
            .init(title: AssetCell.MODEL_INFO.rawValue.localize,
                  key: AssetCell.MODEL_INFO.rawValue,
                  dataType: .Text, isRequired: false,
                  isActive: isEditingEnabled,
                  keyboardType: .default,
                  validation: viewModel.validateModelInfo(),
                  text: viewModel.getModelInfo()),
            
            .init(title: AssetCell.ASSET_TYPE.rawValue.localize,
                  key: AssetCell.ASSET_TYPE.rawValue,
                  dataType: .ListView,
                  isRequired: true,
                  isActive: isEditingEnabled,
                  keyboardType: .default,
                  validation: viewModel.validateAssetType(),
                  text: viewModel.getAssetType(),
                  listData: viewModel.getAssetTypes()),
            
            .init(title: AssetCell.SERIAL_NUMBER.rawValue.localize,
                  key: AssetCell.SERIAL_NUMBER.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  keyboardType: .default,
                  validation: viewModel.validateSerialNumber(),
                  text: viewModel.getSerialNumber()),
            
            .init(title: AssetCell.PURCHASE_PRICE.rawValue.localize,
                  key: AssetCell.PURCHASE_PRICE.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  keyboardType: .default,
                  validation: viewModel.validatePurchasePrice(),
                  text: viewModel.getPurchasePrice()),
            
            .init(title: AssetCell.MILEAGE.rawValue.localize,
                  key: AssetCell.MILEAGE.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  keyboardType: .default,
                  validation: viewModel.validateMileage(),
                  text: viewModel.getMileage()),
            
            .init(title: AssetCell.HOURS_USED.rawValue.localize,
                  key: AssetCell.HOURS_USED.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  keyboardType: .default,
                  validation: viewModel.validateHoursUsed(),
                  text: viewModel.getHoursUsed()),
            
            .init(title: AssetCell.PURCHASED_DATE.rawValue.localize,
                  key: AssetCell.PURCHASED_DATE.rawValue,
                  dataType: .Date,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  keyboardType: .default,
                  validation: .Valid,
                  text: viewModel.getPurchasedDate()),
            
            .init(title: AssetCell.LATEST_MAINTENANCE_DATE.rawValue.localize,
                  key: AssetCell.LATEST_MAINTENANCE_DATE.rawValue,
                  dataType: .Date,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  keyboardType: .default,
                  validation: .Valid,
                  text: viewModel.getLastMaintenanceDate()),
            
            .init(title: AssetCell.ATTACHMENTS.rawValue.localize,
                  key: AssetCell.ATTACHMENTS.rawValue,
                  dataType: .Text,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  keyboardType: .default,
                  validation: .Valid),
        ]
    }
    
    private func openCreateAssetType() {
        let createAssetTypeView = CreateAssetTypeView.instantiate(storyboard: .ASSET_TYPE)
        createAssetTypeView.setViewMode(isEditingEnabled: true)
        createAssetTypeView.viewModel.assetType.bind { [unowned self] (assetType) in
            self.viewModel.setAssetType(assetType: assetType)
            self.fetchAssetTypes()
        }
        navigationController?.pushViewController(createAssetTypeView, animated: false)
    }
    
}

extension CreateAssetView: TextFieldCellDelegate {
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        guard let cell = AssetCell(rawValue: data.key) else { return }
        switch cell {
        
        case .ASSET_NAME:
            viewModel.setName(name: text)
            
        case .DESCRIPTION:
            viewModel.setDescription(description: text)
            
        case .MODEL_INFO:
            viewModel.setModelInfo(info: text)
            
        case .ASSET_TYPE:
            break
        case .SERIAL_NUMBER:
            viewModel.setSerialNumber(number: text)
            
        case .PURCHASE_PRICE:
            viewModel.setPurchasePrice(price: text)
            
        case .MILEAGE:
            viewModel.setMileage(mileage: text)
            
        case .HOURS_USED:
            viewModel.setHoursUsed(hours: text)
            
        case .PURCHASED_DATE:
            viewModel.setPurchaseDate(date: text)
            
        case .LATEST_MAINTENANCE_DATE:
            viewModel.setLastMaintenanceDate(date: text)
        case .ATTACHMENTS:
            break
        }
    }
}

extension CreateAssetView: TextFieldListDelegate {
    
    func willAddItem(data: TextFieldCellData) {
        guard let cell = AssetCell(rawValue: data.key) else { return }
        switch cell {
        case .ASSET_TYPE:
            openCreateAssetType()
        default:
            break
        }
    }
    
    func didChooseItem(at row: Int?, data: TextFieldCellData) {
        guard let cell = AssetCell(rawValue: data.key) else { return }
        switch cell {
        case .ASSET_TYPE:
            viewModel.setAssetType(assetIndex: row)
        default:
            break
        }
    }
}
