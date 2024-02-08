//
//  SBUGroupChannelCell.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 03/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

@available(*, deprecated, renamed: "SBUGroupChannelCell")
public typealias SBUChannelCell = SBUGroupChannelCell

/// `UITableViewCell` of the table view that represents the list of group channels.
open class SBUGroupChannelCell: SBUBaseChannelCell {
    
    // MARK: - property
    /// The image view that shows the channel cover image.
    public lazy var coverImage = SBUCoverImageView()
    /// The label that represents the channel name.
    public lazy var titleLabel = UILabel()
    /// The image view that shows the broadcast icon.
    public lazy var broadcastIcon = UIImageView()
    /// The label that represents the number of members in the channel.
    public lazy var memberCountLabel = UILabel()
    /// The image view that indicates the freezing state of the channel.
    public lazy var freezeState = UIImageView()
    /// The image view that indicates the notification state of the channel.
    public lazy var notificationState = UIImageView()
    /// The label that represents the time when the channel is updated last. e.g. the time when the last message was sent at.
    public lazy var lastUpdatedTimeLabel = UILabel()
    /// The label that shows the last message in up to 2 lines of text.
    public lazy var messageLabel = UILabel()
    /// The label that shows the unread mention messages.
    public lazy var unreadMentionLabel = UILabel()
    /// The button that shows the number of the unread messages.
    public lazy var unreadCount = UIButton()
    /// The image view that represents read/delivery receipt state of the last message that was sent by the current user.
    public lazy var stateImageView = UIImageView()
    /// A view that is used as a separator between the channel cells.
    public lazy var separatorLine = UIView()
    /// A spacer used in `titleStackView` to provide spacing between `titleLabel` and `lastUpdatedTimeLabel`.
    public let titleSpacer = UIView()
    /// A spacer used in `messageStackView` to provide spacing between `messageLabel` and `unreadCount`.
    public let messageSpacer = UIView()
    
    /// A value used in the size of `coverImage`.
    public let coverImageSize: CGFloat = 56
    /// A value used in the height of `unreadCount`.
    public let unreadCountSize: CGFloat = 20
    /// A value used in the size of icon image views.
    public let infoIconSize: CGFloat = 16
    
    @available(*, deprecated, renamed: "coverImageSize")
    public var kCoverImageSize: CGFloat { coverImageSize }
    
    @available(*, deprecated, renamed: "unreadCountSize")
    public var kUnreadCountSize: CGFloat { unreadCountSize }
    
    @available(*, deprecated, renamed: "infoIconSize")
    public var kInfoIconSize: CGFloat { infoIconSize }
    
    @available(*, unavailable, renamed: "sideMarging")
    public var kSideMarging: CGFloat { 16 }
    
    /// A horizontal stack view to configure layouts of the entire view properties.
    public lazy var contentStackView = SBUStackView(axis: .horizontal, alignment: .top, spacing: 16)
    /// A vertical stack view to configure layouts of labels and icons that represent the channel information.
    public lazy var infoStackView = SBUStackView(axis: .vertical, alignment: .leading, spacing: 2)
    /// A horizontal stack view to configure layouts of the `titleLabel`, `lastUpdatedTimeLabel` and icons.
    public lazy var titleStackView = SBUStackView(axis: .horizontal, alignment: .center, spacing: 4)
    /// A horizontal stack view to configure layouts of the `messageLabel` and the `unreadCount`.
    public lazy var messageStackView = SBUStackView(axis: .horizontal, alignment: .top, spacing: 4)
    
    @SBUThemeWrapper(theme: SBUTheme.groupChannelCellTheme)
    public var theme: SBUGroupChannelCellTheme
    
    // MARK: - View Lifecycle
    open override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /// This function handles the initialization of views.
    open override func setupViews() {
        super.setupViews()
        
        self.coverImage.clipsToBounds = true
        self.coverImage.frame = CGRect(
            x: 0,
            y: 0,
            width: coverImageSize,
            height: coverImageSize
        )
        
        self.broadcastIcon.isHidden = true
        self.freezeState.isHidden = true
        self.unreadMentionLabel.isHidden = true
        self.notificationState.isHidden = true
        self.messageLabel.numberOfLines = 2
        
        self.contentView.addSubview(
            self.contentStackView.setHStack([
                self.coverImage,
                self.infoStackView.setVStack([
                    self.titleStackView.setHStack([
                        self.broadcastIcon,
                        self.titleLabel,
                        self.memberCountLabel,
                        self.freezeState,
                        self.notificationState,
                        self.titleSpacer,
                        self.stateImageView,
                        self.lastUpdatedTimeLabel
                    ]),
                    self.messageStackView.setHStack([
                        self.messageLabel,
                        self.messageSpacer,
                        self.unreadMentionLabel,
                        self.unreadCount
                    ]),
                ])
            ])
        )
        self.contentView.addSubview(self.separatorLine)
        
        self.titleStackView.setCustomSpacing(0, after: titleSpacer)
        self.messageStackView.setCustomSpacing(0, after: messageSpacer)
        
        self.unreadCount.isUserInteractionEnabled = false
    }
    
