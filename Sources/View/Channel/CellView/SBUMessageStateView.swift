//
//  SBUMessageStateView.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2020/10/27.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

open class SBUMessageStateViewParams {
    /// The timestamp of message.
    public let timestamp: Int64
    /// The sending state of message.
    public let sendingState: MessageSendingStatus
    /// The receipt state of message.
    public let receiptState: SBUMessageReceiptState
    /// The position of message.
    public let position: MessagePosition
    /// If `true`, the message is the reply message.
    public let isQuotedReplyMessage: Bool
    
    /// Initializes `SBUMessageStateViewParams`
    ///
    /// - Parameters:
    ///   - timestamp: The timestamp of message.
    ///   - sendingState: The sending state of message.
    ///   - receiptState: The receipt state of message.
    ///   - position: The position of message.
    ///   - isQuotedMessage: If `true`, the message is the reply message.
    ///
    public init(
        timestamp: Int64,
        sendingState: MessageSendingStatus,
        receiptState: SBUMessageReceiptState,
        position: MessagePosition,
        isQuotedReplyMessage: Bool = false
    ) {
        self.timestamp = timestamp
        self.sendingState = sendingState
        self.receiptState = receiptState
        self.position = position
        self.isQuotedReplyMessage = isQuotedReplyMessage
    }
}

open class SBUMessageStateView: SBUView {
    // MARK: Public properties (UI)
    
    /// The theme of the view which is type of `SBUMessageCellTheme`.
    /// - Since: 2.1.13
    @SBUThemeWrapper(theme: SBUTheme.messageCellTheme)
    public var theme: SBUMessageCellTheme
    
    /// `UIStackView` that contains UI components such as `stateImageView` and `timeLabel`
    /// - Since: 2.1.13
    public lazy var stackView: SBUStackView = {
        return self.isQuotedReplyMessage
        ? SBUStackView(axis: .horizontal, alignment: .center, spacing: 4)
        : SBUStackView(axis: .vertical, alignment: .leading)
    }()
    
    /// `UIImageView` representing message sending/receipt state
    /// - Since: 2.1.13
    public var stateImageView: UIImageView = UIImageView()
    
    /// `UILabel` representing when the message was sent
    /// - Since: 2.1.13
    public var timeLabel: UILabel = UILabel()
    
    /// The data format for `timeLabel`.
    /// e.g. "hh:mm", "hh:mm a", ...
    /// - Since: 2.1.13
    @available(*, deprecated, renamed: "SBUDateFormatSet.Message.sentTimeFormat")
    public var timeFormat: String { SBUDateFormatSet.Message.sentTimeFormat }

    /// Custom size for `timeLabel`
    /// - Since: 2.1.13
    public var timeLabelCustomSize: CGSize?
    
    private let timeLabelWidth: CGFloat = 55
    private let timeLabelHeight: CGFloat = 12
    
    // MARK: Internal Properties (View models)
    var timestamp: Int64 = 0
    var sendingState: MessageSendingStatus = .none
    var receiptState: SBUMessageReceiptState = .notUsed
    var position: MessagePosition = .center
    var isQuotedReplyMessage: Bool = false
     
    /// Initializes `SBUMessageStateView`
    ///
    /// - Parameters:
    ///   - sendingState: `MessageSendingStatus`.
    ///   - receiptState: `SBUMessageReceiptState`.
    ///   - isQuotedMessage: If `true`, the message is the reply message.
    ///
    /// - Since: 2.1.13
    public init(sendingState: MessageSendingStatus, receiptState: SBUMessageReceiptState, isQuotedReplyMessage: Bool = false) {
        self.receiptState = receiptState
        self.sendingState = sendingState
        self.isQuotedReplyMessage = isQuotedReplyMessage
        
        super.init()
    }
    
    /// Initializes `SBUMessageStateView`.
    ///
    /// - Parameter isQuotedMessage: If `true`, the message is the reply message.
    /// - Since: 2.2.0
    public init(isQuotedReplyMessage: Bool = false) {
        self.isQuotedReplyMessage = isQuotedReplyMessage
        
        super.init()
    }
    
    open override func setupViews() {
        super.setupViews()
        
        self.addSubview(self.stackView)
        self.stackView.setVStack([
            self.stateImageView,
            self.timeLabel
        ])
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        let timeLabelWidth = self.timeLabelCustomSize?.width ?? self.timeLabelWidth
        let timeLabelHeight = self.timeLabelCustomSize?.height ?? self.timeLabelHeight
        
        self.stateImageView.contentMode = .center
        self.setConstraint(width: isQuotedReplyMessage ? timeLabelWidth + 16.0 : timeLabelWidth)
        self.stackView.setConstraint(
            from: self,
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            priority: .defaultLow
        )
        if isQuotedReplyMessage {
            self.timeLabel
                .setConstraint(height: timeLabelHeight)
        } else {
            self.timeLabel
                .setConstraint(width: timeLabelWidth, height: timeLabelHeight)
        }
        self.stateImageView.setConstraint(height: 12)
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
        self.backgroundColor = .clear
        
        self.timeLabel.font = theme.timeFont
        self.timeLabel.textColor = theme.timeTextColor
    }
    
