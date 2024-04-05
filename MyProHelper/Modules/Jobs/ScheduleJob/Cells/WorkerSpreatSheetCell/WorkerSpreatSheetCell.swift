//
//  WorkerSpreatSheetCell.swift
//  MyProHelper
//
//  Created by Samir on 15/02/2021.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit
import SpreadsheetView

class WorkerSpreatSheetCell: Cell {

    static let ID = String(describing: WorkerSpreatSheetCell.self)

    private let workerNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18,
                                       weight: .medium)
        label.textAlignment = .left
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupWorkerNameLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupWorkerNameLabel()
    }

    private func setupWorkerNameLabel() {
        contentView.addSubview(workerNameLabel)
        workerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            workerNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            workerNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 5),
            workerNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            workerNameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 5)
        ])
    }

    func setWorkerName(name: String) {
        workerNameLabel.text = name
    }

}
