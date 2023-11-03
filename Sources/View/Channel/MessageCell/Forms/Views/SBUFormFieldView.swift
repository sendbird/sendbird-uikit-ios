//
//  SBUFormFieldView.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2023/10/23.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// - Since: 3.11.0
public protocol SBUFormFieldViewDelegate: AnyObject {
    /// Called when `SBUForm.Field` is updated.
    /// - Parameters:
    ///    - fieldView: The updated ``SBUFormFieldView`` object.
    ///    - updated: The updated data ``SBUForm/Field/Updated`` object.
    func formFieldView(_ fieldView: SBUFormFieldView, didUpdate updated: SBUForm.Field.Updated)
}

/// - Since: 3.11.0
public class SBUFormFieldView: SBUView, UITextFieldDelegate {
    // MARK: - Properties
    
    /// The theme for ``SBUFormFieldView`` that is type of ``SBUMessageCellTheme``.
    public var theme: SBUMessageCellTheme = SBUTheme.messageCellTheme
    
    /// The key of the ``SBUForm``.
    /// To update the data, use ``SBUFormFieldView/configure(form:field:value:delegate:)``.
    public private(set) var formKey: String?

    /// The field of the ``SBUForm``.
    /// To update the data, use ``SBUFormFieldView/configure(form:field:value:delegate:)``.
    public private(set) var field: SBUForm.Field?
    
    /// The status of the ``SBUForm``.
    /// Include value of field.
    /// To update the data, use ``SBUFormFieldView/configure(form:field:value:delegate:)``.
    public var status: StatusType = .unknown
    
    /// The delegate that is type of ``SBUFormFieldViewDelegate``
    /// ```swift
    /// view.delegate = self // `self` conforms to `SBUFormFieldViewDelegate`
    /// // or
    /// view.configure(formKey: "Another Key", field: anotherField, data: "data", value: "value", delegate: self)
    /// ```
    public weak var delegate: SBUFormFieldViewDelegate?
    
    // MARK: - Configure
    /// Configure ``SBUFormFieldView`` with `field`.
    /// - Since: 3.11.0
    open func configure(
        form: SBUForm,
        field: SBUForm.Field,
        value: String?,
        delegate: SBUFormFieldViewDelegate? = nil
    ) {
        self.formKey = form.formKey
        self.field = field
        self.status = StatusType(form: form, field: field, value: value)
        self.delegate = delegate

        self.setupViews()
        self.setupLayouts()
        self.setupStyles()
        self.setupActions()
    }
}

/// - Since: 3.11.0
public class SBUSimpleFormFieldView: SBUFormFieldView {
    
    /// A vertical stack view to configure layouts of the fields.
    public var stackView = SBUStackView(axis: .vertical, alignment: .leading, spacing: 0)
    /// A horizontal stack view to configure layouts of `title` and `optional`.
    public var titleStackView = SBUStackView(axis: .horizontal, alignment: .fill, spacing: 3)
    /// The `UILabel` displaying form field title.`
    public var titleView = UILabel()
    /// The `UILabel` displaying the `(optional)`.
    public var optionalTitleView = UILabel()
    /// Top space view.
    public var topSpaceView = UIView()
    /// A container view to wrap `inputStackView`.
    public var inputContainer = UIView()
    /// A horizontal stack view to configure layouts of `input field` and `input icon`.
    public var inputStackView = SBUStackView(axis: .horizontal, alignment: .trailing, spacing: 0)
    /// The `UITextField` for displaying and interacting with the input form field.
    public var inputFieldView = UITextField()
    /// The `UIImageView` for displaying input completion icons.
    public var inputIconView = UIImageView()
    /// Bottom space view. can be hidden. Used only if there is an error message.
    public var bottomSpaceView = UIView()
    /// The `UILabel` displaying the error message.
    public var errorTitleView = UILabel()

    // MARK: - Sendbird UIKit Life Cycle
    open override func setupViews() {
        super.setupViews()

        // + -- stackView ------------------------- +
        // | + --- titleStackView --------------- + |
        // | | titleView | optionalView           | |
        // | + ---------------------------------- + |
        // + -------------------------------------- +
        // | topSpaceView                           |
        // + -------------------------------------- +
        // | + -- inputContainer ---------------- + |
        // | | +---- inputStackView ----------- + | |
        // | | | inputFieldView | inputIconView | | |
        // | | +------------------------------- + | |
        // | + ---------------------------------- + |
        // + -------------------------------------- +
        // | bottomSpaceView                        |
        // + -------------------------------------- +
        // | errorTitleView                         |
        // + -------------------------------------- +
        self.inputIconView.isHidden = true

        self.titleStackView.setHStack([self.titleView, self.optionalTitleView])
        self.inputStackView.setHStack([self.inputFieldView, self.inputIconView])

        self.inputContainer.addSubview(inputStackView)

        self.stackView.setVStack([
            self.titleStackView,
            self.topSpaceView,
            self.inputContainer,
            self.bottomSpaceView,
            self.errorTitleView
        ])
        
        self.inputFieldView.delegate = self

        self.addSubview(stackView)
        
        self.titleView.text = self.field?.title

        self.optionalTitleView.text = SBUStringSet.FormType_Optional
        self.optionalTitleView.isHidden = self.field?.required ?? true

        self.errorTitleView.text = SBUStringSet.FormType_Error_Default

        self.inputFieldView.placeholder = self.field?.placeholder
        self.inputFieldView.text = self.status.text
        self.inputFieldView.keyboardType = self.field?.inputTypeValue.keyboardType ?? .default
        self.inputFieldView.isSecureTextEntry = self.field?.inputTypeValue.isSecureText ?? false
    }

