//
//  CreateWorkOrderLineItem.swift
//  MyProHelper
//
//  Created by sismac010 on 12/04/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

private enum LineItemCell: String {
//    case LINE_ITEM              = "LINE_ITEM"
    case TYPE                   = "TYPE"
    case PART                   = "PART"
    case SUPPLYS                = "SUPPLYS"
    case PART_NUMBER            = "PART_NUMBER"
    case QUANTITY               = "QUANTITY"
    case PRICE_PER_ITEM         = "PRICE_PER_ITEM"
    case AMOUNT                 = "AMOUNT"
    case DESCRIPTION            = "DESCRIPTION"
}

private enum TypeCell: String {
    case PART                   = "PART"
    case SUPPLYS                = "SUPPLYS"
    case NON_STOCKABLE_ITEM     = "NON_STOCKABLE_ITEM"

    func stringValue() -> String {
        return self.rawValue.localize
    }
}


class CreateWorkOrderLineItem: BaseCreateItemView, Storyboarded {
    
    let viewModel = CreateWorkOrderLineItemModel()
    var delegate: LineItemDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getParts()
        getSupplies()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    private func getFieldsForLineItemType(at type: LineItemType) -> [TextFieldCellData] {
        switch type {
        case .PART:
//            let partName = viewModel.getPart() != nil && !viewModel.getPart()!.isEmpty ? viewModel.getPart() : ((viewModel.getParts().count > 0) ? viewModel.getParts().first : "")
            let partName = (viewModel.getPart() == nil || viewModel.getPart() == Constants.DefaultValue.SELECT_LIST) ? "" : viewModel.getPart()
            return [
                .init(title: LineItemCell.TYPE.rawValue.localize,
                      key: LineItemCell.TYPE.rawValue,
                      dataType: .Text,
                      isRequired: false,
                      isActive: isEditingEnabled,
                      validation: .Valid,
                      text: ""),
                .init(title: LineItemCell.PART.rawValue.localize,
                      key: LineItemCell.PART.rawValue,
                      dataType: .ListView,
                      isRequired: true,
                      isActive: isEditingEnabled ,//&& viewModel.canEditSupplyLocation(),
                      keyboardType: .default,
                      validation: viewModel.validatePart()/*viewModel.validatePartAndSupply()*/,
                      text: partName,
                      listData: viewModel.getParts()),

                .init(title: LineItemCell.PART_NUMBER.rawValue.localize,
                      key: LineItemCell.PART_NUMBER.rawValue,
                      dataType: .Text,
                      isRequired: false,
                      isActive: isEditingEnabled,
                      keyboardType: .decimalPad,
                      validation: viewModel.validatePartNumber(),
                      text: viewModel.getPartNumber()),

                .init(title: LineItemCell.QUANTITY.rawValue.localize,
                      key: LineItemCell.QUANTITY.rawValue,
                      dataType: .Text,
                      isRequired: false,
                      isActive: isEditingEnabled,
                      keyboardType: .asciiCapableNumberPad,
                      validation: viewModel.validateQuantity(),
                      text: viewModel.getQuantity()),

                .init(title: LineItemCell.PRICE_PER_ITEM.rawValue.localize,
                      key: LineItemCell.PRICE_PER_ITEM.rawValue,
                      dataType: .Text,
                      isRequired: false,
                      isActive: isEditingEnabled,
                      keyboardType: .decimalPad,
                      validation: viewModel.validatePricePerItem(),
                      text: viewModel.getPricePerItem()),

                .init(title: LineItemCell.AMOUNT.rawValue.localize,
                      key: LineItemCell.AMOUNT.rawValue,
                      dataType: .Text,
                      isRequired: false,
                      isActive: false,//isEditingEnabled,
                      keyboardType: .decimalPad,
                      validation: .Valid,
                      text: viewModel.getAmountOfLineITem())
            ]
        case .SUPPLYS:

//            let supplyName = viewModel.getSupply() != nil && !viewModel.getSupply()!.isEmpty ? viewModel.getSupply() : ((viewModel.getSupplies().count > 0) ? viewModel.getSupplies().first : "")
            let supplyName = (viewModel.getSupply() == nil || viewModel.getSupply() == Constants.DefaultValue.SELECT_LIST) ? "" : viewModel.getSupply()

            return [
                .init(title: LineItemCell.TYPE.rawValue.localize,
                      key: LineItemCell.TYPE.rawValue,
                      dataType: .Text,
                      isRequired: false,
                      isActive: isEditingEnabled,
                      validation: .Valid,
                      text: ""),
                .init(title: LineItemCell.SUPPLYS.rawValue.localize,
                      key: LineItemCell.SUPPLYS.rawValue,
                      dataType: .ListView,
                      isRequired: true,
                      isActive: isEditingEnabled ,//&& viewModel.canEditSupplyLocation(),
                      keyboardType: .default,
                      validation: viewModel.validateSupply()/*viewModel.validatePartAndSupply()*/,
                      text: supplyName,
                      listData: viewModel.getSupplies()),

                .init(title: LineItemCell.QUANTITY.rawValue.localize,
                      key: LineItemCell.QUANTITY.rawValue,
                      dataType: .Text,
                      isRequired: false,
                      isActive: isEditingEnabled,
                      keyboardType: .asciiCapableNumberPad,
                      validation: viewModel.validateQuantity(),
                      text: viewModel.getQuantity()),

                .init(title: LineItemCell.PRICE_PER_ITEM.rawValue.localize,
                      key: LineItemCell.PRICE_PER_ITEM.rawValue,
                      dataType: .Text,
                      isRequired: false,
                      isActive: isEditingEnabled,
                      keyboardType: .decimalPad,
                      validation: viewModel.validatePricePerItem(),
                      text: viewModel.getPricePerItem()),

                .init(title: LineItemCell.AMOUNT.rawValue.localize,
                      key: LineItemCell.AMOUNT.rawValue,
                      dataType: .Text,
                      isRequired: false,
                      isActive: false,//isEditingEnabled,
                      keyboardType: .decimalPad,
                      validation: .Valid,
                      text: viewModel.getAmountOfLineITem())
            ]
        case .NON_STOCKABLE_ITEM:
            return [
                .init(title: LineItemCell.TYPE.rawValue.localize,
                      key: LineItemCell.TYPE.rawValue,
                      dataType: .Text,
                      isRequired: false,
                      isActive: isEditingEnabled,
                      validation: .Valid,
                      text: ""),
                .init(title: LineItemCell.DESCRIPTION.rawValue.localize,
                      key: LineItemCell.DESCRIPTION.rawValue,
                      dataType: .Text,
                      isRequired: true,
                      isActive: isEditingEnabled,
                      validation: .Valid,//viewModel.validateDescription(),
                      text: ""/*viewModel.getDescription()*/),

                .init(title: LineItemCell.QUANTITY.rawValue.localize,
                      key: LineItemCell.QUANTITY.rawValue,
                      dataType: .Text,
                      isRequired: false,
                      isActive: isEditingEnabled,
                      keyboardType: .asciiCapableNumberPad,
                      validation: viewModel.validateQuantity(),
                      text: viewModel.getQuantity()),

                .init(title: LineItemCell.PRICE_PER_ITEM.rawValue.localize,
                      key: LineItemCell.PRICE_PER_ITEM.rawValue,
                      dataType: .Text,
                      isRequired: false,
                      isActive: isEditingEnabled,
                      keyboardType: .decimalPad,
                      validation: viewModel.validatePricePerItem(),
                      text: viewModel.getPricePerItem()),

                .init(title: LineItemCell.AMOUNT.rawValue.localize,
                      key: LineItemCell.AMOUNT.rawValue,
                      dataType: .Text,
                      isRequired: false,
                      isActive: false,//isEditingEnabled,
                      keyboardType: .decimalPad,
                      validation: .Valid,
                      text: viewModel.getAmountOfLineITem())
            ]
        }

    }

