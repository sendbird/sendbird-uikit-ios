//
//  SBUTheme+Type.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/08/23.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

extension SBUTheme {
    static func defaultTheme(currentClass: Any) -> AnyObject {
        if type(of: currentClass) == type(of: SBUGroupChannelListTheme.self) {
            return SBUTheme.groupChannelListTheme
        } else if type(of: currentClass) == type(of: SBUGroupChannelCellTheme.self) {
            return SBUTheme.groupChannelCellTheme
        } else if type(of: currentClass) == type(of: SBUOpenChannelListTheme.self) {
            return SBUTheme.openChannelListTheme
        } else if type(of: currentClass) == type(of: SBUOpenChannelCellTheme.self) {
            return SBUTheme.openChannelCellTheme
        } else if type(of: currentClass) == type(of: SBUChannelTheme.self) {
            return SBUTheme.channelTheme
        } else if type(of: currentClass) == type(of: SBUMessageInputTheme.self) {
            return SBUTheme.messageInputTheme
        } else if type(of: currentClass) == type(of: SBUMessageCellTheme.self) {
            return SBUTheme.messageCellTheme
        } else if type(of: currentClass) == type(of: SBUUserListTheme.self) {
            return SBUTheme.userListTheme
        } else if type(of: currentClass) == type(of: SBUUserCellTheme.self) {
            return SBUTheme.userCellTheme
        } else if type(of: currentClass) == type(of: SBUChannelSettingsTheme.self) {
            return SBUTheme.channelSettingsTheme
        } else if type(of: currentClass) == type(of: SBUUserProfileTheme.self) {
            return SBUTheme.userProfileTheme
        } else if type(of: currentClass) == type(of: SBUComponentTheme.self) {
            return SBUTheme.componentTheme
        } else if type(of: currentClass) == type(of: SBUOverlayTheme.self) {
            return SBUTheme.overlayTheme
        } else if type(of: currentClass) == type(of: SBUMessageSearchTheme.self) {
            return SBUTheme.messageSearchTheme
        } else if type(of: currentClass) == type(of: SBUMessageSearchResultCellTheme.self) {
            return SBUTheme.messageSearchResultCellTheme
        } else if type(of: currentClass) == type(of: SBUCreateOpenChannelTheme.self) {
            return SBUTheme.createOpenChannelTheme
        } else if type(of: currentClass) == type(of: SBUMessageTemplateTheme.self) {
            return SBUTheme.messageTemplateTheme
        } else if type(of: currentClass) == type(of: SBUVoiceMessageInputTheme.self) {
            return SBUTheme.voiceMessageInputTheme
        } else if type(of: currentClass) == type(of: SBUNotificationTheme.self) {
            return SBUTheme.notificationTheme
        } else if type(of: currentClass) == type(of: SBUNotificationTheme.NotificationCell.self) {
            return SBUTheme.notificationTheme.notificationCell
        } else if type(of: currentClass) == type(of: SBUNotificationTheme.Header.self) {
            return SBUTheme.notificationTheme.header
        } else if type(of: currentClass) == type(of: SBUNotificationTheme.List.self) {
            return SBUTheme.notificationTheme.list
        } else {
            return SBUTheme.light
        }
    }
}
