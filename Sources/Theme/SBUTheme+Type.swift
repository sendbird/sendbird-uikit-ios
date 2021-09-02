//
//  SBUTheme+Type.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2021/08/23.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

extension SBUTheme {
    static func defaultTheme(currentClass: Any) -> AnyObject {
        if type(of: currentClass) == type(of: SBUChannelListTheme.self) {
            return SBUTheme.channelListTheme
        }
        else if type(of: currentClass) == type(of: SBUChannelCellTheme.self) {
            return SBUTheme.channelCellTheme
        }
        else if type(of: currentClass) == type(of: SBUChannelTheme.self) {
            return SBUTheme.channelTheme
        }
        else if type(of: currentClass) == type(of: SBUMessageInputTheme.self) {
            return SBUTheme.messageInputTheme
        }
        else if type(of: currentClass) == type(of: SBUMessageCellTheme.self) {
            return SBUTheme.messageCellTheme
        }
        else if type(of: currentClass) == type(of: SBUUserListTheme.self) {
            return SBUTheme.userListTheme
        }
        else if type(of: currentClass) == type(of: SBUUserCellTheme.self) {
            return SBUTheme.userCellTheme
        }
        else if type(of: currentClass) == type(of: SBUChannelSettingsTheme.self) {
            return SBUTheme.channelSettingsTheme
        }
        else if type(of: currentClass) == type(of: SBUUserProfileTheme.self) {
            return SBUTheme.userProfileTheme
        }
        else if type(of: currentClass) == type(of: SBUComponentTheme.self) {
            return SBUTheme.componentTheme
        }
        else if type(of: currentClass) == type(of: SBUOverlayTheme.self) {
            return SBUTheme.overlayTheme
        }
        else if type(of: currentClass) == type(of: SBUMessageSearchTheme.self) {
            return SBUTheme.messageSearchTheme
        }
        else if type(of: currentClass) == type(of: SBUMessageSearchResultCellTheme.self) {
            return SBUTheme.messageSearchResultCellTheme
        }
        else {
            return SBUTheme.light
        }
    }
}
