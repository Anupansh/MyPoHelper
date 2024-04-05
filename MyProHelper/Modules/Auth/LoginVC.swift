//
//  LoginVC.swift
//  MyProHelper
//
//  Created by Anupansh on 21/05/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    //MARK: - OUTLETS AND VARIABLES
    @IBOutlet var tfArray: [OtpTextfeild]!
    let myprohelperServer = MyProHelperServer()
    var textfieldHasCharacter = false
    
    //MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        
    }
    
    //MARK: - IBACTIONS
    @IBAction func continueBtnPressed(_ sender: Any) {
        var deviceCode = ""
        for tf in tfArray {
            deviceCode += tf.text!
        }
        if deviceCode.count < 6 {
            CommonController.shared.showSnackBar(message: "Enter a valid device code", view: self)
        }
        else {
            self.getSubDomainForThisDevice(deviceCode: deviceCode)
        }
    }
    
    //MARK: - SERVER CALLS
    func getSubDomainForThisDevice(deviceCode:String) {
        
        myprohelperServer.getSubDomainForThisDevice(deviceCode) { [weak self] result in
            
            switch result {
            case .success(let dd):
                self?.getAccess(accessCode: deviceCode, subDomain: dd.subDomain, companyID: dd.companyID)
            case .failure(let error1):
                var msgText:String = ""
                switch error1 {
                case .NoNetworkConnectivity:
                    msgText = "Please try again when you are connected to the internet."

                case .invalidData, .BadDeviceCode:
                    msgText = "The device code is not valid."
                }
                CommonController.shared.showSnackBar(message: msgText, view: self!)
            }
            

        }
    }
    
    func getAccess(accessCode: String, subDomain: String, companyID: Int) {
        MyProHelperServer.requestGetURL2a(accessCode: accessCode, subDomain: subDomain, companyID: companyID) { [weak self] result1 in
            
            switch result1 {
            case .success(let data1):
                let settings:SavedSettings = SavedSettings()
                settings.setServerAccess(serverAccess: data1)
                AppLocals.serverAccessCode = data1
                let vc = AppStoryboards.auth.instantiateViewController(withIdentifier: DownloadDatabaseVC.className)
                CommonController.shared.setRootVC(withController: vc)
                return
            case .failure(let error1):
                var msgText:String = ""
                switch error1 {
                case .NoNetworkConnectivity:
                    msgText = "Please try again when you are connected to the internet."

                case .invalidData, .BadDeviceCode:
                    msgText = "The device code is not valid."
                }
                CommonController.shared.showSnackBar(message: msgText, view: self!)
            }

        }
    }
    
    //MARK: - HELPER FUNCTIONS
    func initialSetup() {
        for tf in tfArray {
            tf.addTarget(self, action: #selector(changeCharacter(textField:)), for: .editingChanged)
            tf.deleteDelegate = self
        }
        tfArray[0].becomeFirstResponder()
    }
    
    @objc func changeCharacter(textField: UITextField) {
        if textField.text!.count >= 1 {
            switch textField {
            case tfArray[0]:
                tfArray[1].becomeFirstResponder()
            case tfArray[1]:
                tfArray[2].becomeFirstResponder()
            case tfArray[2]:
                tfArray[3].becomeFirstResponder()
            case tfArray[3]:
                tfArray[4].becomeFirstResponder()
            case tfArray[4]:
                tfArray[5].becomeFirstResponder()
            case tfArray[5]:
                tfArray[5].resignFirstResponder()
            default:
                break
            }
        }
        else if textField.text!.count == 0 {
            textfieldHasCharacter = true
        }
    }
}

extension LoginVC: OtpTextfeildDelegate {
    func textFieldDidDelete(textfeild: UITextField) {
        if textfieldHasCharacter {
            textfieldHasCharacter = false
        }
        else {
            if textfeild.text!.isEmpty {
                switch textfeild {
                case tfArray[5]:
                    tfArray[4].becomeFirstResponder()
                    tfArray[4].text = ""
                case tfArray[4]:
                    tfArray[3].becomeFirstResponder()
                    tfArray[3].text = ""
                case tfArray[3]:
                    tfArray[2].becomeFirstResponder()
                    tfArray[2].text = ""
                case tfArray[2]:
                    tfArray[1].becomeFirstResponder()
                    tfArray[1].text = ""
                case tfArray[1]:
                    tfArray[0].becomeFirstResponder()
                    tfArray[0].text = ""
                default:
                    break
                }
            }
        }
    }
}

protocol OtpTextfeildDelegate: AnyObject {
    func textFieldDidDelete(textfeild: UITextField)
}

class OtpTextfeild: UITextField {

    weak var deleteDelegate: OtpTextfeildDelegate?

    override func deleteBackward() {
        super.deleteBackward()
        deleteDelegate?.textFieldDidDelete(textfeild: self)
    }
}
