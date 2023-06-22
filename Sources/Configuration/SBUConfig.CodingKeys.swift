//
//  SBUConfig.CodingKeys.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2023/06/07.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit

extension SBUConfig.Common {
    enum CodingKeys: String, CodingKey {
        case isUsingDefaultUserProfileEnabled = "enableUsingDefaultUserProfile"
    }
}

extension SBUConfig.BaseInput {
    enum CodingKeys: String, CodingKey {
        case camera
        case gallery
        case isDocumentEnabled = "enableDocument"
    }
}

extension SBUConfig.BaseInput.Camera {
    enum CodingKeys: String, CodingKey {
        case isPhotoEnabled = "enablePhoto"
        case isVideoEnabled = "enableVideo"
    }
}

extension SBUConfig.BaseInput.Gallery {
    enum CodingKeys: String, CodingKey {
        case isPhotoEnabled = "enablePhoto"
        case isVideoEnabled = "enableVideo"
    }
}

extension SBUConfig.GroupChannel {
    enum CodingKeys: String, CodingKey {
        case channel
        case channelList
        case setting
    }
}

extension SBUConfig.GroupChannel.Channel {
    enum CodingKeys: String, CodingKey {
        case isOGTagEnabled = "enableOgtag"
        case isTypingIndicatorEnabled = "enableTypingIndicator"
        case isReactionsEnabled = "enableReactions"
        case isMentionEnabled = "enableMention"
        case isVoiceMessageEnabled = "enableVoiceMessage"
        case replyType
        case threadReplySelectType
        case input
    }
}

extension SBUConfig.GroupChannel.ChannelList {
    enum CodingKeys: String, CodingKey {
        case isTypingIndicatorEnabled = "enableTypingIndicator"
        case isMessageReceiptStatusEnabled = "enableMessageReceiptStatus"
    }
}

extension SBUConfig.GroupChannel.Setting {
    enum CodingKeys: String, CodingKey {
        case isMessageSearchEnabled = "enableMessageSearch"
    }
}

extension SBUConfig.OpenChannel.Channel {
    enum CodingKeys: String, CodingKey {
        case isOGTagEnabled = "enableOgtag"
        case input
    }
}
