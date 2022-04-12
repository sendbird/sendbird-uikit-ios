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
