//
//  SBUConstant.swift
//  SendbirdUIKit
//
//  Created by Harry Kim on 2020/03/02.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

class SBUConstant {
    static let messageCellMaxWidth: CGFloat = 244
    static let thumbnailSize: CGSize = .init(width: 240, height: 160)
    static let imageSize: CGSize = .init(width: 240, height: 160)
    static let quotedMessageThumbnailSize: CGSize = .init(width: 156, height: 104)
    
    static let voiceMessageBaseSize: CGSize = .init(width: 136, height: 44)
    
    static let openChannelThumbnailSize: CGSize = .init(width: 311, height: 207)
    static let openChannelImageSize: CGSize = .init(width: 311, height: 207)
    
    static let newMessageInfoSize = CGSize(width: 144.0, height: 38.0)
    static let newMessageButtonSize = CGSize(width: 40.0, height: 40.0)
    static let scrollBottomButtonSize = CGSize(width: 38.0, height: 38.0)
    
    static let newNotificationInfoSize = CGSize(width: 144.0, height: 38.0)

    static let bottomSheetMaxMiddleHeight: CGFloat = 244

    static let emojiListCollectionViewCellSize = CGSize(width: 44, height: 44)

    static let coverImagePrefix = "https://static.sendbird.com/sample/cover"
    
    static let extensionKeyUIKit = "sb_uikit"
    
    static let bundleIdentifier = "com.sendbird.uikit"
    
    static let groupChannelDelegateIdentifier = "\(bundleIdentifier).delegate.channel.group"
    static let openChannelDelegateIdentifier = "\(bundleIdentifier).delegate.channel.open"
    static let feedChannelDelegateIdentifier = "\(bundleIdentifier).delegate.channel.feed"
    
    static let connectionDelegateIdentifier = "\(bundleIdentifier).delegate.connection"
    
    static let sbuAppVersion = "SBUAppVersion"
    
    static let voiceMessageType = "audio/m4a"
    static let voiceMessageTypeVoiceParameter = "sbu_type=voice"
    static let voiceMessageDurationKey = "KEY_VOICE_MESSAGE_DURATION"
    static let internalMessageTypeKey = "KEY_INTERNAL_MESSAGE_TYPE"
}
