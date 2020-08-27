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
        
        self.subTitleLabel.isHidden = true
        self.rightButton.isHidden = true
        self.rightSwitch.isHidden = true
        
        switch type {
        case .operators:
            self.typeIcon.image = icon ?? SBUIconSet.iconOperator.sbu_with(
                tintColor: theme.cellTypeIconTintColor
            )
            self.titleLabel.text = title ?? SBUStringSet.ChannelSettings_Operators
            self.rightButton.isHidden = false
            
        case .mutedMembers:
            self.typeIcon.image = icon ?? SBUIconSet.iconMuted.sbu_with(
                tintColor: theme.cellTypeIconTintColor
            )
            self.titleLabel.text = title ?? SBUStringSet.ChannelSettings_Muted_Members
            self.rightButton.isHidden = false
            
        case .bannedMembers:
            self.typeIcon.image = icon ?? SBUIconSet.iconBanned.sbu_with(
                tintColor: theme.cellTypeIconTintColor
            )
            self.titleLabel.text = title ?? SBUStringSet.ChannelSettings_Banned_Members
            self.rightButton.isHidden = false
            
        case .freezeChannel:
            self.typeIcon.image = icon ?? SBUIconSet.iconFreeze.sbu_with(
                tintColor: theme.cellTypeIconTintColor
            )
            self.titleLabel.text = title ?? SBUStringSet.ChannelSettings_Freeze_Channel
            self.rightSwitch.isHidden = false
            self.rightSwitch.setOn(channel?.isFrozen ?? false, animated: false)
        }
    }
}
