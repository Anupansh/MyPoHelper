//
//  CreatePartsUsedView.swift
//  MyProHelper
//
//  Created by Deep on 2/9/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit

private enum PartsUsedCell: String {
    case PARTS                  = "PARTS"
    case PART_LOCATION          = "PART_LOCATION"
    case PURCHASED_FROM         = "PURCHASED_FROM"
    case QUANTITY               = "QUANTITY"
    case PRICE_TO_RESELL        = "PRICE_TO_RESELL"
}

class CreatePartUsedView: BaseCreateItemView, Storyboarded {
    
    let viewModel = CreatePartUsedViewModel()
    var delegate: PartUsedItemDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getParts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupCellsData() {
        cellData = [
            .init(title: PartsUsedCell.PARTS.rawValue.localize,
                  key: PartsUsedCell.PARTS.rawValue,
                  dataType: .ListView,
                  isRequired: true,
                  isActive: isEditingEnabled ,
                  validation: viewModel.validatePartName(),
                  text: viewModel.getPartName(),
                  listData: viewModel.getParts()),
            
            .init(title: PartsUsedCell.PART_LOCATION.rawValue.localize,
                  key: PartsUsedCell.PART_LOCATION.rawValue,
                  dataType: .ListView,
                  isRequired: true,
                  isActive: isEditingEnabled,
                  validation: viewModel.validatePartLocation(),
                  text: viewModel.getPartLocation(),
                  listData: viewModel.getPartLocations()),
            
            .init(title: PartsUsedCell.PURCHASED_FROM.rawValue.localize,
                  key: PartsUsedCell.PURCHASED_FROM.rawValue,
                  dataType: .ListView,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: viewModel.getVendor(),
                  listData: viewModel.getVendors()),
            
            .init(title: PartsUsedCell.QUANTITY.rawValue.localize,
                  key: PartsUsedCell.QUANTITY.rawValue,
                  dataType: .Text,
                  isRequired: true,
                  isActive: isEditingEnabled,
                  keyboardType: .asciiCapableNumberPad,
                  validation: viewModel.validateQuantity(),
                  text: viewModel.getQuantity()),
            
            .init(title: PartsUsedCell.PRICE_TO_RESELL.rawValue.localize,
                  key: PartsUsedCell.PRICE_TO_RESELL.rawValue,
                  dataType: .Text,
                  isRequired: true,
                  isActive: isEditingEnabled,
                  keyboardType: .decimalPad,
                  validation: viewModel.validatePriceToResell(),
                  text: viewModel.getPriceToResell())
        ]
    }
    
    override func getCell(at indexPath: IndexPath) -> BaseFormCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.ID) as? TextFieldCell else {
             return BaseFormCell()
         }
        
        cell.bindTextField(data: cellData[indexPath.row])
        cell.delegate = self
        cell.listDelegate = self
        return cell
    }
    
    private func getParts() {
        viewModel.fetchParts {
            DispatchQueue.main.async { [unowned self] in
                self.setupCellsData()
                self.tableView.reloadData()
            }
        }
    }
    
    override func handleAddItem() {
        super.handleAddItem()
        setupCellsData()
        if viewModel.isValidData() {
            if viewModel.isWaitingForPart() {
                confirmPartUsing()
            }else {
                if viewModel.isUpdatingPart() {
                    delegate?.didUpdatePart(part: viewModel.getPart())
                }
                else {
                    delegate?.didAddPart(part: viewModel.getPart())
                }
                self.navigationController?.popViewController(animated: true)
            }
        }
        else {
            tableView.reloadData()
        }
    }
    
    func confirmPartUsing(){
        let itemUsedConfirmationView = ItemUsedConfirmaitonView.instantiate(storyboard: .ITEM_USED_CONFIRMATION)
        itemUsedConfirmationView.firstOptionSelected = { option in
            if option {
                self.viewModel.updateCountWaitingFor(selectedOption: option)
                print("first option selected")
            }else {
                self.viewModel.updateCountWaitingFor(selectedOption: option)
                print("second option selected")
            }
            if self.viewModel.isUpdatingPart() {
                self.delegate?.didUpdatePart(part: self.viewModel.getPart())
            }
            else {
                self.delegate?.didAddPart(part: self.viewModel.getPart())
            }
            
            self.navigationController?.popViewController(animated: true)
        }
        present(itemUsedConfirmationView, animated: true)
        itemUsedConfirmationView.setFirstOptionLabel(label: viewModel.getFirtOptionLabel())
        itemUsedConfirmationView.setSecondOptionLabel(label: viewModel.getSecondOptionLabel())
    }
    
    func reloadTableValues(indexPath: IndexPath) {
        setupCellsData()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

//MARK: - TextField cell delegate

extension CreatePartUsedView: TextFieldCellDelegate {
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        guard let cell = PartsUsedCell(rawValue: data.key) else {
            return
        }
        switch cell {
        case .QUANTITY:
            viewModel.setQuantity(quantity: text)
            setupCellsData()
            let quantityIndex = IndexPath(row: 4, section: 0)
            tableView.reloadRows(at: [quantityIndex], with: .automatic)
        case .PRICE_TO_RESELL:
            viewModel.setPriceToResell(price: text)
        default:
            break
        }
    }
}

//MARK: - TextField List delegate

extension CreatePartUsedView: TextFieldListDelegate {
    
    func willAddItem(data: TextFieldCellData) {
        guard let cell = PartsUsedCell(rawValue: data.key) else {
            return
        }
        switch cell {
        case .PART_LOCATION:
            break
        default:
            break
        }
    }
    
    func didChooseItem(at row: Int?, data: TextFieldCellData) {
        guard let cell = PartsUsedCell(rawValue: data.key) else {
            return
        }
        switch cell {
        case .PARTS:
            DispatchQueue.main.async { [unowned self] in
                self.viewModel.setPartName(at: row)
                data.text = viewModel.getPartName()
                viewModel.fetchPartLocations()
                viewModel.fetchVendorList()
                self.tableView.reloadData()
                reloadTableValues(indexPath: IndexPath(row: 1, section: 0))
            }
            
        case .PART_LOCATION:
            DispatchQueue.main.async { [unowned self] in
                self.viewModel.setPartLocation(at: row)
                data.text = viewModel.getPartLocation()
                self.tableView.reloadData()
            }
            
        case .PURCHASED_FROM:
            DispatchQueue.main.async { [unowned self] in
                self.viewModel.setVendor(at: row)
                data.text = viewModel.getVendor()
                self.tableView.reloadData()
            }
            
        default:
            break
        }
    }
}
