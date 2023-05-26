//
//  SBUChannelPushSettingCell.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/05/22.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

class SBUChannelPushSettingCell: SBUTableViewCell {
    lazy var baseStackView = SBUStackView(axis: .vertical, alignment: .fill, spacing: 16)
    lazy var titleStackView = SBUStackView(axis: .horizontal, alignment: .fill, spacing: 16)
    
    var titleLabel = UILabel()
    var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var rightSwitch: UISwitch = {
       let switchItem = UISwitch()
        switchItem.addTarget(self, action: #selector(onChangeSwitch(_:)), for: .valueChanged)
        return switchItem
    }()
    
    lazy var rightRadioButton: UIButton = {
       let radioButton = UIButton()
        radioButton.addTarget(self, action: #selector(onSelectRadioButton(_:)), for: .touchUpInside)
        return radioButton
    }()
    
    var separateView = UIView()
    
    var switchAction: ((Bool) -> Void)?
    var radioButtonAction: (() -> Void)?
    
    var isSubType: Bool = false
    
    @SBUThemeWrapper(theme: SBUTheme.channelSettingsTheme)
    var theme: SBUChannelSettingsTheme
    
    // MARK: - View Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /// This function handles the initialization of views.
    override func setupViews() {
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
    override func setupActions() {
        
    }
    
    /// This function handles the initialization of autolayouts.
    override func setupLayouts() {
        self.baseStackView
            .sbu_constraint(
                equalTo: self.contentView,
                leading: 16, trailing: -16, top: 13, bottom: 12
            )
        
        self.titleStackView.sbu_constraint(height: 31)
        
        self.rightSwitch
            .sbu_constraint(width: 51)
        
        self.rightRadioButton.sbu_constraint(width: 24, height: 24)
        
        self.separateView
            .sbu_constraint(
                equalTo: self.contentView,
                leading: 16, trailing: -16, bottom: 0.5
            )
            .sbu_constraint(height: 0.5)
    }
    
    /// This function handles the initialization of styles.
    override func setupStyles() {
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Action
    @objc
    func onChangeSwitch(_ sender: Any) {
        self.switchAction?(rightSwitch.isOn)
    }
    
    @objc
    func onSelectRadioButton(_ sender: Any) {
        self.radioButtonAction?()
    }
}
