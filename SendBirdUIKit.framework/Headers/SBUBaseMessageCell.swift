//
//  SBUBaseMessageCell.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 03/02/2020.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

@IBDesignable
@available(*, deprecated, renamed: "SBUBaseMessageCell")
open class SBUMessageBaseCell { }

@objcMembers @IBDesignable
open class SBUBaseMessageCell: UITableViewCell {
    public var message: SBDBaseMessage = .init()
    public var position: MessagePosition = .center
    public var groupPosition: MessageGroupPosition = .none
    public var receiptState: SBUMessageReceiptState = .none

    public lazy var messageContentView: UIView = {
        let view = UIView()
        return view
    }()
    
    public lazy var dateView: UIView = MessageDateView()

    // MARK: - Private
    var theme: SBUMessageCellTheme = SBUTheme.messageCellTheme

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 16
        stackView.axis = .vertical
        return stackView
    }()
    
    var stackViewTopConstraint: NSLayoutConstraint?


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
        
        if let dateView = self.dateView as? MessageDateView {
            dateView.configure(timestamp: self.message.createdAt)
        }
    }
    
    
    // MARK: -
    open override func prepareForReuse() {
        super.prepareForReuse()
    }
  
    // MARK: - Action
    var tapHandlerToProfileImage: (() -> Void)? = nil
    var tapHandlerToContent: (() -> Void)? = nil
    var longPressHandlerToContent: (() -> Void)? = nil
    var emojiTapHandler: ((_ emojiKey: String) -> Void)? = nil
    var moreEmojiTapHandler: (() -> Void)? = nil
    var emojiLongPressHandler: ((_ emojiKey: String) -> Void)? = nil
}


// MARK: -
fileprivate class MessageDateView: UIView {
     
    var theme: SBUMessageCellTheme = SBUTheme.messageCellTheme
    
    lazy var dateLabel: UILabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        self.setupViews()
        self.setupAutolayout()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
        self.setupAutolayout()
    }
    
    @available(*, unavailable, renamed: "MessageDateView.init(frame:)")
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setupViews() {
        self.dateLabel.textAlignment = .center
        self.addSubview(self.dateLabel)
    }
    
    func setupAutolayout() {
        self.dateLabel
            .setConstraint(from: self, centerX: true, centerY: true)
            .setConstraint(width: 91, height: 20)
        
        self.setConstraint(height: 20, priority: .defaultLow)
    }
    
    func setupStyles() {
        self.backgroundColor = theme.backgroundColor
        
        self.dateLabel.font = theme.dateFont
        self.dateLabel.textColor = theme.dateTextColor
        self.dateLabel.backgroundColor = theme.dateBackgroundColor
    }
    
    func configure(timestamp: Int64) {
        self.dateLabel.text = Date.from(timestamp).toString(format: .EMMMdd)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        self.dateLabel.layer.cornerRadius = 10
        self.dateLabel.clipsToBounds = true

        self.setupStyles()
    }
}


// MARK: -
public class MessageProfileView: UIView {

    var theme: SBUMessageCellTheme = SBUTheme.messageCellTheme
    
    var imageView: UIImageView = .init()
    
    var urlString: String = ""
     
    private let imageSize: CGFloat = 26
    private let leftSpace: CGFloat = 12
    private let rightSpace: CGFloat = 12
     
    public init(urlString: String) {
        self.urlString = urlString
        super.init(frame: .init(x: 0, y: 0, width: 26, height: 26))
        self.setupViews()
        self.setupAutolayout()
        self.configure(urlString: urlString)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
        self.setupAutolayout()
        self.configure(urlString: self.urlString)
    }
    
    @available(*, unavailable, renamed: "MessageProfileView(imageURL:)")
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setupViews() {
        self.addSubview(self.imageView)
    }
     
    func setupAutolayout() {
        self.imageView
            .setConstraint(width: imageSize, height: imageSize)
            .setConstraint(from: self, left: leftSpace, right: rightSpace, top: 0, bottom: 0)
    }
    
    func setupStyles() {
        self.backgroundColor = .clear
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageView.layer.cornerRadius = imageSize / 2
        self.imageView.layer.borderColor = UIColor.clear.cgColor
        self.imageView.layer.borderWidth = 1
        self.imageView.clipsToBounds = true
        
        self.setupStyles()
    }
    
    func configure(urlString: String) {
        self.urlString = urlString
        self.imageView.loadImage(
            urlString: urlString,
            placeholder: SBUIconSet.iconUser.sbu_with(tintColor: theme.userPlaceholderTintColor)
        )
        self.imageView.backgroundColor = theme.userPlaceholderBackgroundColor
        self.setNeedsLayout()
    }
}


// MARK: -
public class UserNameView: UIView {
    
    var theme: SBUMessageCellTheme = SBUTheme.messageCellTheme
    
    var button: UIButton = .init()
    
    var username: String = ""
    
    public init(username: String) {
        self.username = username
        super.init(frame: .zero)
        self.setupViews()
        self.setupAutolayout()
        self.configure(username: self.username)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
        self.setupAutolayout()
        self.configure(username: self.username)
    }
    