    /// Configures views with `SBUMessageStateViewParams` which contains  message information.
    /// - Parameter configuration: `SBUMessageStateViewParams` object. It contains message information to configure the view
    /// - Since: 2.2.0
    open func configure(with configuration: SBUMessageStateViewParams) {
        self.receiptState = configuration.receiptState
        self.sendingState = configuration.sendingState
        self.position = configuration.position
        self.timestamp = configuration.timestamp
        self.timeLabel.text = Date
            .sbu_from(timestamp)
            .sbu_toString(dateFormat: SBUDateFormatSet.Message.sentTimeFormat)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        if configuration.isQuotedReplyMessage {
            // Reset stack view
            self.stackView.arrangedSubviews.forEach {
                $0.removeFromSuperview()
            }
            
            switch position {
                case .center, .left:
                    self.stackView.setHStack([
                        self.timeLabel,
                        self.stateImageView,
                        UIView()
                    ])
                case .right:
                    self.stackView.setHStack([
                        UIView(),
                        self.stateImageView,
                        self.timeLabel
                    ])
            }
        }
        switch position {
            case .center:
                self.stackView.alignment = .center
                self.timeLabel.textAlignment = .center
                self.stateImageView.isHidden = false
            case .left:
                self.stackView.alignment = isQuotedReplyMessage
                ? .center
                : .leading
                self.timeLabel.textAlignment = isQuotedReplyMessage
                ? .right
                : .left
                self.stateImageView.isHidden = true
            case .right:
                self.stackView.alignment = isQuotedReplyMessage
                ? .center
                : .trailing
                self.timeLabel.textAlignment = isQuotedReplyMessage
                ? .left
                : .right
                self.stateImageView.isHidden = false
        }
        
        guard !self.stateImageView.isHidden else { return }
        stateImageView.layer.removeAnimation(forKey: SBUAnimation.Key.spin.identifier)
        
        let stateImage: UIImage?
        switch self.sendingState {
            case .none:
                stateImage = nil
            case .pending:
                stateImage = SBUIconSetType.iconSpinner.image(
                    with: theme.pendingStateColor,
                    to: SBUIconSetType.Metric.defaultIconSizeSmall
                )
                
                let rotation = CABasicAnimation(keyPath: "transform.rotation")
                rotation.fromValue = 0
                rotation.toValue = 2 * Double.pi
                rotation.duration = 1.1
                rotation.repeatCount = Float.infinity
                stateImageView.layer.add(rotation, forKey: SBUAnimation.Key.spin.identifier)
                
            case .failed, .canceled:
                stateImage = SBUIconSetType.iconError.image(
                    with: theme.failedStateColor,
                    to: SBUIconSetType.Metric.defaultIconSizeSmall
                )
            case .succeeded:
                switch receiptState {
                    case .notUsed:
                        stateImage = nil
                    case .none:
                        stateImage = SBUIconSetType.iconDone.image(
                            with: theme.succeededStateColor,
                            to: SBUIconSetType.Metric.defaultIconSizeSmall
                        )
                    case .read:
                        stateImage = SBUIconSetType.iconDoneAll.image(
                            with: theme.readReceiptStateColor,
                            to: SBUIconSetType.Metric.defaultIconSizeSmall
                        )
                    case .delivered:
                        stateImage = SBUIconSetType.iconDoneAll.image(
                            with: theme.deliveryReceiptStateColor,
                            to: SBUIconSetType.Metric.defaultIconSizeSmall
                        )
                }
            case .scheduled:
                stateImage = nil
            @unknown default:
                stateImage = nil
        }
        self.stateImageView.image = stateImage
        
        self.layoutIfNeeded()
        self.updateConstraints()
    }
    
    @objc
    private func willEnterForeground() {
        guard sendingState == .pending else { return }
     
        stateImageView.layer.removeAnimation(forKey: SBUAnimation.Key.spin.identifier)
        
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = 2 * Double.pi
        rotation.duration = 1.1
        rotation.repeatCount = Float.infinity
        
        stateImageView.layer.add(rotation, forKey: SBUAnimation.Key.spin.identifier)
    }
    
    /// Configures views with message information.
    ///
    /// - Parameters:
    ///   - timestamp: The timestamp of message.
    ///   - sendingState: The sending state of message
    ///   - receiptState: The receipt state of message
    ///   - position: The position of message
    ///
    /// - Since: 2.1.13
    @available(*, deprecated, renamed: "configure(with:)") // 2.2.0
    open func configure(timestamp: Int64,
                        sendingState: MessageSendingStatus,
                        receiptState: SBUMessageReceiptState?,
                        position: MessagePosition) {
        
        let configuration = SBUMessageStateViewParams(
            timestamp: timestamp,
            sendingState: sendingState,
            receiptState: receiptState ?? .none,
            position: position
        )
        self.configure(with: configuration)
    }
}
