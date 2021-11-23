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
import SendBirdSDK


@objc
public protocol SBUMessageInputViewDelegate: NSObjectProtocol {
    /// Called when the send button was selected.
    /// - Parameters:
    ///    - messageInputView: `SBUMessageinputView` object.
    ///    - text: The sent text.
    /// - Since: 2.2.0
    @objc
    optional func messageInputView(_ messageInputView: SBUMessageInputView, didSelectSend text: String)
    
    /// Called when the media resource button was selected.
    /// - Parameters:
    ///    - messageInputView: `SBUMessageinputView` object.
    ///    - type: `MediaResourceType` value.
    /// - Since: 2.2.0
    @objc
    optional func messageInputView(_ messageInputView: SBUMessageInputView, didSelectResource type: MediaResourceType)
    
    
    /// Called when the edit button was selected.
    /// - Parameters:
    ///    - messageInputView: `SBUMessageinputView` object.
    ///    - text: The text on editing
    /// - Since: 2.2.0
    @objc
    optional func messageInputView(_ messageInputView: SBUMessageInputView, didSelectEdit text: String)
    
    /// Called when the text was changed.
    /// - Parameters:
    ///    - messageInputView: `SBUMessageinputView` object.
    ///    - text: The changed text.
    /// - Since: 2.2.0
    @objc
    optional func messageInputView(_ messageInputView: SBUMessageInputView, didChangeText text: String)

    /// Called when the message input mode was changed.
    /// - Parameters:
    ///    - messageInputView: `SBUMessageinputView` object.
    ///    - mode: `SBUMessageInputMode` value. It represents the current mode of `messageInputView`.
    ///    - message: `SBDBaseMessage` object. It's `nil` when the `mode` is `none`.
    /// - Since: 2.2.0
    @objc
    optional func messageInputView(_ messageInputView: SBUMessageInputView, didChangeMode mode: SBUMessageInputMode, message: SBDBaseMessage?)
    
    /// Called when the message input mode will be changed via `setMode(_:message:)` method.
    /// - Parameters:
    ///    - messageInputView: `SBUMessageinputView` object.
    ///    - mode: `SBUMessageInputMode` value. The `messageInputView` changes its mode to this value.
    ///    - message: `SBDBaseMessage` object. It's `nil` when the `mode` is `none`.
    /// - Since: 2.2.0
    @objc
    optional func messageInputView(_ messageInputView: SBUMessageInputView, willChangeMode mode: SBUMessageInputMode, message: SBDBaseMessage?)
    
    
    /// Called when the message input view started to type.
    /// - Since: 2.2.0
    @objc
    optional func messageInputViewDidStartTyping()
    
    /// Called when the message Input view ended typing.
    /// - Since: 2.2.0
    @objc
    optional func messageInputViewDidEndTyping()
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
    
    // + --------- + ------- + ---------------- + ------- + ---------- +
    // | addButton | tvLP(*) | inputContentView | tvTP(*) | sendButton |
    // + --------- + ------- + ---------------- + ------- + ---------- +
    // * tvLP: textViewLeadingPaddingView
    // * tvTP: textViewTrailingPaddinView
    
    /// Input area - horizontal stack (add button, text view, send button)
    /// - Since: 2.1.11
    public lazy var inputHStackView: UIStackView = {
        let stackView = SBUStackView(
            axis: .horizontal,
            alignment: .bottom,
            spacing: 0
        )
        stackView.distribution = .fill
        return stackView
    }()
    
    /// The quote message view which is type of `SBUQuoteMessageInputView`.
    /// - Since: 2.2.0
    public lazy var quoteMessageView: SBUQuoteMessageInputView? = {
        let view = SBUQuoteMessageInputView()
        view.delegate = self
        return view
    }() {
        didSet {
            oldValue?.delegate = nil
            quoteMessageView?.delegate = self
        }
    }
    
    private lazy var divider: UIView = {
        return UIView()
    }()
    
    // MARK: - Property values (Public)
    /// The leading spacing for message input view
    public var leadingSpacing: CGFloat = 12
    /// The trailing spacing for message input view
    public var trailingSpacing: CGFloat = 12
    
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
    public var layoutInsets: UIEdgeInsets = UIEdgeInsets(
        top: 0,
        left: 20,
        bottom: 0,
        right: -16
    )

    // MARK: - Properties (Private)
    
    // + ----------------- +
    // | divider           |
    // + ----------------- +
    // | contentVStackView |
    // + ----------------- +
    
