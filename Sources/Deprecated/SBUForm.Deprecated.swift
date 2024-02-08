//
//  SBUForm.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/01/26.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendbirdChatSDK
import UIKit

/// Form data
/// - Since: 3.11.0
@available(*, unavailable, message: "Use `SendbirdChatSDK.Form`")
public struct SBUForm: Codable {
    public typealias FormData = [String: String]
    
    /// Unique key of form.
    public let formKey: String
    
    /// Indicates the input field data information array.
    public let fields: [SBUForm.Field]
    
    /// Indicates field data values that have been stored.
    public let data: FormData?
    
    /// List of messages that will be exposed after submission.
    public let messagesAfterSubmission: [String]?
    
    enum CodingKeys: String, CodingKey {
        case formKey = "key"
        case fields
        case data
        case messagesAfterSubmission = "messages_after_submission"
    }
    
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
    
    /// Input field data information.
    /// - Since: 3.11.0
    public struct Field: Codable {
        
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
        
        /// Updated field data model
        public struct Updated {
            /// Unique key of form
            public let formKey: String
            
            /// Unique key of field
            public let fieldKey: String
            
            /// Updated value
            public let value: String
        }
        
        /// Indicates the input type of the field.
        /// Can be used to specify the keyboard type.
        /// - Since: 3.11.0
        public enum InputTypeValue: String, Codable {
            case text // default value.
            case phone
            case email
            case password
            
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
        
        enum CodingKeys: String, CodingKey {
            case fieldKey = "key"
            case title
            case inputType = "input_type"
            case required
            case regex
            case placeholder
        }
    } // end field.
    
    /// The data model entered in the field
    public struct Answer {
        public let formKey: String
        public let data: FormData
        
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
}

extension SBUExtendedMessagePayload {
    /// Parsed array of `form`.
    @available(*, unavailable, message: "This model is no longer used internally. Changed to use `SendbirdChatSDK.Form`.")
    public var forms: [SBUForm]? { nil }
}

extension SBUUserMessageCellParams {
    /// The form answers are the data for the message cell to redraw each user's form field input.
    /// - Since: 3.11.0
    @available(*, unavailable, message: "This model is no longer used internally. Changed to use `SendbirdChatSDK.Form`.")
    public var formAnswers: [SBUForm.Answer] { [] }
}

extension SBUUserMessageCell {
    /// This is function to create and set up the `[SBUFormView]`.
    /// - Parameter forms: Form list data.
    /// - Parameter answers: Cached form answer datas.
    /// - Returns: If `true`, succeeds in creating a valid form view
    /// - since: 3.11.0
    @available(*, unavailable, message: "This model is no longer used internally. Changed to use `SendbirdChatSDK.Form`.")
    public func updateFormView(with forms: [SBUForm]?, answers: [SBUForm.Answer]) -> Bool { false }
}

extension SBUFormViewDelegate {
    /// Called when `form` is submitted.
    /// - Parameters:
    ///    - view: ``SBUFormView`` object.
    ///    - answer: the submitted ``SBUForm/Answer`` object.
    @available(*, unavailable, message: "This model is no longer used internally. Changed to use `SendbirdChatSDK.Form`.")
    func formView(_ view: SBUFormView, didSubmit answer: SBUForm.Answer) { }

    /// Called when `field` is updated.
    /// - Parameters:
    ///    - view: ``SBUFormView`` object.
    ///    - answer: the updated form answer data ``SBUForm/Answer`` object.
    @available(*, unavailable, message: "This model is no longer used internally. Changed to use `SendbirdChatSDK.Form`.")
    func formView(_ view: SBUFormView, didUpdate answer: SBUForm.Answer) { }
}

extension SBUFormFieldViewDelegate {
    /// Called when `SBUForm.Field` is updated.
    /// - Parameters:
    ///    - fieldView: The updated ``SBUFormFieldView`` object.
    ///    - updated: The updated data ``SBUForm/Field/Updated`` object.
    @available(*, unavailable, message: "This model is no longer used internally. Changed to use `SendbirdChatSDK.Form`.")
    func formFieldView(_ fieldView: SBUFormFieldView, didUpdate updated: SBUForm.Field.Updated) { }
}

extension SBUFormViewParams {
    @available(*, unavailable, message: "This model is no longer used internally. Changed to use `SendbirdChatSDK.Form`.")
    init(messageId: Int64, form: SBUForm) {
        fatalError("This model is no longer used internally. Changed to use `SendbirdChatSDK.Form`.")
    }
}

extension SBUFormView {
    /// Memory cached answer data.
    @available(*, unavailable, message: "This model is no longer used internally. Changed to use `SendbirdChatSDK.Form`.")
    public var answer: SBUForm.Answer? { nil }
    
