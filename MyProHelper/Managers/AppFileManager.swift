//
//  AppFileManager.swift
//  MyProHelper
//
//  Created by Samir on 11/3/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

struct AppFileManager {
    
    static private let fileManager = FileManager.default
    static private let baseUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    static func isFileExist(fileName: String) -> Bool {
        var url = baseUrl
        url.appendPathComponent(fileName)
        return fileManager.fileExists(atPath: url.path)
    }
    
    static func getFileURL(fileName: String) -> URL {
        var url = baseUrl
        url.appendPathComponent(fileName)
        return url
    }
    
    static func getFileName(at url: URL) -> String? {
        return url.lastPathComponent
    }
    
    static func saveFile(file: Data, withName: String) {
        let url = baseUrl.appendingPathComponent(withName)
        do {
            try file.write(to: url)
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    static func saveFile(from: URL) -> URL? {
        if isFileExist(fileName: from.lastPathComponent) {
            print("file is exsit")
            return getFileURL(fileName: from.lastPathComponent)
        }
        
        let url = baseUrl.appendingPathComponent(from.lastPathComponent)
        
        do {
            try fileManager.copyItem(at: from, to: url)
            return url
        }
        catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    static func deleteFile(at: URL) {
        let url = baseUrl.appendingPathComponent(at.lastPathComponent)
        do {
            try fileManager.removeItem(at: url)
        }
        catch {
            print(error.localizedDescription)
        }
        
    }
    
    static func getFile(withUrl: URL) -> Data? {
        
        var url = baseUrl
        url.appendPathComponent(withUrl.lastPathComponent)
        do {
            let data = try Data(contentsOf: url)
            return data
        }
        catch {
            print(error.localizedDescription)
            return nil
        }
    }
}

extension URL {
    var typeIdentifier  : String? { (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier }
    var localizedName   : String? { (try? resourceValues(forKeys: [.localizedNameKey]))?.localizedName }
}
