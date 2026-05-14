//
//  Logger+UIKit.swift
//  SendbirdUIKit
//
//  Created by Celine Moon on 2026/04/28.
//

@_spi(SendbirdInternal) import SendbirdAuthSDK

@_spi(SendbirdInternal) public extension Logger {
    static let uikit = Logger(product: .uikit, category: .none, descriptor: ExternalDescriptor())
}

class Log {
    static func error(_ object: Any?, filepath: String = #file, line: Int = #line, funcName: String = #function) {
        Logger.uikit.error(filepath: filepath, line: line, funcName: funcName, "\(object ?? "")")
    }

    static func warning(_ object: Any?, filepath: String = #file, line: Int = #line, funcName: String = #function) {
        Logger.uikit.warning(filepath: filepath, line: line, funcName: funcName, "\(object ?? "")")
    }

    static func info(_ object: Any?, filepath: String = #file, line: Int = #line, funcName: String = #function) {
        Logger.uikit.info(filepath: filepath, line: line, funcName: funcName, "\(object ?? "")")
    }
}
