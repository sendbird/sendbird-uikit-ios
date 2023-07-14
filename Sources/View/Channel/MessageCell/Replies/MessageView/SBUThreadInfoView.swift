//
//  SBUThreadInfoView.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/11/02.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

public protocol SBUThreadInfoViewDelegate: AnyObject {
    /// Called when `SBUThreadInfoView` was tapped.
    /// - Parameter threadInfoView: The tapped thread info view.
    func threadInfoViewDidTap(_ threadInfoView: SBUThreadInfoView)
}

/// The protocol to configure the thread info view. It conforms to `SBUViewLifeCycle`
///
/// - Since: 3.3.0
public protocol SBUThreadInfoViewProtocol: SBUViewLifeCycle {
    func configure(with message: BaseMessage, messagePosition: MessagePosition)
}

open class SBUThreadInfoView: SBUView, SBUThreadInfoViewProtocol {
    
    // MARK: - UI properties (Public)
    public var mainContainerView: UIStackView = SBUStackView(
        axis: .horizontal,
        alignment: .center,
        spacing: 4
    )
    
    /// The UIStackView displaying replied users.
    public var repliedUsersHStackView: UIStackView = SBUStackView(
        axis: .horizontal,
        alignment: .top,
        spacing: 4
    )
    
    /// The UILabel displays replied count.
    /// e.g. “5 replies”
    public var repliedCountLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byTruncatingMiddle
        label.numberOfLines = 1
        return label
    }()
    
    @SBUThemeWrapper(theme: SBUTheme.messageCellTheme)
    public var theme: SBUMessageCellTheme
    
    // MARK: - Logic properties (Public)
    public weak var delegate: SBUThreadInfoViewDelegate?
    public private(set) var threadInfo: ThreadInfo?
    public private(set) var message: BaseMessage? {
        didSet { self.threadInfo = message?.threadInfo }
    }
    public var messagePosition: MessagePosition = .center {
        didSet {
            switch messagePosition {
            case .left:
                self.repliedUsersHStackView.alignment = .leading
                self.repliedCountLabel.textAlignment = .left
            case .right:
                self.repliedUsersHStackView.alignment = .trailing
                self.repliedCountLabel.textAlignment = .right
            case .center:
                self.repliedUsersHStackView.alignment = .leading
                self.repliedCountLabel.textAlignment = .left
            }
        }
    }
    
    public let userImageSize: CGFloat = 20
    public let repliedUserLimit: Int = 5
    
    // MARK: - Initializer
    public override init() {
        super.init(frame: .zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // MARK: - LifeCycle
    open override func setupViews() {
        super.setupViews()
        
        self.addSubview(self.repliedUsersHStackView)
        self.addSubview(self.repliedCountLabel)
        self.mainContainerView.setHStack([
            self.repliedUsersHStackView,
            self.repliedCountLabel
        ])
        self.addSubview(self.mainContainerView)
    }
    
    open func setupStyles(theme: SBUMessageCellTheme) {
        self.theme = theme
        self.setupStyles()
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
        self.repliedCountLabel.textColor = self.theme.repliedCountTextColor
        self.repliedCountLabel.font = self.theme.repliedCountTextFont
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        let margin: CGFloat = 12.0
        self.mainContainerView
            .sbu_constraint(equalTo: self, leading: margin, top: 0, bottom: 0, centerX: 0)
            .sbu_constraint(height: userImageSize)
    }
    
    open override func setupActions() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(onTapThreadInfo(sender:))
        )
        self.addGestureRecognizer(tapGesture)
    }
    
    /// Configures views with `message` and `messagePosition`.
    /// - Parameters:
    ///   - message: `BaseMessage` object.
    ///   - messagePosition: `MessagePosition` enumeration value.
    open func configure(with message: BaseMessage, messagePosition: MessagePosition) {
        self.isHidden = false
        self.message = message
        self.messagePosition = messagePosition
        self.repliedCountLabel.text = SBUStringSet.Message_Replied_Users_Count(
            message.threadInfo.replyCount,
            true
        )
        
        self.repliedUsersHStackView.subviews.forEach({ $0.removeFromSuperview() })
        
        self.setupRepliedUsers()
    }
    
    open func setupRepliedUsers() {
        guard let mostRepliedUsers = self.threadInfo?.mostRepliedUsers else { return }
        
        for (index, mostRepliedUser) in mostRepliedUsers.enumerated() {
            if index == self.repliedUserLimit { break }
            let userImageView = UIImageView()
            userImageView.contentMode = .scaleAspectFill
            userImageView.clipsToBounds = true
            userImageView.isUserInteractionEnabled = true
            userImageView.layer.cornerRadius = userImageSize/2
            userImageView.sbu_constraint(width: userImageSize, height: userImageSize)
            userImageView.loadImage(
                urlString: mostRepliedUser.profileURL ?? "",
                placeholder: SBUIconSetType.iconUser.image(
                    with: self.theme.userPlaceholderTintColor,
                    to: SBUIconSetType.Metric.defaultIconSize
                ),
                subPath: SBUCacheManager.PathType.userProfile
            )
            userImageView.backgroundColor = theme.userPlaceholderBackgroundColor
            
            // If replied user count is more than 5, last image will be covered with more icon.
            if index == self.repliedUserLimit - 1 {
                let moreImageView = UIImageView()
                moreImageView.image = SBUIconSetType.iconPlus.image(
                    with: self.theme.repliedUsersMoreIconTintColor,
                    to: SBUIconSetType.Metric.defaultIconSize
                ).resize(with: .init(width: 15, height: 15))
                moreImageView.contentMode = .center
                moreImageView.layer.cornerRadius = userImageSize/2
                moreImageView.backgroundColor = self.theme.repliedUsersMoreIconBackgroundColor
                moreImageView.sbu_constraint(width: userImageSize, height: userImageSize)
                userImageView.addSubview(moreImageView)
            }
            
            self.repliedUsersHStackView.addArrangedSubview(userImageView)
        }
    }
    
    // MARK: - Action
    @objc
    open func onTapThreadInfo(sender: UITapGestureRecognizer) {
        self.delegate?.threadInfoViewDidTap(self)
    }
}
