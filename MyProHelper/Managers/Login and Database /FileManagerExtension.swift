//
//  FileManagerExtension.swift
//  MyprohelperSample
//
//  Created by David Bench on 3/15/21.
//

import Foundation
public enum FileExistence: Equatable {
    case none
    case file
    case directory
}

public func ==(lhs: FileExistence, rhs: FileExistence) -> Bool {

    switch (lhs, rhs) {
    case (.none, .none),
         (.file, .file),
         (.directory, .directory):
        return true

    default: return false
    }
}

extension FileManager {
    public func existence(atUrl url: URL) -> FileExistence {

        var isDirectory: ObjCBool = false
        let exists = self.fileExists(atPath: url.path, isDirectory: &isDirectory)

        switch (exists, isDirectory.boolValue) {
        case (false, _): return .none
        case (true, false): return .file
        case (true, true): return .directory
        }
    }
}
