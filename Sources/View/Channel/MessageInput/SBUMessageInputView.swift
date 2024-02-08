//
//  SBUMessageInputView.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2020/11/02.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import Photos
import AVKit
import SendbirdChatSDK

public protocol SBUMessageInputViewDelegate: AnyObject {
    /// Called when the add button was selected.
    /// - Parameters:
    ///    - messageInputView: `SBUMessageinputView` object.
    /// - Since: 3.4.0
    func messageInputViewDidSelectAdd(_ messageInputView: SBUMessageInputView)
    
    /// Called when the send button was selected.
    /// - Parameters:
    ///    - messageInputView: `SBUMessageinputView` object.
    ///    - text: The sent text.
    /// - Since: 2.2.0
    func messageInputView(_ messageInputView: SBUMessageInputView, didSelectSend text: String)
    
    /// Called when the media resource button was selected.
    /// - Parameters:
    ///    - messageInputView: `SBUMessageinputView` object.
    ///    - type: `MediaResourceType` value.
    /// - Since: 2.2.0
    func messageInputView(_ messageInputView: SBUMessageInputView, didSelectResource type: MediaResourceType)
    
    /// Called when the edit button was selected.
    /// - Parameters:
    ///    - messageInputView: `SBUMessageinputView` object.
    ///    - text: The text on editing
    /// - Since: 2.2.0
    func messageInputView(_ messageInputView: SBUMessageInputView, didSelectEdit text: String)
    
    /// Called when the text was changed.
    /// - Parameters:
    ///    - messageInputView: `SBUMessageinputView` object.
    ///    - text: The changed text.
    /// - Since: 2.2.0
    func messageInputView(_ messageInputView: SBUMessageInputView, didChangeText text: String)

    /// Called when the message input mode was changed.
    /// - Parameters:
    ///    - messageInputView: `SBUMessageinputView` object.
    ///    - mode: `SBUMessageInputMode` value. It represents the current mode of `messageInputView`.
    ///    - message: `BaseMessage` object. It's `nil` when the `mode` is `none`.
    /// - Since: 2.2.0
    func messageInputView(_ messageInputView: SBUMessageInputView, didChangeMode mode: SBUMessageInputMode, message: BaseMessage?)
    
    /// Called when the message input mode will be changed via `setMode(_:message:)` method.
    /// - Parameters:
    ///    - messageInputView: `SBUMessageinputView` object.
    ///    - mode: `SBUMessageInputMode` value. The `messageInputView` changes its mode to this value.
    ///    - message: `BaseMessage` object. It's `nil` when the `mode` is `none`.
    /// - Since: 2.2.0
    func messageInputView(_ messageInputView: SBUMessageInputView, willChangeMode mode: SBUMessageInputMode, message: BaseMessage?)
    
    /// Called when the message input view started to type.
    /// - Since: 2.2.0
    func messageInputViewDidStartTyping()
    
    /// Called when the message Input view ended typing.
    /// - Since: 2.2.0
    func messageInputViewDidEndTyping()
    
    // MARK: Mention
    
