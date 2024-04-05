//
//  JobDeclineView.swift
//  MyProHelper
//
//  Created by Deep on 1/21/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import UIKit

class JobDeclineView: UIViewController, Storyboarded {
    
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var JobDeclineTextView: UITextView!
    @IBOutlet weak var ConfirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var backgroundViewContainer: UIView!
    
    var didSetText: ((_ text: String?) -> Void)?
    
    override func viewDidLoad() {
        title = "Job Decline"
        setupTapGesture()
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDismissView))
        backgroundViewContainer.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func confirmButtonPressed(sender: UIButton) {
        if JobDeclineTextView.text == "" {
            JobDeclineTextView.borderColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
        } else{
            dismiss(animated: false, completion: { [weak self] in
                guard let self = self else { return }
                let data = self.JobDeclineTextView.text
                self.didSetText?(data)
            })
        }
    }
    
    @objc private func handleDismissView() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        handleDismissView()
    }
}
