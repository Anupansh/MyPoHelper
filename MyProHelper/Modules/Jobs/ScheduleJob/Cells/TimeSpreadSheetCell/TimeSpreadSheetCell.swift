//
//  TimeSpreadSheetCell.swift
//  MyProHelper
//
//  Created by Samir on 15/02/2021.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit
import SpreadsheetView

class TimeSpreadSheetCell: Cell {
    
    static let ID = String(describing: TimeSpreadSheetCell.self)

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .left
        return label
    }()

    override var frame: CGRect {
        didSet {
            timeLabel.frame = bounds.insetBy(dx: 6, dy: 0)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTimeLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTimeLabel()
    }

    private func setupTimeLabel() {
        timeLabel.frame = bounds
        timeLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(timeLabel)
    }

    func setTime(time: String) {
        timeLabel.text = time
    }
}
