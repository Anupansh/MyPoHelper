//
//  CommonController.swift
//  MyProHelper
//
//  Created by Anupansh on 17/03/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation
import UIKit
import GRDB

protocol CommonControllerDelegate {
    func pickedImage(image: UIImage)
}

extension CommonControllerDelegate {
    func pickedImage(image: UIImage) {}
}

class CommonController: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    enum JobStatus: String {
        case scheduled = "Scheduled"
        case inProgress = "In Progress"
        case endingSoon = "Ending Soon"
        case completed = "Completed"
        case invoiced = "Invoiced"
    }
    
    var delegate : CommonControllerDelegate?
    static let shared = CommonController()
    var imagePicker = UIImagePickerController()
    
    func showSnackBar(message : String, view : UIViewController) {
        let time = DispatchTime.now() + 2
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        DispatchQueue.main.asyncAfter(deadline: time) {
            alert.dismiss(animated: true, completion: nil)
        }
        view.present(alert, animated: true, completion: nil)
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let pswdRegEx = "^(?=.*\\d)(?=.*[a-zA-Z]).{8,}$"
        // (?=.*[^A-Za-z0-9])
        let pswdTest = NSPredicate(format:"SELF MATCHES %@", pswdRegEx)
        return pswdTest.evaluate(with: password)
    }

    func isValidUsername(_ username: String) -> Bool {
        
        let regularExpressionText = "^[ء-يa-zA-Z0-9_.-]+"
        let regularExpression = NSPredicate(format:"SELF MATCHES %@", regularExpressionText)
        return regularExpression.evaluate(with: username)
    }
    
    func isValidPhone(value: String) -> Bool {
        let PHONE_REGEX = "^((\\+)|(00))[0-9]{6,14}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
    }
    
    func orderAlphabetically(_ arr: [String]) -> [String]{
        let orderedArr = arr.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
        return orderedArr
    }
    
    func openImagePicker(view : UIViewController) {
        let alert = UIAlertController(title: AppLocals.appName, message: "Please select an option.", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (alert) in
            self.handleCameraAction(view: view)

        }
        let photoGalleryAction = UIAlertAction(title: "Photo Gallery", style: .default) { (alert) in
            self.handleGalleryAction(view: view)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cameraAction)
        alert.addAction(photoGalleryAction)
        alert.addAction(cancelAction)
        if let popUpPresentationController = alert.popoverPresentationController {
            popUpPresentationController.sourceView = view.view
        }
        view.present(alert, animated: true, completion: nil)
    }
    

    func handleCameraAction(view : UIViewController) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            view.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func handleGalleryAction(view : UIViewController) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            view.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let kImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            delegate?.pickedImage(image: kImage)
        }
    }
    
    func getWorker(workerId: Int?,_ completion: (Worker?) -> ()) {
        var workerModel = [Worker]()
        guard let queue = AppDatabase.shared.attachDababaseQueue else {return}
        var sql = """
            SELECT * FROM main.\(RepositoryConstants.Tables.WORKERS)
            WHERE  (main.\(RepositoryConstants.Tables.WORKERS).\(RepositoryConstants.Columns.FIRST_NAME) != '--SELECT--') AND
                main.\(RepositoryConstants.Tables.WORKERS).\(RepositoryConstants.Columns.WORKER_ID) = \(workerId!)
        
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            try queue.read { (database) in
                let rows = try Row.fetchCursor(database, sql: sql)
                while let row = try rows.next() {
                    print(row)
                    let singleWorker = Worker.init(row: row)
                    workerModel.append(singleWorker)
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
        completion(workerModel.first)
    }
    
    func getWorker(workerId: Int?)->Worker? {
            var workerModel = [Worker]()
            guard let queue = AppDatabase.shared.attachDababaseQueue else {return nil}
            var sql = """
                SELECT * FROM main.\(RepositoryConstants.Tables.WORKERS)
                WHERE  (main.\(RepositoryConstants.Tables.WORKERS).\(RepositoryConstants.Columns.FIRST_NAME) != \(Constants.DefaultValue.SELECT_LIST) AND
                    main.\(RepositoryConstants.Tables.WORKERS).\(RepositoryConstants.Columns.WORKER_ID) = \(workerId!)
            
            """
            let chgSql = " union \(sql.replaceMain())"
            sql += chgSql
            do {
                try queue.read { (database) in
                    let rows = try Row.fetchCursor(database, sql: sql)
                    while let row = try rows.next() {
                        print(row)
                        let singleWorker = Worker.init(row: row)
                        workerModel.append(singleWorker)
                    }
                }
            }
            catch {
                print(error.localizedDescription)
            }
            return workerModel.first
        }

    func setRootVC(withController: UIViewController) {
        let navigationController = UINavigationController(rootViewController: withController)
        navigationController.isNavigationBarHidden = true
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window!.rootViewController = navigationController
        appDelegate.window!.makeKeyAndVisible()
    }
    
    func setLocationData() {
        guard let UPDBCode = AppLocals.serverAccessCode?.UPDBCode1 else {
            return
        }
        let serverURL = ServerURL()
        var request = URLRequest(url: serverURL.getURL(ServerURL.apiName.LocationDataRequest))
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["UpDnCode" : "\(UPDBCode)"]
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {                                              // check for fundamental networking error
                print("error", error ?? "Unknown error")
                return
            }
            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            let decoder = JSONDecoder()
            do {
                let locations = try decoder.decode([String: LocationData].self, from: data)
                AppLocals.savedLocationData = locations
                NotificationCenter.default.post(name: .locationDataChanged, object: nil, userInfo: [:])
            } catch let error {
                print("downloadImageAndMetadata catch: \(error)")
            }
        }.resume()
//        let (data, imageResponse) = try await URLSession.shared.data(for: request11)
//
//        if let dd = (imageResponse as? HTTPURLResponse)?.statusCode {
//            if dd == 200 {
//                return data
//            }
//            else {
//                print("handle getLocationData status code: \(dd)")
//            }
//        }
//        if (imageResponse as? HTTPURLResponse)?.statusCode == 200 {
//            return data
//        }
////        let (imageData, imageResponse) = try await URLSession.shared.data(for: imageRequest)
////        guard let image = UIImage(data: imageData), (imageResponse as? HTTPURLResponse)?.statusCode == 200 else {
//
//        let decoder = JSONDecoder()
//        do {
//        self.locations = try decoder.decode([String: LocationData].self, from: data)
//        } catch let error {
//            print("downloadImageAndMetadata catch: \(error)")
//            throw ImageDownloadError.badImage
//        }
//
//        return nil
//
////        let imageUrl = URL(string: "http://192.168.0.1:5011/api/ReportLocation/doit1")!
////        var imageRequest = URLRequest(url: imageUrl)
////        imageRequest.httpMethod = "POST"
////        imageRequest.allHTTPHeaderFields = ["UpDnCode" : "\(UPDBCode)"]
//
//
////        let (imageData, imageResponse) = try await URLSession.shared.data(for: imageRequest)
//
////        let decoder = JSONDecoder()
////        do {
////        self.locations = try decoder.decode([String: LocationData].self, from: imageData)
////        } catch let error {
////            print("downloadImageAndMetadata catch: \(error)")
////            throw ImageDownloadError.badImage
////        }
//
////        guard let locations =  try? decoder.decode(LocationDataXX.self, from: imageData) else {
////        guard let locations =  try? decoder.decode([String: LocationData].self, from: imageData) else {
////            throw ImageDownloadError.badImage
////        }
//
//
//        print("locations count \(locations.count)")
    }
    
}
