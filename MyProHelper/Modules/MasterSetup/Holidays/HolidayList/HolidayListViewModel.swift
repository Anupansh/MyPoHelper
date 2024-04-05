//
//  HolidayListViewModel.swift
//  MyProHelper
//
//  Created by Deep on 1/13/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

class HolidayListViewModel: BaseDataTableViewModel<Holiday,HolidayField> {
    
    private let service = HolidayService()
    
    override func reloadData() {
        hasMoreData = true
        fetchHolidays(reloadData: true)
    }
    
    override func fetchMoreData() {
        fetchHolidays(reloadData: false)
    }
    
    override func deleteItem(at row: Int) {
        let holiday = data[row]
        service.deleteHoliday(holiday: holiday) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.reloadData()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
    
    override func undeleteItem(at row: Int) {
        let holiday = data[row]
        service.restoreHoliday(holiday: holiday) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.reloadData()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
    
    private func fetchHolidays(reloadData: Bool) {
        guard hasMoreData else { return }
        let offset = (reloadData == false) ? data.count : 0
        service.fetchHolidays(showRemoved: isShowingRemoved, key: searchKey, sortBy: sortWith?.sortBy, sortType: sortWith?.sortType, offset: offset) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let holidays):
                self.hasMoreData = holidays.count == Constants.DATA_OFFSET
                if reloadData {
                    self.data = holidays
                }
                else {
                    self.data.append(contentsOf: holidays)
                }
                self.delegate.reloadView()
            case .failure(let error):
                self.delegate.showError(message: error.localizedDescription)
            }
        }
    }
}
