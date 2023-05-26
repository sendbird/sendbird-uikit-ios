//
//  SBUMessageThreadTitleView.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/11/06.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

public protocol SBUMessageThreadTitleViewDelegate: AnyObject {
    /// Called when channel name was tapped.
    /// - Parameter messageThreadTitleView: The tapped thread info view.
    func messageThreadTitleViewDidTap(_ messageThreadTitleView: SBUMessageThreadTitleView)
}

open class SBUMessageThreadTitleView: SBUView {
    
    // MARK: - Logic properties (Public)
    /// The channel object for displaying channel name.
    public private(set) var channel: BaseChannel?
    
    /// The object that acts as the delegate of the titleView. The delegate must adopt the `SBUMessageThreadTitleViewDelegate` protocol.
    public weak var delegate: SBUMessageThreadTitleViewDelegate?
    
    @SBUThemeWrapper(theme: SBUTheme.channelTheme)
    public var theme: SBUChannelTheme
    
    /// The created channel name.
    public var channelName: String {
        var baseChannelName = ""
        if let channelName = channel?.name, SBUUtils.isValid(channelName: channelName) {
            baseChannelName = channelName
        } else {
            if let groupChannel = channel as? GroupChannel {
                baseChannelName = SBUUtils.generateChannelName(channel: groupChannel)
            }
        }
        return baseChannelName
    }
    
    // MARK: - UI properties (Private)
    private lazy var stackView = UIStackView()
    private lazy var titleLabel = UILabel()
    private lazy var channelNameLabel = UILabel()
    
    // MARK: - Life cycle
    public override init() {
        super.init(frame: .zero)
    }
    
    public init(delegate: SBUMessageThreadTitleViewDelegate? = nil) {
        super.init()
        
        self.delegate = delegate
    }

    open override func setupViews() {
        self.titleLabel.text = SBUStringSet.MessageThread.Header.title
        self.titleLabel.textAlignment = .center
        
        self.channelNameLabel.textAlignment = .center
        self.channelNameLabel.isUserInteractionEnabled = false
        
        self.stackView.alignment = .center
        self.stackView.axis = .vertical
        self.stackView.addArrangedSubview(self.titleLabel)
        self.stackView.addArrangedSubview(self.channelNameLabel)
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(onTapChannelName(sender:))
        )
        self.stackView.addGestureRecognizer(tapGesture)
        
        self.addSubview(self.stackView)
    }
    
    open override func setupLayouts() {
        self.stackView
            .sbu_constraint(equalTo: self, leading: 0, trailing: -0, top: 0, bottom: 0)
            .sbu_constraint_equalTo(
                centerXAnchor: self.centerXAnchor,
                centerX: 0,
                centerYAnchor: self.centerYAnchor,
                centerY: 0
            )
    }
    
    open override func setupStyles() {
        self.titleLabel.font = theme.messageThreadTitleFont
        self.titleLabel.textColor = theme.messageThreadTitleColor

        self.channelNameLabel.font = theme.messageThreadTitleChannelNameFont
        self.channelNameLabel.textColor = theme.messageThreadTitleChannelNameColor
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setupStyles()
    }
    
    // MARK: - Action
    @objc
    open func onTapChannelName(sender: UITapGestureRecognizer) {
        self.delegate?.messageThreadTitleViewDidTap(self)
    }
    
    // MARK: - Common
    open func configure(channel: BaseChannel?, title: String?) {
        self.channel = channel
        self.channelNameLabel.text = self.channelName
    }
}
