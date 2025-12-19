//
//  SBUConfig.GroupChannel.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2023/06/01.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit

public extension SBUConfig {
    class GroupChannel: Codable, SBUUpdatableConfigProtocol {
        // MARK: Property

        /// Channel configuration set of GroupChannel
        public var channel: Channel = .init()

        /// Channel list configuration set of GroupChannel
        public var channelList: ChannelList = .init()

        /// Channel setting configuration set of GroupChannel
        public var setting: Setting = .init()

        // MARK: Logic

        func updateWithDashboardData(_ groupChannel: GroupChannel) {
            channel.updateWithDashboardData(groupChannel.channel)
            channelList.updateWithDashboardData(groupChannel.channelList)
            setting.updateWithDashboardData(groupChannel.setting)
        }
    }
}

// MARK: - SBUConfig.GroupChannel.Channel

public extension SBUConfig.GroupChannel {
    class Channel: NSObject, Codable, SBUUpdatableConfigProtocol {
        // MARK: Property

        /// When a message contains a web link, and the web link has associated OG Tag information, the OG Tag information will also be displayed.
        /// - IMPORTANT: This property may have different activation states depending on the application attribute settings,
        ///              so if you want to use this value for function implementation,
        ///              please use the ``SBUAvailable/isSupportOgTag(channelType:)`` method in the ``SBUAvailable`` class.
        @SBUPrioritizedConfig public var isOGTagEnabled: Bool = true

        /// In the channel header, the current typing information of the members is displayed under the channel title.
        @SBUPrioritizedConfig public var isTypingIndicatorEnabled: Bool = true

        /// Choose the type of typing indicators to show in a Group Channel.
        /// To enable the types, you must first enable ``isTypingIndicatorEnabled``.
        /// The default value is `[.text]`
        /// - Note: This property is not yet configurable via the Dashboard.
        /// - Since: 3.12.0
        public var typingIndicatorTypes: Set<SBUTypingIndicatorType> = [.text]

        /// Enable the feature to show suggested replies in messages. Default is `false`
        /// - NOTE: A value that cannot be set in the dashboard.
        /// - Since: 3.11.0
        @SBUPrioritizedConfig public var isSuggestedRepliesEnabled: Bool = false

        /// Choose the type of suggested replies render type to show in a Group Channel.
        /// To enable the type, you must first enable ``isSuggestedRepliesEnabled``.
        /// The default value is `lastMessageOnly`
        /// - Note: This property is not yet configurable via the Dashboard.
        /// - Since: 3.19.0
        public var showSuggestedRepliesFor: SBUSuggestedRepliesRenderType = .lastMessageOnly

        /// Choose the type of suggested replies direction to display in group channels
        /// To enable the type, you must first enable ``isSuggestedRepliesEnabled``.
        /// - Note: This property is not yet configurable via the Dashboard.
        /// - Since: 3.23.0
        public var suggestedRepliesDirection: SBUSuggestedRepliesDirection = .vertical

        /// Enable the feature to show form type in messages. Default is `false`
        /// - NOTE: A value that cannot be set in the dashboard.
        /// - Since: 3.11.0
        @SBUPrioritizedConfig public var isFormTypeMessageEnabled: Bool = false

        /// Enable the feature to show feedback in messages. Default is `false`
        /// - NOTE: A value that cannot be set in the dashboard.
        /// - Since: 3.15.0
        @SBUPrioritizedConfig public var isFeedbackEnabled: Bool = false

        /// Enable the feature to react to messages with emojis.
        /// - IMPORTANT: This property may have different activation states depending on the application attribute settings,
        ///              so if you want to use this value for function implementation,
        ///              please use the ``SBUAvailable/isSupportReactions()`` method in the ``SBUAvailable`` class.
        @SBUPrioritizedConfig public var isReactionsEnabled: Bool = true

        /// Enable markdown features for user messages.
        /// - Since: 3.23.0
        @SBUPrioritizedConfig public var isMarkdownForUserMessageEnabled: Bool = false

        /// Enables the Reactions for Super Group Channels.
        /// - Since: 3.24.0
        @SBUPrioritizedConfig private var _isSuperGroupReactionsEnabled: Bool = false

        /// The flag that indicates whether the Reactions feature is enabled in Super Group Channels.
        /// - Since: 3.19.0
        public var isSuperGroupReactionsEnabled: Bool {
            get { _isSuperGroupReactionsEnabled }

            @available(*, unavailable, message: "Currently, this feature is turned off by default. If you wish to use this feature, contact us.")
            set { _isSuperGroupReactionsEnabled = newValue }
        }

        /// Enable the feature to mark message as unread.
        ///
        /// - Since: 3.32.0
        @SBUPrioritizedConfig public var isMarkAsUnreadEnabled: Bool = false

