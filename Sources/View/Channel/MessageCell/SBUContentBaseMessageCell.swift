//
//  SBUContentBaseMessageCell.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2020/08/27.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

/// It is a base class used in message cell with contents.
/// - Since: 1.2.1
@objcMembers
open class SBUContentBaseMessageCell: SBUBaseMessageCell {
    // MARK: - Quoted Reply
    public lazy var quotedMessageView: (UIView & SBUQuotedMessageViewProtocol)? = SBUQuotedBaseMessageView()
    
    // MARK: - Public property

    // MARK: - Views: Controls
    
    public lazy var userNameView: UIView = {
        let userNameView = SBUUserNameView()
        userNameView.leftMargin = 50
        return userNameView
    }()
    
    public lazy var profileView: UIView = SBUMessageProfileView()
    public lazy var stateView: UIView = SBUMessageStateView()
    
    // MARK: Views: Layouts
    
    // + ----------------- +
    // | userNameView      |
    // + ----------------- +
    // | contentHStackView |
    // + ----------------- +
    public lazy var userNameStackView: UIStackView = {
        return SBUStackView(axis: .vertical, spacing: 4)
    }()
    
    // + -------------+-----------------------+-------------------+
    // | profileView  | profileContentSpacing | contentVStackView |
    // + -------------+-----------------------+-------------------+
    public lazy var contentHStackView: UIStackView = {
        return SBUStackView(axis: .horizontal, alignment: .bottom, spacing: 4)
    }()
    
    // MARK: Properties

    public var useReaction = false
    
    public var usingQuotedMessage = false

    // MARK: - Private property
    
    // + ----------------- +
    // | quotedMessageView |
    // + ----------------- +
    // | messageHStackView |
    // + ----------------- +
    public lazy var contentVStackView: UIStackView = {
        return SBUStackView(
            axis: .vertical,
            alignment: self.position == .left ? .leading : .trailing,
            spacing: -6
        )
    }()
    
    // + ----------------- + --------- +
    // | mainContainerView | stateView |
    // + ----------------- + --------- +
    public lazy var messageHStackView: UIStackView = {
        return SBUStackView(axis: .horizontal, alignment: .bottom, spacing: 4)
    }()
    
    public var mainContainerView: SBUSelectableStackView = {
        let mainView = SBUSelectableStackView()
        mainView.layer.cornerRadius = 16
        mainView.layer.borderColor = UIColor.clear.cgColor
        mainView.layer.borderWidth = 1
        mainView.clipsToBounds = true
        return mainView
    }()
    
    var reactionView: SBUMessageReactionView = SBUMessageReactionView()
    lazy var profileContentSpacing: UIView = UIView()
    private let messageSpacing = UIView()

    
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
        self.quotedMessageView?.isHidden = true
        
        // + ---------------------------------------------------------+
        // | userNameView                                             |
        // + -------------+-----------------------+-------------------+
        // | profileView  | profileContentSpacing | quotedMessageView |
        // |              |                       +-------------------+
        // |              |                       | messageHStackView |
        // + -------------+-----------------------+-------------------+
        
        self.userNameStackView.setVStack([
            self.userNameView,
            self.contentHStackView.setHStack([
                self.profileView,
                self.profileContentSpacing,
                self.contentVStackView.setVStack([
                    self.quotedMessageView,
                    self.messageHStackView.setHStack([
                        self.mainContainerView,
                        self.stateView,
                        self.messageSpacing
                    ])
                ])
            ])
        ])

