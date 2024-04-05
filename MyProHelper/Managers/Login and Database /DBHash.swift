//
//  DBHash.swift
//  MyprohelperSample
//
//  Created by David Bench on 4/2/21.
//

import Foundation

open class DBHash {
    
    private static func mySwiftFunc() -> UnsafePointer<CChar>? {
        if let ss = DBHelper.getDBFileName() {
            print("ss - \(ss)")

            let newString = strdup(ss)
            return UnsafePointer(newString)
        }
        else {
            return nil
        }
    }
    
    public static func getDBHash() -> String {
        var ss:String = ""
        
        let foo = mySwiftFunc()
        
        var aVar:UnsafeMutablePointer<CChar>? = nil
        
        if let aVar = aVar {
                
            let str: String? = String(validatingUTF8: aVar)
            if let str = str {
                ss = str
                print("ee - \(str)")
            }
            
            aVar.deallocate()
        }
        return ss
    }
}
