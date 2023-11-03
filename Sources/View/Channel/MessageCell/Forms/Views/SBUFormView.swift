//
//  SBUFormView.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2023/10/23.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// - Since: 3.11.0
public protocol SBUFormViewDelegate: AnyObject {
    /// Called when `form` is submitted.
    /// - Parameters:
    ///    - view: ``SBUFormView`` object.
    ///    - answer: the submitted ``SBUForm/Answer`` object.
    func formView(_ view: SBUFormView, didSubmit answer: SBUForm.Answer)

    /// Called when `field` is updated.
    /// - Parameters:
    ///    - view: ``SBUFormView`` object.
    ///    - answer: the updated form answer data ``SBUForm/Answer`` object.
    func formView(_ view: SBUFormView, didUpdate answer: SBUForm.Answer)
}

/// - Since: 3.11.0
open class SBUFormView: SBUView, SBUFormFieldViewDelegate {
    public var theme: SBUMessageCellTheme = SBUTheme.messageCellTheme
    
    /// (Read-only) The form from ``SBUFormViewParams``
    public var form: SBUForm? { params?.form }
    
    /// (Read-only) The message ID for quick reply which is from ``SBUFormViewParams``
    public var messageId: Int64? { params?.messageId }
    
    /// (Read-only) The data structure for ``SBUFormViewParams``. Please use ``configure(with:delegate:)`` to update ``params``
    public private(set) var params: SBUFormViewParams?
    
    /// Instances of the created field views. Can be `nil`.
    public var fieldViews: [SBUFormFieldView]?
    
    /// Memory cached answer data.
    public var answer: SBUForm.Answer?
    
    /// The delegate that is type of ``SBUFormViewDelegate``
    public weak var delegate: SBUFormViewDelegate?
    
    /// Updates UI with ``SBUFormViewParams`` object and ``SBUFormViewDelegate``.
    /// - Parameters:
    ///    - configuration: ``SBUFormViewParams`` object.
    ///    - delegate: ``SBUFormViewDelegate``, the delegate object that handles the form field event sent by ``SBUFormFieldViewDelegate``.
    /// - Note: This method updates ``params`` and ``delegate`` then, calls ``setupViews()``, ``setupLayouts()`` and ``setupStyles()``
    open func configure(with configuration: SBUFormViewParams, delegate: SBUFormViewDelegate? = nil) {
        self.params = configuration
        let form = configuration.form
        self.answer = SBUForm.Answer(formKey: form.formKey, data: form.data ?? [:])
        self.delegate = delegate
        
        self.setupViews()
        self.setupLayouts()
        self.setupStyles()
    }
    
    /// Method to return a view that inherits from ``SBUFormFieldView``.
    /// The parent class contains only data.
    open func createFieldView() -> SBUFormFieldView { SBUSimpleFormFieldView() }
    
    /// Creates ``SBUFormFieldView`` instances with ``SBUFormViewParams``.
    /// - Parameter forms: The array of ``SBUForm/Field``.
    /// - Returns: The array of ``SBUFormFieldView`` instances.
    open func createFormFieldViews(with form: SBUForm?) -> [SBUFormFieldView] {
        guard let form = form else { return [] }
        let answerData = self.answer?.data
        return form.fields.compactMap { field in
            let view = createFieldView()
            view.configure(form: form,
                           field: field,
                           value: answerData?[field.fieldKey],
                           delegate: self)
            return view
        }
    }
    
    // MARK: `SBUFormFieldViewDelegate``
    
    /// Called when a form field is updated.
    /// It invokes ``SBUFormFieldViewDelegate/formFieldView(_:didUpdate:)`
    open func formFieldView(_ view: SBUFormFieldView, didUpdate updated: SBUForm.Field.Updated) {
        guard let answer = self.answer?.update(with: updated) else { return }

        self.answer = answer
        self.delegate?.formView(self, didUpdate: answer)
        self.setupStyles()
    }
}

/// - Since: 3.11.0
open class SBUSimpleFormView: SBUFormView {
    // views
    
    /// A container view to wrap `stackView`.
    public var container: UIView = UIView()
    /// A vertical stack view to configure layouts of the forms.
    public var stackView: UIStackView = SBUStackView(axis: .vertical, alignment: .fill, spacing: 12)
    /// The `UIButton` displaying the submit button.
    public var submitButton: UIButton = UIButton()
    
    // MARK: - Sendbird UIKit Life Cycle
    
    open override func setupViews() {
        super.setupViews()
        
        // + ---- stackView ---- +
        // |    [fieldViews]     |
        // + ------------------- +
        // |    submitButton     |
        // + ------------------- +
        
        let fieldViews = self.createFormFieldViews(with: self.form)
        self.stackView.setVStack(fieldViews)
        self.fieldViews = fieldViews
        
        self.stackView.addArrangedSubview(self.submitButton)
        self.container.addSubview(self.stackView)
        self.addSubview(self.container)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        self.stackView
            .sbu_constraint(equalTo: self.container, left: 12, right: 12, top: 16, bottom: 16)
        
        self.submitButton
            .sbu_constraint(height: 36)
        
        self.container
            .sbu_constraint(width: 244)
            .sbu_constraint(equalTo: self, leading: 0, trailing: 0, top: 0, bottom: 0)
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
        self.container.backgroundColor = theme.formBackgroundColor
        self.container.layer.cornerRadius = 16
        
        self.submitButton.setTitle(SBUStringSet.Submit, for: .normal)
        self.submitButton.titleLabel?.font = SBUFontSet.button3
        self.submitButton.layer.cornerRadius = 6
        self.submitButton.setTitleColor(theme.formSubmitButtonTitleColor, for: .normal)
        self.submitButton.setBackgroundImage(UIImage.from(color: theme.formSubmitButtonBackgroundColor), for: .normal)
        self.submitButton.setBackgroundImage(UIImage.from(color: theme.formSubmitButtonBackgroundDisabledColor), for: .disabled)
        self.submitButton.clipsToBounds = true
        self.submitButton.isHidden = (self.form?.isSubmitted == true)
        self.submitButton.isEnabled = (self.form?.canSubmit(with: self.answer) == true)
    }
    
    open override func setupActions() {
        super.setupActions()
        
        self.submitButton.addTarget(self, action: #selector(onSubmit), for: .touchUpInside)
    }
    
    @objc
    open func onSubmit() {
        guard let formKey = self.form?.formKey else { return }
        guard let answer = self.answer, answer.formKey == formKey else { return }
        
        self.delegate?.formView(self, didSubmit: answer)
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}