    private lazy var baseStackView: SBUStackView = {
        return SBUStackView(axis: .vertical, alignment: .fill, spacing: 0)
    }()
    
    private lazy var contentView: UIView = {
        return UIView()
    }()
    
    // + ----------------- +
    // | quoteMessageView  |
    // + ----------------- +
    // | contentHStackView |
    // + ----------------- +
    
    private lazy var contentVStackView: SBUStackView = {
        return SBUStackView(axis: .vertical, alignment: .fill, spacing: 0)
    }()
    
    // + ------------------ + --------------- + ------------------ +
    // | leadingPaddingView | inputVStackView | trailingPaddinView |
    // + ------------------ + --------------- + ------------------ +
    
    private lazy var contentHStackView: SBUStackView = {
        return SBUStackView(axis: .horizontal, alignment: .fill, spacing: 0)
    }()
    
    // + --------------------- +
    // | inputViewTopSpacer    |
    // + --------------------- +
    // | inputHStackView       |
    // + --------------------- +
    // | editView              |
    // + --------------------- +
    // | inputViewBottomSpacer |
    // + --------------------- +
    
    private lazy var inputVStackView: SBUStackView = {
        let stackView = SBUStackView(axis: .vertical, alignment: .fill, spacing: 10)
        stackView.distribution = .fill
        return stackView
    }()
    
    /// Space above the input fields.
    var inputViewTopSpacer = UIView()
    
    /// Text view + placeholder label.
    var inputContentView = UIView()
    
    /// Textview's leading/trailing padding view
    var textViewLeadingPaddingView: UIView = UIView()
    
    lazy var textViewTrailingPaddingView: UIView = {
        let view = UIView()
        view.isHidden = !showsSendButton
        return view
    }()
    
    /// SBUMessageInputView's leading / trailing padding view
    var leadingPaddingView = UIView()
    var trailingPaddingView = UIView()
    
    // + ------------ + -------------- + ---------- +
    // | cancelButton | editMarginView | saveButton |
    // + ------------ + -------------- + ---------- +
    
    /// Edit view (edit / cancel button on the bottom)
    var editStackView: SBUStackView = {
        let stackView = SBUStackView(axis: .horizontal, alignment: .fill)
        stackView.distribution = .fill
        return stackView
    }()
    
    /// Empty margin view in `editStackView` between cancel/edit buttons.
    var editMarginView = UIView()
    
    /// Space below the input fields (below edit view).
    var inputViewBottomSpacer = UIView()
    
    var textViewHeightConstraint: NSLayoutConstraint?

    weak var delegate: SBUMessageInputViewDelegate?

    var basedText: String = ""
    
    var isFrozen: Bool = false
    var isMuted: Bool = false

    let cameraItem = SBUActionSheetItem(title: SBUStringSet.Camera, completionHandler: nil)
    let libraryItem = SBUActionSheetItem(title: SBUStringSet.PhotoVideoLibrary, completionHandler: nil)
    let documentItem = SBUActionSheetItem(title: SBUStringSet.Document, completionHandler: nil)
    let cancelItem = SBUActionSheetItem(title: SBUStringSet.Cancel, completionHandler: nil)

    @SBUThemeWrapper(theme: SBUTheme.messageInputTheme)
    var theme: SBUMessageInputTheme
    @SBUThemeWrapper(theme: SBUTheme.overlayTheme.messageInputTheme, setToDefault: true)
    public var overlayTheme: SBUMessageInputTheme
    
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
    
    /// The `SBUMessageInputMode` value.
    /// - Since: 2.2.0
    public var mode: SBUMessageInputMode {
        self.option.value
    }
    
    // Only for Swift
    var option: MessageInputMode = .none {
        willSet {
            // End a previous mode
            switch self.option {
                case .edit:
                    self.endEditMode()
                case .quoteReply:
                    self.endQuoteReplyMode()
                default: break
            }
            
            
            // Start a new mode
            switch newValue {
                case .edit(let message):
                    self.startEditMode(text: message.message)
                case .quoteReply(let message):
                    self.startQuoteReplyMode(message: message)
                default: break
            }
        }
        didSet {
            SBULog.info("Message input view changed mode to \(self.option.toString)")
        }
    }
    
    open func setMode(_ mode: SBUMessageInputMode, message: SBDBaseMessage? = nil) {
        // Call delegate event: willChangeMode
        self.delegate?.messageInputView?(self, willChangeMode: mode, message: message)
        
        switch mode {
            case .edit:
                guard let message = message as? SBDUserMessage else { break }
                self.option = .edit(message)
            case .quoteReply:
                guard let message = message else { break }
                self.option = .quoteReply(message)
            default: self.option = .none
        }
        
        self.delegate?.messageInputView?(self, didChangeMode: mode, message: message)
    }
    
