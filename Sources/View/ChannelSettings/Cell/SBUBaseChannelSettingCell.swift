//
//  SBUBaseChannelSettingCell.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/06/21.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

open class SBUBaseChannelSettingCell: SBUTableViewCell {
    
    // MARK: - UI properties (Public)
    public lazy var baseStackView: UIStackView = {
        let stackView = SBUStackView(axis: .horizontal, spacing: 16.0)
        return stackView
    }()
    
    public var titleLabel = UILabel()
    
    public var subTitleLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.textAlignment = .right
        return label
    }()

    public var typeIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    public lazy var rightSwitch: UISwitch = {
        let switchItem = UISwitch()
        switchItem.isHidden = true
        switchItem.addTarget(self, action: #selector(onChangeSwitch(_:)), for: .valueChanged)
        return switchItem
    }()
    
    public lazy var rightButton: UIButton = {
        let button = UIButton()
        button.isHidden = true
        button.isUserInteractionEnabled = false
        return button
    }()
    
    public lazy var separateView = UIView()
    
    @SBUThemeWrapper(theme: SBUTheme.channelSettingsTheme)
    public var theme: SBUChannelSettingsTheme
    
    public var switchAction: ((Bool) -> Void)?
    
    // MARK: - View Lifecycle
    open override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /// This function handles the initialization of views.
    open override func setupViews() {
        super.setupViews()
        
        self.baseStackView.setHStack([
            self.typeIcon,
            self.titleLabel,
            self.subTitleLabel,
            self.rightSwitch,
            self.rightButton
        ])
        self.baseStackView.setCustomSpacing(8.0, after: self.subTitleLabel)
        
        self.contentView.addSubview(self.baseStackView)
        self.contentView.addSubview(self.separateView)
    }
    
    /// This function handles the initialization of actions.
    open override func setupActions() {
        super.setupActions()
    }
    
    /// This function handles the initialization of autolayouts.
    open override func setupLayouts() {
        super.setupLayouts()
        
        self.baseStackView
            .sbu_constraint(equalTo: self.contentView,
                            leading: 16,
                            trailing: -16,
                            top: 13,
                            bottom: 12)
            .sbu_constraint(height: 31)

        self.titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        self.subTitleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
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
    open override func setupStyles() {
        super.setupStyles()
        
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
    
    /// This function configure a cell using `SBUChannelSettingItem`.
    /// - Parameter item: `SBUChannelSettingItem` object.
    /// - Since: 3.1.0
    open func configure(with item: SBUChannelSettingItem) {
        self.typeIcon.image = item.icon
        self.titleLabel.text = item.title
        self.subTitleLabel.text = item.subTitle
        self.subTitleLabel.isHidden = (item.subTitle == nil)
        self.rightButton.isHidden = item.isRightButtonHidden
        if item.isRightButtonHidden {
            self.rightSwitch.isHidden = item.isRightSwitchHidden
        }
    }
    
    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Action
    @objc
    public func onChangeSwitch(_ sender: Any) {
        self.switchAction?(rightSwitch.isOn)
    }
    
    public func changeBackSwitch() {
        self.rightSwitch.isOn = !self.rightSwitch.isOn
    }
}
