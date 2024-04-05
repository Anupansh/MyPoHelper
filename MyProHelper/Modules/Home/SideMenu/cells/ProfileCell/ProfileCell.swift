//
//  ProfileCell.swift
//  MyProHelper
//
//  Created by Samir on 25/01/2021.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit

class ProfileCell: UITableViewCell {

    static let ID = String(describing: ProfileCell.self)

    @IBOutlet weak var profileImageView : UIImageView!
    @IBOutlet weak var btnProfile       : UIButton!
    @IBOutlet weak var nameLabel        : UILabel!
    @IBOutlet weak var emailLabel       : UILabel!
    @IBOutlet weak var closeButton      : UIButton!
    
    @IBOutlet weak var viContainerStartEndDay: UIView!
    @IBOutlet weak var btnStartEndDay   : UIButton!
    
    @IBOutlet weak var viContainerBreak : UIView!
    @IBOutlet weak var btnBreak         : UIButton!
    @IBOutlet weak var imgCloseBreak    : UIImageView!
    
    
    @IBOutlet weak var viContainerLunch : UIView!
    @IBOutlet weak var btnLunch         : UIButton!
    @IBOutlet weak var imgCloseLunch    : UIImageView!
    
    var didPressCloseButton: (() -> Void)?
    var didPressProfileButton: (() -> Void)?
    var didPressStartButton: (() -> Void)?
    var didPressEndButton: (() -> Void)?
    var didPressStartBreakButton: (() -> Void)?
    var didPressStopBreakButton: (() -> Void)?
    var didPressStartLunchButton: (() -> Void)?
    var didPressStopLunchButton: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupProfileImageView()
        setupCloseButton()
        selectionStyle = .none
    }

    private func setupCloseButton() {
        let closeImage = UIImage(named: Constants.Image.CIRCLE_CLOSE_BUTTON)
        closeButton.setImage(closeImage, for: .normal)
    }

    private func setupProfileImageView() {
        profileImageView.layer.masksToBounds = false
        profileImageView.clipsToBounds = true
    }
    
    func setupButtons(_ isStartDay:Bool,_ isStartBreak:Bool,_ isStartLunch:Bool,_ isEndLunch:Bool){
        
        if isStartDay{
            viContainerBreak.isHidden = false
            viContainerLunch.isHidden = false
//            btnBreak.isHidden = false
//            btnLunch.isHidden = false
            btnStartEndDay.setTitle("End Day", for: .normal)
        }
        else{
            viContainerBreak.isHidden = true
            viContainerLunch.isHidden = true
//            btnBreak.isHidden = true
//            btnLunch.isHidden = true
            btnStartEndDay.setTitle("Start Day", for: .normal)
            
        }
        if isEndLunch{
            viContainerLunch.isHidden = true
//            btnLunch.isHidden = true
        }
        else{
            viContainerLunch.isHidden = false
//            btnLunch.isHidden = false
        }
        
        if isStartBreak{
            btnBreak.setTitle("Stop Break", for: .normal)
            btnBreak.borderWidth = 1
            btnBreak.borderColor = UIColor.red
            imgCloseBreak.isHidden = false
        }
        else{
            btnBreak.setTitle("Start Break", for: .normal)
            btnBreak.borderWidth = 0
            btnBreak.borderColor = UIColor.clear
            imgCloseBreak.isHidden = true
        }
        
        if isStartLunch{
            btnLunch.setTitle("Stop Lunch", for: .normal)
            btnLunch.borderWidth = 1
            btnLunch.borderColor = UIColor.red
            imgCloseLunch.isHidden = false
        }
        else{
            btnLunch.setTitle("Start Lunch", for: .normal)
            btnLunch.borderWidth = 0
            btnLunch.borderColor = UIColor.clear
            imgCloseLunch.isHidden = true
        }
        
    }

    @IBAction private func closeButtonPressed(sender: UIButton) {
        didPressCloseButton?()
    }
    
    @IBAction func startEndDayPressed(_ sender: Any) {
        AppLocals.startDateWorked == nil ? didPressStartButton?() : didPressEndButton?()
        
    }
    
    @IBAction func breakPressed(_ sender: Any) {
        AppLocals.isBreakRunning ? didPressStopBreakButton?() : didPressStartBreakButton?()
    }
    
    @IBAction func lunchPressed(_ sender: Any) {
        
        AppLocals.isLunchRunning ? didPressStopLunchButton?() : didPressStartLunchButton?()
    }
    
    @IBAction func profilePressed(_ sender: Any) {
        
        didPressProfileButton?()
    }
}