    private func setupCellsData() {
        cellData = getFieldsForLineItemType(at: viewModel.getLineItemType())
    }
    
    private func updateAmountCell(){
        
        let cell = TextFieldCellData.init(title: LineItemCell.AMOUNT.rawValue.localize,
                                          key: LineItemCell.AMOUNT.rawValue,
                                          dataType: .Text,
                                          isRequired: false,
                                          isActive: false,
                                          keyboardType: .decimalPad,
                                          validation: .Valid,
                                          text: viewModel.getAmountOfLineITem())
        
        cellData[cellData.count - 1] = cell
        
        DispatchQueue.main.async { [unowned self] in
            self.tableView.reloadData()
        }
    }
    
    override func getCell(at indexPath: IndexPath) -> BaseFormCell {
        if let cellType = LineItemCell(rawValue:  cellData[indexPath.row].key), cellType == .TYPE {

            guard let cell = tableView.dequeueReusableCell(withIdentifier: RadioButtonCell.ID) as? RadioButtonCell else {
                return RadioButtonCell()
            }
            cell.isSelectionEnabled = isEditingEnabled
            cell.setTitle(title: "")
            cell.bindCell(data: [.init(key: TypeCell.PART.rawValue,
                                       title: TypeCell.PART.stringValue(),
                                       value: viewModel.getIsPart()),
                                 .init(key: TypeCell.SUPPLYS.rawValue,
                                       title: TypeCell.SUPPLYS.stringValue(),
                                       value: viewModel.getIsSupply()),
                                .init(key: TypeCell.NON_STOCKABLE_ITEM.rawValue,
                                      title: TypeCell.NON_STOCKABLE_ITEM.stringValue(),
                                      value: viewModel.getIsNonStockable())], 60,true)
            cell.delegate = self
            return cell
        }
        else if let cellType = LineItemCell(rawValue:  cellData[indexPath.row].key), cellType == .DESCRIPTION {
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
        
        if let cellType = LineItemCell(rawValue:  cellData[indexPath.row].key), cellType == .AMOUNT {
            cell.setbackgroundColor(#colorLiteral(red: 0.848439455, green: 0.8582248092, blue: 0.8794361949, alpha: 1))
        }
        else{
            cell.setbackgroundColor(.clear)
        }
        
        cell.bindTextField(data: cellData[indexPath.row])
//        cell.hideListAddButton()
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
    
    private func getSupplies() {
        viewModel.fetchSupplies {
            DispatchQueue.main.async { [unowned self] in
                self.setupCellsData()
                self.tableView.reloadData()
            }
        }
    }
    
    private func openCreatePart() {
        let createPartView = CreatePartView.instantiate(storyboard: .PART)
        createPartView.viewModel = CreatePartViewModel(attachmentSource: .PART)
        createPartView.setViewMode(isEditingEnabled: true)
        createPartView.viewModel.part.bind { [unowned self] part in
            self.viewModel.setPart(part: part)
            self.getParts()
        }
        navigationController?.pushViewController(createPartView, animated: false)
    }
    
    private func openCreateSupply() {
        let createSupplyView = CreateSupplyView.instantiate(storyboard: .SUPPLY)
        createSupplyView.viewModel = CreateSupplyViewModel(attachmentSource: .SUPPLY)
        createSupplyView.setViewMode(isEditingEnabled: true)
        createSupplyView.viewModel.supply.bind { [unowned self] supply in
            self.viewModel.setSupply(supply: supply)
            self.getSupplies()
        }
        navigationController?.pushViewController(createSupplyView, animated: false)
    }
    
    override func handleAddItem() {
        super.handleAddItem()
        setupCellsData()
        if viewModel.isValidData() {
            if viewModel.isUpdateLineItem() {
                delegate?.didUpdateLineItem(lineItem: viewModel.getLineItem())
            }
            else {
                delegate?.didCreateLineItem(lineItem: viewModel.getLineItem())
            }
            navigationController?.popViewController(animated: true)
        }
        else {
            tableView.reloadData()
        }
    }
    
}

//MARK: - Radio Buttom Cell Delegate
extension CreateWorkOrderLineItem: RadioButtonCellDelegate {
    func didChooseButton(data: RadioButtonData) {

        guard let button = TypeCell(rawValue: data.key) else {
            return

        }
        switch button {
        case .PART:
            viewModel.setIsPart()
            viewModel.setLineItemType(.PART)
        case .SUPPLYS:
            viewModel.setIsSupply()
            viewModel.setLineItemType(.SUPPLYS)
        case .NON_STOCKABLE_ITEM:
            viewModel.setIsNonStockable()
            viewModel.setLineItemType(.NON_STOCKABLE_ITEM)
        }
        viewModel.resetFields()
        self.setupCellsData()
        self.tableView.reloadData()
    }
}

extension CreateWorkOrderLineItem: TextFieldCellDelegate {
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        guard let cell = LineItemCell(rawValue: data.key) else {
            return
        }
        switch cell {
        
        case .DESCRIPTION:
            viewModel.setDescription(description: text)
            break
        case .PART_NUMBER:
            viewModel.setPartNumber(number: text)
        case .QUANTITY:
            viewModel.setQuantity(quantity: text)
            viewModel.setAmount()
            updateAmountCell()
            
        case .PRICE_PER_ITEM:
            viewModel.setPricePerItem(price: text)
            viewModel.setAmount()
            updateAmountCell()
            
        case .AMOUNT:break
//            viewModel.setAmount(price: text)
        default:
            break
        }
    }
}

extension CreateWorkOrderLineItem: TextFieldListDelegate {
    
    func willAddItem(data: TextFieldCellData) {
        guard let cell = LineItemCell(rawValue: data.key) else {
            return
        }
        switch cell {
        case .PART:
            openCreatePart()
            break
        case .SUPPLYS:
            openCreateSupply()
            break
        default:
            break
        }
    }
    
    func didChooseItem(at row: Int?, data: TextFieldCellData) {
        guard let cell = LineItemCell(rawValue: data.key) else {
            return
        }
        switch cell {
        case .PART:
            DispatchQueue.main.async { [unowned self] in
                self.viewModel.setPart(at: row)
                data.text = viewModel.getPart()
                self.tableView.reloadData()
            }
            
        case .SUPPLYS:
            DispatchQueue.main.async { [unowned self] in
                self.viewModel.setSupply(at: row)
                data.text = viewModel.getSupply()
                self.tableView.reloadData()
            }
        default:
            break
        }
    }
}
