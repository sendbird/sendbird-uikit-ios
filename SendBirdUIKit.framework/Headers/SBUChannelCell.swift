//
//  SBUChannelCell.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 03/02/2020.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

/// `UITableViewCell` for `SBDGroupChannel` list.
public class SBUChannelCell: SBUBaseChannelCell {
    
    // MARK: - property
    public private(set) lazy var coverImage = SBUCoverImageView()
    public private(set) lazy var titleStackView: UIStackView = {
        let titleStackView = UIStackView()
        titleStackView.alignment = .center
        titleStackView.spacing = 4.0
        titleStackView.axis = .horizontal
        return titleStackView
    }()
    public private(set) lazy var titleLabel = UILabel()
    public private(set) lazy var broadcastIcon = UIImageView()
    public private(set) lazy var memberCountLabel = UILabel()
    public private(set) lazy var freezeState = UIImageView()
    public private(set) lazy var notificationState = UIImageView()
    public private(set) lazy var lastUpdatedTimeLabel = UILabel()
    public private(set) lazy var messageLabel = UILabel()
    public private(set) lazy var unreadCount = UIButton()
    public private(set) var separatorLine = UIView()
    
    public let kCoverImageSize: CGFloat = 56
    public let kUnreadCountSize: CGFloat = 20
    public let kSideMarging: CGFloat = 16
    public let kInfoIconSize: CGFloat = 16
    
    
    // MARK: - View Lifecycle
    open override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /// This function handles the initialization of views.
    public override func setupViews() {
        super.setupViews()
        
        self.coverImage.clipsToBounds = true
        self.coverImage.frame = CGRect(
            x: 0,
            y: 0,
            width: kCoverImageSize,
            height: kCoverImageSize
        )
        
        self.broadcastIcon.isHidden = true
        self.freezeState.isHidden = true
        self.notificationState.alpha = 0.0
        
        self.titleStackView.addArrangedSubview(self.broadcastIcon)
        self.titleStackView.addArrangedSubview(self.titleLabel)
        self.titleStackView.addArrangedSubview(self.memberCountLabel)
        self.titleStackView.addArrangedSubview(self.freezeState)
        self.titleStackView.addArrangedSubview(self.notificationState)
        
        self.unreadCount.isUserInteractionEnabled = false
        
        self.contentView.addSubview(self.coverImage)
        self.contentView.addSubview(self.titleStackView)
        self.contentView.addSubview(self.lastUpdatedTimeLabel)
        self.contentView.addSubview(self.messageLabel)
        self.contentView.addSubview(self.unreadCount)
        self.contentView.addSubview(self.separatorLine)
    }
    
    /// This function handles the initialization of actions.
    public override func setupActions() {
        super.setupActions()
    }
    
    /// This function handles the initialization of autolayouts.
    public override func setupAutolayout() {
        super.setupAutolayout()
        
        self.coverImage
            .sbu_constraint(equalTo: self.contentView, left: kSideMarging, top: 10, bottom: 10)
            .sbu_constraint(width: kCoverImageSize, height: kCoverImageSize)
        
        self.titleStackView
            .sbu_constraint(equalTo: self.contentView, top: 10)
            .sbu_constraint(height: 22)
            .sbu_constraint_equalTo(
                leadingAnchor: self.coverImage.trailingAnchor,
                leading: kSideMarging
        )
        
        self.broadcastIcon.sbu_constraint(width: kInfoIconSize, height: kInfoIconSize)
        self.freezeState.sbu_constraint(width: kInfoIconSize, height: kInfoIconSize)
        self.notificationState.sbu_constraint(width: kInfoIconSize, height: kInfoIconSize)

        self.titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
 
        self.lastUpdatedTimeLabel
            .sbu_constraint(equalTo: self.contentView, trailing: -17, top: 12)
            .sbu_constraint(height: 14)
            .sbu_constraint_greater(leadingAnchor: self.titleStackView.trailingAnchor, leading: 7)
        
        self.messageLabel
            .sbu_constraint_equalTo(
                leadingAnchor: self.coverImage.trailingAnchor,
                leading: kSideMarging,
                topAnchor: self.titleStackView.bottomAnchor,
                top: 2,
                bottomAnchor: self.contentView.bottomAnchor,
                bottom: 10)
            .setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        self.unreadCount
            .sbu_constraint(equalTo: self.contentView, trailing: -kSideMarging)
            .sbu_constraint(height: kUnreadCountSize)
            .sbu_constraint_equalTo(topAnchor: self.lastUpdatedTimeLabel.bottomAnchor, top: 10)
            .sbu_constraint_greater(leadingAnchor: self.messageLabel.trailingAnchor, leading: 8)
        
        self.separatorLine
            .sbu_constraint(equalTo: self.contentView, trailing: 0, bottom: 0.5)
            .sbu_constraint(height: 0.5)
            .sbu_constraint_equalTo(
                leadingAnchor: self.coverImage.trailingAnchor,
                leading: kSideMarging
        )
    }
    