    /// Asks the delegate whether to replace the specified text in the `messageInputView`. Please refer to `textView(_:shouldChangeTextIn:replacementText:)` in `UITextViewDelegate`.
    /// - Parameters:
    ///   - messageInputView: `SBUMessageInputView` object.
    ///   - range: The current selection range. If the length of the range is `0`, range reflects the current insertion point. If the user presses the Delete key, the length of the range is `1` and an empty string object replaces that single character.
    ///   - text: The text to insert.
    /// - Returns: `true` if the old text should be replaced by the new text; `false` if the replacement operation should be aborted.
    func messageInputView(_ messageInputView: SBUMessageInputView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    
    /// Asks the delegate whether the specified text view allows the specified type of user interaction with the specified URL in the specified range of text. Please refer to `textView(_:shouldInteractWith:in:interaction:)`
    /// - Parameters:
    ///   - messageInputView: `SBUMessageInputView` object.
    ///   - url: The URL to be processed.
    ///   - characterRange: The character range containing the URL.
    ///   - interaction: The type of interaction that is occurring (for possible values, see `UITextItemInteraction`).
    /// - Returns: `true` if interaction with the URL should be allowed; `false` if interaction should not be allowed.
    func messageInputView(_ messageInputView: SBUMessageInputView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool
    
    /// Tells the delegate when the text selection changes in the specified message input view.. Please refer to `textViewDidChangeSelection(_:)`
    /// - Parameters:
    ///   - messageInputView: `SBUMessageInputView` object.
    ///   - range: The selected range of the text view in `SBUMessageInputView`
    func messageInputView(_ messageInputView: SBUMessageInputView, didChangeSelection range: NSRange)
    
    // MARK: Voice message
    /// Called when the voice message button was selected.
    /// - Parameters:
    ///    - messageInputView: `SBUMessageinputView` object.
    /// - Since: 3.4.0
    func messageInputViewDidTapVoiceMessage(_ messageInputView: SBUMessageInputView)
}

public extension SBUMessageInputViewDelegate {
    func messageInputView(_ messageInputView: SBUMessageInputView, didSelectSend text: String) { }
    
    func messageInputView(_ messageInputView: SBUMessageInputView, didSelectResource type: MediaResourceType) { }
    
    func messageInputView(_ messageInputView: SBUMessageInputView, didSelectEdit text: String) { }
    
    func messageInputView(_ messageInputView: SBUMessageInputView, didChangeText text: String) { }

    func messageInputView(_ messageInputView: SBUMessageInputView, didChangeMode mode: SBUMessageInputMode, message: BaseMessage?) { }
    
    func messageInputView(_ messageInputView: SBUMessageInputView, willChangeMode mode: SBUMessageInputMode, message: BaseMessage?) { }
    
    func messageInputViewDidStartTyping() { }
    
    func messageInputViewDidEndTyping() { }
    
    func messageInputView(_ messageInputView: SBUMessageInputView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool { true }
    
    func messageInputView(_ messageInputView: SBUMessageInputView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool { true }
    
    func messageInputView(_ messageInputView: SBUMessageInputView, didChangeSelection range: NSRange) { }
}

public protocol SBUMessageInputViewDataSource: AnyObject {
    /// Ask the data source to return the `BaseChannel` object.
    /// - Parameters:
    ///    - messageInputView: `SBUMessageInputView` object.
    /// - Returns: `BaseChannel` object.
    func channelForMessageInputView(_ messageInputView: SBUMessageInputView) -> BaseChannel?
}

open class SBUMessageInputView: SBUView, SBUActionSheetDelegate, UITextViewDelegate {
    // MARK: - Properties (Public)
    public lazy var addButton: UIButton? = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(onTapAddButton(_:)), for: .touchUpInside)
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
        button.addTarget(self, action: #selector(onTapSendButton(_:)), for: .touchUpInside)
        button.isHidden = !showsSendButton
        return button
    }()
    
    /// Voice message button
    /// - Since: 3.4.0
    public lazy var voiceMessageButton: UIButton? = {
        let button = UIButton()
        button.layer.cornerRadius = 4
        button.addTarget(self, action: #selector(onTapVoiceMessageButton(_:)), for: .touchUpInside)
        button.isHidden = !showsVoiceMessageButton
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
        button.addTarget(self, action: #selector(onTapCancelButton(_:)), for: .touchUpInside)
        return button
    }()
    
    public lazy var saveButton: UIButton? = {
        let button = UIButton()
        button.setTitle(SBUStringSet.Save, for: .normal)
        button.layer.cornerRadius = 4
        button.addTarget(self, action: #selector(onTapSaveButton(_:)), for: .touchUpInside)
        return button
    }()
    
    // + --------- + ------- + ---------------- + ------- + -----------+---------------- +
    // | addButton | tvLP(*) | inputContentView | tvTP(*) | sendButton | voiceMessageButton |
    // + --------- + ------- + ---------------- + ------- + -----------+---------------- +
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
    /// (Group channel only) Whether to always show the voice message button. Default value follows the `SendbirdUI.config.groupChannel.channel.enableVoiceMessage`.
    /// - Since: 3.4.0
    public var showsVoiceMessageButton: Bool = SendbirdUI.config.groupChannel.channel.isVoiceMessageEnabled
    
    /// Leading spacing value for `textView`.
    /// If `addButton` is available, this will be spacing between the `addButton` and the `textView`.
    public var textViewLeadingSpacing: CGFloat = 12
    /// Trailing spacing value for `textView`.
    /// If `sendButton` or `voiceMessageButton` is available, this will be spacing between the `textView` and the `sendButton` or `voiceMessageButton`.
    public var textViewTrailingSpacing: CGFloat = 12
    
    /// The padding values for the input view.
    /// This value will be relative to the `safeAreaLayoutGuide` if available.
    public var layoutInsets: UIEdgeInsets = UIEdgeInsets(
        top: 0,
        left: 20,
        bottom: 0,
        right: -16
    )
    
    /// The default attributes values for the input view
    public var defaultAttributes: [NSAttributedString.Key: Any] {
        [
            .font: theme.textFieldFont,
            .backgroundColor: UIColor.clear,
            .foregroundColor: self.isOverlay
            ? self.overlayTheme.textFieldTextColor
            : self.theme.textFieldTextColor
        ]
    }
    
    /// The mentioned attributes values for the input view
    public var mentionedAttributes: [NSAttributedString.Key: Any] {
        let mentionAttributes: [NSAttributedString.Key: Any] = [
            .font: theme.mentionTextFont,
            .backgroundColor: self.theme.mentionTextBackgroundColor,
            .foregroundColor: self.theme.mentionTextColor,
            .link: "",
            .underlineColor: UIColor.clear
        ]
        
        return mentionAttributes
    }
    
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
    
    lazy var contentHStackView: SBUStackView = {
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
        view.isHidden = (!showsSendButton && !showsVoiceMessageButton)
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

    /// The delegate that is type of `SBUMessageInputViewDelegate`.
    /// - NOTE: `SBUMessageInputViewDelegate` notifies events that occur in the message input field. To receive such events, you need to set a delegate to an object that conforms to the `SBUMessageInputViewDelegate` protocol.
    public weak var delegate: SBUMessageInputViewDelegate?
    public weak var datasource: SBUMessageInputViewDataSource?

    var basedText: String = ""
    
    var isFrozen: Bool = false
    var isMuted: Bool = false
    var isDisable: Bool = false
    
    /// The Flag to check if it is the first thread message input. (This flag's priority is higher than `isThreadMessage`)
    var isThreadFirstMessage: Bool = false
    /// The Flag to check if it is the thread message input
    var isThreadMessage: Bool = false

    let cameraItem = SBUActionSheetItem(
        title: SBUStringSet.Camera,
        tag: MediaResourceType.camera.rawValue,
        completionHandler: nil
    )
    let libraryItem = SBUActionSheetItem(
        title: SBUStringSet.PhotoVideoLibrary,
        tag: MediaResourceType.library.rawValue,
        completionHandler: nil
    )
    let documentItem = SBUActionSheetItem(
        title: SBUStringSet.Document,
        tag: MediaResourceType.document.rawValue,
        completionHandler: nil
    )
    let cancelItem = SBUActionSheetItem(title: SBUStringSet.Cancel, completionHandler: nil)

    @SBUThemeWrapper(theme: SBUTheme.messageInputTheme)
    public var theme: SBUMessageInputTheme
    @SBUThemeWrapper(theme: SBUTheme.overlayTheme.messageInputTheme, setToDefault: true)
    public var overlayTheme: SBUMessageInputTheme
    
    var isOverlay = false
    
    var channelType: SendbirdChatSDK.ChannelType {
        self.datasource?.channelForMessageInputView(self)?.channelType ?? .group
    }
    
    // MARK: - Life cycle
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public init(isOverlay: Bool) {
        self.isOverlay = isOverlay

        super.init(frame: .zero)
    }
    
    public override init() {
        super.init()
    }
    
    @available(*, unavailable, renamed: "SBUMessageInputView()")
    required public init?(coder: NSCoder) {
        super.init()
    }
    
    /// The `SBUMessageInputMode` value.
    /// - Since: 2.2.0
    public var mode: SBUMessageInputMode {
        self.option.value
    }
    
    // Only for Swift
    private(set) var option: MessageInputMode = .none {
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
            case .none:
                self.delegate?.messageInputViewDidEndTyping()
            }
        }
        didSet {
            SBULog.info("Message input view changed mode to \(self.option.toString)")
        }
    }
    
    open func setMode(_ mode: SBUMessageInputMode, message: BaseMessage? = nil) {
        // Call delegate event: willChangeMode
        self.delegate?.messageInputView(self, willChangeMode: mode, message: message)
        
        switch mode {
        case .edit:
            guard let message = message as? UserMessage else { break }
            self.option = .edit(message)
        case .quoteReply:
            guard let message = message else { break }
            self.option = .quoteReply(message)
        default:
            self.option = .none
            
        }
        
        self.delegate?.messageInputView(self, didChangeMode: mode, message: message)
    }
    
    /**
     Starts to reply to message. It's called when `mode` is set to `.quoteReply`
     
     - Parameter message: `BaseMessage` that is replied to.
     - Since: 2.2.0
     */
    public func startQuoteReplyMode(message: BaseMessage) {
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
    open override func setupViews() {
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
        // + --------- + ------- + ---------------- + ------- + ---------- + ----------------- +
        // | addButton | tvLP(*) | inputContentView | tvTP(*) | sendButton | voiceRecordButton |
        // + --------- + ------- + ---------------- + ------- + ---------- + ----------------- +
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
                            self.voiceMessageButton,
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
    open override func setupLayouts() {
        // Subviews of EditView
        self.editStackView
            .sbu_constraint(equalTo: self.editView, leading: 0, trailing: 0, top: 0, bottom: 0)
        
        self.cancelButton?
            .sbu_constraint(width: 75)
        
        self.saveButton?
            .sbu_constraint(width: 75)

        self.editView
            .sbu_constraint(height: 32)
        
        // Subviews in InputVStackView
        self.inputViewTopSpacer
            .sbu_constraint(height: 0)
        
        self.inputViewBottomSpacer
            .sbu_constraint(height: 0)
        
        // Subviews in InputHStackView
        self.addButton?
            .sbu_constraint(width: 32, height: 38)
        
        // leading/trailing spacing for textview
        self.textViewLeadingPaddingView
            .sbu_constraint(width: self.textViewLeadingSpacing)
        
        self.textViewTrailingPaddingView
            .sbu_constraint(width: self.textViewTrailingSpacing)
        
        self.sendButton?
            .sbu_constraint(width: 32, height: 38)
        
        self.voiceMessageButton?
            .sbu_constraint(width: 32, height: 38)
        
        // Subivews in InputContentView
        self.textView?
            .sbu_constraint(equalTo: self.inputContentView, leading: 0, trailing: 0, top: 0, bottom: 0)
        
        if let textView = self.textView {
            self.placeholderLabel
                .sbu_constraint(equalTo: textView, leading: 14, top: 10)
            self.setupTextViewHeight(textView: textView)
        }
        
        // Subviews in ContentVStackView
        self.divider
            .sbu_constraint(height: 1)
        
        self.quoteMessageView?
            .sbu_constraint(height: 56)
        
        // Subviews in ContentHStackView
        self.leadingPaddingView
            .sbu_constraint(width: self.leadingSpacing)
        
        self.trailingPaddingView
            .sbu_constraint(width: self.trailingSpacing)
        
        // ContentVStackView
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
        
        // baseStackView
        self.baseStackView
            .sbu_constraint(
                equalTo: self,
                leading: 0,
                trailing: 0,
                top: 0,
                bottom: 0
            )
    }
    
    /// This function handles the initialization of styles.
    open override func setupStyles() {
        let theme = self.isOverlay ? self.overlayTheme : self.theme
        
        self.backgroundColor = theme.backgroundColor

        // placeholderLabel
        self.placeholderLabel.font = theme.textFieldPlaceholderFont
        if self.isFrozen {
            self.placeholderLabel.text = SBUStringSet.MessageInput_Text_Unavailable
            self.placeholderLabel.textColor = theme.textFieldDisabledColor
        } else if self.isMuted {
            self.placeholderLabel.text = SBUStringSet.MessageInput_Text_Muted
            self.placeholderLabel.textColor = theme.textFieldDisabledColor
        } else if self.isDisable {
            self.placeholderLabel.text = SBUStringSet.MessageInput_Text_Unavailable
            self.placeholderLabel.textColor = theme.textFieldDisabledColor
        } else if self.isThreadFirstMessage {
            self.placeholderLabel.text = SBUStringSet.MessageThread.MessageInput.replyInThread
            self.placeholderLabel.textColor = theme.textFieldPlaceholderColor
        } else if self.isThreadMessage {
            self.placeholderLabel.text = SBUStringSet.MessageThread.MessageInput.replyToThread
            self.placeholderLabel.textColor = theme.textFieldPlaceholderColor
        } else if self.mode == .quoteReply {
            self.placeholderLabel.text = SBUStringSet.MessageInput_Text_Reply
            self.placeholderLabel.textColor = theme.textFieldPlaceholderColor
        } else {
            self.placeholderLabel.text = SBUStringSet.MessageInput_Text_Placeholder
            self.placeholderLabel.textColor = theme.textFieldPlaceholderColor
        }

        // textView
        self.textView?.backgroundColor = theme.textFieldBackgroundColor
        self.textView?.tintColor = theme.textFieldTintColor
        self.textView?.layer.borderColor = theme.textFieldBorderColor.cgColor
        self.textView?.typingAttributes = defaultAttributes
        
        // addButton
        let iconAdd = SBUIconSetType.iconAdd
            .image(with: (self.isFrozen || self.isMuted || self.isDisable)
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
        
        // IconVoiceMessage
        self.voiceMessageButton?.setImage(
            SBUIconSetType.iconVoiceMessageOn.image(
                with: (self.isFrozen || self.isMuted || self.isDisable)
                ? theme.buttonDisabledTintColor
                : theme.buttonTintColor,
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
    }
    
    // MARK: - Edit View
    public func startEditMode(text: String) {
        self.textView?.text = text
        self.basedText = text
        self.placeholderLabel.isHidden = !text.isEmpty

        self.addButton?.isHidden = true
        self.addButton?.alpha = 0
        
        self.sendButton?.isHidden = !showsSendButton
        self.voiceMessageButton?.isHidden = true
        self.textViewTrailingPaddingView.isHidden = !showsSendButton
        
        self.editView.isHidden = false
        self.editView.alpha = 1

        self.updateTextViewHeight()
        let bottom = NSRange(location: (self.textView?.text.count ?? 0) - 1, length: 1)
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
        
        self.textViewTrailingPaddingView.isHidden = (!showsSendButton && !showsVoiceMessageButton)
        self.voiceMessageButton?.isHidden = !showsVoiceMessageButton
        
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
        self.voiceMessageButton?.isEnabled = !self.isFrozen
        
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
        self.voiceMessageButton?.isEnabled = !self.isMuted
        
        if self.isMuted {
            self.endTypingMode()
        }
        self.setupStyles()
    }
    
    /// Sets disable chat input value
    /// - Parameter isDisable: `true` is disable mode, `false` is available mode
    func setDisableChatInputState(_ isDisable: Bool) {
        if SendbirdUI.config.groupChannel.channel.isSuggestedRepliesEnabled == false { return }
        if self.isMuted || self.isFrozen { return }
            
        self.isDisable = isDisable
        
        self.textView?.isEditable = !self.isDisable
        self.textView?.isUserInteractionEnabled = !self.isDisable
        self.addButton?.isEnabled = !self.isDisable
        self.voiceMessageButton?.isEnabled = !self.isDisable
        
        if self.isDisable {
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
        self.placeholderLabel.isHidden = false
        self.sendButton?.isHidden = !showsSendButton
        self.voiceMessageButton?.isHidden = !showsVoiceMessageButton
        self.textViewTrailingPaddingView.isHidden = (!showsSendButton && !showsVoiceMessageButton)
        self.setMode(.none)
        self.updateTextViewHeight()
        self.layoutIfNeeded()
    }
    
    /// Setup textview's initial height.
    /// The initial height will be set to the `textViewMinHeight` value.
    ///
    /// - Parameter textView: Your input text view.
    /// - Since: 2.1.1
    public func setupTextViewHeight(textView: UIView) {
        self.textViewHeightConstraint?.isActive = false
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
    
    /// Updates textview's placeholder text depending on the status.
    /// - Since: 3.3.0
    public func updatePlaceholderText() {
        if self.isFrozen {
            self.placeholderLabel.text = SBUStringSet.MessageInput_Text_Unavailable
        } else if self.isMuted {
            self.placeholderLabel.text = SBUStringSet.MessageInput_Text_Muted
        } else if self.isThreadFirstMessage {
            self.placeholderLabel.text = SBUStringSet.MessageThread.MessageInput.replyInThread
        } else if self.isThreadMessage {
            self.placeholderLabel.text = SBUStringSet.MessageThread.MessageInput.replyToThread
        } else if self.mode == .quoteReply {
            self.placeholderLabel.text = SBUStringSet.MessageInput_Text_Reply
        } else {
            self.placeholderLabel.text = SBUStringSet.MessageInput_Text_Placeholder
        }
    }

    // MARK: - Action
    
    @objc open func onTapAddButton(_ sender: Any) {
        self.endEditing(true)
        let items = self.generateResourceItems()
        SBUActionSheet.show(
            items: items,
            cancelItem: self.cancelItem,
            oneTimetheme: isOverlay ? SBUComponentTheme.dark : nil,
            delegate: self
        )
        self.delegate?.messageInputViewDidSelectAdd(self)
    }
    
    /// Generates resource items
    /// - Returns: resource items
    ///
    /// - Since: 3.6.0
    open func generateResourceItems() -> [SBUActionSheetItem] {
        var items: [SBUActionSheetItem] = []
        var inputConfig: SBUConfig.BaseInput?
        
        if self.channelType == .group {
            inputConfig = SendbirdUI.config.groupChannel.channel.input
        } else if self.channelType == .open {
            inputConfig = SendbirdUI.config.openChannel.channel.input
        }
        
        guard let inputConfig = inputConfig else { return items }
        
        if inputConfig.camera.isPhotoEnabled || inputConfig.camera.isVideoEnabled {
            items.append(self.cameraItem)
        }
        if inputConfig.gallery.isPhotoEnabled || inputConfig.gallery.isVideoEnabled {
            items.append(self.libraryItem)
        }
        if inputConfig.isDocumentEnabled {
            items.append(self.documentItem)
        }
        
        return items
    }
    
    @objc open func onTapSendButton(_ sender: Any) {
        self.delegate?.messageInputView(
            self,
            didSelectSend: self.textView?.text.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        )
        self.endTypingMode()
        self.placeholderLabel.isHidden = !(self.textView?.text.isEmpty ?? true)
        self.updateTextViewHeight()
    }
    
    /// Shows voice message input view
    /// - Parameter sender: Button
    /// - Since: 3.4.0
    @objc open func onTapVoiceMessageButton(_ sender: Any) {
        self.delegate?.messageInputViewDidTapVoiceMessage(self)
        self.endEditing(true)
    }
        
    @objc open func onTapCancelButton(_ sender: Any) {
        self.setMode(.none)
    }
    
    @objc open func onTapSaveButton(_ sender: Any) {
        let editedText = self.textView?.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard basedText != editedText else {
            self.endEditMode()
            self.delegate?.messageInputViewDidEndTyping()
            return
        }
        self.delegate?.messageInputView(
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
            
            self.sendButton?.isHidden = (!showsSendButton &&
                text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            self.voiceMessageButton?.isHidden = !(showsVoiceMessageButton && (self.sendButton?.isHidden ?? false))
            self.textViewTrailingPaddingView.isHidden = (self.sendButton?.isHidden == true) && (self.voiceMessageButton?.isHidden == true)
            self.layoutIfNeeded()
        }
        
        self.delegate?.messageInputView(self, didChangeText: text)
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        self.delegate?.messageInputViewDidEndTyping()
    }

    public func textView(_ textView: UITextView,
                         shouldChangeTextIn range: NSRange,
                         replacementText text: String) -> Bool {
        if text.count > 0 {
            self.delegate?.messageInputViewDidStartTyping()
        } else if text.isEmpty, textView.text?.count ?? 0 <= 1 {
            self.delegate?.messageInputViewDidEndTyping()
        }

        return self.delegate?.messageInputView(
            self,
            shouldChangeTextIn: range,
            replacementText: text
        ) ?? true
    }
    
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return self.delegate?.messageInputView(
            self,
            shouldInteractWith: URL,
            in: characterRange,
            interaction: interaction
        ) ?? true
    }
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
        self.delegate?.messageInputView(self, didChangeSelection: textView.selectedRange)
    }

    // MARK: - SBUActionSheetDelegate
    open func didSelectActionSheetItem(index: Int, identifier: Int) {
        let type = MediaResourceType.init(rawValue: index) ?? .unknown
        switch type {
        case .camera:
            SBUPermissionManager.shared.requestCameraAccess(for: .video) { [weak self] in
                guard let self = self else { return }
                self.delegate?.messageInputView(self, didSelectResource: type)
            } onDenied: { [weak self] in
                guard let self = self else { return }
                self.delegate?.messageInputView(self, didSelectResource: type)
            }
        case .library:
            SBUPermissionManager.shared.requestPhotoAccessIfNeeded { _ in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.messageInputView(self, didSelectResource: type)
                }
            }
        default:
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.messageInputView(self, didSelectResource: type)
            }
        }
    }
    
    open func didDismissActionSheet() { }
    
    // MARK: - Deprecated
    @available(*, deprecated, renamed: "onTapAddButton")
    @objc open func onClickAddButton(_ sender: Any) {
        self.onTapAddButton(sender)
    }
    
    @available(*, deprecated, renamed: "onTapSendButton")
    @objc open func onClickSendButton(_ sender: Any) {
        self.onTapSendButton(sender)
    }
    
    @available(*, deprecated, renamed: "onTapCancelButton")
    @objc open func onClickCancelButton(_ sender: Any) {
        self.onTapCancelButton(sender)
    }
    
    @available(*, deprecated, renamed: "onTapSaveButton")
    @objc open func onClickSaveButton(_ sender: Any) {
        self.onTapSaveButton(sender)
    }

}

extension SBUMessageInputView: SBUQuoteMessageInputViewDelegate {
    func didTapClose() {
        self.setMode(.none)
    }
}
