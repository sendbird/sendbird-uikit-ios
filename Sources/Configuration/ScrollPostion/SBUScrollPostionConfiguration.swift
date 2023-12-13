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
    public var groupChannel = BaseChannel()
    public var openChannel = BaseChannel()
    public var feedChannel = BaseChannel()
    
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
        case is GroupChannel: return SBUGlobals.scrollPostionConfiguration.groupChannel
        case is OpenChannel: return SBUGlobals.scrollPostionConfiguration.openChannel
        case is FeedChannel: return SBUGlobals.scrollPostionConfiguration.feedChannel
        default: return SBUGlobals.scrollPostionConfiguration.groupChannel
        }
    }
}
