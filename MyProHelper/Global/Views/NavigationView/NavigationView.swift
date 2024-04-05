//
//  NavigationView.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 05/04/1942 Saka.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation
import UIKit

protocol NavigationViewDelegate {
    func addButtonAction()
    func menuButtonAction()
    func layoutButtonAction()
}

class NavigationView:UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentView:UIView!
    
    var delegate:NavigationViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("NavigationView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
    }
    
    func setTitle(_ title:String) {
        self.titleLabel.setTitle(title: title, fontSize: .large)
    }
    
    @IBAction func addButtonAction(_ sender: Any) {
        self.delegate?.addButtonAction()
    }
    
    @IBAction func menuButton(_ sender: Any) {
        self.delegate?.menuButtonAction()
    }
    
    @IBAction func layoutButtonAction(_ sender: Any) {
        self.delegate?.layoutButtonAction()
    }
}