        /// Enable the feature to mention specific members in a message for notification.
        ///
        /// - NOTE: If it's `true`, it sets new ``SBUUserMentionConfiguration`` instance to ``SBUGlobals/userMentionConfig`` if needed. If it's `false`, ``SBUGlobals/userMentionConfig`` is set to `nil`
        @SBUPrioritizedConfig public var isMentionEnabled: Bool = false {
            didSet {
                switch isMentionEnabled {
                case true:
                    if SBUGlobals.userMentionConfig == nil {
                        SBUGlobals.userMentionConfig = .init()
                    }
                case false:
                    SBUGlobals.userMentionConfig = nil
                }
            }
        }

        /// Enable the Voice Message feature.
        @SBUPrioritizedConfig public var isVoiceMessageEnabled: Bool = false

        /// Enable the feature to reply to messages.
        /// - Note: `.quoteReply` type can only set `.none` or `.parent` type of `threadReplySelectType`.
        @SBUPrioritizedConfig public var replyType: SBUReplyType = .quoteReply {
            didSet {
                if replyType == .quoteReply, threadReplySelectType == .thread {
                    _threadReplySelectType.value = .parent
                }
            }
        }

        /// This enum property allows you to direct your users to view either the parent message or the message thread when they tap on a reply in the group channel view.
        @SBUPrioritizedConfig public var threadReplySelectType: SBUThreadReplySelectType = .thread {
            didSet {
                if replyType == .quoteReply, threadReplySelectType == .thread {
                    _threadReplySelectType.value = .parent
                }
            }
        }

        /// Input configuration set of OpenChannel.Channel
        public var input: Input = .init()

        /// Configuration option that decides whether or not sending a MultipleFilesMessage feature is enabled.
        /// If true, selecting multiple images and videos in a GroupChannel is enabled.
        /// Default is false.
        /// ```swift
        /// SendbirdUI.config.groupChannel.channel.isMultipleFilesMessageEnabled = false // Allows a single image or video selection
        /// SendbirdUI.config.groupChannel.channel.isMultipleFilesMessageEnabled = true // Allows multiple images and videos selections
        /// ```
        /// - Note:
        ///     - This is supported only for iOS 14 or above.
        ///     - If it's true, it sets `SBUGlobals.isPHPickerEnabled` as true internally.
        /// - IMPORTANT: Do not set `SBUGlobals.isPHPickerEnabled` to false after setting `isMultipleFilesMessageEnabled` to `true`
        /// - Since: 3.10.0
        @SBUPrioritizedConfig public var isMultipleFilesMessageEnabled: Bool = false {
            willSet {
                if newValue == true {
                    if #available(iOS 14, *) {
                        SBUGlobals.isPHPickerEnabled = newValue
                    } else {
                        SBULog.error("`isMultipleFilesMessageEnabled` can only be enabled in iOS 14 or above.")
                    }
                }
            }
        }

        /// Configuration option that allows the message list tableview in a group channel
        /// to automatically scroll to the **top** of a new incoming message under the following conditions:
        /// - the user is looking at the bottom of the tableview
        /// - the new message cell's height > tableview's visible height
        /// Default is `false`, in which case the message list tableview scrolls to the **bottom** of a new incoming message.
        /// ```swift
        /// SendbirdUI.config.groupChannel.channel.isAutoscrollMessageOverflowToTopEnabled = true // Allows auto scroll to the top of a new incoming message's cell.
        /// SendbirdUI.config.groupChannel.channel.isAutoscrollMessageOverflowToTopEnabled = false // Auto scroll to the bottom of a new incoming message's cell.
        /// ```
        /// - Since: 3.33.0
        public var isAutoscrollMessageOverflowToTopEnabled: Bool = false

        // MARK: Logic

        override init() {}

