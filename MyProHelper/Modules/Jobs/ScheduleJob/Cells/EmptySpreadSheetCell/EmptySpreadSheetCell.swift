//
//  EmptySpreadSheetCell.swift
//  MyProHelper
//
//  Created by Samir on 21/02/2021.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit
import SpreadsheetView

class EmptySpreadSheetCell: Cell {

    static let ID = String(describing: EmptySpreadSheetCell.self)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setbackgroundColor()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setbackgroundColor()
    }

    func setbackgroundColor(color: UIColor = .white) {
        backgroundColor = color
    }
}
