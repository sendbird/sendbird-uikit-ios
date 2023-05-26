//
//  SBUOpenChannelBaseMessageCell.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2020/10/27.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

@IBDesignable
open class SBUOpenChannelBaseMessageCell: SBUTableViewCell {
    // MARK: - Public
    public var message: BaseMessage?
    public var groupPosition: MessageGroupPosition = .none

    public lazy var dateView: UIView = SBUMessageDateView()

    public lazy var messageContentView: UIView = {
        let view = UIView()
        return view
    }()
    
    @SBUThemeWrapper(theme: SBUTheme.messageCellTheme)
    public var theme: SBUMessageCellTheme
    @SBUThemeWrapper(theme: SBUTheme.overlayTheme.messageCellTheme, setToDefault: true)
    public var overlayTheme: SBUMessageCellTheme
    
    /// A vertical stack view that contains `dateView` and `messageContentView` as defaults.
    ///
    /// As a default, it has following  configuration:
    /// - axis: `.vertical`
    /// - spacing: `16`
    public lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 16
        stackView.axis = .vertical
        return stackView
    }()
    
    public var stackViewTopConstraint: NSLayoutConstraint?
    
    var isOverlay = false
    
    // MARK: - Action
    var userProfileTapHandler: (() -> Void)?
    var tapHandlerToContent: (() -> Void)?
    var longPressHandlerToContent: (() -> Void)?

    // MARK: - View Lifecycle
    
    /// This function handles the initialization of views.
    open override func setupViews() {
        super.setupViews()
        
        self.dateView.isHidden = true
        
        self.stackView.addArrangedSubview(self.dateView)
        self.stackView.addArrangedSubview(self.messageContentView)
        
        self.contentView.addSubview(self.stackView)
    }
    
    /// This function handles the initialization of autolayouts.
    open override func setupLayouts() {
        super.setupLayouts()
        
        self.stackView
            .setConstraint(from: self.contentView, left: 0, bottom: 0)
            .setConstraint(from: self.contentView, right: 0)
        
        self.updateTopAnchorConstraint()
    }

    /// This function handles the initialization of styles.
    open override func setupStyles() {
        super.setupStyles()
        
        self.backgroundColor = .clear
        
        if let dateView = self.dateView as? SBUMessageDateView {
            dateView.setupStyles()
        }
    }
    
    open func updateTopAnchorConstraint() {
        let isGrouped = SBUGlobals.isMessageGroupingEnabled
            && self.groupPosition != .none
            && self.groupPosition != .top
        let constant: CGFloat = isGrouped ? 4 : 16
        
        self.stackViewTopConstraint?.isActive = false
        self.stackViewTopConstraint = self.stackView.topAnchor.constraint(
            equalTo: self.contentView.topAnchor,
            constant: constant
        )
        self.stackViewTopConstraint?.isActive = true
    }
    
    // MARK: - Common
    
    /// This function configure a cell using informations.
    /// - Parameters:
    ///   - message: Message object
    ///   - hideDateView: Hide or expose date information
    ///   - isOverlay: Whether to use in overlay
    open func configure(message: BaseMessage,
                        hideDateView: Bool,
                        groupPosition: MessageGroupPosition = .none,
                        isOverlay: Bool = false) {
        self.message = message
        self.groupPosition = groupPosition
        self.dateView.isHidden = hideDateView
        self.isOverlay = isOverlay
        
        if let dateView = self.dateView as? SBUMessageDateView {
            dateView.configure(timestamp: message.createdAt)
        }
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        let theme = self.isOverlay ? self.overlayTheme : self.theme
        
        super.setSelected(selected, animated: animated)
        if selected {
            self.backgroundColor = theme.leftBackgroundColor
        } else {
            self.backgroundColor = theme.backgroundColor
        }
    }
    
    // MARK: -
    open override func prepareForReuse() {
        super.prepareForReuse()
    }
}
