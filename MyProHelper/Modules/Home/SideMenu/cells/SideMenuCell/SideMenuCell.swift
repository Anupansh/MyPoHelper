//
//  SideMenuCell.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/11/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit
import ExpandableCell

private enum CellState {
    case Open
    case Closed
}

class SideMenuCell: UITableViewCell {
    
    static let ID = String(describing: SideMenuCell.self)

    @IBOutlet weak private var cellIconImageView    : UIImageView!
    @IBOutlet weak private var cellTitleLabel       : UILabel!
    @IBOutlet weak private var expandIcon           : UIImageView!
    
    private var cellState: CellState = .Closed
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func setupCell(title: String, icon: UIImage?) {
        cellIconImageView.image = icon
        cellTitleLabel.text = title
    }
    
    func hideExpandArrow() {
        expandIcon.isHidden = true
    }
    
    func showExpandArrow() {
        expandIcon.isHidden = false
    }

    func animate() {
        if cellState == .Open {
            close()
        }
        else {
            open()
        }
    }

    private func open() {
        cellState = .Open
        UIView.animate(withDuration: 0.3) {[weak self] in
            self?.expandIcon.layer.transform = CATransform3DMakeRotation(CGFloat(Double.pi), 1.0, 0.0, 0.0)
        }
    }

    private func close() {
        cellState = .Closed
        UIView.animate(withDuration: 0.3) {[weak self] in
            self?.expandIcon.layer.transform = CATransform3DMakeRotation(CGFloat(Double.pi), 0.0, 0.0, 0.0)
        }
    }
    
    func isOpenCell() -> Bool {
        return cellState == .Open
    }
}
