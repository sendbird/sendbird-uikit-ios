//
//  SBUUserMessageCell.swift
//  SendbirdUIKit
//
//  Created by Harry Kim on 2020/02/20.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

@IBDesignable
open class SBUUserMessageCell: SBUContentBaseMessageCell, SBUUserMessageTextViewDelegate, SBUSuggestedReplyViewDelegate, SBUFormViewDelegate {
    // MARK: - Public property
    public lazy var messageTextView: UIView = SBUUserMessageTextView()
    
    public var userMessage: UserMessage? {
        self.message as? UserMessage
    }
    
    // + ------------ +
    // | reactionView |
    // + ------------ +
    /// A ``SBUSelectableStackView`` that contains `reactionView`.
    public private(set) var additionContainerView: SBUSelectableStackView = {
        let view = SBUSelectableStackView()
        return view
    }()
    
    /// A ``SBUMessageWebView`` which represents a preview of the web link
    public var webView: SBUMessageWebView = {
        let webView = SBUMessageWebView()
        return webView
    }()
    
    // MARK: - Quick Reply
    
    /// The boolean value whether the ``suggestedReplyView`` instance should appear or not. The default is `true`
    /// - Important: If it's true, ``suggestedReplyView`` never appears even if the ``userMessage`` has quick reply options.
    /// - Since: 3.11.0
    public private(set) var shouldHideSuggestedReplies: Bool = true

    /// ``SBUSuggestedReplyView`` instance.
    /// If you want to override that view, override the ``createSuggestedReplyView()`` constructor function.
    /// - Since: 3.11.0
    public private(set) var suggestedReplyView: SBUSuggestedReplyView?
    
    // MARK: - Form Type Message
    
    /// The boolean value whether the ``formViews`` instance should appear or not. The default is `true`
    /// - Important: If it's true, ``formViews`` never appears even if the ``userMessage`` has `forms`.
    /// - Since: 3.11.0
    public private(set) var shouldHideFormTypeMessage: Bool = true
    
    /// The array of ``SBUFormView`` instance.
    /// If you want to override that view, override the ``createFormView()`` constructor function.
    /// - Since: 3.11.0
    public private(set) var formViews: [SBUFormView]?
    
    /// This is a user message custom cell factory type
    /// to support customization via the `custom_view` data in `BaseMessage.extendedMessage`.
    ///
    /// - Important:
    /// 1. This value can be ignored if you are fully customizing the `SBUUserMessageCell`.
    /// 2. It must implement the `SBUExtendedMessagePayloadCustomViewFactory` protocol instead of `SBUExtendedMessagePayloadCustomViewFactoryInternal`.
    ///
    /// See the example below for type setting.
    /// ```
    /// class CustomViewFactory:  SBUExtendedMessagePayloadCustomViewFactory {
    ///    public static func makeCustomView(
    ///        _ data: CustomViewData, // Returns data with type inference internally.
    ///        message: SendbirdChatSDK.BaseMessage?
    ///    ) -> UIView? {
    ///        switch data.type { // `data.type` is an example for explanation purposes
    ///        case .type1:
    ///            let view = CustomView1()
    ///            // bind data
    ///            return view
    ///        case .type2:
    ///            let view = CustomView2()
    ///            // bind data
    ///            return view
    ///        }
    ///    }
    /// }
    ///
    /// struct CustomData: Decodable {
    ///     let customDataField: String // your own field
    ///     ...
    ///
    ///     enum CodingKey: String, CodingKey {
    ///         case customDataField = "custom_data_field" // Required if snake case.
    ///         ...
    ///     }
    /// }
    ///
    /// class CustomUserMessageCell: SBUUserMessageCell {
    ///     override var customViewFactory: SBUCustomViewFactoryInternal.Type? {
    ///         CustomViewFactory.self
    ///     }
    /// }
    ///
    /// class CustomModuleList: SBUGroupChannelModule.List {
    ///     override func configure(
    ///         delegate: SBUGroupChannelModuleListDelegate,
    ///         dataSource: SBUGroupChannelModuleListDataSource,
    ///         theme: SBUChannelTheme
    ///     ) {
    ///         self.register(userMessageCell: CustomUserMessageCell())
    ///         super.configure(
    ///             delegate: delegate,
    ///             dataSource: dataSource,
    ///             theme: theme
    ///         )
    ///     }
    /// }
    /// ```
    /// - Since: 3.11.0
    open var extendedMessagePayloadCustomViewFactory: SBUExtendedMessagePayloadCustomViewFactoryInternal.Type? { nil }

    // MARK: - View Lifecycle
    open override func setupViews() {
        super.setupViews()
        
        (self.messageTextView as? SBUUserMessageTextView)?.delegate = self

        // + --------------- +
        // | messageTextView |
        // + --------------- +
        // | reactionView    |
        // + --------------- +
        
        self.mainContainerView.setStack([
            self.messageTextView,
            self.additionContainerView.setStack([
                self.reactionView
            ])
        ])
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
    }
    