    /// This function handles the initialization of styles.
    public override func setupStyles() {
        super.setupStyles()
        
        self.theme = SBUTheme.channelCellTheme
        
        self.backgroundColor = theme.backgroundColor
        
        self.titleLabel.font = theme.titleFont
        self.titleLabel.textColor = theme.titleTextColor
        
        self.memberCountLabel.font = theme.memberCountFont
        self.memberCountLabel.textColor = theme.memberCountTextColor
        
        self.lastUpdatedTimeLabel.font = theme.lastUpdatedTimeFont
        self.lastUpdatedTimeLabel.textColor = theme.lastUpdatedTimeTextColor
        
        self.messageLabel.font = theme.messageFont
        self.messageLabel.textColor = theme.messageTextColor
        
        self.unreadCount.backgroundColor = theme.unreadCountBackgroundColor
        self.unreadCount.setTitleColor(theme.unreadCountTextColor, for: .normal)
        self.unreadCount.titleLabel?.font = theme.unreadCountFont
        
        self.broadcastIcon.image = SBUIconSetType.iconBroadcast.image(
            with: theme.broadcastMarkTintColor,
            to: SBUIconSetType.Metric.defaultIconSize
        )
        self.freezeState.image = SBUIconSetType.iconFreeze.image(
            with: theme.freezeStateTintColor,
            to: SBUIconSetType.Metric.defaultIconSize
        )
        self.notificationState.image = SBUIconSetType.iconNotificationOffFilled.image(
            with: theme.messageTextColor,
            to: SBUIconSetType.Metric.defaultIconSize
        )
        
        self.separatorLine.backgroundColor = theme.separatorLineColor
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.coverImage.layer.cornerRadius = kCoverImageSize/2

        self.unreadCount.contentEdgeInsets.left = 6.0
        self.unreadCount.contentEdgeInsets.right = 6.0
        self.unreadCount.layer.cornerRadius = kUnreadCountSize/2
        
        self.setupStyles()
    }
    
    deinit {
        SBULog.info("")
    }
    
    /// This function configure a cell using `SBDGroupChannel` information.
    /// - Note: If you use `SBDOpenChannel`, your cell class must inherit `SBUBaseChannelCell` and override `configure(channel:)` method.
    /// - Parameter channel: `SBDGroupChannel` object
    open override func configure(channel: SBDBaseChannel) {
        super.configure(channel: channel)
        
        guard let channel = channel as? SBDGroupChannel else { return }

        // Cover image
        if let url = channel.coverUrl, SBUUtils.isValid(coverUrl: url) {
            self.coverImage.setImage(withCoverUrl: url)
        } else if channel.isBroadcast {
            self.coverImage.setBroadcastIcon()
        } else {
            if let members = channel.members as? [SBDUser] {
                self.coverImage.setImage(withUsers: members)
            } else {
                self.coverImage.setPlaceholderImage(iconSize: .init(width: 40, height: 40))
            }
        }
        
        // Title
        if SBUUtils.isValid(channelName: channel.name) {
            self.titleLabel.text = channel.name
        } else {
            self.titleLabel.text = SBUUtils.generateChannelName(channel: channel)
        }
        
        // Member cound. If 1:1 channel, not set
        if channel.memberCount > 2 {
            self.memberCountLabel.text = channel.memberCount.unitFormattedString
        }
        else {
            self.memberCountLabel.text = nil
        }
        
        // Broadcast channel state. If isBroadcast is false, this property will hidden.
        self.broadcastIcon.isHidden = channel.isBroadcast == false
        
        // Channel frozen state. If isFrozen is false, this property will hidden.
        self.freezeState.isHidden = channel.isFrozen == false
        
        // Notification state. If myPushTriggerOption is all, this property will hidden.
        self.notificationState.alpha = (channel.myPushTriggerOption != .off) ? 0.0 : 1.0
        
        // Last updated time
        self.lastUpdatedTimeLabel.text = self.buildLastUpdatedDate()
        
        // Last message
        switch channel.lastMessage {
        case let userMessage as SBDUserMessage:
            self.messageLabel.lineBreakMode = .byTruncatingTail
            self.messageLabel.text = userMessage.message
            
        case let fileMessage as SBDFileMessage:
            self.messageLabel.lineBreakMode = .byTruncatingMiddle
            self.messageLabel.text = fileMessage.name
            
        default:
            self.messageLabel.text = ""
        }
        
        // Unread count
        switch channel.unreadMessageCount {
        case 0:
            self.unreadCount.isHidden = true
        case 1...99:
            self.unreadCount.setTitle(String(channel.unreadMessageCount), for: .normal)
            self.unreadCount.isHidden = false
        case 100...:
            self.unreadCount.setTitle("99+", for: .normal)
            self.unreadCount.isHidden = false
        default:
            break
        }
    }
    
    
    // MARK: - Common
    
    /// This function builds last message updated date.
    /// - Returns: last updated date string
    public func buildLastUpdatedDate() -> String? {
        guard let channel = self.channel as? SBDGroupChannel else { return nil }
        var lastUpdatedAt: Int64
        
        if let lastMessage = channel.lastMessage {
            lastUpdatedAt = Int64(lastMessage.createdAt / 1000)
        } else {
            lastUpdatedAt = Int64(channel.createdAt)
        }
        
        guard let lastSeenTiemString = Date.lastUpdatedTime(
            baseTimestamp: lastUpdatedAt) else { return nil }
        
        return lastSeenTiemString
    }

    
    // MARK: -
    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
    }
}
