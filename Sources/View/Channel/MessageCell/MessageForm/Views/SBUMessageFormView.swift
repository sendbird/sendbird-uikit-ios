//
//  SBUMessageFormView.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/07/02.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// delegate for forwarding events from the form.
/// - Since: 3.27.0
public protocol SBUMessageFormViewDelegate: AnyObject {
    /// Called when `messageForm` is submitted.
    /// - Parameters:
    ///    - view: ``SBUMessageFormView`` object.
    ///    - draft: the submitted ``SendbirdChatSDK.MessageForm`` object.
    func messageFormView(_ view: SBUMessageFormView, didSubmit form: SendbirdChatSDK.MessageForm)
    
    /// Called the validation status of the `MessageFormItem`
    /// - Parameters:
    ///    - view: ``SBUMessageFormView`` object.
    ///    - didUpdateValidationStatus: Validation status of form items (key: item number, value: validation status)
    func messageFormView(_ view: SBUMessageFormView, didUpdateValidationStatus: [Int64: Bool])
    
    /// Called when the view frame of the `MessageFormView` is changed.
    /// - Parameters:
    ///    - view: ``SBUMessageFormView`` object.
    ///    - didUpdateLayoutSize: Updated form view frame.
    func messageFormView(_ view: SBUMessageFormView, didUpdateViewFrame: CGRect)
}

/// Basic message form view
/// - Since: 3.27.0
open class SBUMessageFormView: SBUView, SBUMessageFormItemViewDelegate {
    public var theme: SBUMessageCellTheme = SBUTheme.messageCellTheme
    
    /// (Read-only) The form from ``SBUMessageFormViewParams``
    /// - Since: 3.27.0
    public var messageForm: SendbirdChatSDK.MessageForm? { params?.messageForm }
    
    /// (Read-only) The message ID for quick reply which is from ``SBUMessageFormViewParams``
    public var messageId: Int64? { params?.messageId }
    
    /// (Read-only) The data structure for ``SBUMessageFormViewParams``. Please use ``configure(with:delegate:)`` to update ``params``
    public private(set) var params: SBUMessageFormViewParams?
    
    /// Instances of the created item views. Can be `nil`.
    public var itemViews: [SBUMessageFormItemView]?
    
    /// Tracks validation status of each form item to prevent duplicate submissions.
    public var itemValidationStatus: [Int64: Bool] = [:]
    
    /// The delegate that is type of ``SBUMessageFormViewDelegate``
    public weak var delegate: SBUMessageFormViewDelegate?
    
    var currentBounds: CGRect = .zero
    
    /// Updates UI with ``SBUMessageFormViewParams`` object and ``SBUMessageFormViewDelegate``.
    /// - Parameters:
    ///    - configuration: ``SBUMessageFormViewParams`` object.
    ///    - delegate: ``SBUMessageFormViewDelegate``, the delegate object that handles the form item event sent by ``SBUMessageFormItemViewDelegate``.
    /// - Note: This method updates ``params`` and ``delegate`` then, calls ``setupViews()``, ``setupLayouts()`` and ``setupStyles()``
    open func configure(with configuration: SBUMessageFormViewParams, delegate: SBUMessageFormViewDelegate? = nil) {
        self.params = configuration
        self.delegate = delegate
        self.itemValidationStatus = configuration.itemValidationStatus
        
        self.setupViews()
        self.setupLayouts()
        self.setupStyles()
    }
    
    /// Method to return a view that inherits from ``SBUMessageFormItemView``.
    /// The parent class contains only data.
    open func createItemView(_ item: MessageFormItem) -> SBUMessageFormItemView? {
        switch item.style.layout {
        case .chip:
            return SBUMessageFormChipsItemView()
        case .textarea:
            return SBUMessageFormMultiTextItemView()
        case .text, .email, .number, .phone:
            return SBUMessageFormSingleTextItemView()
        case .unknown:
            return nil
        }
    }
    
    /// Creates ``SBUMessageFormItemView`` instances with ``SBUMessageFormViewParams``.
    /// - Parameter forms: The array of ``SBUMessageForm``.
    /// - Returns: The array of ``SBUMessageFormItemView`` instances.
    /// - Since: 3.27.0
    open func createFormItemViews(with form: SendbirdChatSDK.MessageForm?) -> [SBUMessageFormItemView] {
        guard let form = form else { return [] }
        return form.items.compactMap { item in
            let view = createItemView(item)
            view?.configure(
                form: form,
                item: item,
                didValidation: itemValidationStatus[item.id] ?? false,
                delegate: self
            )
            return view
        }
    }
    