    open override func setupActions() {
        super.setupActions()

        if let messageTextView = self.messageTextView as? SBUUserMessageTextView {
            messageTextView.longPressHandler = { [weak self] _ in
                guard let self = self else { return }
                self.onLongPressContentView(sender: nil)
            }
        }
        
        self.messageTextView.addGestureRecognizer(self.contentLongPressRecognizer)
        self.messageTextView.addGestureRecognizer(self.contentTapRecognizer)

        self.webView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.onTapWebview(sender:))
        ))
    }

    open override func setupStyles() {
        super.setupStyles()
        
        let isWebviewVisible = !self.webView.isHidden
        self.additionContainerView.leftBackgroundColor = isWebviewVisible
            ? self.theme.contentBackgroundColor
            : self.theme.leftBackgroundColor
        self.additionContainerView.leftPressedBackgroundColor = isWebviewVisible
            ? self.theme.pressedContentBackgroundColor
            : self.theme.leftPressedBackgroundColor
        self.additionContainerView.rightBackgroundColor = isWebviewVisible
            ? self.theme.contentBackgroundColor
            : self.theme.rightBackgroundColor
        self.additionContainerView.rightPressedBackgroundColor = isWebviewVisible
            ? self.theme.pressedContentBackgroundColor
            : self.theme.rightPressedBackgroundColor

        self.additionContainerView.setupStyles()
        
        self.webView.setupStyles()
        
        self.additionContainerView.layer.cornerRadius = 8
    }
    
    // MARK: - Common
    open override func configure(with configuration: SBUBaseMessageCellParams) {
        guard let configuration = configuration as? SBUUserMessageCellParams else { return }
        guard let message = configuration.userMessage else { return }
        // Set using reaction
        self.useReaction = configuration.useReaction
        
        self.useQuotedMessage = configuration.useQuotedMessage
        
        self.useThreadInfo = configuration.useThreadInfo
        self.shouldHideSuggestedReplies = configuration.shouldHideSuggestedReplies
        self.shouldHideFormTypeMessage = configuration.shouldHideFormTypeMessage

        // Configure Content base message cell
        super.configure(with: configuration)

        // MARK: Suggested Reply
        self.suggestedReplyView?.removeFromSuperview()
        self.suggestedReplyView = nil
        self.updateSuggestedReplyView(with: message.suggestedReplies)
        
        // MARK: Form Views
        self.formViews?.forEach({ $0.removeFromSuperview() })
        self.formViews = nil
        let hasForms = self.updateFormView(with: message)
        self.mainContainerView.isHidden = hasForms && configuration.useOnlyFromView
        
        // Set up message position of additionContainerView(reactionView)
        self.additionContainerView.position = self.position
        self.additionContainerView.isSelected = false
        
        // Set up SBUUserMessageTextView
        if let messageTextView = messageTextView as? SBUUserMessageTextView, configuration.withTextView {
            messageTextView.configure(
                model: SBUUserMessageTextViewModel(
                    message: message,
                    position: configuration.messagePosition
                )
            )
        }
        // Set up WebView with OG meta data
        if let ogMetaData = configuration.message.ogMetaData, SBUAvailable.isSupportOgTag() {
            self.additionContainerView.insertArrangedSubview(self.webView, at: 0)
            self.webView.isHidden = false
            let model = SBUMessageWebViewModel(metaData: ogMetaData)
            self.webView.configure(model: model)
        } else {
            self.additionContainerView.removeArrangedSubview(self.webView)
            self.webView.isHidden = true
        }
        
        // Custom Message
        if let factory = self.extendedMessagePayloadCustomViewFactory,
            let view = factory.makeCustomView(message: self.message) {
            factory.configure(with: view, cell: self)
        }
    }
    
    @available(*, deprecated, renamed: "configure(with:)") // 2.2.0
    open func configure(_ message: UserMessage,
                        hideDateView: Bool,
                        groupPosition: MessageGroupPosition,
                        receiptState: SBUMessageReceiptState?,
                        useReaction: Bool) {
        let configuration = SBUUserMessageCellParams(
            message: message,
            hideDateView: hideDateView,
            useMessagePosition: true,
            groupPosition: groupPosition,
            receiptState: receiptState ?? .none,
            useReaction: false,
            withTextView: true
        )
        self.configure(with: configuration)
    }
    
    @available(*, deprecated, renamed: "configure(with:)") // 2.2.0
    open func configure(_ message: BaseMessage,
                        hideDateView: Bool,
                        receiptState: SBUMessageReceiptState?,
                        groupPosition: MessageGroupPosition,
                        withTextView: Bool) {
        guard let userMessage = message as? UserMessage else {
            SBULog.error("The message is not a type of UserMessage")
            return
        }

        let configuration = SBUUserMessageCellParams(
            message: userMessage,
            hideDateView: hideDateView,
            useMessagePosition: true,
            groupPosition: groupPosition,
            receiptState: receiptState ?? .none,
            useReaction: self.useReaction,
            withTextView: withTextView
        )
        self.configure(with: configuration)
    }
    
    /// Adds highlight attribute to the message
    open override func configure(highlightInfo: SBUHighlightMessageInfo?) {
        // Only apply highlight for the given message, that's not edited (updatedAt didn't change)
        guard let message = self.message,
              message.messageId == highlightInfo?.messageId,
              message.updatedAt == highlightInfo?.updatedAt else { return }

        guard let messageTextView = messageTextView as? SBUUserMessageTextView else { return }

        messageTextView.configure(
            model: SBUUserMessageTextViewModel(
                message: message,
                position: position,
                highlightKeyword: highlightInfo?.keyword
            )
        )
    }
    
    // MARK: - Action
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.additionContainerView.isSelected = selected
    }

    @objc
    open func onTapWebview(sender: UITapGestureRecognizer) {
        guard
            let ogMetaData = self.userMessage?.ogMetaData,
            let urlString = ogMetaData.url,
            let url = URL(string: urlString),
            UIApplication.shared.canOpenURL(url) else {
            return
        }
        
        url.open()
    }
    
    // MARK: - Suggested Reply
    
    /// This is function to create and set up the `SBUSuggestedReplyView`.
    /// - Parameter options: The string array that configured the view list.
    /// - since: 3.11.0
    open func updateSuggestedReplyView(with options: [String]?) {
        guard SendbirdUI.config.groupChannel.channel.isSuggestedRepliesEnabled else { return }
        guard shouldHideSuggestedReplies == false else { return }
        
        guard let options = options else { return }
        guard let messageId = self.message?.messageId else { return }
        
        let suggestedReplyView = createSuggestedReplyView()
        let configuration = SBUSuggestedReplyViewParams(
            messageId: messageId,
            replyOptions: options
        )
        suggestedReplyView.configure(with: configuration, delegate: self)
        self.userNameStackView.addArrangedSubview(suggestedReplyView)
        suggestedReplyView.sbu_constraint(equalTo: self.userNameStackView, leading: 0, trailing: 0)

        self.suggestedReplyView = suggestedReplyView

        self.layoutIfNeeded()
    }
    
    /// Methods to use when you want to fully customize the design of the ``SBUSuggestedReplyView``.
    /// Create your own view that inherits from ``SBUSuggestedReplyView`` and return it.
    /// NOTE: The default view is ``SBUVerticalSuggestedReplyView``, which is a vertically organized option view.
    /// - Returns: Views that inherit from ``SBUSuggestedReplyView``.
    /// - since: 3.11.0
    open func createSuggestedReplyView() -> SBUSuggestedReplyView { SBUVerticalSuggestedReplyView() }
    
    // MARK: - form view

    /// This is function to create and set up the `[SBUFormView]`.
    /// - Parameter forms: Form list data.
    /// - Parameter answers: Cached form answer datas.
    /// - Returns: If `true`, succeeds in creating a valid form view
    /// - since: 3.11.0
    public func updateFormView(with message: BaseMessage?) -> Bool {
        guard SendbirdUI.config.groupChannel.channel.isFormTypeMessageEnabled else { return false }
        guard shouldHideFormTypeMessage == false else { return false }
        
        guard let forms = message?.forms else { return false }
        guard let messageId = message?.messageId else { return false }

        let formViews = forms.reduce(into: [SBUFormView]()) { result, form in
            let formView = createFormView()
            let configuration = SBUFormViewParams(messageId: messageId, form: form)
            formView.configure(with: configuration, delegate: self)
            result.append(formView)
        }

        formViews.forEach { self.mainContainerVStackView.addArrangedSubview($0) }

        self.formViews = formViews
        self.layoutIfNeeded()
        
        return formViews.count > 0
    }
    
    /// Methods to use when you want to fully customize the design of the ``SBUFormView``.
    /// Create your own view that inherits from ``SBUFormView`` and return it.
    /// NOTE: The default view is ``SBUSimpleFormView``, which is a vertically organized form view.
    /// - Returns: Views that inherit from ``SBUFormView``.
    /// - since: 3.11.0
    open func createFormView() -> SBUFormView { SBUSimpleFormView() }
    
    // MARK: - Mention
    /// As a default, it calls `groupChannelModule(_:didTapMentionUser:)` in ``SBUGroupChannelModuleListDelegate``.
    open func userMessageTextView(_ textView: SBUUserMessageTextView, didTapMention user: SBUUser) {
        self.mentionTapHandler?(user)
    }

    // MARK: - Suggested reply delegate
    
    open func suggestedReplyView(_ view: SBUSuggestedReplyView, didSelectOption optionView: SBUSuggestedReplyOptionView) {
        self.suggestedReplySelectHandler?(optionView)
        
        self.suggestedReplyView?.removeFromSuperview()
        self.suggestedReplyView = nil
        
        self.layoutIfNeeded()
    }

    // MARK: - form view delegate
    
    public func formView(_ view: SBUFormView, didSubmit form: SendbirdChatSDK.Form) {
        self.submitFormHandler?(form, self)
    }
}
