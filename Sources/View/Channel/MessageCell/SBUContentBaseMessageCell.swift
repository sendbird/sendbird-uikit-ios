//
//  SBUContentBaseMessageCell.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2020/08/27.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// It is a base class used in message cell with contents.
/// - Since: 1.2.1

open class SBUContentBaseMessageCell: SBUBaseMessageCell {
    // MARK: - Public property
    public var useReaction = false
    public var useQuotedMessage = false
    public var useThreadInfo = false
    
    /// The boolean value that decides whether to enable a long press on a reaction emoji.
    /// If `true`, a member list for each reaction emoji is shown.
    /// - Since: 3.19.0
    public var enableEmojiLongPress = true
    
    // MARK: Views: Controls
    public lazy var userNameView: UIView = {
        let userNameView = SBUUserNameView()
        userNameView.leftMargin = 50
        return userNameView
    }()
    
    /// - Since: 3.12.0
    public lazy var profilesStackView: SBUStackView = {
        return SBUStackView(axis: .horizontal, alignment: .fill, spacing: -6)
    }()
    public lazy var profileView: UIView = SBUMessageProfileView()
    public lazy var stateView: UIView = SBUMessageStateView()
    
    #if SWIFTUI
    /// A hostingView for senderProfileImage.
    /// If this is non-nil, it means that SwiftUI View was set for senderProfileImage.
//    var profileHostingView: UIView?
    #endif
    
    // MARK: Views: Layouts
    
    // + ----------------- +
    // | userNameView      |
    // + ----------------- +
    // | contentHStackView |
    // + ----------------- +
    /// A vertical stack view that contains `userNameView` and `contentHStackView` as defaults.
    ///
    /// As a default, it has following configuration:
    /// - axis: `.vertical`
    /// - spacing: `4`
    public lazy var userNameStackView: UIStackView = {
        return SBUStackView(axis: .vertical, spacing: 4)
    }()
    
    // + -------------+-----------------------+-------------------+
    // | profileView  | profileContentSpacing | contentVStackView |
    // + -------------+-----------------------+-------------------+
    /// A horizontal stack view that contains `profileView`, `profileContentSpacing` and `contentVStackView` as defaults.
    ///
    /// As a default, it has following configuration:
    /// - axis: `.horizontal`
    /// - alignment: `.bottom`
    /// - spacing: `4`
    public lazy var contentHStackView: UIStackView = {
        return SBUStackView(axis: .horizontal, alignment: .bottom, spacing: 4)
    }()
    
    // + ----------------- +
    // | quotedMessageView |
    // + ----------------- +
    // | messageHStackView |
    // + ----------------- +
    /// A vertical stack view that contains `quotedMessageView` and `messageHStackView` as defaults.
    ///
    /// As a default, it has following configuration:
    /// - axis: `.vertical`
    /// - alignment: `.leading` or `.trailing` (following `self.position`)
    /// - spacing: `-6`
    public lazy var contentVStackView: UIStackView = {
        return SBUStackView(
            axis: .vertical,
            alignment: self.position == .left ? .leading : .trailing,
            spacing: -6
        )
    }()
    
    public lazy var quotedMessageView: (UIView & SBUQuotedMessageViewProtocol)? = SBUQuotedBaseMessageView()
    
    // + ------------------+----------------+
    // | threadInfoSpacing | threadInfoView |
    // + ------------------+----------------+
    /// A horizontal stack view that contains `threadInfoSpacing` and `threadInfoView` as defaults.
    ///
    /// As a default, it has following configuration:
    /// - axis: `.horizontal`
    /// - alignment: `.center`
    /// - spacing: `0`
    public lazy var threadHStackView: UIStackView = {
        return SBUStackView(axis: .horizontal, alignment: .center, spacing: 0)
    }()
    
    public private(set) lazy var threadInfoSpacing: UIView = UIView()
    public lazy var threadInfoView: (UIView & SBUThreadInfoViewProtocol)? = SBUThreadInfoView()
    
