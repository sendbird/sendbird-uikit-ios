//
//  SBUConfig.OpenChannel.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2023/06/01.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: - SBUConfig.OpenChannel
extension SBUConfig {
    public class OpenChannel: NSObject, Codable, SBUUpdatableConfigProtocol {
        // MARK: Property
        
        /// Channel configuration set of OpenChannel
        public var channel: Channel = Channel()
        
        // MARK: Logic
        func updateWithDashboardData(_ openChannel: OpenChannel) {
            self.channel.updateWithDashboardData(openChannel.channel)
        }
    }
}

// MARK: - SBUConfig.OpenChannel.Channel
extension SBUConfig.OpenChannel {
    public class Channel: Codable, SBUUpdatableConfigProtocol {
        // MARK: Property
        
        /// When a message contains a web link, and the web link has associated OG Tag information, the OG Tag information will also be displayed.
        /// - IMPORTANT: This property may have different activation states depending on the application attribute settings,
        ///              so if you want to use this value for function implementation,
        ///              please use the ``SBUAvailable/isSupportOgTag(channelType:)`` method in the ``SBUAvailable`` class.
        @SBUPrioritizedConfig public var isOGTagEnabled: Bool = true
        
        /// Input configuration set of OpenChannel.Channel
        public var input: Input = Input()
        
        func updateWithDashboardData(_ channel: Channel) {
            self._isOGTagEnabled.setDashboardValue(channel.isOGTagEnabled)
            self.input.updateWithDashboardData(channel.input)
        }
    }
}

// MARK: - SBUConfig.OpenChannel.Channel.Input
extension SBUConfig.OpenChannel.Channel {
    public class Input: SBUConfig.BaseInput {}
}
