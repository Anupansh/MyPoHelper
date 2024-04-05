//
//  CreateServiceUsedView.swift
//  MyProHelper
//
//  Created by Deep on 2/7/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit

private enum ServiceUsedCell: String {
    case SERVICE_TYPE           = "SERVICE_TYPE"
    case QUANTITY               = "QUANTITY"
    case PRICE_TO_RESELL        = "PRICE_TO_RESELL"
}

class CreateServiceUsedView: BaseCreateItemView, Storyboarded {
    
    let viewModel = CreateServiceUsedViewModel()
    var delegate: ServiceUsedItemDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getServices()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupCellsData() {
        cellData = [
            .init(title: ServiceUsedCell.SERVICE_TYPE.rawValue.localize,
                  key: ServiceUsedCell.SERVICE_TYPE.rawValue,
                  dataType: .ListView,
                  isRequired: true,
                  isActive: isEditingEnabled,
                  keyboardType: .default,
                  validation: viewModel.validateService(),
                  text: viewModel.getServiceUsed(),
                  listData: viewModel.getServices()),
            
            .init(title: ServiceUsedCell.QUANTITY.rawValue.localize,
                  key: ServiceUsedCell.QUANTITY.rawValue,
                  dataType: .Text,
                  isRequired: true,
                  isActive: isEditingEnabled,
                  keyboardType: .asciiCapableNumberPad,
                  validation: viewModel.validateQuantity(),
                  text: viewModel.getQuantity()),
            
            .init(title: ServiceUsedCell.PRICE_TO_RESELL.rawValue.localize,
                  key: ServiceUsedCell.PRICE_TO_RESELL.rawValue,
                  dataType: .Text,
                  isRequired: true,
                  isActive: isEditingEnabled,
                  keyboardType: .decimalPad,
                  validation: viewModel.validatePriceToResell(),
                  text: viewModel.getPriceToResell()),
        ]
    }
    
    private func openCreateServiceType() {
        let createServiceView = CreateServiceView.instantiate(storyboard: .SERVICE)
        createServiceView.setViewMode(isEditingEnabled: true)
        navigationController?.pushViewController(createServiceView, animated: true)
    }
    
    private func getServices() {
        viewModel.fetchServices {
            DispatchQueue.main.async { [unowned self] in
                self.setupCellsData()
                self.tableView.reloadData()
            }
        }
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
    
    override func handleAddItem() {
        super.handleAddItem()
        setupCellsData()
        if viewModel.isValidData() {
            if viewModel.isUpdateService() {
                delegate?.didUpdateService(service: viewModel.getService())
            }
            else {
                delegate?.didAddService(service: viewModel.getService())
            }
            navigationController?.popViewController(animated: true)
        }
        else {
            tableView.reloadData()
        }
    }
}
//MARK: -  TextField Delegate

extension CreateServiceUsedView: TextFieldCellDelegate {
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        guard let cell = ServiceUsedCell(rawValue: data.key) else {
            return
        }
        switch cell {
        case .QUANTITY:
            viewModel.setQuantity(quantity: text)
            setupCellsData()
            let quantityIndex = IndexPath(row: 2, section: 0)
            tableView.reloadRows(at: [quantityIndex], with: .automatic)
            
        case .PRICE_TO_RESELL:
            viewModel.setPriceToResell(price: text)
        default:
            break
        }
    }
}

//MARK: -  List Delegate
extension CreateServiceUsedView: TextFieldListDelegate {
    
    func willAddItem(data: TextFieldCellData) {
        guard let cell = ServiceUsedCell(rawValue: data.key) else {
            return
        }
        switch cell {
        case .SERVICE_TYPE:
            openCreateServiceType()
            break
        default:
            break
        }
    }
    
    func didChooseItem(at row: Int?, data: TextFieldCellData) {
        guard let cell = ServiceUsedCell(rawValue: data.key) else {
            return
        }
        switch cell {
        case .SERVICE_TYPE:
            DispatchQueue.main.async { [unowned self] in
                self.viewModel.setServiceUsed(at: row)
                data.text = viewModel.getServiceUsed()
                setupCellsData()
                self.tableView.reloadData()
            }
        default:
            break
        }
    }
}

