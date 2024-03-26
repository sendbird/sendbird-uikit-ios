//
//  SBUPropertyWrapper.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 12/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import Foundation
import UIKit

/// `SBUAtomic` is a property wrapper class for atomic operations.
/// It provides a way to perform atomic operations on a value of type `Value`.
@propertyWrapper
public class SBUAtomic<Value> {
    private var storage: Value
    private var atomicQueue = DispatchQueue(label: "com.sendbird.atomic")
    
    /// Initializer for `SBUAtomic`.
    /// - Parameter wrappedValue: The value of type `Value` to be used for atomic operations.
    public init(wrappedValue value: Value) {
        storage = value
    }
    
    /// The wrapped value for atomic operations. 
    /// It uses a DispatchQueue to ensure that get and set operations are thread-safe.
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

/// `SBUAutoLayout` is a property wrapper struct for UIView.
/// It provides a way to set `translatesAutoresizingMaskIntoConstraints` to false automatically.
@propertyWrapper
public struct SBUAutoLayout<T: UIView> {
    /// The wrapped value of type `T`. It's a UIView and its `translatesAutoresizingMaskIntoConstraints` is set to false when it's set.
    public var wrappedValue: T {
        didSet {
            wrappedValue.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    /// Initializer for `SBUAutoLayout`.
    /// - Parameter wrappedValue: The UIView of type `T`. Its `translatesAutoresizingMaskIntoConstraints` is set to false when it's initialized.
    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
        wrappedValue.translatesAutoresizingMaskIntoConstraints = false
    }
}

/// `SBUThemeWrapper` is a property wrapper struct for theme.
/// It provides a way to set a default theme if no theme is provided.
@propertyWrapper
public struct SBUThemeWrapper<T> {
    /// The theme of type `T`. It's optional and can be nil.
    private var theme: T?

    /// The wrapped value of the theme. If no theme is provided, it returns the default theme.
    public var wrappedValue: T {
        // swiftlint:disable force_cast
        get { self.theme ?? SBUTheme.defaultTheme(currentClass: T.self) as! T }
        set { self.theme = newValue }
        // swiftlint:enable force_cast
    }

    /// Initializer for `SBUThemeWrapper`.
    /// - Parameters:
    ///   - theme: The theme of type `T`. It's optional and can be nil.
    ///   - setToDefault: A Boolean value that determines whether to set the theme to default.
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
    
    // NOTE: for cache value.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.value = try container.decode(T.self)
    }
    
    // NOTE: for cache value.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.value)
    }
}
