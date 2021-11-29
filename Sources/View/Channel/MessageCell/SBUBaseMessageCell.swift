//
//  SBUBaseMessageCell.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 03/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

@IBDesignable
@available(*, deprecated, renamed: "SBUBaseMessageCell")
open class SBUMessageBaseCell { }

@objcMembers @IBDesignable
open class SBUBaseMessageCell: UITableViewCell {
    // MARK: - Public
    public var message: SBDBaseMessage = .init()
    public var position: MessagePosition = .center
    public var groupPosition: MessageGroupPosition = .none
    public var receiptState: SBUMessageReceiptState = .none

    public lazy var messageContentView: UIView = {
        let view = UIView()
        return view
    }()
    
    public lazy var dateView: UIView = SBUMessageDateView()

    @SBUThemeWrapper(theme: SBUTheme.messageCellTheme)
    public var theme: SBUMessageCellTheme

    
    // MARK: - Private
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 16
        stackView.axis = .vertical
        return stackView
    }()
    
    var stackViewTopConstraint: NSLayoutConstraint?

    
    // MARK: - Action
    public var userProfileTapHandler: (() -> Void)? = nil
    public var tapHandlerToContent: (() -> Void)? = nil
    public var longPressHandlerToContent: (() -> Void)? = nil
    public var emojiTapHandler: ((_ emojiKey: String) -> Void)? = nil
    public var moreEmojiTapHandler: (() -> Void)? = nil
    public var emojiLongPressHandler: ((_ emojiKey: String) -> Void)? = nil


    // MARK: - View Lifecycle
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
        self.setupAutolayout()
        self.setupActions()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupViews()
        self.setupAutolayout()
        self.setupActions()
    }
    
    /// This function handles the initialization of views.
    open func setupViews() {
        self.dateView.isHidden = true
        
        self.contentView.addSubview(self.stackView)
        self.stackView.addArrangedSubview(self.dateView)
        self.stackView.addArrangedSubview(self.messageContentView)
    }
    
    /// This function handles the initialization of actions.
    open func setupActions() {
        
    }
    
    /// This function handles the initialization of autolayouts.
    open func setupAutolayout() {
        self.stackView
            .setConstraint(from: self.contentView, left: 0, bottom: 0)
            .setConstraint(from: self.contentView, right: 0, priority: .defaultHigh)
        
        self.updateTopAnchorConstraint()
    }

    /// This function handles the initialization of styles.
    open func setupStyles() {
        self.backgroundColor = theme.backgroundColor
        
        if let dateView = self.dateView as? SBUMessageDateView {
            dateView.setupStyles()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.setupStyles()
    }
    
    
    func updateTopAnchorConstraint() {
        self.stackViewTopConstraint?.isActive = false
        self.stackViewTopConstraint = self.stackView.topAnchor.constraint(
            equalTo: self.contentView.topAnchor,
            constant: (self.groupPosition == .none || self.groupPosition == .top) ? 16 : 4
        )
        self.stackViewTopConstraint?.isActive = true
    }
    
    
    // MARK: - Common
    
    /// This function configure a cell using informations.
    /// - Parameters:
    ///   - message: Message object
    ///   - position: Cell position (left / right / center)
    ///   - hideDateView: Hide or expose date information
    ///   - receiptState: ReadReceipt state
    open func configure(message: SBDBaseMessage,
                        position: MessagePosition,
                        hideDateView: Bool,
                        groupPosition: MessageGroupPosition = .none,
                        receiptState: SBUMessageReceiptState) {
        self.message = message
        self.position = position
        self.groupPosition = groupPosition
        self.dateView.isHidden = hideDateView
        self.receiptState = receiptState
        
        if let dateView = self.dateView as? SBUMessageDateView {
            dateView.configure(timestamp: self.message.createdAt)
        }
    }
    
    
    // MARK: -
    open override func prepareForReuse() {
        super.prepareForReuse()
    }
}


// MARK: -
@available(*, deprecated, message: "deprecated in 2.0.0", renamed: "SBUMessageDateView")
fileprivate class MessageDateView: SBUMessageDateView { }

// MARK: -
@available(*, deprecated, message: "deprecated in 2.0.0", renamed: "SBUMessageProfileView")
public class MessageProfileView: SBUMessageProfileView { }

// MARK: -
@available(*, deprecated, message: "deprecated in 2.0.0", renamed: "SBUUserNameView")
public class UserNameView: SBUUserNameView { }

// MARK: -
@available(*, deprecated, message: "deprecated in 2.0.0", renamed: "SBUMessageStateView")
public class MessageStateView: SBUMessageStateView { }
