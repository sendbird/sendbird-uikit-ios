//
//  SBUOpenChannelContentBaseMessageCell.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2020/10/27.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// It is a base class used in message cell with contents.
/// - Since: 2.0.0
open class SBUOpenChannelContentBaseMessageCell: SBUOpenChannelBaseMessageCell {
    
    // MARK: - Public property
    public lazy var baseStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        return stackView
    }()
    public lazy var profileView: UIView = {
        let profileView = SBUMessageProfileView()
        return profileView
    }()
    public lazy var contentsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.alignment = .top
        return stackView
    }()
    public lazy var infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .leading
        return stackView
    }()
    public lazy var userNameView: UIView = {
        let userNameView = SBUUserNameView()
        return userNameView
    }()
    public lazy var messageTimeLabel: UILabel = UILabel()
    public lazy var mainContainerView: UIView = {
        let mainView = SBUSelectableStackView()
        mainView.layer.cornerRadius = 16
        mainView.layer.borderColor = UIColor.clear.cgColor
        mainView.layer.borderWidth = 1
        mainView.clipsToBounds = true
        return mainView
    }()
    public lazy var stateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // MARK: - Gesture Recognizers
    
    lazy var contentLongPressRecognizer: UILongPressGestureRecognizer = {
        return .init(target: self, action: #selector(self.onLongPressContentView(sender:)))
    }()
    
    lazy var contentTapRecognizer: UITapGestureRecognizer = {
        return .init(target: self, action: #selector(self.onTapContentView(sender:)))
    }()
    
    public var isFileType: Bool = false
    public var isWebType: Bool = false
    
    // MARK: - View Lifecycle
    open override func setupViews() {
        super.setupViews()
        
        self.profileView.isHidden = true
        self.userNameView.isHidden = true
        self.messageTimeLabel.isHidden = true

        self.infoStackView.addArrangedSubview(self.userNameView)
        self.infoStackView.addArrangedSubview(self.messageTimeLabel)
        self.infoStackView.addArrangedSubview(UIView())

        self.contentsStackView.addArrangedSubview(self.infoStackView)
        self.contentsStackView.addArrangedSubview(self.mainContainerView)
        self.contentsStackView.addArrangedSubview(self.stateImageView)
        
        let profileStackView = UIStackView()
        profileStackView.axis = .vertical
        profileStackView.addArrangedSubview(self.profileView)
        profileStackView.addArrangedSubview(UIView())
        
        self.baseStackView.addArrangedSubview(profileStackView)
        self.baseStackView.addArrangedSubview(self.contentsStackView)
        self.baseStackView.addArrangedSubview(UIView())

        self.messageContentView.addSubview(self.baseStackView)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        self.stateImageView.setConstraint(
            width: 12,
            height: 12
        )
        
        self.baseStackView
            .setConstraint(from: self.messageContentView, leading: 12, trailing: 12, top: 0, bottom: 0)
        
        self.messageTimeLabel.setContentCompressionResistancePriority(UILayoutPriority(751), for: .horizontal)
    }
    
    open override func setupActions() {
        super.setupActions()
        
        self.stateImageView.isUserInteractionEnabled = !self.stateImageView.isHidden
        self.stateImageView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.onTapContentView(sender:)))
        )

        self.profileView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.onTapUserProfileView(sender:)))
        )
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
        let theme = self.isOverlay ? self.overlayTheme : self.theme
        
        if let mainContainerView = self.mainContainerView as? SBUSelectableStackView {
            if self.isFileType {
                mainContainerView.leftBackgroundColor = theme.leftBackgroundColor
                mainContainerView.leftPressedBackgroundColor = theme.leftPressedBackgroundColor
                
                mainContainerView.layer.cornerRadius = 12
                mainContainerView.clipsToBounds = true
            } else {
                mainContainerView.leftBackgroundColor = .clear
                mainContainerView.leftPressedBackgroundColor = .clear
            }
            
            mainContainerView.setupStyles()
        }
        
        if let userNameView = self.userNameView as? SBUUserNameView {
            userNameView.theme = self.theme
            userNameView.overlayTheme = self.overlayTheme
            userNameView.setupStyles()
        }
        
        self.messageTimeLabel.font = theme.timeFont
        self.messageTimeLabel.textColor = theme.timeTextColor
        
        if let profileView = self.profileView as? SBUMessageProfileView {
            profileView.theme = self.theme
            profileView.setupStyles()
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
    open func configure(_ message: BaseMessage,
                          hideDateView: Bool,
                          groupPosition: MessageGroupPosition,
                          isOverlay: Bool = false) {
        super.configure(
            message: message,
            hideDateView: hideDateView,
            groupPosition: groupPosition,
            isOverlay: isOverlay
        )
        
        let theme = self.isOverlay ? self.overlayTheme : self.theme
        
        if let mainContainerView = self.mainContainerView as? SBUSelectableStackView {
            mainContainerView.position = .left
            mainContainerView.isSelected = false
        }
        
        if let userNameView = self.userNameView as? SBUUserNameView {
            var username = ""
            if let sender = message.sender {
                username = SBUUser(user: sender).refinedNickname()
                
                userNameView.setUsernameColor(
                    message.isOperatorMessage
                        ? theme.currentUserNameTextColor
                        : theme.userNameTextColor
                )
            }
            
            userNameView.configure(username: username, isOverlay: self.isOverlay)
        }
        
        self.messageTimeLabel.text = Date
            .sbu_from(message.createdAt)
            .sbu_toString(dateFormat: SBUDateFormatSet.Message.sentTimeFormatInOpenChannel)
        self.messageTimeLabel.textAlignment = .left
        
        if let profileView = self.profileView as? SBUMessageProfileView {
            let urlString = message.sender?.profileURL ?? ""
            profileView.configure(urlString: urlString)
        }
        
        self.configureStateImage()
        
        self.setMessageGrouping()
    }
    
    open func configureStateImage() {
        stateImageView.layer.removeAnimation(forKey: SBUAnimation.Key.spin.identifier)
        
        guard let message = self.message else {
            SBULog.error("Failed state image configuration")
            return
        }
        
        let stateImage: UIImage?
        
        switch message.sendingStatus {
            case .none, .succeeded:
                stateImage = nil
            case .pending:
                stateImage = SBUIconSetType.iconSpinner.image(
                    with: theme.pendingStateColor,
                    to: SBUIconSetType.Metric.defaultIconSizeSmall
                )
                
                let rotation = CABasicAnimation(keyPath: "transform.rotation")
                rotation.fromValue = 0
                rotation.toValue = 2 * Double.pi
                rotation.duration = 1.1
                rotation.repeatCount = Float.infinity
                stateImageView.layer.add(rotation, forKey: SBUAnimation.Key.spin.identifier)
            case .failed, .canceled:
                stateImage = SBUIconSetType.iconError.image(
                    with: theme.failedStateColor,
                    to: SBUIconSetType.Metric.defaultIconSizeSmall
                )
            case .scheduled:
                stateImage = nil
            @unknown default:
                stateImage = nil
        }
        
        self.stateImageView.image = stateImage
        self.stateImageView.isHidden = stateImage == nil
        
        self.layoutIfNeeded()
        self.updateConstraints()
    }
    
    open func setMessageGrouping() {
        let isMessageGroupingEnabled = SBUGlobals.isMessageGroupingEnabled
        let profileImageView = (self.profileView as? SBUMessageProfileView)?.imageView
        
        switch self.groupPosition {
        case .top:
            self.userNameView.isHidden = false
            profileImageView?.isHidden = false
            self.messageTimeLabel.isHidden = false
        case .middle:
            self.userNameView.isHidden = isMessageGroupingEnabled
            profileImageView?.isHidden = isMessageGroupingEnabled
            self.messageTimeLabel.isHidden = isMessageGroupingEnabled
        case .bottom:
            self.userNameView.isHidden = isMessageGroupingEnabled
            profileImageView?.isHidden = isMessageGroupingEnabled
            self.messageTimeLabel.isHidden = isMessageGroupingEnabled
        case .none:
            self.userNameView.isHidden = false
            profileImageView?.isHidden = false
            self.messageTimeLabel.isHidden = false
        }
        
        self.updateTopAnchorConstraint()
    }
    
    open func setUsernameColor(_ color: UIColor) {
        if let userNameView = self.userNameView as? SBUUserNameView {
            userNameView.setUsernameColor(color)
            userNameView.updateStyles()
        }
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        let theme = self.isOverlay ? self.overlayTheme : self.theme
        
        if selected {
            self.messageContentView.backgroundColor = theme.openChannelPressedBackgroundColor
        } else {
            self.messageContentView.backgroundColor = theme.openChannelBackgroundColor
        }
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
}