    // + ----------------------- + --------- +
    // | mainContainerVStackView | stateView |
    // + ----------------------- + --------- +
    /// A horizontal stack view that contains `mainContainerVStackView` and `stateView` as defaults.
    ///
    /// As a default, it has ollowing  configuration:
    /// - axis: `.horizontal`
    /// - alignment: `.bottom`
    /// - spacing: `4`
    public lazy var messageHStackView: UIStackView = {
        return SBUStackView(axis: .horizontal, alignment: .bottom, spacing: 4)
    }()
    
    /// Type specifying the maximum width of the message view
    /// - Since: 3.21.0
    @available(*, deprecated, message: "`containerType` has been deprecated since 3.27.2.")
    var containerType: SBUMessageContainerType { .default }
    
    /// Used when the containertype is wide, to place state view below the message bubble.
    /// - Since: 3.21.0
    @available(*, deprecated, message: "`wideSizeStateContainerView` has been deprecated since 3.27.2.")
    lazy var wideSizeStateContainerView: UIStackView = {
        return SBUStackView(axis: .horizontal, alignment: .center, spacing: 12)
    }()
    
    /// This is the view used to display the state view after spacing out the profile area in the `wideSizeStateContainerView`.
    /// - Since: 3.21.0
    @available(*, deprecated, message: "`wideSizeProfileSpaceView` has been deprecated since 3.27.2.")
    lazy var wideSizeProfileSpaceView: UIView = {
        return UIView()
    }()
    
    /// The fullSizeMessageContainerView is attached as an overlay.
    /// - Since: 3.21.0
    @available(*, deprecated, message: "`fullSizeMessageContainerView` has been deprecated since 3.27.2.")
    lazy var fullSizeMessageContainerView: UIStackView = {
        return SBUStackView(axis: .vertical, alignment: .fill, spacing: 4)
    }()

    // fullSizeMessageConstraints exists as a property to handle active/deactive.
    /// - Since: 3.21.0
    @available(*, deprecated, message: "`fullSizeMessageConstraints` has been deprecated since 3.27.2.")
    var fullSizeMessageConstraints: [NSLayoutConstraint] = [] {
        didSet {
            NSLayoutConstraint.deactivate(oldValue)
        }
    }
    
    // + ----------------- +
    // | mainContainerView |
    // + ----------------- +
    // | additional views  |
    // + ----------------- +
    /// A horizontal stack view that contains `mainContainerView` and some other additional views as defaults.
    ///
    /// As a default, it has ollowing  configuration:
    /// - axis: `.vertical`
    /// - alignment: `.bottom`
    /// - spacing: `8`
    /// - Since: 3.11.0
    public lazy var mainContainerVStackView: UIStackView = {
        return SBUStackView(axis: .vertical, alignment: .leading, spacing: 8)
    }()
    
    /// A ``SBUSelectableStackView`` that represents a message bubble.
    open lazy var mainContainerView: SBUSelectableStackView = {
        let mainView = SBUSelectableStackView()
        mainView.layer.cornerRadius = 16
        mainView.layer.borderColor = UIColor.clear.cgColor
        mainView.layer.borderWidth = 1
        mainView.clipsToBounds = true
        mainView.position = self.position
        return mainView
    }()
    
    /// Update the radius of the mainContainerView to the default value.
    /// - Since: 3.21.0
    public func resetMainContainerViewLayer() {
        self.mainContainerView.layer.cornerRadius = 16
        self.mainContainerView.layer.borderColor = UIColor.clear.cgColor
        self.mainContainerView.layer.borderWidth = 1
        self.mainContainerView.clipsToBounds = true
    }
    
    /// A ``SBUMessageReactionView`` that shows reactions on the message.
    public var reactionView: SBUMessageReactionView = SBUMessageReactionView()
    
    public private(set) lazy var profileContentSpacing: UIView = UIView()
    
    /// A view that is a spacer in `messageHStackView`.
    public let messageSpacing = UIView()
    