    // MARK: `SBUMessageFormItemViewDelegate``
    
    /// Called when a form item is updated.
    /// It invokes ``SBUMessageFormItemViewDelegate/messageFormItemView(_:didUpdate:)`
    open func messageFormItemView(_ itemView: SBUMessageFormItemView, didUpdate formItem: MessageFormItem) {
        self.setupStyles()
    }
    
    /// Called when `MessageFormItem` is validation checked.
    /// It invokes ``SBUMessageFormItemViewDelegate/messageFormItemView(_:didUpdateValidationStatus:)`
    open func messageFormItemView(_ itemView: SBUMessageFormItemView, didCheckedValidation formItem: MessageFormItem) {
        self.itemValidationStatus.updateValue(true, forKey: formItem.id)
        self.delegate?.messageFormView(self, didUpdateValidationStatus: self.itemValidationStatus)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        guard self.currentBounds != self.bounds else { return }
        
        self.currentBounds = self.bounds
        
        self.delegate?.messageFormView(self, didUpdateViewFrame: self.bounds)
    }
    
    /// Method called when the form is submitted.
    /// If submit is not possible, treat all form items as having validation checked once
    /// If submit is successful, proceed with the submit flow
    /// - Returns: Boolean if submit went successfully
    @objc
    open func onSubmit() -> Bool {
        defer {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
        guard let form = self.messageForm else { return false }
        
        guard form.canSubmit == true else {
            for item in form.items {
                if let itemView = itemViews?.first(where: { $0.formId == item.id }) {
                    itemView.didValidation = true
                    itemView.setNeedsLayout()
                }
                self.itemValidationStatus.updateValue(true, forKey: item.id)
            }
            self.delegate?.messageFormView(self, didUpdateValidationStatus: self.itemValidationStatus)
            self.setupViews()
            return false
        }
        
        self.delegate?.messageFormView(self, didSubmit: form)
        return true
    }
}

/// - Since: 3.27.0
public class SBUSimpleMessageFormView: SBUMessageFormView {
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
        // |    [itemViews]     |
        // + ------------------- +
        // |    submitButton     |
        // + ------------------- +
        
        let itemViews = self.createFormItemViews(with: self.messageForm)
        self.stackView.setVStack(itemViews)
        self.itemViews = itemViews
        
        self.stackView.addArrangedSubview(self.submitButton)
        self.container.addSubview(self.stackView)
        self.addSubview(self.container)
    }
    
    public override func setupLayouts() {
        super.setupLayouts()
        
        self.stackView
            .sbu_constraint(equalTo: self.container, left: 12, right: 12, top: 16, bottom: 16)
        
        self.submitButton
            .sbu_constraint(height: 36)
        
        self.container
            .sbu_constraint(width: 244)
            .sbu_constraint(equalTo: self, leading: 0, trailing: 0, top: 0, bottom: 0)
    }
    
    public override func setupStyles() {
        super.setupStyles()
        
        self.container.backgroundColor = theme.formBackgroundColor
        self.container.layer.cornerRadius = 16

        self.submitButton.clipsToBounds = true
        self.submitButton.layer.cornerRadius = 6
        self.submitButton.titleLabel?.font = theme.formSubmittButtonFont
        self.submitButton.setTitle(SBUStringSet.Submit, for: .normal)
        self.submitButton.setTitle(SBUStringSet.FormType_Submit_Done, for: .disabled)
        self.submitButton.setTitleColor(theme.formSubmitButtonTitleColor, for: .normal)
        self.submitButton.setTitleColor(theme.formSubmitButtonTitleDisabledColor, for: .disabled)
        self.submitButton.setBackgroundImage(UIImage.from(color: theme.formSubmitButtonBackgroundColor), for: .normal)
        self.submitButton.setBackgroundImage(UIImage.from(color: theme.formSubmitButtonBackgroundDisabledColor), for: .disabled)
        
        self.submitButton.isEnabled = (self.params?.isSubmitting == false && self.messageForm?.isSubmitted == false)
    }
    
    public override func setupActions() {
        super.setupActions()
        
        self.submitButton.addTarget(self, action: #selector(onSubmit), for: .touchUpInside)
    }
    
    public override func onSubmit() -> Bool {
        let success = super.onSubmit()
        if success {
            self.submitButton.isEnabled = false
        }
        return success
    }
}
