//
//  SBUModerationCell.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2020/07/27.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

// TODO: Need to Improve. setupItems
class SBUModerationCell: SBUBaseChannelSettingCell {
    /// This function configure a cell using moderation list information.
    /// - Parameter channel: channel object
    func configure(type: ModerationItemType,
                   channel: BaseChannel?,
                   title: String? = nil,
                   icon: UIImage? = nil) {

        self.subTitleLabel.isHidden = true
        self.rightButton.isHidden = true
        self.rightSwitch.isHidden = true
        
        switch type {
        case .operators:
            self.typeIcon.image = icon ?? SBUIconSetType.iconOperator.image(
                with: theme.cellTypeIconTintColor,
                to: SBUIconSetType.Metric.defaultIconSize
            )
            self.titleLabel.text = title ?? SBUStringSet.ChannelSettings_Operators
            self.rightButton.isHidden = false
            
        case .mutedMembers:
            self.typeIcon.image = icon ?? SBUIconSetType.iconMute.image(
                with: theme.cellTypeIconTintColor,
                to: SBUIconSetType.Metric.defaultIconSize
            )
            self.titleLabel.text = title ?? SBUStringSet.ChannelSettings_Muted_Members
            self.rightButton.isHidden = false
            
        case .mutedParticipants:
            self.typeIcon.image = icon ?? SBUIconSetType.iconMute.image(
                with: theme.cellTypeIconTintColor,
                to: SBUIconSetType.Metric.defaultIconSize
            )
            self.titleLabel.text = title ?? SBUStringSet.ChannelSettings_Muted_Participants
            self.rightButton.isHidden = false
            
        case .bannedUsers:
            self.typeIcon.image = icon ?? SBUIconSetType.iconBan.image(
                with: theme.cellTypeIconTintColor,
                to: SBUIconSetType.Metric.defaultIconSize
            )
            self.titleLabel.text = title ?? SBUStringSet.ChannelSettings_Banned_Users
            self.rightButton.isHidden = false
            
        case .freezeChannel:
            self.typeIcon.image = icon ?? SBUIconSetType.iconFreeze.image(
                with: theme.cellTypeIconTintColor,
                to: SBUIconSetType.Metric.defaultIconSize
            )
            self.titleLabel.text = title ?? SBUStringSet.ChannelSettings_Freeze_Channel
            self.rightSwitch.isHidden = false
            self.rightSwitch.setOn(channel?.isFrozen ?? false, animated: false)
            
        default:
            break
        }
    }
}
