//
//  SBUChannelPushSettingCell.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/05/22.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// Channel Push Setting cell class
/// - Since: 3.28.0
open class SBUChannelPushSettingCell: SBUTableViewCell {
    /// base vertical stack view
    public lazy var baseStackView = SBUStackView(axis: .vertical, alignment: .fill, spacing: 16)
    /// title horizontal stack view
    public lazy var titleStackView = SBUStackView(axis: .horizontal, alignment: .fill, spacing: 16)
    
    /// title label
    public var titleLabel = UILabel()
    
    /// description label
    public var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    /// switch button
    public lazy var rightSwitch: UISwitch = {
       let switchItem = UISwitch()
        switchItem.addTarget(self, action: #selector(onChangeSwitch(_:)), for: .valueChanged)
        return switchItem
    }()
    
    /// radio button
    public lazy var rightRadioButton: UIButton = {
       let radioButton = UIButton()
        radioButton.addTarget(self, action: #selector(onSelectRadioButton(_:)), for: .touchUpInside)
        return radioButton
    }()
    
    /// separate view
    public var separateView = UIView()
    
    /// switch action handler
    public var switchAction: ((Bool) -> Void)?
    
    /// radio action handler
    public var radioButtonAction: (() -> Void)?
    
    /// Value indicating whether sub type
    public private(set) var isSubType: Bool = false
    
    @SBUThemeWrapper(theme: SBUTheme.channelSettingsTheme)
    public var theme: SBUChannelSettingsTheme
    
    // MARK: - View Lifecycle
    open override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /// This function handles the initialization of views.
    open override func setupViews() {
        self.baseStackView.setVStack([
            self.titleStackView.setHStack([
                self.titleLabel,
                self.rightSwitch,
                self.rightRadioButton
            ]),
            self.descriptionLabel
        ])
        
        self.rightRadioButton.setImage(
            SBUIconSetType.iconRadioButtonOff.image(
                with: self.theme.cellRadioButtonDeselectedColor,
                to: SBUIconSetType.Metric.defaultIconSize
            ),
            for: .normal
        )
        self.rightRadioButton.setImage(
            SBUIconSetType.iconRadioButtonOn.image(
                with: self.theme.cellRadioButtonSelectedColor,
                to: SBUIconSetType.Metric.defaultIconSize
            ),
            for: .selected
        )
        self.rightRadioButton.setImage(
            SBUIconSetType.iconRadioButtonOn.image(
                with: self.theme.cellRadioButtonSelectedColor,
                to: SBUIconSetType.Metric.defaultIconSize
            ),
            for: .highlighted
        )
        
        self.contentView.addSubview(self.baseStackView)
        self.contentView.addSubview(self.separateView)
    }
    
    /// This function handles the initialization of actions.
    open override func setupActions() {
        
    }
    
    /// This function handles the initialization of autolayouts.
    open override func setupLayouts() {
        
        self.rightSwitch
            .sbu_constraint(width: 51)
        
        self.rightRadioButton
            .sbu_constraint(width: 24, height: 24, priority: .defaultHigh)
        
        self.titleStackView
            .sbu_constraint(height: 31, priority: .defaultHigh)
        
        self.separateView
            .sbu_constraint(
                equalTo: self.contentView,
                leading: 16, 
                trailing: -16,
                bottom: 0.5
            )
            .sbu_constraint(height: 0.5)
        
        self.baseStackView
            .sbu_constraint(
                equalTo: self.contentView,
                leading: 16, 
                trailing: -16,
                top: 13,
                bottom: 12
            )
        
    }
    
    /// This function handles the initialization of styles.
    open override func setupStyles() {
        self.backgroundColor = theme.backgroundColor
        
        self.titleLabel.font = self.isSubType ? theme.cellDescriptionTextFont : theme.cellTextFont
        self.titleLabel.textColor = theme.cellTextColor
        
        self.descriptionLabel.font = theme.cellDescriptionTextFont
        self.descriptionLabel.textColor = theme.cellDescriptionTextColor
        
        self.rightSwitch.onTintColor = theme.cellSwitchColor
        
        self.separateView.backgroundColor = theme.cellSeparateColor
    }
    
    open func configure(pushTriggerOption: GroupChannelPushTriggerOption,
                        subType: ChannelPushSettingsSubType? = nil) {
        if let subType = subType {
            self.isSubType = true
            switch subType {
            case .all:
                self.titleLabel.text = SBUStringSet.ChannelPushSettings_Item_All
                self.rightRadioButton.isSelected = (
                    pushTriggerOption == .all || pushTriggerOption == .default
                )
            case .mention:
                self.titleLabel.text = SBUStringSet.ChannelPushSettings_Item_Mentions_Only
                self.rightRadioButton.isSelected = pushTriggerOption == .mentionOnly
            }
            self.descriptionLabel.isHidden = true
            self.rightSwitch.isHidden = true
            self.rightRadioButton.isHidden = false
        } else {
            self.isSubType = false
            let isOn = pushTriggerOption != .off
            self.titleLabel.text = SBUStringSet.ChannelPushSettings_Notification_Title
            self.descriptionLabel.text = SBUStringSet.ChannelPushSettings_Notification_Description
            self.descriptionLabel.isHidden = false
            self.rightSwitch.setOn(isOn, animated: false)
            self.rightSwitch.isHidden = false
            self.rightRadioButton.isHidden = true
        }
    }
    
    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Action
    /// Methods called when the switch is triggered
    @objc
    public func onChangeSwitch(_ sender: Any) {
        self.switchAction?(rightSwitch.isOn)
    }
    
    /// Methods called when the radio button is triggered
    @objc
    public func onSelectRadioButton(_ sender: Any) {
        self.radioButtonAction?()
    }
}
