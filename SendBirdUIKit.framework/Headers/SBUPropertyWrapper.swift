//
//  SBUPropertyWrapper.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 12/02/2020.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
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
