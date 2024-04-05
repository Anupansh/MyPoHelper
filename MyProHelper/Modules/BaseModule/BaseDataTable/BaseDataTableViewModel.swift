//
//  BaseDataTableViewModel.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/20/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

class BaseDataTableViewModel<T: RepositoryBaseModel,F> {
    
    var data: [T] = []
    var isApprovals = false
    var isShowingRemoved = false
    var delegate: RefreshDelegate
    var hasMoreData = true
    var searchKey: String? {
        didSet {
            reloadData()
        }
    }
    var sortWith: (sortType: SortType, sortBy: F)? {
        didSet {
            reloadData()
        }
    }
    
    init(delegate: RefreshDelegate) {
        self.delegate = delegate
    }
    
    func getItems() -> [T] {
        return data
    }
    
    func countData() -> Int {
        return data.count
    }
    
    func getItem(at index: Int) -> T {
        return data[index]
    }
    
    func setSearchKey(key: String) {
        searchKey = key
    }
    
    func setSortType(sortType: SortType, sortBy: F) {
        sortWith = (sortType, sortBy)
    }
    func isItemRemoved(at index: Int) -> Bool {
        return data[index].removed ?? false
    }
    
    func reloadData() { }
    func fetchMoreData() { }
    func deleteItem(at row: Int) { }
    func undeleteItem(at row: Int) { }
    
}

