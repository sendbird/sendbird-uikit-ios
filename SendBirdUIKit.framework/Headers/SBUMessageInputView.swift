//
//  SBUMessageInputView.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2020/11/02.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import Photos
import AVKit


@objc public protocol SBUMessageInputViewDelegate: NSObjectProtocol {
    @objc optional func messageInputView(_ messageInputView: SBUMessageInputView, didSelectSend text: String)
    @objc optional func messageInputView(_ messageInputView: SBUMessageInputView, didSelectResource type: MediaResourceType)
    @objc optional func messageInputView(_ messageInputView: SBUMessageInputView, didSelectEdit text: String)
    @objc optional func messageInputViewDidStartTyping()
    @objc optional func messageInputViewDidEndTyping()
}

@objcMembers
open class SBUMessageInputView: UIView, SBUActionSheetDelegate, UITextViewDelegate {
    // MARK: - Properties (Public)
    public lazy var addButton: UIButton? = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(onClickAddButton(_:)), for: .touchUpInside)
        button.isHidden = false
        button.alpha = 1
        return button
    }()
    
    public lazy var placeholderLabel = UILabel()
    
    public lazy var textView: UITextView? = {
        let tv = UITextView()
        tv.textContainerInset = UIEdgeInsets(top: 10, left: 9, bottom: 10, right: 16)
        tv.layer.borderWidth = 1
        tv.layer.cornerRadius = 20
        tv.delegate = self
        return tv
    }()
    
    public lazy var sendButton: UIButton? = {
        let button = UIButton()
        button.layer.cornerRadius = 4
        button.addTarget(self, action: #selector(onClickSendButton(_:)), for: .touchUpInside)
        button.isHidden = !showsSendButton
        return button
    }()

    public lazy var editView: UIView = {
        let editView = UIView()
        editView.isHidden = true
        editView.alpha = 0
        return editView
    }()
    
    public lazy var cancelButton: UIButton? = {
        let button = UIButton()
        button.setTitle(SBUStringSet.Cancel, for: .normal)
        button.layer.cornerRadius = 4
        button.addTarget(self, action: #selector(onClickCancelButton(_:)), for: .touchUpInside)
        return button
    }()
    
    public lazy var saveButton: UIButton? = {
        let button = UIButton()
        button.setTitle(SBUStringSet.Save, for: .normal)
        button.layer.cornerRadius = 4
        button.addTarget(self, action: #selector(onClickSaveButton(_:)), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - Property values (Public)
    
    /// Textview's minimum height value.
    public var textViewMinHeight: CGFloat = 38
    /// Textview's maximum height value.
    public var textViewMaxHeight: CGFloat = 87
    /// Whether to always show the send button. Default is `false`.
    public var showsSendButton: Bool = false
    
    /// Leading spacing value for `textView`.
    /// If `addButton` is available, this will be spacing between the `addButton` and the `textView`.
    public var textViewLeadingSpacing: CGFloat = 12
    /// Trailing spacing value for `textView`.
    /// If `sendButton` is available, this will be spacing between the `textView` and the `sendButton`.
    public var textViewTrailingSpacing: CGFloat = 12
    
    /// The padding values for the input view.
    /// This value will be relative to the `safeAreaLayoutGuide` if available.
    public var layoutInsets: UIEdgeInsets =
        UIEdgeInsets(top: 0,
                     left: 20,
                     bottom: 0,
                     right: -16)
    

    // MARK: - Properties (Private)
    var baseStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 10
        return stackView
    }()
    
    /// Space above the input fields.
    var topSpace = UIView()
    
    /// Input row (add button, text view, send button)
    lazy var inputStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .bottom
        stackView.distribution = .fill
        stackView.spacing = 0
        return stackView
    }()
    
    /// Text view + placeholder label.
    var inputContentView = UIView()
    
    /// Textview's leading/trailing padding view
    var textViewLeadingPaddingView: UIView = UIView()
    var textViewTrailingPaddingView: UIView = UIView()
    
    /// Edit view (edit / cancel button on the bottom)
    var editStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    /// Empty margin view in `editStackView` between cancel/edit buttons.
    var editMarginView = UIView()
    
    /// Space below the input fields (below edit view).
    var bottomSpace = UIView()
    
    var textViewHeightConstraint: NSLayoutConstraint?

    weak var delegate: SBUMessageInputViewDelegate?

    var basedText: String = ""
    
    var isFrozen: Bool = false
    var isMuted: Bool = false

    let cameraItem = SBUActionSheetItem(title: SBUStringSet.Camera, completionHandler: nil)
    let libraryItem = SBUActionSheetItem(title: SBUStringSet.PhotoVideoLibrary, completionHandler: nil)
    let documentItem = SBUActionSheetItem(title: SBUStringSet.Document, completionHandler: nil)
    let cancelItem = SBUActionSheetItem(title: SBUStringSet.Cancel, completionHandler: nil)

    var theme: SBUMessageInputTheme = SBUTheme.messageInputTheme
    
    var isOverlay = false

    
    // MARK: - Life cycle
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupViews()
        self.setupAutolayout()
    }
    
    init(isOverlay: Bool) {
        super.init(frame: .zero)
        
        self.isOverlay = isOverlay
        
        self.setupViews()
        self.setupAutolayout()
    }
    
    @available(*, unavailable, renamed: "SBUMessageInputView()")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /// This function handles the initialization of views.
    open func setupViews() {
        self.editView.isHidden = true
        
        // Add views
        self.baseStackView.addArrangedSubview(self.topSpace)
        
        if let addButton = self.addButton {
            self.inputStackView.addArrangedSubview(addButton)
        }
        self.inputStackView.addArrangedSubview(self.textViewLeadingPaddingView)
        if let textView = self.textView {
            self.inputContentView.addSubview(textView)
            self.inputContentView.addSubview(self.placeholderLabel)
        }
        self.inputStackView.addArrangedSubview(self.inputContentView)
        self.inputStackView.addArrangedSubview(self.textViewTrailingPaddingView)
        if let sendButton = self.sendButton {
            self.inputStackView.addArrangedSubview(sendButton)
        }
        self.baseStackView.addArrangedSubview(self.inputStackView)
        
        if let cancelButton = self.cancelButton {
            self.editStackView.addArrangedSubview(cancelButton)
        }
        self.editStackView.addArrangedSubview(self.editMarginView)
        if let saveButton = self.saveButton {
            self.editStackView.addArrangedSubview(saveButton)
        }
        self.editView.addSubview(self.editStackView)
        self.baseStackView.addArrangedSubview(self.editView)
        
        self.baseStackView.addArrangedSubview(self.bottomSpace)
        
        self.addSubview(self.baseStackView)
    }
    
    /// This function handles the initialization of autolayouts.
    open func setupAutolayout() {
        if #available(iOS 11.0, *) {
            self.baseStackView.sbu_constraint_equalTo(
                leadingAnchor: self.safeAreaLayoutGuide.leadingAnchor,
                leading: layoutInsets.left
            )
            self.baseStackView.sbu_constraint_equalTo(
                topAnchor: self.safeAreaLayoutGuide.topAnchor,
                top: layoutInsets.top
            )
            self.baseStackView.sbu_constraint_equalTo(
                trailingAnchor: self.safeAreaLayoutGuide.trailingAnchor,
                trailing: layoutInsets.right
            )
            self.baseStackView.sbu_constraint_equalTo(
                bottomAnchor: self.safeAreaLayoutGuide.bottomAnchor,
                bottom: layoutInsets.bottom
            )
        } else {
            self.baseStackView.sbu_constraint(
                equalTo: self,
                leading: layoutInsets.left,
                trailing: layoutInsets.right,
                top: layoutInsets.top,
                bottom: layoutInsets.bottom
            )
        }
        
        self.topSpace.sbu_constraint(width: self.baseStackView.frame.width, height: 0)
        
        self.inputStackView.sbu_constraint(width: self.baseStackView.frame.width)
        
        self.addButton?.sbu_constraint(width: 32, height: 38)
        self.textView?.sbu_constraint(equalTo: self.inputContentView, leading: 0, trailing: 0, top: 0, bottom: 0)
        if let textView = self.textView {
            self.placeholderLabel.sbu_constraint(equalTo: textView, leading: 14, top: 10)
            self.setupTextViewHeight(textView: textView)
        }
        self.sendButton?.sbu_constraint(width: 32, height: 38)
        
        // leading/trailing spacing for textview
        self.textViewLeadingPaddingView.translatesAutoresizingMaskIntoConstraints = false
        self.textViewTrailingPaddingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.textViewLeadingPaddingView.widthAnchor.constraint(
                equalToConstant: self.textViewLeadingSpacing
            ),
            self.textViewTrailingPaddingView.widthAnchor.constraint(
                equalToConstant: self.textViewTrailingSpacing
            )
        ])

        self.cancelButton?.sbu_constraint(width: 75)
        self.saveButton?.sbu_constraint(width: 75)
        self.editStackView.sbu_constraint(equalTo: self.editView, leading: 0, trailing: 0, top: 0, bottom: 0)
        self.editView.sbu_constraint(height: 32)
        
        self.bottomSpace.sbu_constraint(width: self.baseStackView.frame.width, height: 0)
    }
    
    /// This function handles the initialization of styles.
    open func setupStyles() {
        self.theme = self.isOverlay ? SBUTheme.overlayTheme.messageInputTheme : SBUTheme.messageInputTheme
        
        self.backgroundColor = theme.backgroundColor

        // placeholderLabel
        self.placeholderLabel.font = theme.textFieldPlaceholderFont
        if self.isFrozen {
            self.placeholderLabel.text = SBUStringSet.MessageInput_Text_Unavailable
            self.placeholderLabel.textColor = theme.textFieldDisabledColor
        }
        else if self.isMuted {
            self.placeholderLabel.text = SBUStringSet.MessageInput_Text_Muted
            self.placeholderLabel.textColor = theme.textFieldDisabledColor
        }
        else {
            self.placeholderLabel.text = SBUStringSet.MessageInput_Text_Placeholder
            self.placeholderLabel.textColor = theme.textFieldPlaceholderColor
        }

        // textView
        self.textView?.backgroundColor = theme.textFieldBackgroundColor
        self.textView?.tintColor = theme.textFieldTintColor
        self.textView?.textColor = theme.textFieldTextColor
        self.textView?.layer.borderColor = theme.textFieldBorderColor.cgColor
        self.textView?.font = theme.textFieldPlaceholderFont
        
        // addButton
        let iconAdd = SBUIconSetType.iconAdd
            .image(with:
                    (self.isFrozen || self.isMuted)
                    ? theme.buttonDisabledTintColor
                    : theme.buttonTintColor,
                   to: SBUIconSetType.Metric.defaultIconSize)
        self.addButton?.setImage(iconAdd, for: .normal)
        
        // IconSend
        self.sendButton?.setImage(
            SBUIconSetType.iconSend.image(
                with: theme.buttonTintColor,
                to: SBUIconSetType.Metric.defaultIconSize
            ),
            for: .normal)
        
        // cancelButton
        self.cancelButton?.setTitleColor(theme.buttonTintColor, for: .normal)
        self.cancelButton?.titleLabel?.font = theme.cancelButtonFont
        
        // saveButton
        self.saveButton?.backgroundColor = theme.buttonTintColor
        self.saveButton?.setTitleColor(theme.saveButtonTextColor, for: .normal)
        self.saveButton?.titleLabel?.font = theme.saveButtonFont
        
        // Item
        self.cameraItem.image = SBUIconSetType.iconCamera.image(
            with: theme.buttonTintColor,
            to: SBUIconSetType.Metric.iconActionSheetItem
        )
        self.libraryItem.image = SBUIconSetType.iconPhoto.image(
            with: theme.buttonTintColor,
            to: SBUIconSetType.Metric.iconActionSheetItem
        )
        self.documentItem.image = SBUIconSetType.iconDocument.image(
            with: theme.buttonTintColor,
            to: SBUIconSetType.Metric.iconActionSheetItem
        )
        self.cancelItem.color = theme.buttonTintColor
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.setupStyles()
    }

    
    // MARK: - Edit View
    public func startEditMode(text: String) {
        self.textView?.text = text
        self.basedText = text
        self.placeholderLabel.isHidden = !text.isEmpty

        self.addButton?.isHidden = true
        self.addButton?.alpha = 0
        
        self.sendButton?.isHidden = !showsSendButton
        
        self.editView.isHidden = false
        self.editView.alpha = 1

        self.updateTextViewHeight()
        let bottom = NSMakeRange((self.textView?.text.count ?? 0) - 1, 1)
        self.textView?.scrollRangeToVisible(bottom)
        
        self.textView?.becomeFirstResponder()

        self.layoutIfNeeded()
    }
    
    public func endEditMode() {
        self.textView?.text = ""
        self.basedText = ""
        self.placeholderLabel.isHidden = false

        self.addButton?.isHidden = false
        self.addButton?.alpha = 1
        
        self.editView.isHidden = true
        self.editView.alpha = 0

        self.updateTextViewHeight()
        
        self.layoutIfNeeded()
    }
    
    // MARK: State
    
    /// Sets frozen mode state.
    /// - Parameter isFrozen `true` is frozen mode, `false` is unfrozen mode
    public func setFrozenModeState(_ isFrozen: Bool) {
        self.isFrozen = isFrozen
        
        self.textView?.isEditable = !self.isFrozen
        self.textView?.isUserInteractionEnabled = !self.isFrozen
        self.addButton?.isEnabled = !self.isFrozen
        
        if self.isFrozen {
            self.endEditMode()
            self.endTypingMode()
        }
        self.setupStyles()
    }
    
    /// Sets frozen mode state.
    /// - Parameter isMuted `true` is muted mode, `false` is unmuted mode
    public func setMutedModeState(_ isMuted: Bool) {
        self.isMuted = isMuted
        
        self.textView?.isEditable = !self.isMuted
        self.textView?.isUserInteractionEnabled = !self.isMuted
        self.addButton?.isEnabled = !self.isMuted
        
        if self.isMuted {
            self.endEditMode()
            self.endTypingMode()
        }
        self.setupStyles()
    }
    
    /// Sets error state. Disable all
    public func setErrorState() {
        self.textView?.isEditable = false
        self.textView?.isUserInteractionEnabled = false
        self.addButton?.isEnabled = false
        
        self.endEditMode()
        self.endTypingMode()
        self.setupStyles()
    }
    
    // MARK: Common
    public func endTypingMode() {
        self.textView?.text = ""
        self.sendButton?.isHidden = !showsSendButton
        self.endEditMode()
        self.layoutIfNeeded()
    }
    
    /// Setup textview's initial height.
    /// The initial height will be set to the `textViewMinHeight` value.
    ///
    /// - Parameter textView: Your input text view.
    /// - Since: 2.1.1
    public func setupTextViewHeight(textView: UIView) {
        self.textViewHeightConstraint = textView.heightAnchor.constraint(equalToConstant: self.textViewMinHeight)
        self.textViewHeightConstraint?.isActive = true
    }
    
    /// Updates textview's height depending on the content size..
    /// `setupTextViewHeight(textView:)` must be called prior to this for this to work.
    /// The min/max height of the text view can be modified by changing `textViewMinHeight` and `textViewMaxHeight` values.
    public func updateTextViewHeight() {
        guard let textViewContentHeight = self.textView?.contentSize.height else { return }
        
        switch textViewContentHeight {
        case ..<self.textViewMinHeight:
            self.textViewHeightConstraint?.constant = self.textViewMinHeight
        case self.textViewMaxHeight...:
            self.textViewHeightConstraint?.constant = self.textViewMaxHeight
        default:
            self.textViewHeightConstraint?.constant = textViewContentHeight
        }
    }

    // MARK: - Action
    @objc open func onClickAddButton(_ sender: Any) {
        self.endEditing(true)
        let itmes = [self.cameraItem, self.libraryItem, self.documentItem]
        SBUActionSheet.show(
            items: itmes,
            cancelItem: self.cancelItem,
            oneTimetheme: isOverlay ? SBUComponentTheme.dark : nil,
            delegate: self
        )
    }
    
    @objc open func onClickSendButton(_ sender: Any) {
        self.delegate?.messageInputView?(
            self,
            didSelectSend: self.textView?.text.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        )
        self.placeholderLabel.isHidden = !(self.textView?.text.isEmpty ?? true)
        self.updateTextViewHeight()
    }
    
    @objc open func onClickCancelButton(_ sender: Any) {
        self.endEditMode()
    }
    
    @objc open func onClickSaveButton(_ sender: Any) {
        let editedText = self.textView?.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard basedText != editedText else {
            self.endEditMode()
            return
        }
        self.delegate?.messageInputView?(
            self,
            didSelectEdit: self.textView?.text.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        )
    }

    // MARK: UITextViewDelegate
    public func textViewDidChange(_ textView: UITextView) {
        self.placeholderLabel.isHidden = !textView.text.isEmpty
        self.updateTextViewHeight()
        
        if self.editView.isHidden {
            let text = textView.text ?? ""
            self.sendButton?.isHidden = !showsSendButton &&
                text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            
            self.layoutIfNeeded()
        }
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        self.delegate?.messageInputViewDidEndTyping?()
    }

    public func textView(_ textView: UITextView,
                         shouldChangeTextIn range: NSRange,
                         replacementText text: String) -> Bool {
        if text.count > 0 {
            self.delegate?.messageInputViewDidStartTyping?()
        } else if text.count == 0, textView.text?.count ?? 0 <= 1 {
            self.delegate?.messageInputViewDidEndTyping?()
        }

        return true
    }

    // MARK: SBUActionSheetDelegate
    public func didSelectActionSheetItem(index: Int, identifier: Int) {
        let type = MediaResourceType.init(rawValue: index) ?? .unknown
        switch type {
        case .camera:
            SBUPermissionManager.shared.requestDeviceAccessIfNeeded(for: .video) { (granted) in
                if (granted) {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.delegate?.messageInputView?(self, didSelectResource: type)
                    }
                } else {
                    //show alert view to go to settings
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                    }
                }
            }
        case .library:
            //need to know access level for ios 14
            SBUPermissionManager.shared.requestPhotoAccessIfNeeded { (completed) in
                if (completed) {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.delegate?.messageInputView?(self, didSelectResource: type)
                    }
                } else {
                    //show alert view to go to settings
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                    }
                }
            }
        default:
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.messageInputView?(self, didSelectResource: type)
            }
        }
    }

}
