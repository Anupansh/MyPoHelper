//
//  String+Extensions.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 05/06/20.
//  Copyright © 2020 Sourabh. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    var localize: String {
        get {
            return NSLocalizedString(self, comment: "")
        }
    }
    
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.width)
    }
    
    func removeSpace() -> String {
        let filteredText = String(self.filter { !" \n\t\r".contains($0) })
        return filteredText
    }
    
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
    
    
    func makePluralIfNeeded(theCount:Int) -> String{
        if theCount == 1 {
            return  self
        }
        
        return self + "s"
    }
    
    func replaceMain() -> String{
        self.replacingOccurrences(of: "main.", with: "chg.")
    }
    
}

extension String{
   func isDecimal()->Bool{
       let formatter = NumberFormatter()
       formatter.allowsFloats = true
       formatter.locale = Locale.current
       return formatter.number(from: self) != nil
   }
}

extension String {
    public func trimHTMLTags() -> String? {
        guard let htmlStringData = self.data(using: String.Encoding.utf8) else {
            return nil
        }
    
        let options: [NSAttributedString.DocumentReadingOptionKey : Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
    
        let attributedString = try? NSAttributedString(data: htmlStringData, options: options, documentAttributes: nil)
        return attributedString?.string
    }
}

extension String {
    func leftPadding(toLength: Int, withPad: String = " ") -> String {

        guard toLength > self.count else { return self }

        let padding = String(repeating: withPad, count: toLength - self.count)
        return padding + self
    }
}

extension String {
    func PadLeft( totalWidth: Int,byString:String) -> String {
        let toPad = totalWidth - self.count
        if toPad < 1 {
            return self
        }
        
        return "".padding(toLength: toPad, withPad: byString, startingAt: 0) + self
    }
}
