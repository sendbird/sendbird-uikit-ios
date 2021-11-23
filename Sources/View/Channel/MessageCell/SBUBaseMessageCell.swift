//
//  SBUBaseMessageCell.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 03/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

@objcMembers @IBDesignable
open class SBUBaseMessageCell: SBUTableViewCell, SBUMessageCellProtocol {
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
    
    // + ------------------ +
    // | dateView           |
    // + ------------------ +
    // | messageContentView |
    // + ------------------ +
    private lazy var stackView: UIStackView = {
        return SBUStackView(axis: .vertical, spacing: 16)
    }()
    
    var stackViewTopConstraint: NSLayoutConstraint?

    
    // MARK: - Action
    var userProfileTapHandler: (() -> Void)? = nil
    var tapHandlerToContent: (() -> Void)? = nil
    var longPressHandlerToContent: (() -> Void)? = nil
    var emojiTapHandler: ((_ emojiKey: String) -> Void)? = nil
    var moreEmojiTapHandler: (() -> Void)? = nil
    var emojiLongPressHandler: ((_ emojiKey: String) -> Void)? = nil


    // MARK: - View Lifecycle
    
    /// This function handles the initialization of views.
    open override func setupViews() {
        self.dateView.isHidden = true
        
        // + ------------------ +
        // | dateView           |
        // + ------------------ +
        // | messageContentView |
        // + ------------------ +
        
        self.contentView.addSubview(self.stackView)
        self.stackView.setVStack([
            self.dateView,
            self.messageContentView
        ])
    }
    
    /// This function handles the initialization of actions.
    open override func setupActions() {
        
    }
    
    /// This function handles the initialization of autolayouts.
    open override func setupAutolayout() {
        self.stackView
            .setConstraint(from: self.contentView, left: 0, bottom: 0)
            .setConstraint(from: self.contentView, right: 0, priority: .defaultHigh)
        
        self.updateTopAnchorConstraint()
    }

    open override func setupStyles() {
        self.backgroundColor = theme.backgroundColor
        
        if let dateView = self.dateView as? SBUMessageDateView {
            dateView.setupStyles()
        }
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
    
    /**
     This function configure a cell using informations.
     
     - Parameter configuration: `SBUBaseMessageCellParams` object.
     */
    open func configure(with configuration: SBUBaseMessageCellParams) {
        self.message = configuration.message
        self.position = configuration.messagePosition
        self.groupPosition = configuration.groupPosition
        self.dateView.isHidden = configuration.hideDateView
        self.receiptState = configuration.receiptState
        
        if let dateView = self.dateView as? SBUMessageDateView {
            dateView.configure(timestamp: self.message.createdAt)
        }
    }
    
    open func configure(highlightInfo: SBUHighlightMessageInfo?) {
        
    }
    
    /// This function configure a cell using informations.
    /// - Parameters:
    ///   - message: Message object
    ///   - position: Cell position (left / right / center)
    ///   - hideDateView: Hide or expose date information
    ///   - receiptState: ReadReceipt state
    @available(*, deprecated, renamed: "configure(message:configuration:)") // 2.2.0
    open func configure(message: SBDBaseMessage,
                        position: MessagePosition,
                        hideDateView: Bool,
                        groupPosition: MessageGroupPosition = .none,
                        receiptState: SBUMessageReceiptState) {
        let configuration = SBUBaseMessageCellParams(
            message: message,
            hideDateView: hideDateView,
            messagePosition: position,
            groupPosition: groupPosition,
            receiptState: receiptState
        )
        self.configure(with: configuration)
    }
    
    
    // MARK: -
    open override func prepareForReuse() {
        super.prepareForReuse()
    }
}


// TODO: Remove
@IBDesignable
@available(*, deprecated, renamed: "SBUBaseMessageCell")
open class SBUMessageBaseCell { }
