//
//  SBUContentBaseMessageCell.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2020/08/27.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit


/// It is a base class used in message cell with contents.
/// - Since: 1.2.1
@objcMembers
open class SBUContentBaseMessageCell: SBUBaseMessageCell {
    
    // MARK: - Public property
    public lazy var userNameStackView: UIStackView = _userNameStackView
    public lazy var contentsStackView: UIStackView = _contentsStackView
    public lazy var userNameView: UIView = _userNameView
    public lazy var profileView: UIView = _profileView
    public lazy var stateView: UIView = _stateView

    // MARK: - Private property
    internal var _userNameStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    internal var _userNameView: SBUUserNameView = {
        let userNameView = SBUUserNameView()
        userNameView.leftMargin = 50
        return userNameView
    }()
    
    internal var _contentsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .bottom
        stackView.spacing = 4
        return stackView
    }()
    
    internal var _profileView: SBUMessageProfileView = {
        let profileView = SBUMessageProfileView()
        return profileView
    }()
    
    internal var _stateView: SBUMessageStateView = {
        let stateView = SBUMessageStateView()
        return stateView
    }()
    
    internal var mainContainerView: SBUSelectableStackView = {
        let mainView = SBUSelectableStackView()
        mainView.layer.cornerRadius = 16
        mainView.layer.borderColor = UIColor.clear.cgColor
        mainView.layer.borderWidth = 1
        mainView.clipsToBounds = true
        return mainView
    }()
    
    internal var reactionView: SBUMessageReactionView = {
        let reactionView = SBUMessageReactionView()
        return reactionView
    }()
    
    internal lazy var profileContentSpacing: UIView = {
        let view = UIView()
        return view
    }()
    
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
        
        self.contentsStackView.addArrangedSubview(self.profileView)
        self.contentsStackView.addArrangedSubview(self.profileContentSpacing)
        self.contentsStackView.addArrangedSubview(self.mainContainerView)
        self.contentsStackView.addArrangedSubview(self.stateView)
        
        self.userNameStackView.addArrangedSubview(self.userNameView)
        self.userNameStackView.addArrangedSubview(self.contentsStackView)

        self.messageContentView.addSubview(self.userNameStackView)
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
    open func configure(_ message: SBDBaseMessage,
                          hideDateView: Bool,
                          position: MessagePosition,
                          groupPosition: MessageGroupPosition,
                          receiptState: SBUMessageReceiptState?) {

        // nil for super/broadcast channel which doesn't support receipts.
        // Kept receipt to .none for backward compatibility as this configure() is *open*.
        super.configure(
            message: message,
            position: position,
            hideDateView: hideDateView,
            groupPosition: groupPosition,
            receiptState: receiptState ?? .none
        )
        
        self.reactionView.configure(
            maxWidth: SBUConstant.imageSize.width,
            reactions: message.reactions
        )
        
        self.mainContainerView.position = self.position
        self.mainContainerView.isSelected = false
        
        if let userNameView = self.userNameView as? SBUUserNameView {
            var username = ""
            if let sender = message.sender {
                username = SBUUser(user: sender).refinedNickname()
            }
            userNameView.configure(username: username)
        }
        
        if let profileView = self.profileView as? SBUMessageProfileView {
            let urlString = message.sender?.profileUrl ?? ""
            profileView.configure(urlString: urlString)
        }
        
        if let stateView = self.stateView as? SBUMessageStateView {
            stateView.configure(
                timestamp: message.createdAt,
                sendingState: message.sendingStatus,
                receiptState: receiptState,
                position: position
            )
        }
        
        self.setMessageGrouping()
    }
    
    public func setMessageGrouping() {
        guard SBUGlobals.UsingMessageGrouping else { return }
        self.profileView.isHidden = self.position == .right
        let profileImageView = (self.profileView as? SBUMessageProfileView)?.imageView
        let timeLabel = (self.stateView as? SBUMessageStateView)?.timeLabel
        
        self.contentsStackView.arrangedSubviews.forEach(
            self.contentsStackView.removeArrangedSubview(_:)
        )
        
        switch self.position {
        case .left:
            self.userNameStackView.alignment = .leading
            self.contentsStackView.addArrangedSubview(self.profileView)
            self.contentsStackView.addArrangedSubview(self.profileContentSpacing)
            self.contentsStackView.addArrangedSubview(self.mainContainerView)
            self.contentsStackView.addArrangedSubview(self.stateView)
            
        case .right:
            self.userNameStackView.alignment = .trailing
            self.contentsStackView.addArrangedSubview(self.stateView)
            self.contentsStackView.addArrangedSubview(self.mainContainerView)
            self.contentsStackView.addArrangedSubview(self.profileContentSpacing)
            
        case .center:
            break
        }
        
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
    
    @available(*, deprecated, message: "deprecated in 1.2.2", renamed: "onTapUserProfileView(sender:)")
    @objc open func onTapProfileImageView(sender: UITapGestureRecognizer) {
        self.onTapUserProfileView(sender: sender)
    }
    
    @objc open func onTapUserProfileView(sender: UITapGestureRecognizer) {
        self.userProfileTapHandler?()
    }
}
