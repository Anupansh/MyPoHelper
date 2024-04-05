//
//  AppListView.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/27/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit

protocol AppListDelegate {
    func didSelectItem(row: Int, text: String)
    func willAddItem()
    func willShowLastItem()
}

class AppListView: BaseViewController, Storyboarded {

    @IBOutlet weak private var listTableView    : UITableView!
    @IBOutlet weak private var searchBar        : UISearchBar!
    @IBOutlet weak private var addItemButton    : UIButton!
    
    private var delegate: AppListDelegate?
    private var data: [String] = []
    private var filteredData: [String] = []
    private var isAddButtonHidden = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupListTableView()
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        setupAddButton()
    }
    
    private func setupNavigationBar() {
        let addItemBarButton = UIBarButtonItem(barButtonSystemItem: .add,
                                               target: self,
                                               action: #selector(handleAddButton))
        if !isAddButtonHidden {
            navigationItem.rightBarButtonItem = addItemBarButton
        }
        navigationController?.navigationBar.isHidden = false
    }

    private func setupAddButton() {
        if navigationController == nil {
            addItemButton.isHidden = isAddButtonHidden
        }
        else {
            addItemButton.isHidden = true
        }
    }

    private func setupListTableView() {
        let appListCell = UINib(nibName: AppListCell.cellId, bundle: nil)
        listTableView.delegate = self
        listTableView.dataSource = self
        listTableView.separatorStyle = .none
        listTableView.rowHeight = 50
        listTableView.register(appListCell, forCellReuseIdentifier: AppListCell.cellId)
        
    }
    
    private func filterList(with text: String?) {
        guard  let text = text else {
            filteredData = data
            listTableView.reloadData()
            return
        }
        if text.isEmpty {
            filteredData = data
            listTableView.reloadData()
        }
        else {
            filteredData = data.filter({ $0.lowercased().contains(text.lowercased()) })
            listTableView.reloadData()
        }
    }
    
    private func handleSelectItem(row: Int) {
        delegate?.didSelectItem(row: row, text: data[row])
        dismissListView()
    }

    @objc private func handleAddButton() {
        dismissListView()
        delegate?.willAddItem()
    }
    
    @IBAction private func addButtonPressed(sender: UIButton) {
        handleAddButton()
    }
    
    func bindView(data: [String], delegate: AppListDelegate) {
        self.data = data
        self.filteredData = data
        self.delegate = delegate
    }
    
    func dismissListView() {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: false)
        }
        else {
           dismiss(animated: true, completion: nil)
        }
    }
    
    func hideAddButton() {
        isAddButtonHidden = true
    }
}

extension AppListView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == filteredData.count - 1 {
            delegate?.willShowLastItem()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = filteredData[indexPath.row]
        if let selectedItemRow = data.firstIndex(of: item) {
            handleSelectItem(row: selectedItemRow)
        }
        
    }
}

extension AppListView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AppListCell.cellId) as? AppListCell else {
            return UITableViewCell()
        }
        cell.setTitle(title: filteredData[indexPath.row])
        cell.isLastCell(indexPath.row == filteredData.count - 1)
        return cell
    }
    
}

extension AppListView: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async { [unowned self] in
            self.filterList(with: searchBar.text)
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async { [unowned self] in
            self.filterList(with: "")
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        DispatchQueue.main.async { 
            self.filterList(with: searchBar.text)
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        DispatchQueue.main.async { [unowned self] in
            self.filterList(with: searchBar.text)
        }
    }
}
