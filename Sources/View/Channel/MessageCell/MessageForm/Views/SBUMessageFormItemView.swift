//
//  SBUMessageFormItemView.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/07/02.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// delegate for forwarding events from the form item
/// - Since: 3.27.0
public protocol SBUMessageFormItemViewDelegate: AnyObject {
    /// Called when `MessageFormItem` is updated.
    /// - Parameters:
    ///    - itemView: The updated ``SBUMessageFormItemView`` object.
    ///    - formItem: The updated ``SendbirdChatSDK.MessageFormItem`` object.
    func messageFormItemView(_ itemView: SBUMessageFormItemView, didUpdate formItem: SendbirdChatSDK.MessageFormItem)
    
    /// Called when `MessageFormItem` is validation checked.
    /// - Parameters:
    ///    - itemView: The updated ``SBUMessageFormItemView`` object.
    ///    - formItem: The updated ``SendbirdChatSDK.MessageFormItem`` object.
    func messageFormItemView(_ itemView: SBUMessageFormItemView, didCheckedValidation formItem: SendbirdChatSDK.MessageFormItem)
}

/// The base view that holds the data for the form item.
/// - Since: 3.27.0
open class SBUMessageFormItemView: SBUView {
    // MARK: - Properties
    
    /// The theme for ``SBUMessageFormItemView`` that is type of ``SBUMessageCellTheme``.
    public var theme: SBUMessageCellTheme = SBUTheme.messageCellTheme
    
    /// The id of the ``MessageForm``.
    /// To update the data, use ``SBUMessageFormItemView/configure(form:item:didValidation:delegate:)``.
    /// - Since: 3.27.0
    public private(set) var formId: Int64?
    
    /// The formItem of the ``MessageForm``.
    /// To update the data, use ``SBUMessageFormItemView/configure(form:item:didValidation:delegate:)``.
    /// - Since: 3.27.0
    public private(set) var formItem: SendbirdChatSDK.MessageFormItem?
    
    /// The validation status of the ``MessageForm``.
    /// To update the data, use ``SBUMessageFormItemView/configure(form:item:didValidation:delegate:)``.
    public var didValidation: Bool = false {
        didSet {
            guard didValidation == true else { return }
            guard let item = self.formItem else { return }
            self.delegate?.messageFormItemView(self, didCheckedValidation: item)
        }
    }
    
    /// The status of the ``MessageForm``.
    /// Include value of item.
    /// To update the data, use ``SBUMessageFormItemView/configure(form:item:didValidation:delegate:)``.
    public var status: StatusType = .unknown
    
    /// The delegate that is type of ``SBUMessageFormItemViewDelegate``
    /// ```swift
    /// view.delegate = self // `self` conforms to `SBUMessageFormItemViewDelegate`
    /// ```
    public weak var delegate: SBUMessageFormItemViewDelegate?
    
    // MARK: - Configure
    /// Configure ``SBUMessageFormItemView`` with `item`.
    open func configure(
        form: SendbirdChatSDK.MessageForm,
        item: SendbirdChatSDK.MessageFormItem,
        didValidation: Bool,
        delegate: SBUMessageFormItemViewDelegate? = nil
    ) {
        self.formId = form.id
        self.formItem = item
        self.didValidation = didValidation
        self.status = StatusType(form: form, item: item)
        self.delegate = delegate

        self.setupViews()
        self.setupLayouts()
        self.setupStyles()
        self.setupActions()
    }
}

extension SBUMessageFormItemView {
    /// Attributed string for displaying the title of the item view. Also includes whether it is optional
    public var titleAttributedString: NSAttributedString {
        let title = NSMutableAttributedString()
        title.append(NSAttributedString(
            string: self.formItem?.name ?? "",
            attributes: [
                .foregroundColor: theme.formTitleColor,
                .font: theme.formTitleFont
            ]
        ))
        title.append(NSAttributedString(
            string: self.formItem?.required == false ? " " : ""
        ))
        title.append(NSAttributedString(
            string: self.formItem?.required == false ? SBUStringSet.FormType_Optional : "",
            attributes: [
                .foregroundColor: theme.formOptionalTitleColor,
                .font: theme.formOptionalTitleFont
            ]
        ))
        return title
    }
}

extension SBUMessageFormItemView {
    /// Enum model to indicate the error type of the input value.
    /// - Since: 3.27.0
    public enum InputErrorType {
        /// Represents a required item error.
        case required
        /// Represents a invalid value error.
        case invalid
        /// none error.
        case none
        
        var hasError: Bool {
            switch self {
            case .invalid: return true
            case .required: return true
            default: return false
            }
        }
        
        var errorMessage: String {
            switch self {
            case .invalid: return SBUStringSet.FormType_Error_Default
            case .required: return SBUStringSet.FormType_Error_Required
            default: return SBUStringSet.FormType_Error_Default
            }
        }
    }
}

extension SBUMessageFormItemView {
    /// Enum model to indicate the status of the value in the currently entered item.
    /// - Since: 3.27.0
    public enum StatusType {
        /// Represents a completed form item with a value.
        case done(values: [String])
        /// Represents an optional form item.
        case optional
        /// Represents a form item that is currently being edited with a value.
        case editing(values: [String]?)
        /// Represents an unknown form item status.
        case unknown
        
        /// init
        /// - Parameters:
        ///   - form: form data
        ///   - item: form item
        ///   - value: user input value
        public init(
            form: SendbirdChatSDK.MessageForm,
            item: SendbirdChatSDK.MessageFormItem
        ) {
            guard form.isSubmitted == true else {
                self = .editing(values: item.draftValues)
                return
            }

            if let values = item.submittedValues?.compactMap({ $0.hasElements ? $0 : nil }), values.hasElements {
                self = .done(values: values)
            } else {
                self = .optional
            }
        }
        
        mutating func edting(item: MessageFormItem) {
            guard isEditable == true else { return }
            self = .editing(values: item.draftValues)
        }

        /// The text property represents the current text value of the form item.
        public var text: String? {
            switch self {
            case .done(let values): return values.first
            case .editing(let values): return values?.first
            case .optional: return SBUStringSet.FormType_No_Reponse
            case .unknown: return nil
            }
        }

        /// The isDone property represents whether the form item has been completed.
        public var isDone: Bool {
            switch self {
            case .done: return true
            default: return false
            }
        }
        
        /// The didSubmit property represents whether the form has been submitted.
        public var didSubmit: Bool {
            switch self {
            case .done: return true
            case .optional: return true
            default: return false
            }
        }

        /// The isOptional property represents whether the form item is optional.
        public var isOptional: Bool {
            switch self {
            case .optional: return true
            default: return false
            }
        }

        /// The isEditable property represents whether the form item is editable.
        public var isEditable: Bool {
            switch self {
            case .editing:  return true
            case .unknown:  return true
            case .done:     return false
            case .optional: return false
            }
        }
    }
}