    // MARK: - Gesture Recognizers
    
    lazy var contentLongPressRecognizer: UILongPressGestureRecognizer = {
        return .init(target: self, action: #selector(self.onLongPressContentView(sender:)))
    }()
    
    lazy var contentTapRecognizer: UITapGestureRecognizer = {
        return .init(target: self, action: #selector(self.onTapContentView(sender:)))
    }()
    
    // MARK: - View Lifecycle
    open override func setupViews() {
        super.setupViews()
        
        self.userNameView.isHidden = true
        self.profileView.isHidden = true
        self.profilesStackView.isHidden = true
        self.quotedMessageView?.isHidden = true
        self.threadHStackView.isHidden = true
        
        // + --------------------------------------------------------------+
        // | userNameView                                                  |
        // + ------------------+-----------------------+-------------------+
        // | profilesStackView | profileContentSpacing | quotedMessageView |
        // |                   |                       +-------------------+
        // |                   |                       | messageHStackView |
        // + ------------------+-----------------------+-------------------+
        // | threadInfoSpacing                         | threadInfoView    |
        // + ------------------------------------------+-------------------+
        // | wideSizeStateContainerView                                    |
        // + --------------------------------------------------------------+
        
        self.userNameStackView.setVStack([
            self.userNameView,
            self.contentHStackView.setHStack([
                self.profilesStackView.setHStack([
                    self.profileView
                ]),
                self.profileContentSpacing,
                self.contentVStackView.setVStack([
                    self.quotedMessageView,
                    self.messageHStackView.setHStack([
                        self.mainContainerVStackView.setVStack([
                            self.mainContainerView,
                        ]),
                        self.stateView,
                        self.messageSpacing
                    ])
                ])
            ]),
            self.threadHStackView.setHStack([
                self.threadInfoSpacing,
                self.threadInfoView
            ])
        ])

        self.messageContentView
            .addSubview(self.userNameStackView)
    }
    
    open override func setupLayouts() {
        self.profileContentSpacing.sbu_constraint(width: 4, height: 4)
        
        self.threadInfoSpacing.sbu_constraint(width: 4 + 20 + 4)

        self.userNameStackView
            .sbu_constraint(equalTo: self.messageContentView, left: 12, right: 12, bottom: 0)
            .sbu_constraint(equalTo: self.messageContentView, top: 0, priority: .defaultLow)
                
        super.setupLayouts()
    }
    
    open override func setupActions() {
        super.setupActions()

        self.stateView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.onTapContentView(sender:)))
        )

