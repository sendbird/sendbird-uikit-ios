//
//  SBUPropertyWrapper.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 12/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import Foundation
import UIKit

@propertyWrapper
public class SBUAtomic<Value> {
    private var storage: Value
    private var atomicQueue = DispatchQueue(label: "com.sendbird.atomic")
    
    public init(wrappedValue value: Value) {
        storage = value
    }
    
    public var wrappedValue: Value {
        get {
            var result: Value!
            atomicQueue.sync {
                result = storage
            }
            return result
        }
        set {
            atomicQueue.async(flags: .barrier) {
                self.storage = newValue
            }
        }
    }
}

@propertyWrapper
public struct SBUAutoLayout<T: UIView> {
    public var wrappedValue: T {
        didSet {
            wrappedValue.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
        wrappedValue.translatesAutoresizingMaskIntoConstraints = false
    }
}

@propertyWrapper
public struct SBUThemeWrapper<T> {
    private var theme: T?

    public var wrappedValue: T {
        get { self.theme ?? SBUTheme.defaultTheme(currentClass: T.self) as! T }
        set { self.theme = newValue }
    }

    public init(theme: T, setToDefault: Bool = false) {
        if setToDefault {
            self.theme = theme
        }
    }
}

@propertyWrapper
public struct SBUPrioritizedConfig<T>: Codable where T: Codable {
    /// The enumeration that represents the priority.
    /// - IMPORTANT: The higher the raw value, the higher the priority.
    /// - Options:
    ///   - **default**: The case that represents the value predefined by Sendbird UIKit internally
    ///   - **dashboard**: The case that represents the value set in the [Sendbird dashboard](https://dashboard.sendbird.com)
    ///   - **custom**: The case that represents the value updated in the code level.
    ///     ```swift
    ///     SendbirdUI.config.groupChannel.channel.isMentionEnabled = {YOUR.VALUE}
    ///     ```
    enum Priority: Int, Codable {
        case `default`
        case dashboard
        case custom
    }
    var value: T
    
    public var wrappedValue: T {
        get { value }
        set {
            value = newValue
            priority = .custom
        }
    }
    private var priority: Priority = .default
    
    public init(wrappedValue: T) {
        self.value = wrappedValue
        self.priority = .default
    }

    mutating func setDashboardValue(_ value: T?) {
        let priority = Priority.dashboard
        guard let value = value,
              self.priority.rawValue <= priority.rawValue else { return }
        
        self.value = value
        self.priority = priority
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.value = try container.decode(T.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.value)
    }
}
