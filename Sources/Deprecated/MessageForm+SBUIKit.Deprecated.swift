//
//  MessageForm+SBUIKit.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 7/3/24.
//

import UIKit
import SendbirdChatSDK

extension BaseMessage {
    /// boolean to prevent duplicate message forms from being submitted
    /// - Since: 3.27.0
    @available(*, deprecated, message: "This property is deprecated in 3.34.1")
    public var isFormSubmitting: Bool {
        get { false }
        set { }
    }

    /// Tracks validation status of each form item to prevent duplicate submissions.
    /// (key: item id, value: validation status)
    /// - Since: 3.27.0
    @available(*, deprecated, message: "This property is deprecated in 3.34.1")
    public var formItemValidationStatus: [Int64: Bool] {
        get { [:] }
        set { }
    }
}

@available(*, deprecated, message: "This API is deprecated.")
extension MessageForm {
    /// boolean variable indicating whether the form has valid version.
    /// - Since: 3.27.0
    @available(*, deprecated, message: "This property is deprecated in 3.34.1")
    public var isValidVersion: Bool {
        version == 1
    }
}

@available(*, deprecated, message: "This API is deprecated.")
extension MessageFormItem.LayoutType {
    /// Keyboard type
    /// - Since: 3.27.0
    @available(*, deprecated, message: "This property is deprecated in 3.34.1")
    public var keyboardType: UIKeyboardType {
        switch self {
        case .text: return .default
        case .textarea: return .default
        case .number: return .numberPad
        case .phone: return .phonePad
        case .email: return .emailAddress
        case .chip: return .default
        case .unknown: return .default
        @unknown default: return .default
        }
    }
    
    /// Whether this layout is a text input type.
    @available(*, deprecated, message: "This property is deprecated in 3.34.1")
    public var isTextInputType: Bool {
        switch self {
        case .text: return true
        case .textarea: return true
        case .number: return true
        case .phone: return true
        case .email: return true
        case .chip: return false
        case .unknown: return false
        @unknown default: return false
        }
    }
}

@available(*, deprecated, message: "This API is deprecated.")
extension MessageFormItem.ResultCount {
    /// Method to check the max value of resultCount to see if values can be updated.
    /// - Parameter values: draft values.
    /// - Since: 3.27.0
    @available(*, deprecated, message: "This method is deprecated in 3.34.1")
    public func canUpdate(_ values: [String]) -> Bool {
        guard min != nil, let max = max else { return false }
        return values.count <= max
    }

    /// Method to check if values is a valid value by checking the min/max value of resultCount.
    /// - Parameter values: draft values.
    /// - Since: 3.27.0
    @available(*, deprecated, message: "This method is deprecated in 3.34.1")
    public func isValid(_ values: [String]) -> Bool {
        guard let min = min, let max = max else { return false }
        return values.count <= max && values.count >= min
    }

    /// A boolean to indicate whether the resultCount is a single-value result.
    /// - Since: 3.27.0
    @available(*, deprecated, message: "This property is deprecated in 3.34.1")
    public var isOnlyOne: Bool { max == 1 }
}