    /**
     Starts to reply to message. It's called when `mode` is set to `.quoteReply`
     
     - Parameter message: `SBDBaseMessage` that is replied to.
     - Since: 2.2.0
     */
    public func startQuoteReplyMode(message: SBDBaseMessage) {
        self.quoteMessageView?.isHidden = false
        self.divider.isHidden = false
        let configuration = SBUQuoteMessageInputViewParams(
            message: message
        )
        self.quoteMessageView?.configure(with: configuration)
    }
    
    /**
     Ends replying to message. It's called when `mode` is set from `.quoteReply` to the other.
     - Since: 2.2.0
     */
    public func endQuoteReplyMode() {
        self.quoteMessageView?.isHidden = true
        self.divider.isHidden = true
    }

    /// This function handles the initialization of views.
    open func setupViews() {
        self.editView.isHidden = true
        self.quoteMessageView?.isHidden = true
        self.divider.isHidden = true
        
        // baseStackView
        // + ---------------------------------------------------------------- +
        // | divider                                                          |
        // + ---------------------------------------------------------------- +
        // | quoteMessageView                                                 |
        // + ------------------ + --------------------- + ------------------- +
        // |                    | inputViewTopSpacer    |                     |
        // |                    + --------------------- +                     |
        // |                    | inputHStackView       |                     |
        // | leadingPaddingView + --------------------- + trailingPaddingView |
        // |                    | editView              |                     |
        // |                    + --------------------- +                     |
        // |                    | inputViewBottomSpacer |                     |
        // + ------------------ + --------------------- + ------------------- +
        
        // inputHStacView
        // + --------- + ------- + ---------------- + ------- + ---------- +
        // | addButton | tvLP(*) | inputContentView | tvTP(*) | sendButton |
        // + --------- + ------- + ---------------- + ------- + ---------- +
        // * tvLP: textViewLeadingPaddingView
        // * tvTP: textViewTrailingPaddinView
        
        // editView
        // + ------------ + -------------- + ---------- +
        // | cancelButton | editMarginView | saveButton |
        // + ------------ + -------------- + ---------- +
        
        
        // Add views
        if let textView = self.textView {
            self.inputContentView.addSubview(textView)
            self.inputContentView.addSubview(self.placeholderLabel)
        }

        self.editView.addSubview(
            self.editStackView.setHStack([
                self.cancelButton,
                self.editMarginView,
                self.saveButton
            ])
        )
        
        self.contentView.addSubview(
            self.contentVStackView.setVStack([
                self.quoteMessageView,
                self.contentHStackView.setHStack([
                    self.leadingPaddingView,
                    self.inputVStackView.setVStack([
                        self.inputViewTopSpacer,
                        self.inputHStackView.setHStack([
                            self.addButton,
                            self.textViewLeadingPaddingView,
                            self.inputContentView,
                            self.textViewTrailingPaddingView,
                            self.sendButton,
                        ]),
                        self.editView,
                        self.inputViewBottomSpacer
                    ]),
                    self.trailingPaddingView
                ]),
            ])
        )
        
        self.baseStackView.setVStack([
            self.divider,
            self.contentView
        ])
        
        self.addSubview(self.baseStackView)
    }
    
