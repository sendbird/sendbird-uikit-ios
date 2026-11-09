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

// 레벨이 꺼져 있으면 메시지를 만들지 않는다. object는 레벨을 확인한 뒤 한 번만 만든다.
class Log {
    static func error(_ object: @autoclosure () -> Any?, filepath: String = #file, line: Int = #line, funcName: String = #function) {
        guard SendbirdLogger.level(for: .uikit) <= .error else { return }
        Logger.uikit.error(filepath: filepath, line: line, funcName: funcName, "\(object() ?? "")")
    }

    static func warning(_ object: @autoclosure () -> Any?, filepath: String = #file, line: Int = #line, funcName: String = #function) {
        guard SendbirdLogger.level(for: .uikit) <= .warning else { return }
        Logger.uikit.warning(filepath: filepath, line: line, funcName: funcName, "\(object() ?? "")")
    }

    static func info(_ object: @autoclosure () -> Any?, filepath: String = #file, line: Int = #line, funcName: String = #function) {
        guard SendbirdLogger.level(for: .uikit) <= .info else { return }
        Logger.uikit.info(filepath: filepath, line: line, funcName: funcName, "\(object() ?? "")")
    }
}