        self.profileView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.onTapUserProfileView(sender:)))
        )

        self.reactionView.emojiTapHandler = { [weak self] emojiKey in
            guard let self = self else { return }
            self.emojiTapHandler?(emojiKey)
        }

        self.reactionView.emojiLongPressHandler = { [weak self] emojiKey in
            guard let self = self else { return }
            self.emojiLongPressHandler?(emojiKey)
        }

        self.reactionView.moreEmojiTapHandler = { [weak self] in
            guard let self = self else { return }
            self.moreEmojiTapHandler?()
        }
        
        self.reactionView.errorHandler = { [weak self] error in
            guard let self = self else { return }
            self.errorHandler?(error)
        }
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
        self.resetMainContainerViewLayer()
        self.mainContainerView.leftBackgroundColor = self.theme.leftBackgroundColor
        self.mainContainerView.leftPressedBackgroundColor = self.theme.leftPressedBackgroundColor
        self.mainContainerView.rightBackgroundColor = self.theme.rightBackgroundColor
        self.mainContainerView.rightPressedBackgroundColor = self.theme.rightPressedBackgroundColor
        
        self.mainContainerView.setupStyles()
        self.reactionView.setupStyles()
        
        if let userNameView = self.userNameView as? SBUUserNameView {
            userNameView.setupStyles()
        }
        
        if let profileView = self.profileView as? SBUMessageProfileView {
            profileView.theme = self.theme
            profileView.setupStyles()
        }
        
        if let stateView = self.stateView as? SBUMessageStateView {
            stateView.setupStyles()
        }
        
        if let threadInfoView = self.threadInfoView as? SBUThreadInfoView {
            threadInfoView.setupStyles(theme: self.theme)
        }
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        
        if let profileView = self.profileView as? SBUMessageProfileView {
            profileView.imageDownloadTask?.cancel()
            profileView.urlString = ""
            profileView.imageView.image = nil
        }
    }
    
    // MARK: - Common
    
    open override func configure(with configuration: SBUBaseMessageCellParams) {
        // nil for super/broadcast channel which doesn't support receipts.
        // Kept receipt to .none for backward compatibility as this configure() is *open*.
        // MARK: Configure base message cell
        super.configure(with: configuration)
        
        guard let message = self.message else { return }
        
        // MARK: Configure reaction view
        let params = SBUMessageReactionViewParams(
            maxWidth: SBUConstant.imageSize.width,
            useReaction: self.useReaction,
            reactions: message.reactions,
            enableEmojiLongPress: self.enableEmojiLongPress,
            message: message
        )
        self.reactionView.configure(configuration: params)
        
        // MARK: update UI with message position
        
        self.contentVStackView.alignment = self.position == .left
        ? .leading
        : .trailing
        
        self.mainContainerView.position = self.position
        self.mainContainerView.isSelected = false
        
        // MARK: Set up SBU user name view
        if let userNameView = self.userNameView as? SBUUserNameView {
            var username = ""
            if let sender = message.sender {
                username = SBUUser(user: sender).refinedNickname()
            }
            userNameView.configure(username: username)
        }
        
        // MARK: Set up SBU message profile view
        self.profileView.isHidden = self.position == .right
        self.profilesStackView.isHidden = self.position == .right
        
        if configuration.messagePosition != .right {
            self.configureMessageProfileViews(message: message)
        }
        
//        let usingProfileView = !(
//            SBUGlobals.isMessageGroupingEnabled &&
//            (configuration.groupPosition == .top || configuration.groupPosition == .middle)
//        )
        
        // MARK: Set up SBU message state view
        if self.stateView is SBUMessageStateView {
            let isQuotedReplyMessage = (self.useQuotedMessage ? message.parentMessage != nil : false)
            let configuration = SBUMessageStateViewParams(
                timestamp: message.createdAt,
                sendingState: message.sendingStatus,
                receiptState: self.receiptState,
                position: self.position,
                isQuotedReplyMessage: isQuotedReplyMessage
            )
            self.stateView.removeFromSuperview()
            self.stateView = SBUMessageStateView(
                isQuotedReplyMessage: isQuotedReplyMessage
            )
            (self.stateView as? SBUMessageStateView)?.configure(with: configuration)
        }
        
        if self.useQuotedMessage {
            self.setupQuotedMessageView(
                joinedAt: configuration.joinedAt,
                messageOffsetTimestamp: configuration.messageOffsetTimestamp
            )
        } else {
            self.quotedMessageView?.isHidden = true
        }
        
        if self.useThreadInfo {
            self.setupThreadInfoView()
            self.threadHStackView.isHidden = false
        } else {
            self.threadHStackView.isHidden = true
        }
        
        // MARK: Group messages
        self.setMessageGrouping()
    }
    
    public func setupQuotedMessageView(joinedAt: Int64 = 0, messageOffsetTimestamp: Int64 = 0) {
        guard self.quotedMessageView != nil,
              let message = self.message,
              let quotedMessage = self.message?.parentMessage else { return }
        let configuration = SBUQuotedBaseMessageViewParams(
            message: message,
            position: self.position,
            useQuotedMessage: self.useQuotedMessage,
            joinedAt: joinedAt,
            messageOffsetTimestamp: messageOffsetTimestamp
        )
        guard self.quotedMessageView is SBUQuotedBaseMessageView else {
            // For customized parent message view.
            self.quotedMessageView?.configure(with: configuration)
            return
        }
        
        let isMessageUnavailable = (
            (message.parentMessage?.createdAt ?? 0) < messageOffsetTimestamp
            && SendbirdUI.config.groupChannel.channel.replyType == .thread
        )

        let userMessageBlock = {
            if !(self.quotedMessageView is SBUQuotedUserMessageView) {
                self.contentVStackView.arrangedSubviews.forEach {
                    $0.removeFromSuperview()
                }
                self.quotedMessageView = SBUQuotedUserMessageView()
                self.contentVStackView.setVStack([
                    self.quotedMessageView,
                    self.messageHStackView
                ])
            }
            (self.quotedMessageView as? SBUQuotedUserMessageView)?.configure(with: configuration)
        }
        
        switch quotedMessage {
        case is UserMessage: 
            userMessageBlock()
        case is FileMessage, is MultipleFilesMessage: 
            if isMessageUnavailable {
                userMessageBlock()
            }
            if !(self.quotedMessageView is SBUQuotedFileMessageView) {
                self.contentVStackView.arrangedSubviews.forEach {
                    $0.removeFromSuperview()
                }
                self.quotedMessageView = SBUQuotedFileMessageView()
                self.contentVStackView.setVStack([
                    quotedMessageView,
                    messageHStackView
                ])
            }
            (self.quotedMessageView as? SBUQuotedFileMessageView)?.configure(with: configuration)
        default:
            self.quotedMessageView?.removeFromSuperview()
        }
        self.updateContentsPosition()
    }
    
    /// Set up the thread info view.
    /// - Since: 3.3.0
    public func setupThreadInfoView() {
        guard self.threadInfoView != nil,
              let message = self.message else { return }
        
        self.threadInfoView?.configure(with: message, messagePosition: self.position)
    }
    
    public func setMessageGrouping() {
        let isMessageGroupingEnabled = SBUGlobals.isMessageGroupingEnabled
        let profileImageView = (self.profileView as? SBUMessageProfileView)?.imageView
        let timeLabel = (self.stateView as? SBUMessageStateView)?.timeLabel
        
        switch self.groupPosition {
        case .top:
            self.userNameView.isHidden = false
            profileImageView?.isHidden = isMessageGroupingEnabled
            timeLabel?.isHidden = isMessageGroupingEnabled
        case .middle:
            self.userNameView.isHidden = isMessageGroupingEnabled
            profileImageView?.isHidden = isMessageGroupingEnabled
            timeLabel?.isHidden = isMessageGroupingEnabled
        case .bottom:
            self.userNameView.isHidden = isMessageGroupingEnabled
            profileImageView?.isHidden = false
            timeLabel?.isHidden = false
        case .none:
            self.userNameView.isHidden = false
            profileImageView?.isHidden = false
            timeLabel?.isHidden = false
        }
        
        if self.position == .right {
            self.userNameView.isHidden = true
            self.profileView.isHidden = true
            self.profilesStackView.isHidden = true
        }
        
        self.updateContentsPosition()
    }
    
    open func updateContentsPosition() {
        self.contentHStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        
        self.contentVStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        
        self.messageHStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        
        self.threadHStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        
        switch self.position {
        case .left:
            self.userNameStackView.alignment = .leading
            self.mainContainerVStackView.alignment = .leading
            self.messageHStackView.setHStack([
                self.mainContainerVStackView.setVStack([
                    self.mainContainerView,
                ]),
                self.stateView,
                self.messageSpacing
            ])
            self.contentVStackView.setVStack([
                self.quotedMessageView,
                self.messageHStackView
            ])
            self.contentHStackView.setHStack([
                self.profilesStackView,
                self.profileContentSpacing,
                self.contentVStackView
            ])
            #if SWIFTUI
            if self.configuration?.isThreadMessage == false {
                self.applyViewConverter(.senderProfileImage)
            } else {
                self.applyViewConverterForMessageThread(.senderProfileImage)
            }
            #endif
            self.threadHStackView.setHStack([
                self.threadInfoSpacing,
                self.threadInfoView
            ])
            
        case .right:
            self.userNameStackView.alignment = .trailing
            self.mainContainerVStackView.alignment = .trailing
            self.messageHStackView.setHStack([
                self.messageSpacing,
                self.stateView,
                self.mainContainerVStackView.setVStack([
                    self.mainContainerView,
                ]),
            ])
            self.contentVStackView.setVStack([
                self.quotedMessageView,
                self.messageHStackView
            ])
            self.contentHStackView.setHStack([
                self.contentVStackView,
                self.profileContentSpacing
            ])
            self.threadHStackView.setHStack([
                self.threadInfoView
            ])
            
        case .center:
            break
        }
        
        if self.useQuotedMessage {
            self.userNameView.isHidden = true
        }
        
        self.updateTopAnchorConstraint()
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.mainContainerView.isSelected = selected
    }
    
    /// Configures message profile views for different message types.
    /// - Since: 3.12.0
    public func configureMessageProfileViews(message: BaseMessage) {
        // Set profileViews for TypingIndicatorMessage.
        if let message = message as? SBUTypingIndicatorMessage,
           let typingInfo = message.typingIndicatorInfo {
            self.configureTyperProfileViews(typingInfo: typingInfo)
        } 
        
        // Set profileView for other message types.
        else {
            self.configureUserProfileView(message: message)
        }
    }
    
    /// Configures profile views for typers.
    /// - Note: Override this method to customize typer profile views.
    /// - Since: 3.12.0
    open func configureTyperProfileViews(typingInfo: SBUTypingIndicatorInfo) {
        var profileViews = [SBUMessageProfileView]()
        
        for user in typingInfo.typers {
            let profileView = SBUMessageProfileView()
            profileView.theme = theme
            profileView.setupStyles()
            profileView.configure(urlString: user.profileURL ?? "", imageSize: 30)
            profileView.configureTyperProfileImageView()
            profileViews.append(profileView)
        }
        
        if SBUConstant.maxNumberOfProfileImages < typingInfo.numberOfTypers {
            let profileView = SBUMessageProfileView()
            profileView.theme = theme
            profileView.setupStyles()
            
            profileView.configure(urlString: "", imageSize: 30)
            profileView.configureNumberLabel(typingInfo.numberOfTypers)
            
            profileViews.append(profileView)
        }
        
        profilesStackView.setHStack(profileViews)
    }
    
    /// Configure profile views for the user who sent the message.
    /// Override this method to customize user profile views.
    /// - Since: 3.12.0
    open func configureUserProfileView(message: BaseMessage) {
        if let profileView = self.profileView as? SBUMessageProfileView {
            let urlString = message.sender?.profileURL ?? ""
            profileView.configure(urlString: urlString)
        }
    }
        
    // MARK: - Action
    @objc
    open func onLongPressContentView(sender: UILongPressGestureRecognizer?) {
        if let sender = sender {
            if sender.state == .began {
                self.longPressHandlerToContent?()
            }
        } else {
            self.longPressHandlerToContent?()
        }
    }
    
    @objc
    open func onTapContentView(sender: UITapGestureRecognizer) {
        self.tapHandlerToContent?()
    }
    
    @objc
    open func onTapUserProfileView(sender: UITapGestureRecognizer) {
        self.userProfileTapHandler?()
    }
    
    @available(*, deprecated, renamed: "configure(message:configuration:)") // 2.2.0
    open func configure(_ message: BaseMessage,
                        hideDateView: Bool,
                        position: MessagePosition,
                        groupPosition: MessageGroupPosition,
                        receiptState: SBUMessageReceiptState?) {
        let configuration = SBUBaseMessageCellParams(
            message: message,
            hideDateView: hideDateView,
            messagePosition: position,
            groupPosition: groupPosition,
            receiptState: receiptState ?? .none
        )
        self.configure(with: configuration)
    }
}
