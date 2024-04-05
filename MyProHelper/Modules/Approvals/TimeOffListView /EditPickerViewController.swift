//
//  EditPickerViewController.swift
//


import UIKit

protocol PickerDelegate: class {
    func pickerDone(selecteditem: Int)
    func pickerCancel(selecteditem: Int)
}
class EditPickerViewController: UIViewController,Storyboarded {
    var datasourse = [Any]()
    var isWorkerData = Bool()
    @IBOutlet weak var mypicker: UIPickerView!
    @IBOutlet var al_Bottom: NSLayoutConstraint! {
        didSet { al_Bottom.constant = -240 }
    }
    weak var newpickerDelegate: PickerDelegate?
    //  weak var ratepickerDelegate: RatePickerDelegate?
    var selectedItem : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateBottomLayout(constant: 0)
    }
    //MARK: To Hide the pikcerview
    private func updateBottomLayout(constant: CGFloat ) {
        UIView.animate(withDuration: 0.3, animations: {
            self.al_Bottom.constant = constant
            self.view.layoutIfNeeded()
        }) { (isFinish) in
            if (isFinish) && (constant < 0){
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        if let _pickerDelegate = newpickerDelegate {
            _pickerDelegate.pickerDone(selecteditem: selectedItem)
        }
        self.updateBottomLayout(constant: -240)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
      //  self.DISMISS()
        self.updateBottomLayout(constant: -240)
    }
}

//MARK: - Pickerview method
extension EditPickerViewController: UIPickerViewDataSource,UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        print(datasourse)
        return datasourse.count
        
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if isWorkerData
        {
            return (datasourse[row] as! Worker).fullName
        }
        return datasourse[row] as? String
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedItem = row
//        if let _pickerDelegate = newpickerDelegate {
//            _pickerDelegate.pickerDone(selecteditem: selectedItem)
//
//        }
        
    }
}