    @available(*, unavailable, renamed: "UserNameView(username:)")
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupViews() {
        self.addSubview(self.button)
    }
    
    func setupAutolayout() {
        self.button
            .setConstraint(from: self, left: 62, right: 0, top: 0, bottom: 0)
            .setConstraint(height: 12)
    }
    
    func setupStyles() {
        self.backgroundColor = .clear

        self.button.titleLabel?.font = theme.userNameFont
        self.button.contentHorizontalAlignment = .left
        self.button.setTitleColor(theme.userNameTextColor, for: .normal)
    }

    func configure(username: String) {
        self.username = username
        self.button.setTitle(username, for: .normal)
        self.button.sizeToFit()
        self.setupStyles()
        self.setNeedsLayout()
    }
}


// MARK: -
public class MessageStateView: UIView {
    
    var theme: SBUMessageCellTheme = SBUTheme.messageCellTheme
    
    var stackView: UIStackView = {
     let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()
    var stateImageView: UIImageView = UIImageView()
    var timeLabel: UILabel = UILabel()

    private let leftSpace: CGFloat = 4
    private let rightSpace: CGFloat = 4
    private let timeLabelWidth: CGFloat = 55
    private let timeLabelHeight: CGFloat = 12
     
    var timestamp: Int64 = 0
    var sendingState: SBDMessageSendingStatus = .none
    var receiptState: SBUMessageReceiptState = .none
    var position: MessagePosition = .center
     
    public init(sendingState: SBDMessageSendingStatus, receiptState: SBUMessageReceiptState) {
        self.receiptState = receiptState
        super.init(frame: .zero)
        self.setupViews()
        self.setupAutolayout()
        self.configure(
            timestamp: self.timestamp,
            sendingState: sendingState,
            receiptState: self.receiptState,
            position: .center
        )
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
        self.setupAutolayout()
        self.configure(
            timestamp: self.timestamp,
            sendingState: sendingState,
            receiptState: self.receiptState,
            position: .center
        )
    }
    
    @available(*, unavailable, renamed: "MessageStateView(type:)")
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupViews() {
        self.addSubview(self.stackView)
        self.stackView.addArrangedSubview(self.stateImageView)
        self.stackView.addArrangedSubview(self.timeLabel)
    }
    
    func setupAutolayout() {
        stateImageView.contentMode = .center
        let width = leftSpace + timeLabelWidth + rightSpace
        self.setConstraint(width: width)
        self.stackView.setConstraint(
            from: self,
            left: 4,
            right: 4,
            top: 0,
            bottom: 0,
            priority: .defaultLow
        )
        self.timeLabel.setConstraint(width: timeLabelWidth, height: timeLabelHeight)
        self.stateImageView.setConstraint(height: 12)
    }
    
    func setupStyles() {
        self.backgroundColor = .clear
        
        self.timeLabel.font = theme.timeFont
        self.timeLabel.textColor = theme.timeTextColor
        
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setupStyles()
    }
    
    func configure(timestamp: Int64,
                   sendingState: SBDMessageSendingStatus,
                   receiptState: SBUMessageReceiptState,
                   position: MessagePosition) {
        
        self.receiptState = receiptState
        self.sendingState = sendingState
        self.position = position
        self.timestamp = timestamp
        self.timeLabel.text = Date.from(timestamp).toString(format: .hhmma)
        
        switch position {
        case .center:
            self.stackView.alignment = .center
            self.timeLabel.textAlignment = .center
            self.stateImageView.isHidden = false
        case .left:
            self.stackView.alignment = .leading
            self.timeLabel.textAlignment = .left
            self.stateImageView.isHidden = true
        case .right:
            self.stackView.alignment = .trailing
            self.timeLabel.textAlignment = .right
            self.stateImageView.isHidden = false
        }
        
        guard !self.stateImageView.isHidden else { return }
        stateImageView.layer.removeAnimation(forKey: "Spin")
        
        let stateImage: UIImage?
        switch sendingState {
        case .none:
            stateImage = nil
        case .pending:
            stateImage = SBUIconSet.iconSpinnerSmall.sbu_with(tintColor: theme.pendingStateColor)

            let rotation = CABasicAnimation(keyPath: "transform.rotation")
            rotation.fromValue = 0
            rotation.toValue = 2 * Double.pi
            rotation.duration = 1.1
            rotation.repeatCount = Float.infinity
            stateImageView.layer.add(rotation, forKey: "Spin")
            
        case .failed, .canceled:
            stateImage = SBUIconSet.iconFailed.sbu_with(tintColor: theme.failedStateColor)
        case .succeeded:
            switch receiptState {
            case .none:
                stateImage = SBUIconSet.iconSent.sbu_with(tintColor: theme.succeededStateColor)
            case .readReceipt:
                stateImage = SBUIconSet.iconRead.sbu_with(tintColor: theme.readReceiptStateColor)
            case .deliveryReceipt:
                stateImage = SBUIconSet.iconDelivered.sbu_with(
                    tintColor: theme.deliveryReceiptStateColor
                )
            }
        @unknown default:
            stateImage = nil
        }
        self.stateImageView.image = stateImage
        
        self.layoutIfNeeded()
        self.updateConstraints()
    }
}
