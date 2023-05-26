//
//  SBULogger.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 20/04/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

// 📕📙📗📘📓📔

class SBULog {
    static var logType: UInt8 = LogType.none.rawValue
    
    static func error<T>(_ object: T?, filepath: String = #file, line: Int = #line, funcName: String = #function) {
        if (SBULog.logType & LogType.error.rawValue) > 0 {
            SBULog.Log(object, type: "📕Error", filepath: filepath, line: line, funcName: funcName)
        }
    }
    
    static func warning<T>(_ object: T?, filepath: String = #file, line: Int = #line, funcName: String = #function) {
        if (SBULog.logType & LogType.warning.rawValue) > 0 {
            SBULog.Log(object, type: "📙Warning", filepath: filepath, line: line, funcName: funcName)
        }
    }
    
    static func info<T>(_ object: T?, filepath: String = #file, line: Int = #line, funcName: String = #function) {
        if (SBULog.logType & LogType.info.rawValue) > 0 {
            SBULog.Log(object, type: "📘Info", filepath: filepath, line: line, funcName: funcName)
        }
    }
   
    static fileprivate func Log<T>(_ object: T?, type: String, filepath: String, line: Int, funcName: String) {
        let thread = Thread.current.isMainThread ? "Main": Thread.current.name ?? "-"
        let filename = (filepath.components(separatedBy: "/").last ?? "").components(separatedBy: ".").first ?? ""

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let time = formatter.string(from: Date())
        
        if let obj = object {
            print(String(format: "🎨SBULog \(type) \(thread) [%@ %@:%@:%d] \(obj)", time, filename, funcName, line))
        } else {
            print(String(format: "🎨SBULog \(type) \(thread) [%@ %@:%@:%d]", time, filename, funcName, line))
        }
    }
}
