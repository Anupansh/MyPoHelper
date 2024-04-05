//
//  CreateHolidayViewModel.swift
//  MyProHelper
//
//  Created by Deep on 1/14/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
class CreateHolidayViewModel {
    
    var holiday :Box<Holiday> = Box(Holiday())
    private var isUpdatingHoliday = false
    private let service = HolidayService()
    let calendar    = Calendar.current
    
    func setHoliday(holiday: Holiday) {
        self.holiday.value = holiday
        self.isUpdatingHoliday = true
        self.holiday.value.updateModifyDate()
    }
    
    func checkWeekend() -> Bool {
        if let date = holiday.value.actualDate {
            return calendar.isDateInWeekend(date)
        }else {
            return true
        }
    }
    
    func setHolidayName(holidayName: String?) {
        holiday.value.holidayName = holidayName
    }
    
    func setYear(year: String?){
        holiday.value.year = Int(year ?? "0")
    }
    func setActualDate(actualDate: String?){
        guard let actualDate = actualDate else { return }
        holiday.value.actualDate = DateManager.stringToDate(string: actualDate)
    }
    func setDateCelebrated(dateCelebrated: String?){
        guard let dateCelebrated = dateCelebrated else { return }
        holiday.value.dateCelebrated = DateManager.stringToDate(string: dateCelebrated)
    }
    
    func getHolidayName() -> String? {
        return holiday.value.holidayName
    }
    func getYear() -> String? {
        return String(holiday.value.year ?? 0 )
    }
    func getHolidayActualDate() -> String? {
        return DateManager.getStandardDateString(date: holiday.value.actualDate)
    }
    func getHolidayCelebratedDate() -> String? {
        return DateManager.getStandardDateString(date: holiday.value.dateCelebrated)
    }
    
    func validateHolidayName() -> ValidationResult {
        return Validator.validateName(name: holiday.value.holidayName)
    }
    
    private func isValidData() -> Bool {
        return
            validateHolidayName()            == .Valid
    }
    func saveHoliday(completion: @escaping (_ error: String?, _ isValidData: Bool) -> ()) {
        if !isValidData() {
            completion(nil, false)
            return
        }
        if isUpdatingHoliday {
            updateHoliday { (error) in
                completion(error, true)
            }
        }
        else {
            createHoliday { (error) in
                completion(error, true)
            }
        }
    }
    
    private func updateHoliday(completion: @escaping (_ error: String?)->()) {
        service.updateHoliday(holiday: holiday.value) { (result) in
            switch result {
            case .success(_):
                completion(nil)
                
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    private func createHoliday(completion: @escaping (_ error: String?)->()) {
        service.createHoliday(holiday: holiday.value) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let typeID):
                self.holiday.value.holidayID = Int(typeID)
                completion(nil)
                
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
}
