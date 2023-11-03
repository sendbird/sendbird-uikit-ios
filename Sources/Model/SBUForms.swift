//
//  SBUForms.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2023/10/23.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendbirdChatSDK
import UIKit

/// Form data
/// - Since: 3.11.0
public struct SBUForm {
    
    /// Unique key of form.
    public let formKey: String
    
    /// Indicates the input field data information array.
    public let fields: [SBUForm.Field]
    
    /// Indicates field data values that have been stored.
    public let data: FormData?
    
    /// List of messages that will be exposed after submission.
    public let messagesAfterSubmission: [String]?
}

extension SBUForm {
    public typealias FormData = [String: String]
}

extension SBUForm {
    class Cache {
        var messageId: Int64
        var forms: [SBUForm]
        var answers: [SBUForm.Answer]
        
        init?(message: BaseMessage) {
            guard let forms = message.asForms else { return nil }
            self.messageId = message.messageId
            self.forms = forms
            self.answers = []
        }
    }    
}

extension SBUForm {
    
    /// Input field data information.
    /// - Since: 3.11.0
    public struct Field {
        
        /// Unique key of field
        public let fieldKey: String
        
        /// Title
        public let title: String
        
        /// Input type
        public let inputType: String
        
        /// Indicate whether the field is required or not
        public let required: Bool
        public let regex: String?
        public let placeholder: String?
    }
}

extension SBUForm {
    /// The data model entered in the field
    public struct Answer {
        public let formKey: String
        public let data: FormData
    }
}

extension SBUForm.Field {
    /// Updated field data model
    public struct Updated {
        /// Unique key of form
        public let formKey: String
        
        /// Unique key of field
        public let fieldKey: String
        
        /// Updated value
        public let value: String
        
    }
}

extension SBUForm.Field {
    /// Indicates the input type of the field.
    /// Can be used to specify the keyboard type.
    /// - Since: 3.11.0
    public enum InputTypeValue: String, Codable {
        case text // default value.
        case phone
        case email
        case password
    }
}

// extension features
extension SBUForm.Cache {
    func updateForms(with forms: [SBUForm]?) {
        guard let forms = forms else { return }
        self.forms = forms
    }

    func updateAnswer(with answer: SBUForm.Answer?) {
        guard let answer = answer else { return }
        self.answers = answers.reduce(into: [SBUForm.Answer]()) { result, old in
            result.append(old.formKey == answer.formKey ? answer : old)
        }
    }
}

extension SBUForm {
    
    /// Indicates that the form data has already been submitted.
    public var isSubmitted: Bool {
        for field in self.fields {
            if let _ = self.data?[field.fieldKey] { continue }
            if field.required == false { continue }
            return false
        }
        return true
    }
    
    /// Indicates that the form data can be submitted.
    /// - Parameter answer: The currently entered answer value.
    /// - Returns: If `true`, can be submitted
    public func canSubmit(with answer: SBUForm.Answer?) -> Bool {
        guard let answer = answer else { return false }

        for field in self.fields {
            let value = answer.data[field.fieldKey]
            if field.isValid(with: value, isStrict: true) { continue }
            if field.required == false { continue }
            return false
        }
        return true
    }
}

extension SBUForm.Answer {
    /// Function that takes in an updated value and returns a new `answer`.
    /// - Parameter updated: Updated data.
    /// - Returns: Returns the updated `answer`. If `nil`, no update is required.
    public func update(with updated: SBUForm.Field.Updated) -> SBUForm.Answer? {
        guard self.formKey == updated.formKey else { return nil }
        var updatedData = self.data
        updatedData[updated.fieldKey] = updated.value
        return SBUForm.Answer(formKey: self.formKey, data: updatedData)
    }
}

extension SBUForm.Field {
    
    /// Input type value
    public var inputTypeValue: InputTypeValue { .init(rawValue: self.inputType.lowercased()) ?? .text }

    /// Functions to check if the entered value is valid.
    /// - Parameters:
    ///   - value: The value entered in the field.
    ///   - isStrict: Determines whether empty values should be processed.
    /// - Returns: If `true`, it is a valid value
    public func isValid(with value: String?, isStrict: Bool = false) -> Bool {
        let value = value ?? ""

        if isStrict == false { // pass empty or nil value.
            if value.isEmpty { return true }
        }

        guard let regex = self.regex, !regex.isEmpty else { return value.count > 0 }
        guard let _ = value.range(of: regex, options: .regularExpression) else { return false }
        return true
    }
}

extension SBUForm.Field.InputTypeValue {
    
    /// Keyboard type
    public var keyboardType: UIKeyboardType {
        switch self {
        case .text: return .default
        case .phone: return UIKeyboardType.phonePad
        case .email: return UIKeyboardType.emailAddress
        case .password: return .default
        }
    }
    
    /// Indicates if the text is captcha for the keyboard.
    public var isSecureText: Bool { self == .password }
}

// extension codable
extension SBUForm: Codable {
    enum CodingKeys: String, CodingKey {
        case formKey = "key"
        case fields
        case data
        case messagesAfterSubmission = "messages_after_submission"
    }
}

extension SBUForm.Field: Codable {
    enum CodingKeys: String, CodingKey {
        case fieldKey = "key"
        case title
        case inputType = "input_type"
        case required
        case regex
        case placeholder
    }
}
