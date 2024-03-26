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
        case isSuperGroupReactionsEnabled = "enableReactionsSupergroup" // 3.19.0
        case isMentionEnabled = "enableMention"
        case isVoiceMessageEnabled = "enableVoiceMessage"
        case isSuggestedRepliesEnabled = "enableSuggestedReplies" // 3.11.0
        case isFormTypeMessageEnabled = "enableFormTypeMessage" // 3.11.0
        case isFeedbackEnabled = "enableFeedback" // 3.15.0
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
