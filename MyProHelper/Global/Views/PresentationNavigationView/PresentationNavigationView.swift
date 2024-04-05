//
//  PresentationNavigationView.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 01/07/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation
import UIKit

protocol PresentationNavigationViewDelegate {
    func cancelButtonAction()
    func doneButtonAction()
}

class PresentationNavigationView:UIView {
    
    @IBOutlet weak var contentView:UIView!
    var delegate:PresentationNavigationViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("PresentationNavigationView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.delegate?.cancelButtonAction()
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        self.delegate?.doneButtonAction()
    }
    
}
