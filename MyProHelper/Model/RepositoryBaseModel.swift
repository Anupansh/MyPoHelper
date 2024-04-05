//
//  RepositoryBaseModel.swift
//  MyProHelper
//
//  Created by Samir on 12/10/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import GRDB

protocol RepositoryBaseModel {
    var removed: Bool? { get set }
    init(row: Row)
    func getDataArray() -> [Any]
    func decimalAlignRightSideIndex()->[Int]
}

extension RepositoryBaseModel {

    func createDate(with value: DatabaseValueConvertible?) -> Date? {
        return DateManager.stringToDate(string: value as? String ?? "")
    }

    func getDateString(date: Date?) -> String {
        return DateManager.dateToString(date: date)
    }

    func getStringValue(value: String?) -> String {
        return value as String? ?? ""
    }

    func getFloatValue(value: Float?) -> Float {
        return value as Float? ?? 0.0
    }

    func getDoubleValue(value: Double?) -> Double {
        return value as Double? ?? 0.0
    }
    
    func  getIntValue(value: Int?) -> Int {
        return value as Int? ?? 0
    }
    
    func getYesNo(value: Bool?) -> String {
        guard let value = value else {
            return "No".localize
        }
        return (value == true) ? "Yes".localize : "No".localize
    }
    
    func getFormattedStringValue(value: Double?) -> String{
        let result = value as Double? ?? 0.00
        return String(format:"%.2f ", result)
    }
    
    func getFormattedStringValueFromDouble(value: Double?) -> String{
        return getFormattedStringValue(value: value)
    }
    
    func getFormattedStringValueFromInt(value: Int?) -> String{
        let result = value as Int? ?? 0
        return String(format:"%d ", result)
    }
    
    func decimalAlignRightSideIndex()->[Int]{
        return []
    }
    
}
