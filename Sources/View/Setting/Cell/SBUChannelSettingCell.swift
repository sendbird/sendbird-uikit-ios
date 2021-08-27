//
//  SBUChannelSettingCell.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2020/07/22.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

class SBUChannelSettingCell: UITableViewCell {
    // MARK: - property
    lazy var baseStackView: UIStackView = {
        let baseStackView = UIStackView()
        baseStackView.spacing = 16.0
        baseStackView.axis = .horizontal
        return baseStackView
    }()
    
    var typeIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    var titleLabel = UILabel()
    
    lazy var rightSwitch: UISwitch = {
       let switchItem = UISwitch()
        switchItem.isHidden = true
        switchItem.addTarget(self, action: #selector(onChangeSwitch(_:)), for: .valueChanged)
        return switchItem
    }()
    
    var subTitleLabel: UILabel = {
       let label = UILabel()
        label.isHidden = true
        label.textAlignment = .right
        return label
    }()
    
    lazy var rightButton: UIButton = {
        let button = UIButton()
        button.isHidden = true
        button.isUserInteractionEnabled = false
        return button
    }()
    var separateView = UIView()
    
    var theme: SBUChannelSettingsTheme = SBUTheme.channelSettingsTheme
    
    var switchAction: ((Bool) -> Void)? = nil
    
    
    // MARK: - View Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
        self.setupAutolayout()
        self.setupActions()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupViews()
        self.setupAutolayout()
        self.setupActions()
    }
    
    /// This function handles the initialization of views.
    func setupViews() {
        self.baseStackView.addArrangedSubview(self.typeIcon)
        self.baseStackView.addArrangedSubview(self.titleLabel)
        self.baseStackView.addArrangedSubview(self.subTitleLabel)
        if #available(iOS 11.0, *) {
            self.baseStackView.setCustomSpacing(8.0, after: self.subTitleLabel)
        }
        self.baseStackView.addArrangedSubview(self.rightSwitch)
        self.baseStackView.addArrangedSubview(self.rightButton)
        
        self.contentView.addSubview(self.baseStackView)
        self.contentView.addSubview(self.separateView)
    }
    
    /// This function handles the initialization of actions.
    func setupActions() {
        
    }
    
    /// This function handles the initialization of autolayouts.
    func setupAutolayout() {
        self.baseStackView
            .sbu_constraint(equalTo: self.contentView,
                            leading: 16,
                            trailing: -16,
                            top:13,
                            bottom: 12)
            .sbu_constraint(height: 31)

        self.typeIcon.sbu_constraint(width: 24)
        self.rightSwitch.sbu_constraint(width: 51)
        self.rightButton.sbu_constraint(width: 24)
        
        self.separateView
            .sbu_constraint(equalTo: self.contentView,
                            leading: 16,
                            trailing: -16,
                            bottom: 0.5)
            .sbu_constraint(height: 0.5)
    }
    
    /// This function handles the initialization of styles.
    func setupStyles() {
        self.theme = SBUTheme.channelSettingsTheme
        
        self.backgroundColor = theme.backgroundColor
        
        self.titleLabel.font = theme.cellTextFont
        self.titleLabel.textColor = theme.cellTextColor
        
        self.subTitleLabel.font = theme.cellSubTextFont
        self.subTitleLabel.textColor = theme.cellSubTextColor
        
        self.rightButton.backgroundColor = theme.backgroundColor
        self.rightButton.setImage(
            SBUIconSetType.iconChevronRight.image(
                with: theme.cellArrowIconTintColor,
                to: SBUIconSetType.Metric.defaultIconSize
            ),
            for: .normal
        )

        self.rightSwitch.onTintColor = theme.cellSwitchColor
        
        self.separateView.backgroundColor = theme.cellSeparateColor
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setupStyles()
    }
    
    /// This function configure a cell using channel information.
    /// - Parameter channel: cell object
    open func configure(type: ChannelSettingItemType,
                        channel: SBDGroupChannel?,
                        title: String? = nil,
                        icon: UIImage? = nil) {
        
        self.theme = SBUTheme.channelSettingsTheme
        
        self.subTitleLabel.isHidden = true
        self.rightButton.isHidden = true
        self.rightSwitch.isHidden = true
        
        switch type {
        case .moderations:
            self.typeIcon.image = icon ?? SBUIconSetType.iconModerations.image(
                with: theme.cellTypeIconTintColor,
                to: SBUIconSetType.Metric.defaultIconSize
            )

            self.titleLabel.text = title ?? SBUStringSet.ChannelSettings_Moderations
            
            self.rightButton.isHidden = false

        case .notifications:
            self.typeIcon.image = icon ?? SBUIconSetType.iconNotifications.image(
                with: theme.cellTypeIconTintColor,
                to: SBUIconSetType.Metric.defaultIconSize
            )
            
            self.titleLabel.text = title ?? SBUStringSet.ChannelSettings_Notifications
            
            self.rightSwitch.isHidden = false
            self.rightSwitch.setOn((channel?.myPushTriggerOption != .off), animated: false)

        case .members:
            self.typeIcon.image = icon ?? SBUIconSetType.iconMembers.image(
                with: theme.cellTypeIconTintColor,
                to: SBUIconSetType.Metric.defaultIconSize
            )
            
            self.titleLabel.text = title ?? SBUStringSet.ChannelSettings_Members_Title
            
            self.subTitleLabel.text = channel?.memberCount.unitFormattedString
            
            self.subTitleLabel.isHidden = false
            self.rightButton.isHidden = false

        case .leave:
            self.typeIcon.image = icon ?? SBUIconSetType.iconLeave.image(
                with: theme.cellLeaveIconColor,
                to: SBUIconSetType.Metric.defaultIconSize
            )
            
            self.titleLabel.text = title ?? SBUStringSet.ChannelSettings_Leave
        case .search:
            self.typeIcon.image = icon ?? SBUIconSetType.iconSearch.image(
                with: theme.cellTypeIconTintColor,
                to: SBUIconSetType.Metric.defaultIconSize
            )
            
            self.titleLabel.text = title ?? SBUStringSet.ChannelSettings_Search
            
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    
    // MARK: - Action
    @objc func onChangeSwitch(_ sender: Any) {
        self.switchAction?(rightSwitch.isOn)
    }
    
    func changeBackSwitch() {
        self.rightSwitch.isOn = !self.rightSwitch.isOn
    }
}
