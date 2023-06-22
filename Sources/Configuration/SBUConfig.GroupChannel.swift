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
        
        /// Enable the feature to react to messages with emojis.
        /// - IMPORTANT: This property may have different activation states depending on the application attribute settings,
        ///              so if you want to use this value for function implementation,
        ///              please use the ``SBUAvailable/isSupportReactions()`` method in the ``SBUAvailable`` class.
        @SBUPrioritizedConfig public var isReactionsEnabled: Bool = true
        
        /// Enable the feature to mention specific members in a message for notification.
        @SBUPrioritizedConfig public var isMentionEnabled: Bool = false
        
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
        
        // MARK: Logic
        override init() {}
        
        func updateWithDashboardData(_ channel: Channel) {
            self._isOGTagEnabled.setDashboardValue(channel.isOGTagEnabled)
            self._isTypingIndicatorEnabled.setDashboardValue(channel.isTypingIndicatorEnabled)
            self._isReactionsEnabled.setDashboardValue(channel.isReactionsEnabled)
            self._isMentionEnabled.setDashboardValue(channel.isMentionEnabled)
            self._isVoiceMessageEnabled.setDashboardValue(channel.isVoiceMessageEnabled)
            self._replyType.setDashboardValue(channel.replyType)
            self._threadReplySelectType.setDashboardValue(channel.threadReplySelectType)
            
            self.input.updateWithDashboardData(channel.input)
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
