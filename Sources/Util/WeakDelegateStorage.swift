//
//  WeakDelegateStorage.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 10/31/24.
//

import Foundation

enum WeakDelegateType: String {
    case uikit = "UIKitDelegate"
    case swiftui = "SwiftUIDelegate"
}

class WeakDelegate {
    weak var value: AnyObject?
    
    init(value: AnyObject? = nil) {
        self.value = value
    }
}

class WeakDelegateStorage<T> {
    var delegates = [String: Any]()
}

extension WeakDelegateStorage {
    func addDelegate(_ delegate: T?, type: WeakDelegateType) {
        delegates[type.rawValue] = WeakDelegate(value: delegate as? AnyObject)
    }
    
    func forEach(_ closure: (T) -> Void) {
        delegates
            .values
            .compactMap { $0 as? WeakDelegate }
            .forEach {
                if let value = $0.value as? T {
                    closure(value)
                }
            }
    }
    
    func allKeys() -> [WeakDelegateType] {
        delegates.keys.compactMap { WeakDelegateType(rawValue: $0) }
    }
    
    func allKeyValuePairs() -> [(WeakDelegateType, T)] {
        delegates.compactMap { delegate in
            if let key = WeakDelegateType(rawValue: delegate.key),
               let value = (delegate.value as? WeakDelegate)?.value as? T {
                return (key, value)
            } else {
                return nil
            }
        }
    }
}