    open override func setupLayouts() {
        super.setupLayouts()

        self.titleView.sbu_constraint(height: 12)
        self.optionalTitleView.sbu_constraint(height: 12)
        
        self.errorTitleView.sbu_constraint(height: 12)

        self.topSpaceView.sbu_constraint(width: 1, height: 8)
        self.bottomSpaceView.sbu_constraint(width: 1, height: 4)

        self.inputFieldView
            .sbu_constraint(height: 20)

        self.inputIconView
            .sbu_constraint(width: 20, height: 20)

        self.inputStackView
            .sbu_constraint(equalTo: self.inputContainer, left: 12, top: 8)
            .sbu_constraint(equalTo: self.inputContainer, right: 12, bottom: 8)

        self.inputContainer
            .sbu_constraint(equalTo: self.stackView, left: 0, right: 0)
            .sbu_constraint(height: 36, priority: .defaultHigh)
        
        self.stackView
            .sbu_constraint(equalTo: self, left: 0, top: 0)
            .sbu_constraint(equalTo: self, right: 0, bottom: 0, priority: .defaultHigh)
    }

    open override func setupStyles() {
        super.setupStyles()

        self.titleView.font = SBUFontSet.caption3
        self.titleView.textColor = theme.formTitleColor

        self.optionalTitleView.font = SBUFontSet.caption3
        self.optionalTitleView.textColor = theme.formOptionalTitleColor

        self.errorTitleView.font = SBUFontSet.caption4
        self.errorTitleView.textColor = theme.formInputErrorColor

        self.inputFieldView.font = SBUFontSet.body3
        self.inputFieldView.textColor = theme.formInputTitleColor
        self.inputFieldView.setPlaceholderColor(theme.formInputPlaceholderColor)
        self.inputFieldView.textAlignment = .left
        self.inputFieldView.borderStyle = .none

        self.inputContainer.layer.borderColor = theme.formInputBorderNormalColor.cgColor
        self.inputContainer.layer.borderWidth = 1.0
        self.inputContainer.layer.cornerRadius = 6
        self.inputContainer.backgroundColor = self.status.isDone ? theme.formInputBackgroundDoneColor : theme.formInputBackgroundColor

        self.inputIconView.image = SBUIconSet.iconDone.sbu_with(tintColor: theme.formInputIconColor)

        self.updateInputValidation()
        self.updateInputData()
    }

    open override func setupActions() {
        super.setupActions()
        
        self.inputFieldView.addTarget(self, action: #selector(onChangeFieldValue(textField:)), for: .editingChanged)
    }

    /// Calls ``SBUFormFieldViewDelegate/formFieldView(_:didUpdate:)``
    /// - Since: 3.11.0
    @objc
    open func onChangeFieldValue(textField: UITextField) {
        guard self.status.isEditable == true else { return }
        guard let formKey = formKey, let field = field else { return }

        self.status = .editing(value: textField.text)
        let updated = SBUForm.Field.Updated(formKey: formKey, fieldKey: field.fieldKey, value: textField.text ?? "")
        self.delegate?.formFieldView(self, didUpdate: updated)

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    open func updateInputValidation() {
        self.bottomSpaceView.isHidden = true
        self.errorTitleView.isHidden = true

        switch (self.status.isEditable, field?.isValid(with: self.status.text)) {
        case (false, _):
            self.inputContainer.layer.borderColor = UIColor.clear.cgColor
        case (_, true):
            self.inputContainer.layer.borderColor = theme.formInputBorderNormalColor.cgColor
        case (_, false):
            self.inputContainer.layer.borderColor = theme.formInputErrorColor.cgColor
            self.errorTitleView.isHidden = false
            self.bottomSpaceView.isHidden = false
        default:
            self.inputContainer.layer.borderColor = UIColor.clear.cgColor
        }
    }

    open func updateInputData() {
        self.inputFieldView.text = self.status.text
        self.inputFieldView.isEnabled = self.status.isEditable
        self.inputIconView.isHidden = self.status.isEditable
        self.isHidden = self.status.isOptional
    }

}

extension SBUFormFieldView {
    /// Enum model to indicate the status of the value in the currently entered field.
    /// - Since: 3.11.0
    public enum StatusType {
        case done(value: String)
        case optional
        case editing(value: String?)
        case unknown

        public init(form: SBUForm, field: SBUForm.Field, value: String?) {
            guard let data = form.data, data.count > 0 else {
                self = .editing(value: value)
                return
            }

            if let done = form.data?[field.fieldKey], done.isEmpty == false {
                self = .done(value: done)
            } else {
                self = .optional
            }
        }

        public var text: String? {
            switch self {
            case .done(let value): return value
            case .editing(let value): return value
            case .optional: return nil
            case .unknown: return nil
            }
        }

        public var isDone: Bool {
            switch self {
            case .done: return true
            default: return false
            }
        }

        public var isOptional: Bool {
            switch self {
            case .optional: return true
            default: return false
            }
        }

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