    /// This function handles the initialization of actions.
    open override func setupActions() {
        super.setupActions()
    }
    
    /// This function handles the initialization of autolayouts.
    open override func setupLayouts() {
        super.setupLayouts()
        
        // content stack view
        self.contentStackView
            .sbu_constraint(equalTo: self.contentView, leading: 16, trailing: -16, top: 10, bottom: 10)
        
        self.coverImage
            .sbu_constraint(width: coverImageSize, height: coverImageSize)
        
        // title stack view
        self.titleStackView
            .sbu_constraint(equalTo: self.contentStackView, trailing: 0)
            .sbu_constraint(height: 22, priority: .defaultLow)
            .sbu_constraint_greaterThan(height: 22)
        
        self.broadcastIcon
            .sbu_constraint(width: infoIconSize, height: infoIconSize)
        
        self.freezeState
            .sbu_constraint(width: infoIconSize, height: infoIconSize)
        
        self.notificationState
            .sbu_constraint(width: infoIconSize, height: infoIconSize)
        
        self.titleLabel
            .setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        self.stateImageView
            .sbu_constraint(width: infoIconSize, height: infoIconSize)
        
        // message stack view
        self.messageStackView
            .sbu_constraint(equalTo: self.contentStackView, trailing: 0)
            .sbu_constraint_greaterThan(height: 20)
        
        self.messageLabel
            .setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        self.unreadCount
            .sbu_constraint(height: unreadCountSize)
            .sbu_constraint_greaterThan(width: unreadCountSize)
        
        self.separatorLine
            .sbu_constraint(equalTo: self.contentView, trailing: 0, bottom: 0.5)
            .sbu_constraint(equalTo: self.infoStackView, leading: 0)
            .sbu_constraint(height: 0.5)
        
    }
    
    /// This function handles the initialization of styles.
    open override func setupStyles() {
        super.setupStyles()
        
        self.backgroundColor = theme.backgroundColor
        
        self.titleLabel.font = theme.titleFont
        self.titleLabel.textColor = theme.titleTextColor
        
        self.memberCountLabel.font = theme.memberCountFont
        self.memberCountLabel.textColor = theme.memberCountTextColor
        
        self.lastUpdatedTimeLabel.font = theme.lastUpdatedTimeFont
        self.lastUpdatedTimeLabel.textColor = theme.lastUpdatedTimeTextColor
        
        self.messageLabel.font = theme.messageFont
        self.messageLabel.textColor = theme.messageTextColor
        
        // TODO: Need to add StringSet constant?
        self.unreadMentionLabel.text = SBUGlobals.userMentionConfig?.trigger ?? SBUStringSet.Mention.Trigger_Key
        self.unreadMentionLabel.textColor = theme.unreadMentionTextColor
        self.unreadMentionLabel.font = theme.unreadMentionTextFont
        
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
        
        self.coverImage.layer.cornerRadius = coverImageSize / 2

        self.unreadCount.contentEdgeInsets.left = 6.0
        self.unreadCount.contentEdgeInsets.right = 6.0
        self.unreadCount.layer.cornerRadius = unreadCountSize / 2
    }
    
    deinit {
        SBULog.info("")
    }
    
