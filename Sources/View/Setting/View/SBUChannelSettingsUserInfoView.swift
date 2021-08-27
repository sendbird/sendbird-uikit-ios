//
//  SBUChannelSettingsUserInfoView.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2020/10/06.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

@objcMembers
class SBUChannelSettingsUserInfoView: UIView {
    lazy var stackView = UIStackView()
    lazy var coverImage = SBUCoverImageView()
    lazy var channelNameField = UITextField()
    lazy var lineView = UIView()
    lazy var urlTitleLabel = UILabel()
    lazy var urlLabel = UILabel()
    lazy var urlLineView = UIView()
    
    var theme: SBUChannelSettingsTheme = SBUTheme.channelSettingsTheme
    
    var channel: SBDBaseChannel?
    var channelType: ChannelType = .group
    
    let kCoverImageSize: CGFloat = 64.0
    
    var lineViewBottomConstraint: NSLayoutConstraint!
    var urlLineViewBottomConstraint: NSLayoutConstraint!
     
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupViews()
        self.setupAutolayout()
    }
    
    @available(*, unavailable, renamed: "SBUChannelSettingsUserInfoView(frame:)")
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setupViews() {
        self.channelNameField.textAlignment = .center
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        self.channelNameField.leftView = paddingView
        self.channelNameField.leftViewMode = .always
        self.channelNameField.rightView = paddingView
        self.channelNameField.rightViewMode = .always
        self.channelNameField.returnKeyType = .done
        self.channelNameField.isUserInteractionEnabled = false
        
        self.coverImage.clipsToBounds = true
        
        self.urlTitleLabel.isUserInteractionEnabled = false
        self.urlTitleLabel.isHidden = true
        
        self.urlLabel.numberOfLines = 0
        self.urlLabel.lineBreakMode = .byCharWrapping
        self.urlLabel.isHidden = true
        
        self.urlLineView.isHidden = true
        
        self.stackView.alignment = .center
        self.stackView.axis = .vertical
        self.stackView.spacing = 7
        self.stackView.alignment = .center
        self.stackView.addArrangedSubview(self.coverImage)
        self.stackView.addArrangedSubview(self.channelNameField)
        self.addSubview(stackView)
        self.addSubview(lineView)
        
        self.addSubview(self.urlTitleLabel)
        self.addSubview(self.urlLabel)
        self.addSubview(self.urlLineView)
    }
    
    func setupAutolayout() {
        self.coverImage
            .sbu_constraint(width: kCoverImageSize, height: kCoverImageSize)

        self.stackView
            .sbu_constraint(equalTo: self, left: 0, right: 0, top: 20)
        
        self.lineView
            .sbu_constraint(height: 0.5)
            .sbu_constraint(equalTo: self, left: 16, right: 16)
            .sbu_constraint_equalTo(topAnchor: self.stackView.bottomAnchor, top: 20)
        self.lineViewBottomConstraint = self.lineView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        self.lineViewBottomConstraint.isActive = true
        
        self.urlTitleLabel
            .sbu_constraint(equalTo: self, left: 24, right: 24)
            .sbu_constraint_equalTo(topAnchor: self.lineView.bottomAnchor, top: 15)
        
        self.urlLabel
            .sbu_constraint(equalTo: self, left: 24, right: 24)
            .sbu_constraint_equalTo(topAnchor: self.urlTitleLabel.bottomAnchor, top: 2)
        
        self.urlLineView
            .sbu_constraint(height: 0.5)
            .sbu_constraint(equalTo: self, left: 16, right: 16)
            .sbu_constraint_equalTo(topAnchor: self.urlLabel.bottomAnchor, top: 20)
        self.urlLineViewBottomConstraint = self.urlLineView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        self.urlLineViewBottomConstraint.isActive = false
    }
    
    func setupStyles() {
        self.theme = SBUTheme.channelSettingsTheme
        
        self.backgroundColor = .clear
            
        self.lineView.backgroundColor = theme.cellSeparateColor

        self.channelNameField.font = theme.userNameFont
        self.channelNameField.textColor = theme.userNameTextColor
        
        self.urlTitleLabel.font = theme.urlTitleFont
        self.urlTitleLabel.textColor = theme.urlTitleColor
        
        self.urlLabel.font = theme.urlFont
        self.urlLabel.textColor = theme.urlColor
        
        self.urlLineView.backgroundColor = theme.cellSeparateColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.coverImage.layer.cornerRadius = kCoverImageSize / 2
        self.coverImage.layer.borderColor = UIColor.clear.cgColor
        self.coverImage.layer.borderWidth = 1
        
        self.setupStyles()
    }
    
    func configure(channel: SBDBaseChannel?) {
        self.channel = channel
        
        guard let channel = self.channel else {
            self.coverImage.setPlaceholderImage(iconSize: CGSize(width: 46, height: 46))
            return
        }
        
        if channel is SBDOpenChannel {
            if let coverUrl = channel.coverUrl {
                self.coverImage.setImage(withCoverUrl: coverUrl)
            } else {
                self.coverImage.setPlaceholderImage(iconSize: CGSize(width: 46, height: 46))
            }
        } else if let channel = channel as? SBDGroupChannel {
            if let coverUrl = channel.coverUrl,
               SBUUtils.isValid(coverUrl: coverUrl) {
                self.coverImage.setImage(withCoverUrl: coverUrl)
            } else if channel.isBroadcast == true {
                self.coverImage.setBroadcastIcon()
            } else if let members = channel.members as? [SBDUser] {
                self.coverImage.setImage(withUsers: members)
            } else {
                self.coverImage.setPlaceholderImage(iconSize: CGSize(width: 46, height: 46))
            }
        }
        
        if SBUUtils.isValid(channelName: channel.name) {
            self.channelNameField.text = channel.name
        } else {
            if let channel = channel as? SBDGroupChannel {
                self.channelNameField.text = SBUUtils.generateChannelName(channel: channel)
            } else {
                self.channelNameField.text = SBUStringSet.Open_Channel_Name_Default
            }
        }
        
        self.urlTitleLabel.text = SBUStringSet.ChannelSettings_URL
        self.urlLabel.text = channel.channelUrl + "\n"
        
        let isOpenChannel =  self.channel is SBDOpenChannel
        self.urlTitleLabel.isHidden = !isOpenChannel
        self.urlLabel.isHidden = !isOpenChannel
        self.urlLineView.isHidden = !isOpenChannel
        
        self.urlLineViewBottomConstraint.isActive = isOpenChannel
        self.lineViewBottomConstraint.isActive = !isOpenChannel
    }
}