    /// This function handles the initialization of autolayouts.
    open func setupAutolayout() {
        self.baseStackView
            .sbu_constraint(
                equalTo: self,
                leading: 0,
                trailing: 0,
                top: 0,
                bottom: 0
            )
        
        self.contentVStackView.sbu_constraint_equalTo(
            leadingAnchor: self.safeAreaLayoutGuide.leadingAnchor,
            leading: 0
        )
        self.contentVStackView.sbu_constraint_equalTo(
            topAnchor: self.safeAreaLayoutGuide.topAnchor,
            top: layoutInsets.top
        )
        self.contentVStackView.sbu_constraint_equalTo(
            trailingAnchor: self.safeAreaLayoutGuide.trailingAnchor,
            trailing: 0
        )
        self.contentVStackView.sbu_constraint_equalTo(
            bottomAnchor: self.safeAreaLayoutGuide.bottomAnchor,
            bottom: layoutInsets.bottom
        )
        
        // Subviews in ContentVStackView
        self.divider
            .setConstraint(height: 1)
        
        self.quoteMessageView?
            .setConstraint(height: 56)
        
        // Subviews in ContentHStackView
        self.leadingPaddingView
            .setConstraint(width: self.leadingSpacing)
        
        self.trailingPaddingView
            .setConstraint(width: self.trailingSpacing)
        
        // Subviews in InputVStackView
        self.inputViewTopSpacer
            .sbu_constraint(height: 0)
        
        self.inputViewBottomSpacer
            .sbu_constraint(height: 0)
        
        self.inputHStackView
            .sbu_constraint(width: self.baseStackView.frame.width)
        
        // Subviews in InputHStackView
        self.addButton?
            .setConstraint(width: 32, height: 38)
        
        // leading/trailing spacing for textview
        self.textViewLeadingPaddingView
            .sbu_constraint(width: self.textViewLeadingSpacing)
        
        self.textViewTrailingPaddingView
            .sbu_constraint(width: self.textViewTrailingSpacing)
        
        self.sendButton?
            .sbu_constraint(width: 32, height: 38)
        
        // Subivews in InputContentView
        self.textView?
            .sbu_constraint(equalTo: self.inputContentView, leading: 0, trailing: 0, top: 0, bottom: 0)
        
        if let textView = self.textView {
            self.placeholderLabel
                .sbu_constraint(equalTo: textView, leading: 14, top: 10)
            self.setupTextViewHeight(textView: textView)
        }
        
        // Subviews of EditView
        self.editView
            .sbu_constraint(height: 32)
        
        self.cancelButton?
            .sbu_constraint(width: 75)
        
        self.saveButton?
            .sbu_constraint(width: 75)
        
        self.editStackView
            .sbu_constraint(equalTo: self.editView, leading: 0, trailing: 0, top: 0, bottom: 0)
    }
    
    /// This function handles the initialization of styles.
    open func setupStyles() {
        let theme = self.isOverlay ? self.overlayTheme : self.theme
        
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
        else if self.mode == .quoteReply {
            self.placeholderLabel.text = SBUStringSet.MessageInput_Text_Reply
            self.placeholderLabel.textColor = theme.textFieldPlaceholderColor
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
        
        self.divider.backgroundColor = theme.channelViewDividerColor
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
        self.textViewTrailingPaddingView.isHidden = !showsSendButton
        
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
    
    // MARK: - State
    
    /// Sets frozen mode state.
    /// - Parameter isFrozen `true` is frozen mode, `false` is unfrozen mode
    public func setFrozenModeState(_ isFrozen: Bool) {
        self.isFrozen = isFrozen
        
        self.textView?.isEditable = !self.isFrozen
        self.textView?.isUserInteractionEnabled = !self.isFrozen
        self.addButton?.isEnabled = !self.isFrozen
        
        if self.isFrozen {
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
            self.endTypingMode()
        }
        self.setupStyles()
    }
    
    /// Sets error state. Disable all
    public func setErrorState() {
        self.textView?.isEditable = false
        self.textView?.isUserInteractionEnabled = false
        self.addButton?.isEnabled = false
        
        self.endTypingMode()
        self.setupStyles()
    }
    
    // MARK: - Common
    public func endTypingMode() {
        self.textView?.text = ""
        self.sendButton?.isHidden = !showsSendButton
        self.textViewTrailingPaddingView.isHidden = !showsSendButton
        self.setMode(.none)
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

    // MARK: - UITextViewDelegate
    public func textViewDidChange(_ textView: UITextView) {
        self.placeholderLabel.isHidden = !textView.text.isEmpty
        self.updateTextViewHeight()
        
        let text = textView.text ?? ""
        if self.editView.isHidden {
            self.sendButton?.isHidden = !showsSendButton &&
                text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            self.textViewTrailingPaddingView.isHidden = self.sendButton?.isHidden == true
            self.layoutIfNeeded()
        }
        
        self.delegate?.messageInputView?(self, didChangeText: text)
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        self.delegate?.messageInputViewDidEndTyping?()
    }

    public func textView(_ textView: UITextView,
                         shouldChangeTextIn range: NSRange,
                         replacementText text: String) -> Bool {
        if text.count > 0 {
            self.delegate?.messageInputViewDidStartTyping?()
        } else if text.isEmpty, textView.text?.count ?? 0 <= 1 {
            self.delegate?.messageInputViewDidEndTyping?()
        }

        return true
    }

    // MARK: - SBUActionSheetDelegate
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

extension SBUMessageInputView: SBUQuoteMessageInputViewDelegate {
    func didTapClose() {
        self.setMode(.none)
    }
}
