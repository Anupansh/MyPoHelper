//
//  CreateSuppliesUsedView.swift
//  MyProHelper
//
//  Created by Deep on 2/11/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit

private enum SupplyUsedCell: String {
    case SUPPLYS                = "SUPPLYS"
    case SUPPLY_LOCATION        = "SUPPLY_LOCATION"
    case PURCHASED_FROM         = "PURCHASED_FROM"
    case QUANTITY               = "QUANTITY"
    case PRICE_TO_RESELL        = "PRICE_TO_RESELL"
}

class CreateSupplyUsedView: BaseCreateItemView, Storyboarded {
    
    let viewModel = CreateSupplyUsedViewModel()
    var delegate: SupplyUsedItemDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSupplies()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupCellsData() {
        cellData = [
            .init(title: SupplyUsedCell.SUPPLYS.rawValue.localize,
                  key: SupplyUsedCell.SUPPLYS.rawValue,
                  dataType: .ListView,
                  isRequired: true,
                  isActive: isEditingEnabled ,
                  validation: viewModel.validateSupplyName(),
                  text: viewModel.getSupplyName(),
                  listData: viewModel.getSupplies()),
            
            .init(title: SupplyUsedCell.SUPPLY_LOCATION.rawValue.localize,
                  key: SupplyUsedCell.SUPPLY_LOCATION.rawValue,
                  dataType: .ListView,
                  isRequired: true,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: viewModel.getSupplyLocation(),
                  listData: viewModel.getSupplyLocations()),
            
            .init(title: SupplyUsedCell.PURCHASED_FROM.rawValue.localize,
                  key: SupplyUsedCell.PURCHASED_FROM.rawValue,
                  dataType: .ListView,
                  isRequired: false,
                  isActive: isEditingEnabled,
                  validation: .Valid,
                  text: viewModel.getVendorName(),
                  listData: viewModel.getVendors()),
            
            .init(title: SupplyUsedCell.QUANTITY.rawValue.localize,
                  key: SupplyUsedCell.QUANTITY.rawValue,
                  dataType: .Text,
                  isRequired: true,
                  isActive: isEditingEnabled,
                  keyboardType: .asciiCapableNumberPad,
                  validation: viewModel.validateQuantity(),
                  text: viewModel.getQuantity()),
            
            .init(title: SupplyUsedCell.PRICE_TO_RESELL.rawValue.localize,
                  key: SupplyUsedCell.PRICE_TO_RESELL.rawValue,
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
    
    private func getSupplies() {
        viewModel.fetchSupplies {
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
            if viewModel.isWaitingForSupply() {
                confirmSupplyUsing()
            }else {
                if viewModel.isUpdatingSupply() {
                    delegate?.didUpdateSupply(supply: viewModel.getSupply())
                }
                else {
                    delegate?.didAddSupply(supply: viewModel.getSupply())
                }
                self.navigationController?.popViewController(animated: true)
            }
        }
        else {
            tableView.reloadData()
        }
    }
    
    func confirmSupplyUsing(){
        let itemUsedConfirmationView = ItemUsedConfirmaitonView.instantiate(storyboard: .ITEM_USED_CONFIRMATION)
        itemUsedConfirmationView.firstOptionSelected = { option in
            if option {
                self.viewModel.updateCountWaitingFor(selectedOption: option)
                print("first option selected")
            }else {
                self.viewModel.updateCountWaitingFor(selectedOption: option)
                print("second option selected")
            }
            if self.viewModel.isUpdatingSupply() {
                self.delegate?.didUpdateSupply(supply: self.viewModel.getSupply())
            }
            else {
                self.delegate?.didAddSupply(supply: self.viewModel.getSupply())
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

extension CreateSupplyUsedView: TextFieldCellDelegate {
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        guard let cell = SupplyUsedCell(rawValue: data.key) else {
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

extension CreateSupplyUsedView: TextFieldListDelegate {
    
    func willAddItem(data: TextFieldCellData) {}
    
    func didChooseItem(at row: Int?, data: TextFieldCellData) {
        guard let cell = SupplyUsedCell(rawValue: data.key) else {
            return
        }
        switch cell {
        case .SUPPLYS:
            DispatchQueue.main.async { [unowned self] in
                self.viewModel.setSupplyName(at: row)
                data.text = viewModel.getSupplyName()
                // Fetch locations and vendors for selected part
                viewModel.fetchSupplyLocations()
                viewModel.fetchVendorList()
                self.tableView.reloadData()
                reloadTableValues(indexPath: IndexPath(row: 1, section: 0))
            }
            
        case .SUPPLY_LOCATION:
            DispatchQueue.main.async { [unowned self] in
                self.viewModel.setSupplyLocation(at: row)
                data.text = viewModel.getSupplyLocation()
                self.tableView.reloadData()
            }
            
        case .PURCHASED_FROM:
            DispatchQueue.main.async { [unowned self] in
                self.viewModel.setVendor(at: row)
                data.text = viewModel.getVendorName()
                self.tableView.reloadData()
            }
            
        default:
            break
        }
    }
}
