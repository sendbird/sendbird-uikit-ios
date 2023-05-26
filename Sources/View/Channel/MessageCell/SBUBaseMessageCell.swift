//
//  SBUBaseMessageCell.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 03/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

 @IBDesignable
open class SBUBaseMessageCell: SBUTableViewCell, SBUMessageCellProtocol {
    // MARK: - Public
    public var message: BaseMessage?
    public var position: MessagePosition = .center
    public var groupPosition: MessageGroupPosition = .none
    public var receiptState: SBUMessageReceiptState = .none

    public lazy var messageContentView: UIView = {
        let view = UIView()
        return view
    }()
    
    // Used to display the date separator in the message list.
    public lazy var dateView: UIView = SBUMessageDateView()

    @SBUThemeWrapper(theme: SBUTheme.messageCellTheme)
    public var theme: SBUMessageCellTheme
    
    // MARK: - Private
    
    // + ------------------ +
    // | dateView           |
    // + ------------------ +
    // | messageContentView |
    // + ------------------ +
    /// A stack view that contains `dateView` and `messageContentView`
    /// The default value is `SBUStackView` with `.vertical` axis and spacing value `16`.
    public private(set) lazy var stackView: UIStackView = {
        return SBUStackView(axis: .vertical, spacing: 16)
    }()
    
    public var stackViewTopConstraint: NSLayoutConstraint?
    
    // MARK: - Action
    var userProfileTapHandler: (() -> Void)?
    var tapHandlerToContent: (() -> Void)?
    var longPressHandlerToContent: (() -> Void)?
    var emojiTapHandler: ((_ emojiKey: String) -> Void)?
    var moreEmojiTapHandler: (() -> Void)?
    var emojiLongPressHandler: ((_ emojiKey: String) -> Void)?
    var mentionTapHandler: ((_ user: SBUUser) -> Void)?

    // MARK: - View Lifecycle
    
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
    
    open override func setupActions() {
        
    }
    
    open override func setupLayouts() {
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
        
        if let dateView = self.dateView as? SBUMessageDateView,
           let message = self.message {
            dateView.configure(timestamp: message.createdAt)
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
    open func configure(message: BaseMessage,
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