    /// This function configure a cell using `GroupChannel` information.
    /// - Parameter channel: `GroupChannel` object
    open override func configure(channel: BaseChannel) {
        super.configure(channel: channel)
        
        guard let channel = channel as? GroupChannel else { return }

        // Cover image
        if let url = channel.coverURL, SBUUtils.isValid(coverURL: url) {
            self.coverImage.setImage(withCoverURL: url)
        } else if channel.isBroadcast {
            self.coverImage.setBroadcastIcon()
        } else {
            if !channel.members.isEmpty {
                self.coverImage.setImage(withUsers: channel.members)
            } else {
                self.coverImage.setPlaceholder(type: .iconUser, iconSize: .init(width: 40, height: 40))
            }
        }
        
        // Title
        if SBUUtils.isValid(channelName: channel.name) {
            self.titleLabel.text = channel.name
        } else {
            self.titleLabel.text = SBUUtils.generateChannelName(channel: channel)
        }
        
        // Member count. If 1:1 channel, not set
        if channel.memberCount > 2 {
            self.memberCountLabel.text = channel.memberCount.unitFormattedString
        } else {
            self.memberCountLabel.text = nil
        }
        
        // Broadcast channel state. If isBroadcast is false, this property will hidden.
        self.broadcastIcon.isHidden = channel.isBroadcast == false
        
        // Channel frozen state. If isFrozen is false, this property will hidden.
        self.freezeState.isHidden = channel.isFrozen == false
        
        // Notification state. If myPushTriggerOption is all, this property will hidden.
        self.notificationState.isHidden = channel.myPushTriggerOption != .off
        
        // Last updated time
        self.lastUpdatedTimeLabel.text = self.buildLastUpdatedDate()
        
        // Last message
        self.messageLabel.text = ""
        switch channel.lastMessage {
        case let userMessage as UserMessage:
            self.messageLabel.lineBreakMode = .byTruncatingTail
            self.messageLabel.text = userMessage.message
            
        case let fileMessage as FileMessage:
            self.messageLabel.lineBreakMode = .byTruncatingMiddle
            self.messageLabel.text = SBUUtils.getFileTypePreviewString(by: fileMessage.type)
            
        case let adminMessage as AdminMessage:
            self.messageLabel.lineBreakMode = .byTruncatingMiddle
            self.messageLabel.text = adminMessage.message
        
        case _ as MultipleFilesMessage:
            self.messageLabel.lineBreakMode = .byTruncatingMiddle
            self.messageLabel.text = SBUStringSet.GroupChannel.Preview.multipleFiles
            
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
        
        self.unreadMentionLabel.isHidden = !SendbirdUI.config.groupChannel.channel.isMentionEnabled || channel.unreadMentionCount == 0
        
        self.updateMessageLabel()
        self.updateStateImageView()
    }
    
    // MARK: - Type indicator
    /// Updates message label when someone is typing. To show typing indicator, set `SBUGlobals.isChannelListTypingIndicatorEnabled` to `true`.
    open func updateMessageLabel() {
        guard SendbirdUI.config.groupChannel.channelList.isTypingIndicatorEnabled else { return }
        guard let groupChannel = channel as? GroupChannel else { return }
        
        if let typingMembers = groupChannel.getTypingUsers(),
           !typingMembers.isEmpty,
           SendbirdUI.config.groupChannel.channelList.isTypingIndicatorEnabled {
            messageLabel.lineBreakMode = .byTruncatingTail
            messageLabel.text = SBUStringSet.Channel_Typing(typingMembers)
        } else {
            switch groupChannel.lastMessage {
            case let userMessage as UserMessage:
                messageLabel.lineBreakMode = .byTruncatingTail
                messageLabel.text = userMessage.message
                messageLabel.numberOfLines = 2
            case let fileMessage as FileMessage:
                self.messageLabel.lineBreakMode = .byTruncatingMiddle
                self.messageLabel.text = SBUUtils.getFileTypePreviewString(by: fileMessage.type)
            case let adminMessage as AdminMessage:
                if groupChannel.isChatNotification {
                    self.messageLabel.lineBreakMode = .byTruncatingMiddle
                    self.messageLabel.text = adminMessage.message
                }
            case _ as MultipleFilesMessage:
                self.messageLabel.lineBreakMode = .byTruncatingMiddle
                self.messageLabel.text = SBUStringSet.GroupChannel.Preview.multipleFiles
            default:
                messageLabel.text = ""
            }
        }
    }
    
    // MARK: - Receipt state
    /// Updates the image view that represents read/delivery receipt state. The image view is displayed when the last message was sent by the current user. To show the state image view, set `SBUGlobals.isChannelListMessageReceiptStateEnabled` to `true`.
    /// - NOTE: As a default, the *super* and the *broadcast* group channel are not supported.
    open func updateStateImageView() {
        guard SendbirdUI.config.groupChannel.channelList.isMessageReceiptStatusEnabled else { return }
        guard let groupChannel = channel as? GroupChannel else { return }
        guard !groupChannel.isSuper, !groupChannel.isBroadcast else { return }
        guard let lastMessage = groupChannel.lastMessage else { return }
        guard lastMessage.sender?.userId == SBUGlobals.currentUser?.userId else { return }
        
        let stateImage: UIImage?
        let receiptState = SBUUtils.getReceiptState(of: lastMessage, in: groupChannel)
        switch receiptState {
        case .none:
            stateImage = SBUIconSet.iconDone
                .sbu_with(tintColor: theme.succeededStateColor)
                .resize(with: CGSize(value: infoIconSize))
        case .delivered:
            stateImage = SBUIconSet.iconDoneAll
                .sbu_with(tintColor: theme.deliveryReceiptStateColor)
                .resize(with: CGSize(value: infoIconSize))
        case .read:
            stateImage = SBUIconSet.iconDoneAll
                .sbu_with(tintColor: theme.readReceiptStateColor)
                .resize(with: CGSize(value: infoIconSize))
        default:
            stateImage = nil
        }
        stateImageView.image = stateImage
    }
    
    // MARK: - Common
    
    /// This function builds last message updated date.
    /// - Returns: last updated date string
    public func buildLastUpdatedDate() -> String? {
        guard let channel = self.channel as? GroupChannel else { return nil }
        var lastUpdatedAt: Int64
        
        if let lastMessage = channel.lastMessage {
            lastUpdatedAt = Int64(lastMessage.createdAt / 1000)
        } else {
            lastUpdatedAt = Int64(channel.createdAt)
        }
        
        guard let lastSeenTimeString = Date.lastUpdatedTimeForChannelCell(
            baseTimestamp: lastUpdatedAt
        ) else { return nil }
        
        return lastSeenTimeString
    }
    
    // MARK: -
    open override func prepareForReuse() {
        super.prepareForReuse()
        
        stateImageView.image = nil
    }
}
