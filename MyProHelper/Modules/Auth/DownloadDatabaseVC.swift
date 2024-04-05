//
//  DownloadDatabaseVC.swift
//  MyProHelper
//
//  Created by Anupansh on 25/05/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit
import CryptoKit
import GRDB

class DownloadDatabaseVC: UIViewController {

    //MARK: - OUTLETS AND VARIABLES
    @IBOutlet weak var downloadingDbLbl: UILabel!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var progressBaseView: UIView!
    @IBOutlet weak var progressLbl: UILabel!
    @IBOutlet weak var progressViewWidth: NSLayoutConstraint!
    @IBOutlet weak var retryDownloadBtn: UIButton!
    
    private lazy var downloader = FilesDownloader()
    var localURL:URL?
    var dbChangesStatus:String = ""
    var downloadIndex = 0
    var timer: Timer?
    var downloadingDbArray = ["Downloading Database","Downloading Database.","Downloading Database..","Downloading Database...","Downloading Database...."]
    
    //MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    //MARK: - RETRY BUTTON ACTION
    @IBAction func retryDownloadBtnPressed(_ sender: Any) {
        downloadDb()
        retryDownloadBtn.isHidden = true
        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(changeDownloadLbl), userInfo: nil, repeats: true)
        downloadingDbLbl.text = downloadingDbArray[0]
    }
    
    
    //MARK: - HELPER FUNCTIONS
    @objc func changeDownloadLbl() {
        downloadingDbLbl.text = downloadingDbArray[downloadIndex]
        downloadIndex += 1
        if downloadIndex == 5 {
            downloadIndex = 0
        }
    }
    
    func initialSetup() {
        progressViewWidth.constant = 0
        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(changeDownloadLbl), userInfo: nil, repeats: true)
        downloadDb()
    }
    
    func downloadDb() {
        guard let companyID  = AppLocals.serverAccessCode?.CompanyID else {return }
        let company = CompanyID(id: companyID)
        guard  let custDB = company.getDBFileNameWithPath() else {return}
        localURL = custDB
        if let serverAccess = AppLocals.serverAccessCode {
            let serverURL = ServerURL()
            let MyprohelperURL   = serverURL.getURL(ServerURL.apiName.DownloadDB)
            downloader.download(from: MyprohelperURL, UpDnCode: serverAccess.UPDBCode1, delegate: self)
            return
        }
    }
}

extension DownloadDatabaseVC: FileDownloadingDelegate {
    func updateDownloadProgressWith(progress: Float) {
        UIView.animate(withDuration: 0.1) {
            self.progressViewWidth.constant = self.progressBaseView.frame.width * CGFloat(progress)
            self.progressLbl.text = "\(String(format: "%.2f", progress * 100)) %"
        }
    }
    
    func downloadFinishedCopyFile(localFilePath: URL, completeHeader: [AnyHashable : Any], status: Int) {
        if status != 200 {
            let downloadError = DownloadFailure.BadDeviceCode
            DispatchQueue.main.async {self.downloadComplete(res1: Result.failure(downloadError))}
            return
        }
        guard let local = localURL else { return }
        if let data:Data = try? Data(contentsOf: localFilePath) {
            let digest = SHA256.hash(data: data)
            
            let stringHash = digest.map { String(format: "%02hhx", $0) }.joined()
            print("hash computed on device: \(stringHash)")
            if let serverHash = completeHeader["Hash"] as? String {
                print("server hash: \(serverHash)")
                // use contentType here
                if serverHash == stringHash {
                    print("has match!")
                    let fileManager:FileManager = FileManager.default
                    do {
                        try? fileManager.removeItem(at: local)
                    }
                    do {
                        try fileManager.moveItem(at: localFilePath, to: local)
                        print("after copy \(local)")
                        DispatchQueue.main.async {self.downloadComplete(res1: Result.success(local))}
                    }
                    catch {
                        print("copy error \(error)")
                        let downloadError = DownloadFailure.HashMismatch
                        DispatchQueue.main.async {self.downloadComplete(res1: Result.failure(downloadError))}
                    }
                }
                else {
                    print("no hash match!")
                    let downloadError = DownloadFailure.HashMismatch
                    
                    DispatchQueue.main.async {self.downloadComplete(res1: Result.failure(downloadError))}
                    return
                }
            }
            else {
                print("no header Hash")
                let downloadError = DownloadFailure.HashMismatch
                DispatchQueue.main.async {self.downloadComplete(res1: Result.failure(downloadError))}
            }
        }
    }
    
    func downloadFailed(withError error: Error) {
        retryDownloadBtn.isHidden = false
        timer?.invalidate()
        downloadingDbLbl.text = error.localizedDescription
        progressLbl.text = "0 %"
        progressViewWidth.constant = 0
    }
    
    func downloadComplete(res1: Result<URL, DownloadFailure>) {
        switch res1 {
        case .success(_):
            DBHelper.emptyChangesDB()
            CommonController.shared.setRootVC(withController: DashboardViewController())
        case .failure(_):
            let vc = AppStoryboards.auth.instantiateViewController(withIdentifier: LoginVC.className)
            CommonController.shared.setRootVC(withController: vc)
        }
    }
}
