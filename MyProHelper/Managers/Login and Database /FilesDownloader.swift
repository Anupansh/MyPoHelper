//
//  FilesDownloader.swift
//  MyprohelperSample
//
//  Created by David Bench on 3/15/21.
//

// https://stackoverflow.com/questions/28219848/how-to-download-file-in-swift

import Foundation
   
protocol FileDownloadingDelegate: class {
    func updateDownloadProgressWith(progress: Float)
    func downloadFinishedCopyFile(localFilePath: URL, completeHeader: [AnyHashable : Any], status:Int)
    func downloadFailed(withError error: Error)
    func downloadComplete(res1: Result<URL, DownloadFailure>)
}

 open class FilesDownloader: NSObject, URLSessionDownloadDelegate {
    
    enum DownloadFailure: Error {
        case HashMismatch
        case NoNetworkConnectivity
        case BadDeviceCode

    }
    
    private weak var delegate: FileDownloadingDelegate?

    func download(from url: URL,  UpDnCode:String, delegate: FileDownloadingDelegate) {

        
        self.delegate = delegate
//        let sessionConfig = URLSessionConfiguration.background(withIdentifier: url.absoluteString) // use this identifier to resume download after app restart
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 20
        sessionConfig.timeoutIntervalForResource = 60
        
        sessionConfig.httpAdditionalHeaders = ["UpDnCode" : "\(UpDnCode)"]
        
        let session = Foundation.URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
  
        let task = session.downloadTask(with: url)
        task.resume()
    }

    open func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let response = downloadTask.response as? HTTPURLResponse else {
            return //something went wrong
        }
        
        let status = response.statusCode
        if status != 200 {
            
        }
        
        
        let completeHeader = response.allHeaderFields
        
        //        DispatchQueue.main.async { self.delegate?.downloadFinished(localFilePath: location, completeHeader: completeHeader, status: status) }
        
        self.delegate?.downloadFinishedCopyFile(localFilePath: location, completeHeader: completeHeader, status: status)
    }

    open func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        DispatchQueue.main.async { self.delegate?.updateDownloadProgressWith(progress: Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)) }
    }

    open func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    
        if error == nil {
            return // not sure why this is being called
        }
        if let resp = task.response {
            print("www")
            
        }
        
        if let error22 = error as NSError? {
            
            // -1004 - Could not connect to the server
            // -1001 - The request timed out.
            
            print("didCompleteWithError error domain \(error22.domain) error code: \(error22.code)")

        }
        
//        print("didCompleteWithError")
        if error != nil {
            guard let theError = error else { assertionFailure("something weird happened here"); return }
            DispatchQueue.main.async { self.delegate?.downloadFailed(withError: theError) }

        }
    }

}
