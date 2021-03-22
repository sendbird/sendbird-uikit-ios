//
//  SBUModerationCell.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2020/07/27.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

class SBUModerationCell: SBUChannelSettingCell {
    /// This function configure a cell using moderation list information.
    /// - Parameter channel: cell object
    func configure(type: ModerationItemType,
                   channel: SBDGroupChannel?,
                   title: String? = nil,
                   icon: UIImage? = nil) {
        
        self.theme = SBUTheme.channelSettingsTheme
        
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
            
        case .bannedMembers:
            self.typeIcon.image = icon ?? SBUIconSetType.iconBan.image(
                with: theme.cellTypeIconTintColor,
                to: SBUIconSetType.Metric.defaultIconSize
            )
            self.titleLabel.text = title ?? SBUStringSet.ChannelSettings_Banned_Members
            self.rightButton.isHidden = false
            
        case .freezeChannel:
            self.typeIcon.image = icon ?? SBUIconSetType.iconFreeze.image(
                with: theme.cellTypeIconTintColor,
                to: SBUIconSetType.Metric.defaultIconSize
            )
            self.titleLabel.text = title ?? SBUStringSet.ChannelSettings_Freeze_Channel
            self.rightSwitch.isHidden = false
            self.rightSwitch.setOn(channel?.isFrozen ?? false, animated: false)
        }
    }
}
