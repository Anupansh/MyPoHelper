//
//  DashboardLayoutTableHeader.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 02/07/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation
import UIKit

class DashboardLayoutTableHeader:UIView {
    
    @IBOutlet weak var contentView:UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("DashboardLayoutTableHeader", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
    }
}
