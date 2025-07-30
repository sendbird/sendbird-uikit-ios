//
//  SBUConfig.GroupChannel.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2023/06/01.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit

extension SBUConfig {
    public class GroupChannel: Codable, SBUUpdatableConfigProtocol {
        // MARK: Property
        
        /// Channel configuration set of GroupChannel
        public var channel: Channel = Channel()
        
        /// Channel list configuration set of GroupChannel
        public var channelList: ChannelList = ChannelList()
        
        /// Channel setting configuration set of GroupChannel
        public var setting: Setting = Setting()
        
        // MARK: Logic
        func updateWithDashboardData(_ groupChannel: GroupChannel) {
            self.channel.updateWithDashboardData(groupChannel.channel)
            self.channelList.updateWithDashboardData(groupChannel.channelList)
            self.setting.updateWithDashboardData(groupChannel.setting)
        }
    }
}

// MARK: - SBUConfig.GroupChannel.Channel
extension SBUConfig.GroupChannel {
    public class Channel: NSObject, Codable, SBUUpdatableConfigProtocol {
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
        /// - Since: [NEXT_VERSION]
        @SBUPrioritizedConfig public var isMarkAsUnreadEnabled: Bool = false
        
        /// Enable the feature to mention specific members in a message for notification.
        ///
        /// - NOTE: If it's `true`, it sets new ``SBUUserMentionConfiguration`` instance to ``SBUGlobals/userMentionConfig`` if needed. If it's `false`, ``SBUGlobals/userMentionConfig`` is set to `nil`
        @SBUPrioritizedConfig public var isMentionEnabled: Bool = false {
            didSet {
                switch self.isMentionEnabled {
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
                if self.replyType == .quoteReply, self.threadReplySelectType == .thread {
                    self._threadReplySelectType.value = .parent
                }
            }
        }
        
        /// This enum property allows you to direct your users to view either the parent message or the message thread when they tap on a reply in the group channel view.
        @SBUPrioritizedConfig public var threadReplySelectType: SBUThreadReplySelectType = .thread {
            didSet {
                if self.replyType == .quoteReply, self.threadReplySelectType == .thread {
                    self._threadReplySelectType.value = .parent
                }
            }
        }
        
        /// Input configuration set of OpenChannel.Channel
        public var input: Input = Input()
        
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
        
        // MARK: Logic
        override init() {}
        
        func updateWithDashboardData(_ channel: Channel) {
            self._isOGTagEnabled.setDashboardValue(channel.isOGTagEnabled)
            self._isTypingIndicatorEnabled.setDashboardValue(channel.isTypingIndicatorEnabled)
            self._isReactionsEnabled.setDashboardValue(channel.isReactionsEnabled)
            self.__isSuperGroupReactionsEnabled.setDashboardValue(channel.isSuperGroupReactionsEnabled)
            self._isMentionEnabled.setDashboardValue(channel.isMentionEnabled)
            self._isVoiceMessageEnabled.setDashboardValue(channel.isVoiceMessageEnabled)
            self._replyType.setDashboardValue(channel.replyType)
            self._threadReplySelectType.setDashboardValue(channel.threadReplySelectType)
            self._isSuggestedRepliesEnabled.setDashboardValue(channel.isSuggestedRepliesEnabled)
            self._isFormTypeMessageEnabled.setDashboardValue(channel.isFormTypeMessageEnabled)
            self._isFeedbackEnabled.setDashboardValue(channel.isFeedbackEnabled)
            self._isMarkdownForUserMessageEnabled.setDashboardValue(channel.isMarkdownForUserMessageEnabled)
            self._isMarkAsUnreadEnabled.setDashboardValue(channel.isMarkAsUnreadEnabled)
            
            self.input.updateWithDashboardData(channel.input)
        }
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self.isOGTagEnabled = try container.decode(Bool.self, forKey: .isOGTagEnabled)
            self.isTypingIndicatorEnabled = try container.decode(Bool.self, forKey: .isTypingIndicatorEnabled)
            self.isReactionsEnabled = try container.decode(Bool.self, forKey: .isReactionsEnabled)
            self.isMentionEnabled = try container.decode(Bool.self, forKey: .isMentionEnabled)
            self.isVoiceMessageEnabled = try container.decode(Bool.self, forKey: .isVoiceMessageEnabled)
            self.replyType = try container.decode(SBUReplyType.self, forKey: .replyType)
            self.threadReplySelectType = try container.decode(SBUThreadReplySelectType.self, forKey: .threadReplySelectType)
            
            // optional values
            self.isSuggestedRepliesEnabled = (try? container.decode(Bool.self, forKey: .isSuggestedRepliesEnabled)) ?? SendbirdUI.config.groupChannel.channel.isSuggestedRepliesEnabled
            self.isFormTypeMessageEnabled = (try? container.decode(Bool.self, forKey: .isFormTypeMessageEnabled)) ??
                SendbirdUI.config.groupChannel.channel.isFormTypeMessageEnabled
            self._isSuperGroupReactionsEnabled = try container.decodeIfPresent(Bool.self, forKey: .isSuperGroupReactionsEnabled) ?? false
            self.isFeedbackEnabled = (try? container.decode(Bool.self, forKey: .isFeedbackEnabled)) ??
                SendbirdUI.config.groupChannel.channel.isFeedbackEnabled
            self.isMarkdownForUserMessageEnabled = (try? container.decode(Bool.self, forKey: .isMarkdownForUserMessageEnabled)) ??
            SendbirdUI.config.groupChannel.channel.isMarkdownForUserMessageEnabled
            self.isMarkAsUnreadEnabled = (try? container.decode(Bool.self, forKey: .isMarkAsUnreadEnabled)) ?? SendbirdUI.config.groupChannel.channel.isMarkAsUnreadEnabled
            
            self.input = try container.decode(SBUConfig.GroupChannel.Channel.Input.self, forKey: .input)
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(self.isOGTagEnabled, forKey: .isOGTagEnabled)
            try container.encode(self.isTypingIndicatorEnabled, forKey: .isTypingIndicatorEnabled)
            try container.encode(self.isReactionsEnabled, forKey: .isReactionsEnabled)
            try container.encode(self.isMentionEnabled, forKey: .isMentionEnabled)
            try container.encode(self.isVoiceMessageEnabled, forKey: .isVoiceMessageEnabled)
            try container.encode(self.replyType, forKey: .replyType)
            try container.encode(self.threadReplySelectType, forKey: .threadReplySelectType)
            
            try container.encode(self.isSuggestedRepliesEnabled, forKey: .isSuggestedRepliesEnabled)
            try container.encode(self.isFormTypeMessageEnabled, forKey: .isFormTypeMessageEnabled)
            try container.encode(self._isSuperGroupReactionsEnabled, forKey: .isSuperGroupReactionsEnabled)
            try container.encode(self.isFeedbackEnabled, forKey: .isFeedbackEnabled)
            try container.encode(self.isMarkdownForUserMessageEnabled, forKey: .isMarkdownForUserMessageEnabled)
            try container.encode(self.isMarkAsUnreadEnabled, forKey: .isMarkAsUnreadEnabled)
            
            try container.encode(self.input, forKey: .input)
        }
    }
}

