//
//  SBUChannelSettingsChannelInfoView.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2020/10/06.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

// TODO: Need improvement
public class SBUChannelSettingsChannelInfoView: SBUView {
    public lazy var stackView = UIStackView()
    public lazy var coverImage = SBUCoverImageView()
    public lazy var channelNameField = UITextField()
    public lazy var lineView = UIView()
    public lazy var urlTitleLabel = UILabel()
    public lazy var urlLabel = UILabel()
    public lazy var urlLineView = UIView()
    
    @SBUThemeWrapper(theme: SBUTheme.channelSettingsTheme)
    var theme: SBUChannelSettingsTheme
    
    var channel: BaseChannel?
    
    let kCoverImageSize: CGFloat = 64.0
    
    var lineViewBottomConstraint: NSLayoutConstraint!
    var urlLineViewBottomConstraint: NSLayoutConstraint!
     
    override init() {
        super.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupViews()
        self.setupLayouts()
        self.setupStyles()
    }
    
    @available(*, unavailable, renamed: "SBUChannelSettingsChannelInfoView(frame:)")
    required convenience init?(coder: NSCoder) {
        fatalError()
    }

    open override func setupViews() {
        super.setupViews()
        
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
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        self.coverImage
            .sbu_constraint(width: kCoverImageSize, height: kCoverImageSize)
        
        self.stackView
            .sbu_constraint_equalTo(
                leftAnchor: self.safeAreaLayoutGuide.leftAnchor, left: 0,
                rightAnchor: self.safeAreaLayoutGuide.rightAnchor, right: 0,
                topAnchor: self.topAnchor, top: 20
            )
        
        self.lineView
            .sbu_constraint_equalTo(
                leftAnchor: self.safeAreaLayoutGuide.leftAnchor, left: 16,
                rightAnchor: self.safeAreaLayoutGuide.rightAnchor, right: 16,
                topAnchor: self.stackView.bottomAnchor, top: 20
            )
            .sbu_constraint(height: 0.5)
        self.lineViewBottomConstraint = self.lineView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        
        self.urlTitleLabel
            .sbu_constraint_equalTo(
                leftAnchor: self.safeAreaLayoutGuide.leftAnchor, left: 24,
                rightAnchor: self.safeAreaLayoutGuide.rightAnchor, right: 24,
                topAnchor: self.lineView.bottomAnchor, top: 15
            )
        
        self.urlLabel
            .sbu_constraint_equalTo(
                leftAnchor: self.safeAreaLayoutGuide.leftAnchor, left: 24,
                rightAnchor: self.safeAreaLayoutGuide.rightAnchor, right: 24,
                topAnchor: self.urlTitleLabel.bottomAnchor, top: 2
            )
        
        self.urlLineView
            .sbu_constraint_equalTo(
                leftAnchor: self.safeAreaLayoutGuide.leftAnchor, left: 16,
                rightAnchor: self.safeAreaLayoutGuide.rightAnchor, right: 16,
                topAnchor: self.urlLabel.bottomAnchor, top: 16
            )
            .sbu_constraint(height: 0.5)
        
        self.urlLineViewBottomConstraint = self.urlLineView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
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
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.coverImage.layer.cornerRadius = kCoverImageSize / 2
        self.coverImage.layer.borderColor = UIColor.clear.cgColor
        self.coverImage.layer.borderWidth = 1
    }
    
    open func configure(channel: BaseChannel?) {
        self.channel = channel
        
        guard let channel = self.channel else {
            self.coverImage.setPlaceholder(type: .iconUser)
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if channel is OpenChannel {
                if let url = channel.coverURL, SBUUtils.isValid(coverURL: url) {
                    self.coverImage.setImage(withCoverURL: url)
                } else {
                    self.coverImage.setPlaceholder(type: .iconChannels)
                }
            } else if let channel = channel as? GroupChannel {
                if let coverURL = channel.coverURL,
                   SBUUtils.isValid(coverURL: coverURL) {
                    self.coverImage.setImage(withCoverURL: coverURL)
                } else if channel.isBroadcast == true {
                    self.coverImage.setBroadcastIcon()
                } else if channel.members.count > 0 {
                    self.coverImage.setImage(withUsers: channel.members)
                } else {
                    self.coverImage.setPlaceholder(type: .iconUser)
                }
            }
        }
            
        if SBUUtils.isValid(channelName: channel.name) {
            self.channelNameField.text = channel.name
        } else {
            if let channel = channel as? GroupChannel {
                self.channelNameField.text = SBUUtils.generateChannelName(channel: channel)
            } else {
                self.channelNameField.text = SBUStringSet.Open_Channel_Name_Default
            }
        }
        
        self.urlTitleLabel.text = SBUStringSet.ChannelSettings_URL
        self.urlLabel.text = channel.channelURL
        
        let isOpenChannel =  self.channel is OpenChannel
        self.urlTitleLabel.isHidden = !isOpenChannel
        self.urlLabel.isHidden = !isOpenChannel
        self.urlLineView.isHidden = !isOpenChannel
        
        self.urlLineViewBottomConstraint.isActive = isOpenChannel
        self.lineViewBottomConstraint.isActive = !isOpenChannel
    }
}
