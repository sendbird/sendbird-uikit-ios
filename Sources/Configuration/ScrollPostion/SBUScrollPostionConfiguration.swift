//
//  SBUScrollPostionConfiguration.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2023/11/22.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// The class for configuring scroll position.
/// - Since: 3.13.0
public class SBUScrollPostionConfiguration {
    /// The class for configuring the group channel scroll position.
    public var groupChannel = BaseChannel()
    /// The class for configuring the open channel scroll position.
    public var openChannel = BaseChannel()
    /// The class for configuring the feed channel scroll position.
    public var feedChannel = BaseChannel()
    
    /// BaseChannel class is used to configure the scroll position for different types of channels.
    public class BaseChannel {
        /// Position value when the message is scrolled to the bottom by user interaction.
        public var scrollToBottom: SBUScrollPosition = .bottom
        
        /// Position value when the message is scrolled to the bottom with the New Message interaction.
        public var scrollToNewMessage: SBUScrollPosition = .bottom
        
        /// Position value to be scrolled on initialization.
        public var scrollToInitial: SBUScrollPosition = .bottom
        
        /// Position value to be scrolled on initialization with a starting point.
        public var scrollToInitialWithStartingPoint: SBUScrollPosition = .middle
    }
    
    class GroupChannel: BaseChannel { }
    class OpenChannel: BaseChannel { }
    class FeedChannel: BaseChannel { }
}

extension SBUScrollPostionConfiguration {
    static func getConfiguration(with channel: SendbirdChatSDK.BaseChannel?) -> SBUScrollPostionConfiguration.BaseChannel {
        switch channel {
        case is SendbirdChatSDK.GroupChannel: return SBUGlobals.scrollPostionConfiguration.groupChannel
        case is SendbirdChatSDK.OpenChannel: return SBUGlobals.scrollPostionConfiguration.openChannel
        case is SendbirdChatSDK.FeedChannel: return SBUGlobals.scrollPostionConfiguration.feedChannel
        default: return SBUGlobals.scrollPostionConfiguration.groupChannel
        }
    }
}
