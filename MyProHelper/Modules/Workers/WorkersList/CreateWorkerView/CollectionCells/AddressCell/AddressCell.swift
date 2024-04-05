//
//  AddressCell.swift
//  MyProHelper
//
//  Created by Samir on 12/30/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit
import DropDown

private enum AddressField : String {
    case STREET_ADDRESS     = "STREET_ADDRESS"
    case STREET_ADDRESS_TWO = "STREET_ADDRESS_TWO"
    case CITY               = "CITY"
    case STATE              = "STATE"
    case ZIP                = "ZIP"
    
    func stringValue() -> String {
        return self.rawValue.localize
    }
    
}

class AddressCell: UICollectionViewCell {

    static let ID = String(describing: AddressCell.self)
    
    @IBOutlet weak private var addressTableView: UITableView!
    
    var dropDown:DropDown = DropDown() //2
    
    private let fields: [AddressField] = [.STREET_ADDRESS,
                                                .STREET_ADDRESS_TWO,
                                                .CITY,
                                                .STATE,
                                                .ZIP]
    
    var isEditingEnabled = true
    var viewModel: CreateWorkerViewModel!
    
    override func prepareForReuse() {
        addressTableView.reloadData()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTableView()
    }
    
    private func setupTableView() {
        let textFieldCell   = UINib(nibName: TextFieldCell.ID, bundle: nil)
        
        addressTableView.allowsSelection   = false
        addressTableView.dataSource        = self
        addressTableView.separatorStyle    = .none
        addressTableView.contentInset.top  = 20
        
        addressTableView.register(textFieldCell, forCellReuseIdentifier: TextFieldCell.ID)
    }

}

extension AddressCell: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.ID) as? TextFieldCell else {
            return TextFieldCell()
        }
        let field = fields[indexPath.row]
        
        switch field {
        
        case .STREET_ADDRESS:
            cell.bindTextField(data: .init(title: field.stringValue(),
                                           key: field.rawValue,
                                           dataType: .Text,
                                           isRequired: true,
                                           isActive: isEditingEnabled,
                                           validation: viewModel.validatePrimaryAddress(),
                                           text: viewModel.getPrimaryAddress()))
        case .STREET_ADDRESS_TWO:
            cell.bindTextField(data: .init(title: field.stringValue(),
                                           key: field.rawValue,
                                           dataType: .Text,
                                           isRequired: false,
                                           isActive: isEditingEnabled,
                                           validation: viewModel.validateSecondryAddress(),
                                           text: viewModel.getSecondryAddress()))
        case .CITY:
            cell.bindTextField(data: .init(title: field.stringValue(),
                                           key: field.rawValue,
                                           dataType: .Text,
                                           isRequired: true,
                                           isActive: isEditingEnabled,
                                           validation: viewModel.validateCity(),
                                           text: viewModel.getCity()))
        case .STATE:
            cell.bindTextField(data: .init(title: field.stringValue(),
                                           key: field.rawValue,
                                           dataType: .Text,
                                           isRequired: true,
                                           isActive: isEditingEnabled,
                                           validation: viewModel.validateState(),
                                           text: viewModel.getState()))
        case .ZIP:
            cell.bindTextField(data: .init(title: field.stringValue(),
                                           key: field.rawValue,
                                           dataType: .ZipCode,
                                           isRequired: true,
                                           isActive: isEditingEnabled,
                                           validation: viewModel.validateZipCode(),
                                           text: viewModel.getZipCode()))
            
        }
        cell.showValidation = viewModel.didPerformAdd(for: .ADDRESS)
        cell.delegate       = self
        cell.validateData()
        return cell
    }
}

extension AddressCell: TextFieldCellDelegate {
    
    func didUpdateTextField(text: String?, data: TextFieldCellData) {
        guard let field = AddressField(rawValue: data.key) else {
            return
        }
        
        switch field {
        case .STREET_ADDRESS:
            viewModel.setPrimaryAddress(address: text)
        case .STREET_ADDRESS_TWO:
            viewModel.setSecondryAddress(address: text)
        case .CITY:
            viewModel.setCity(city: text)
        case .STATE:break
//            viewModel.setState(state: text)
        case .ZIP:
            viewModel.setZipCode(code: text)
        }
    }
    
    func didChangeTextField(text: String?, data: TextFieldCellData) {
        guard let field = AddressField(rawValue: data.key) else {
            return
        }
        
        let finalText = text ?? ""
        print("Changed text:\(finalText)")
        
        switch field {
        case .STATE:
            
            let i = fields.firstIndex(where: {AddressField(rawValue:$0.rawValue) == .STATE}) ?? -1
            if i != -1{
                let indexPath = IndexPath(row: i, section: 0)
                if let cell = addressTableView.cellForRow(at: indexPath) as? TextFieldCell{
                    
                    let arrResult = arrStatesListGlobal
                        .filter { NSPredicate(format: "(StateNickName contains[c] %@)", finalText).evaluate(with: $0) }
                        
                    
                    let arr = arrResult.map({$0["StateNickName"] as! String}) // For Select Item from list
                    let arr2 = arrResult.map({"\($0["StateNickName"] as! String)" + " (\($0["FullStateName"] as! String))"})  // For Show list
                    
                    dropDown.anchorView = cell //5
                    dropDown.direction = .any
                    dropDown.width = cell.frame.width
                    dropDown.dataSource = arr2
                    dropDown.show()
                    dropDown.bottomOffset = CGPoint(x: 0, y: cell.frame.size.height)
                    
                    dropDown.selectionAction = { [weak self] (index: Int, item: String) in //8
                      guard let self = self else { return }
                        print("Selected Item:\(item)")
                        self.viewModel.setState(state: arr[index])
                        data.text = arr[index]
                        self.addressTableView.reloadData()
                    }
                }
            }
            break
        default:break
        }
    }
}