    /// Creates ``SBUFormFieldView`` instances with ``SBUFormViewParams``.
    /// - Parameter forms: The array of ``SBUForm/Field``.
    /// - Returns: The array of ``SBUFormFieldView`` instances.
    @available(*, unavailable, message: "This model is no longer used internally. Changed to use `SendbirdChatSDK.Form`.")
    open func createFormFieldViews(with form: SBUForm?) -> [SBUFormFieldView] { [] }
    
    /// Called when a form field is updated.
    /// It invokes ``SBUFormFieldViewDelegate/formFieldView(_:didUpdate:)`
    @available(*, unavailable, message: "This model is no longer used internally. Changed to use `SendbirdChatSDK.Form`.")
    open func formFieldView(_ view: SBUFormFieldView, didUpdate updated: SBUForm.Field.Updated) { }
}

extension SBUFormFieldView {
    
    // MARK: - Configure
    /// Configure ``SBUFormFieldView`` with `field`.
    /// - Since: 3.11.0
    @available(*, unavailable, message: "This model is no longer used internally. Changed to use `SendbirdChatSDK.Form`.")
    open func configure(
        form: SBUForm,
        field: SBUForm.Field,
        value: String?,
        delegate: SBUFormFieldViewDelegate? = nil
    ) {
        fatalError("This model is no longer used internally. Changed to use `SendbirdChatSDK.Form`.")
    }
}

extension SBUGroupChannelModuleListDelegate {
    /// Called when submit the form answer.
    /// - Parameters:
    ///    - answer: The answer of the form that is submitted by user.
    ///    - messageCell: Message cell object
    /// - Since: 3.11.0
    @available(*, unavailable, message: "This model is no longer used internally. Changed to use `SendbirdChatSDK.Form`.")
    public func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, didSubmit answer: SBUForm.Answer, messageCell: SBUBaseMessageCell) { }

    /// Called when updated the form answer.
    /// - Parameters:
    ///    - answer: The answer of the form that is updated by user.
    ///    - messageCell: Message cell object
    /// - Since: 3.11.0
    @available(*, unavailable, message: "This model is no longer used internally. Changed to use `SendbirdChatSDK.Form`.")
    public func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, didUpdate answer: SBUForm.Answer, messageCell: SBUBaseMessageCell) { }
}

extension SBUGroupChannelViewController {
    @available(*, unavailable, message: "This model is no longer used internally. Changed to use `SendbirdChatSDK.Form`.")
    public func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, didSubmit answer: SBUForm.Answer, messageCell: SBUBaseMessageCell) { }

    @available(*, unavailable, message: "This model is no longer used internally. Changed to use `SendbirdChatSDK.Form`.")
    public func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, didUpdate answer: SBUForm.Answer, messageCell: SBUBaseMessageCell) { }
    
    @available(*, unavailable, message: "This model is no longer used internally. Changed to use `SendbirdChatSDK.Form`.")
    public func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, answersFor messageId: Int64?) -> [SBUForm.Answer]? { nil }
}

extension SBUFormFieldView.StatusType {
    @available(*, unavailable, message: "This model is no longer used internally. Changed to use `SendbirdChatSDK.Form`.")
    public init(form: SBUForm, field: SBUForm.Field, value: String?) {
        fatalError("This model is no longer used internally. Changed to use `SendbirdChatSDK.Form`.")
    }
}

extension SBUGroupChannelViewModel {
    
    // MARK: - Submit Form.
    /// This function is used to submit form data.
    /// - Parameters:
    ///   - message: `BaseMessage` object to submit form.
    ///   - answer: set form asnwer.
    /// - Since: 3.11.0
    @available(*, unavailable, message: "This model is no longer used internally. Changed to use `SendbirdChatSDK.Form`.")
    public func submitForm(message: BaseMessage, answer: SBUForm.Answer) { }
    
    // MARK: - Updated cached form data.
    /// This function is used to update cached form data.
    /// - Parameters:
    ///   - message: `BaseMessage` object to submit form.
    ///   - form: for updating reload form.
    ///   - answer: for updating asnwer.
    /// - Since: 3.11.0
    @available(*, unavailable, message: "This model is no longer used internally. Changed to use `SendbirdChatSDK.Form`.")
    public func updateForm(message: BaseMessage, answer: SBUForm.Answer) { }
}

extension SBUGroupChannelModuleListDataSource {
    /// Ask to data source to return the formData by messageId.
    /// - Parameters:
    ///   - listComponent: `SBUGroupChannelModule.List` object.
    ///   - formAnswerByMessageId: Specific message id.
    /// - Returns: `SBUForm.Answer` object.
    ///
    /// - Since: 3.11.0
    @available(*, unavailable, message: "This model is no longer used internally. Changed to use `SendbirdChatSDK.Form`.")
    public func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, answersFor messageId: Int64?) -> [SBUForm.Answer]? { nil }
}