        func updateWithDashboardData(_ channel: Channel) {
            _isOGTagEnabled.setDashboardValue(channel.isOGTagEnabled)
            _isTypingIndicatorEnabled.setDashboardValue(channel.isTypingIndicatorEnabled)
            _isReactionsEnabled.setDashboardValue(channel.isReactionsEnabled)
            __isSuperGroupReactionsEnabled.setDashboardValue(channel.isSuperGroupReactionsEnabled)
            _isMentionEnabled.setDashboardValue(channel.isMentionEnabled)
            _isVoiceMessageEnabled.setDashboardValue(channel.isVoiceMessageEnabled)
            _replyType.setDashboardValue(channel.replyType)
            _threadReplySelectType.setDashboardValue(channel.threadReplySelectType)
            _isSuggestedRepliesEnabled.setDashboardValue(channel.isSuggestedRepliesEnabled)
            _isFormTypeMessageEnabled.setDashboardValue(channel.isFormTypeMessageEnabled)
            _isFeedbackEnabled.setDashboardValue(channel.isFeedbackEnabled)
            _isMarkdownForUserMessageEnabled.setDashboardValue(channel.isMarkdownForUserMessageEnabled)
            _isMarkAsUnreadEnabled.setDashboardValue(channel.isMarkAsUnreadEnabled)

            input.updateWithDashboardData(channel.input)
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            isOGTagEnabled = try container.decode(Bool.self, forKey: .isOGTagEnabled)
            isTypingIndicatorEnabled = try container.decode(Bool.self, forKey: .isTypingIndicatorEnabled)
            isReactionsEnabled = try container.decode(Bool.self, forKey: .isReactionsEnabled)
            isMentionEnabled = try container.decode(Bool.self, forKey: .isMentionEnabled)
            isVoiceMessageEnabled = try container.decode(Bool.self, forKey: .isVoiceMessageEnabled)
            replyType = try container.decode(SBUReplyType.self, forKey: .replyType)
            threadReplySelectType = try container.decode(SBUThreadReplySelectType.self, forKey: .threadReplySelectType)

            // optional values
            isSuggestedRepliesEnabled = (try? container.decode(Bool.self, forKey: .isSuggestedRepliesEnabled)) ?? SendbirdUI.config.groupChannel.channel.isSuggestedRepliesEnabled
            isFormTypeMessageEnabled = (try? container.decode(Bool.self, forKey: .isFormTypeMessageEnabled)) ??
                SendbirdUI.config.groupChannel.channel.isFormTypeMessageEnabled
            _isSuperGroupReactionsEnabled = try container.decodeIfPresent(Bool.self, forKey: .isSuperGroupReactionsEnabled) ?? false
            isFeedbackEnabled = (try? container.decode(Bool.self, forKey: .isFeedbackEnabled)) ??
                SendbirdUI.config.groupChannel.channel.isFeedbackEnabled
            isMarkdownForUserMessageEnabled = (try? container.decode(Bool.self, forKey: .isMarkdownForUserMessageEnabled)) ??
                SendbirdUI.config.groupChannel.channel.isMarkdownForUserMessageEnabled
            isMarkAsUnreadEnabled = (try? container.decode(Bool.self, forKey: .isMarkAsUnreadEnabled)) ?? SendbirdUI.config.groupChannel.channel.isMarkAsUnreadEnabled

            input = try container.decode(SBUConfig.GroupChannel.Channel.Input.self, forKey: .input)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(isOGTagEnabled, forKey: .isOGTagEnabled)
            try container.encode(isTypingIndicatorEnabled, forKey: .isTypingIndicatorEnabled)
            try container.encode(isReactionsEnabled, forKey: .isReactionsEnabled)
            try container.encode(isMentionEnabled, forKey: .isMentionEnabled)
            try container.encode(isVoiceMessageEnabled, forKey: .isVoiceMessageEnabled)
            try container.encode(replyType, forKey: .replyType)
            try container.encode(threadReplySelectType, forKey: .threadReplySelectType)

            try container.encode(isSuggestedRepliesEnabled, forKey: .isSuggestedRepliesEnabled)
            try container.encode(isFormTypeMessageEnabled, forKey: .isFormTypeMessageEnabled)
            try container.encode(_isSuperGroupReactionsEnabled, forKey: .isSuperGroupReactionsEnabled)
            try container.encode(isFeedbackEnabled, forKey: .isFeedbackEnabled)
            try container.encode(isMarkdownForUserMessageEnabled, forKey: .isMarkdownForUserMessageEnabled)
            try container.encode(isMarkAsUnreadEnabled, forKey: .isMarkAsUnreadEnabled)

            try container.encode(input, forKey: .input)
        }
    }
}

// MARK: - SBUConfig.GroupChannel.ChannelList

public extension SBUConfig.GroupChannel {
    class ChannelList: NSObject, Codable, SBUUpdatableConfigProtocol {
        // MARK: Property

        /// If this value is enabled, the channel list shows the typing indicator. The defaut value is `false`.
        @SBUPrioritizedConfig public var isTypingIndicatorEnabled: Bool = false

        /// If this value is enabled, the channel list provides receipt state of the sent message. The defaut value is `false`.
        @SBUPrioritizedConfig public var isMessageReceiptStatusEnabled: Bool = false

        // MARK: Logic

        override init() {}

        func updateWithDashboardData(_ channelList: ChannelList) {
            _isTypingIndicatorEnabled.setDashboardValue(channelList.isTypingIndicatorEnabled)
            _isMessageReceiptStatusEnabled.setDashboardValue(channelList.isMessageReceiptStatusEnabled)
        }
    }
}

// MARK: - SBUConfig.GroupChannel.Setting

public extension SBUConfig.GroupChannel {
    class Setting: NSObject, Codable, SBUUpdatableConfigProtocol {
        // MARK: Property

        /// Enable the feature to search for messages within a channel.
        /// - IMPORTANT: This property may have different activation states depending on the application attribute settings,
        ///              so if you want to use this value for function implementation,
        ///              please use the ``SBUAvailable/isSupportMessageSearch()`` method in the ``SBUAvailable`` class.
        @SBUPrioritizedConfig public var isMessageSearchEnabled: Bool = false

        // MARK: Logic

        override init() {}

        func updateWithDashboardData(_ setting: Setting) {
            _isMessageSearchEnabled.setDashboardValue(setting.isMessageSearchEnabled)
        }
    }
}

// MARK: - SBUConfig.GroupChannel.Channel.Input

public extension SBUConfig.GroupChannel.Channel {
    class Input: SBUConfig.BaseInput {}
}