// MARK: - SBUConfig.GroupChannel.ChannelList
extension SBUConfig.GroupChannel {
    public class ChannelList: NSObject, Codable, SBUUpdatableConfigProtocol {
        // MARK: Property
        
        /// If this value is enabled, the channel list shows the typing indicator. The defaut value is `false`.
        @SBUPrioritizedConfig public var isTypingIndicatorEnabled: Bool = false
        
        /// If this value is enabled, the channel list provides receipt state of the sent message. The defaut value is `false`.
        @SBUPrioritizedConfig public var isMessageReceiptStatusEnabled: Bool = false
        
        // MARK: Logic
        override init() {}
        
        func updateWithDashboardData(_ channelList: ChannelList) {
            self._isTypingIndicatorEnabled.setDashboardValue(channelList.isTypingIndicatorEnabled)
            self._isMessageReceiptStatusEnabled.setDashboardValue(channelList.isMessageReceiptStatusEnabled)
        }
    }
}

// MARK: - SBUConfig.GroupChannel.Setting
extension SBUConfig.GroupChannel {
    public class Setting: NSObject, Codable, SBUUpdatableConfigProtocol {
        // MARK: Property
        
        /// Enable the feature to search for messages within a channel. 
        /// - IMPORTANT: This property may have different activation states depending on the application attribute settings,
        ///              so if you want to use this value for function implementation,
        ///              please use the ``SBUAvailable/isSupportMessageSearch()`` method in the ``SBUAvailable`` class.
        @SBUPrioritizedConfig public var isMessageSearchEnabled: Bool = false
        
        // MARK: Logic
        override init() {}
        
        func updateWithDashboardData(_ setting: Setting) {
            self._isMessageSearchEnabled.setDashboardValue(setting.isMessageSearchEnabled)
        }
    }
}

// MARK: - SBUConfig.GroupChannel.Channel.Input
extension SBUConfig.GroupChannel.Channel {
    public class Input: SBUConfig.BaseInput {}
}
