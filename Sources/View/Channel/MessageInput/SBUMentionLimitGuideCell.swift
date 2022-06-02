//
//  SBUMentionLimitGuideCell.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/04/19.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

open class SBUMentionLimitGuideCell: SBUTableViewCell {
    public lazy var iconImageView = UIImageView()
    
    public let limitGuideLabel = UILabel()
    
    public var baseStackView: UIStackView = SBUStackView(
        axis: .horizontal,
        alignment: .center,
        spacing: 4
    )
    
    @SBUThemeWrapper(theme: SBUTheme.channelTheme)
    public var theme: SBUChannelTheme
    
    open override func setupViews() {
        super.setupViews()
        
        baseStackView.setHStack([
            iconImageView,
            limitGuideLabel
        ])
        self.contentView.addSubview(baseStackView)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        self.iconImageView
            .sbu_constraint(width: 20, height: 20)
        
        self.baseStackView
            .sbu_constraint(
                equalTo: self.contentView,
                leading: 16, trailing: -16, top: 12, bottom: 12
            )
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
        self.iconImageView.image = SBUIconSetType.iconInfo.image(
            with: theme.mentionLimitGuideTextColor,
            to: SBUIconSetType.Metric.defaultIconSizeMedium
        )
        
        self.limitGuideLabel.textAlignment = .left
        self.limitGuideLabel.font = theme.mentionLimitGuideTextFont
        self.limitGuideLabel.textColor = theme.mentionLimitGuideTextColor
        self.limitGuideLabel.text = SBUStringSet.Mention.Limit_Guide
        self.limitGuideLabel.adjustsFontSizeToFitWidth = true
    }
}