        self.messageContentView
            .addSubview(self.userNameStackView)
    }
    
    open override func setupAutolayout() {
        super.setupAutolayout()

        NSLayoutConstraint.activate([
            self.profileContentSpacing.widthAnchor.constraint(equalToConstant: 4),
            self.profileContentSpacing.heightAnchor.constraint(equalToConstant: 4)
        ])
        
        self.userNameStackView
            .setConstraint(from: self.messageContentView, left: 12, right: 12, bottom: 0)
            .setConstraint(from: self.messageContentView, top: 0, priority: .defaultLow)
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
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
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
            profileView.setupStyles()
        }
        
        if let stateView = self.stateView as? SBUMessageStateView {
            stateView.setupStyles()
        }
    }
    
    
    // MARK: - Common
    open override func configure(with configuration: SBUBaseMessageCellParams) {
        // nil for super/broadcast channel which doesn't support receipts.
        // Kept receipt to .none for backward compatibility as this configure() is *open*.
        // MARK: Configure base message cell
        super.configure(with: configuration)
        
        // MARK: Configure reaction view
        self.reactionView.configure(
            maxWidth: SBUConstant.imageSize.width,
            useReaction: self.useReaction,
            reactions: self.message.reactions
        )
        
        // MARK: update UI with message position
        
        self.contentVStackView.alignment = self.position == .left
        ? .leading
        : .trailing
        
        self.mainContainerView.position = self.position
        self.mainContainerView.isSelected = false
        
        // MARK: Set up SBU user name view
        if let userNameView = self.userNameView as? SBUUserNameView {
            var username = ""
            if let sender = self.message.sender {
                username = SBUUser(user: sender).refinedNickname()
            }
            userNameView.configure(username: username)
        }
        
        // MARK: Set up SBU message profile view
        if let profileView = self.profileView as? SBUMessageProfileView {
            let urlString = self.message.sender?.profileUrl ?? ""
            profileView.configure(urlString: urlString)
        }
        
        // MARK: Set up SBU message state view
        if self.stateView is SBUMessageStateView {
            let isQuotedReplyMessage = self.message.parent != nil
            let configuration = SBUMessageStateViewParams(
                timestamp: self.message.createdAt,
                sendingState: self.message.sendingStatus,
                receiptState: self.receiptState,
                position: self.position,
                isQuotedReplyMessage: usingQuotedMessage ? isQuotedReplyMessage : false
            )
            self.messageHStackView.arrangedSubviews.forEach {
                $0.removeFromSuperview()
            }
            self.stateView = SBUMessageStateView(
                isQuotedReplyMessage: usingQuotedMessage
                ? isQuotedReplyMessage
                : false
            )
            self.messageHStackView.setHStack([
                self.mainContainerView,
                self.stateView,
                self.messageSpacing
            ])
            (self.stateView as? SBUMessageStateView)?.configure(with: configuration)
        }
        
        // TODO: (모듈화 할 때) 백워드가 많이 깨질거라 cell 쪽 구조를 편한 방향으로 싹 바꾸는 것도 좋아보임
        if self.usingQuotedMessage {
            self.setupQuotedMessageView()
        }
        // MARK: Group messages
        self.setMessageGrouping()
    }
    
    public func setupQuotedMessageView() {
        guard self.quotedMessageView != nil else { return }
        guard let quotedMessage = self.message.parent else { return }
        let configuration = SBUQuotedBaseMessageViewParams(
            message: self.message,
            position: self.position,
            usingQuotedMessage: self.usingQuotedMessage
        )
        guard self.quotedMessageView is SBUQuotedBaseMessageView else {
            // For customized parent message view.
            self.quotedMessageView?.configure(with: configuration)
            return
        }
        
        switch quotedMessage {
        case is SBDUserMessage :
            if !(self.quotedMessageView is SBUQuotedUserMessageView) {
                self.contentVStackView.arrangedSubviews.forEach {
                    $0.removeFromSuperview()
                }
                self.quotedMessageView = SBUQuotedUserMessageView()
                self.contentVStackView.setVStack([
                    quotedMessageView,
                    messageHStackView
                ])
            }
            (self.quotedMessageView as? SBUQuotedUserMessageView)?.configure(with: configuration)
        case is SBDFileMessage:
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
    
    public func setMessageGrouping() {
        guard SBUGlobals.UsingMessageGrouping else { return }
        guard !self.usingQuotedMessage else { return }
        self.quotedMessageView?.isHidden = true
        
        self.updateContentsPosition()
    }
    
    private func updateContentsPosition() {
        self.profileView.isHidden = self.position == .right
        
        self.contentHStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        
        self.contentVStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        
        self.messageHStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        
        switch self.position {
            case .left:
                self.userNameStackView.alignment = .leading
                self.messageHStackView.setHStack([
                    self.mainContainerView,
                    self.stateView,
                    self.messageSpacing
                ])
                self.contentVStackView.setVStack([
                    self.quotedMessageView,
                    self.messageHStackView
                ])
                self.contentHStackView.setHStack([
                    self.profileView,
                    self.profileContentSpacing,
                    self.contentVStackView
                ])
                
            case .right:
                self.userNameStackView.alignment = .trailing
                self.messageHStackView.setHStack([
                    self.messageSpacing,
                    self.stateView,
                    self.mainContainerView
                ])
                self.contentVStackView.setVStack([
                    self.quotedMessageView,
                    self.messageHStackView
                ])
                self.contentHStackView.setHStack([
                    self.contentVStackView,
                    self.profileContentSpacing
                ])
                
            case .center:
                break
        }
        
        let profileImageView = (self.profileView as? SBUMessageProfileView)?.imageView
        let timeLabel = (self.stateView as? SBUMessageStateView)?.timeLabel
        
        switch self.groupPosition {
            case .top:
                self.userNameView.isHidden = self.position == .right
                profileImageView?.isHidden = true
                timeLabel?.isHidden = true
            case .middle:
                self.userNameView.isHidden = true
                profileImageView?.isHidden = true
                timeLabel?.isHidden = true
            case .bottom:
                self.userNameView.isHidden = true
                profileImageView?.isHidden = false
                timeLabel?.isHidden = false
            case .none:
                self.userNameView.isHidden = self.position == .right
                profileImageView?.isHidden = false
                timeLabel?.isHidden = false
        }
        
        if usingQuotedMessage {
            self.userNameView.isHidden = true
        }
        
        self.updateTopAnchorConstraint()
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.mainContainerView.isSelected = selected
    }
        
    // MARK: - Action
    @objc open func onLongPressContentView(sender: UILongPressGestureRecognizer?) {
        if let sender = sender {
            if sender.state == .began {
                self.longPressHandlerToContent?()
            }
        } else {
            self.longPressHandlerToContent?()
        }
    }
    
    @objc open func onTapContentView(sender: UITapGestureRecognizer) {
        self.tapHandlerToContent?()
    }
    
    @objc open func onTapUserProfileView(sender: UITapGestureRecognizer) {
        self.userProfileTapHandler?()
    }
    
    
    @available(*, deprecated, renamed: "configure(message:configuration:)") // 2.2.0
    open func configure(_ message: SBDBaseMessage,
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
