//
//  SBUMessageStateView.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2020/10/27.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

open class SBUMessageStateView: UIView {
    // MARK: Public properties (UI)
    
    /// The theme of the view which is type of `SBUMessageCellTheme`.
    /// - Since: 2.1.13
    @SBUThemeWrapper(theme: SBUTheme.messageCellTheme)
    public var theme: SBUMessageCellTheme
    
    /// `UIStackView` that contains UI components such as `stateImageView` and `timeLabel`
    /// - Since: 2.1.13
    public var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
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
    public var timeFormat: String = Date.SBUDateFormat.hhmma.rawValue

    /// Custom size for `timeLabel`
    /// - Since: 2.1.13
    public var timeLabelCustomSize: CGSize?
    
    private let timeLabelWidth: CGFloat = 55
    private let timeLabelHeight: CGFloat = 12
    
    // MARK: Internal Properties (View models)
    var timestamp: Int64 = 0
    var sendingState: SBDMessageSendingStatus = .none
    var receiptState: SBUMessageReceiptState? = nil
    var position: MessagePosition = .center
     
    /// Initializes `SBUMessageStateView`
    ///
    /// - Parameters:
    ///   - sendingState: `SBDMessageSendingStatus`.
    ///   - receiptState: `SBUMessageReceiptState`.
    ///
    /// - Since: 2.1.13
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
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /// Sets up views.
    ///
    /// - Since: 2.1.13`
    open func setupViews() {
        self.addSubview(self.stackView)
        self.stackView.addArrangedSubview(self.stateImageView)
        self.stackView.addArrangedSubview(self.timeLabel)
    }
    
    /// Sets up auto layouts of views.
    ///
    /// - Since: 2.1.13`
    open func setupAutolayout() {
        let timeLabelWidth = self.timeLabelCustomSize?.width ?? self.timeLabelWidth
        let timeLabelHeight = self.timeLabelCustomSize?.height ?? self.timeLabelHeight
        
        self.stateImageView.contentMode = .center
        self.setConstraint(width: timeLabelWidth)
        self.stackView.setConstraint(
            from: self,
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            priority: .defaultLow
        )
        self.timeLabel.setConstraint(width: timeLabelWidth, height: timeLabelHeight)
        self.stateImageView.setConstraint(height: 12)
    }
    
    /// Sets up UI details of views such as fonts and colors.
    ///
    /// - Since: 2.1.13`
    open func setupStyles() {
        self.backgroundColor = .clear
        
        self.timeLabel.font = theme.timeFont
        self.timeLabel.textColor = theme.timeTextColor
        
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setupStyles()
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
    open func configure(timestamp: Int64,
                   sendingState: SBDMessageSendingStatus,
                   receiptState: SBUMessageReceiptState?,
                   position: MessagePosition) {
        
        self.receiptState = receiptState
        self.sendingState = sendingState
        self.position = position
        self.timestamp = timestamp
        self.timeLabel.text = Date.from(timestamp).sbu_toString(formatString: timeFormat)
        
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
            stateImage = SBUIconSetType.iconSpinner.image(
                with: theme.pendingStateColor,
                to: SBUIconSetType.Metric.defaultIconSizeSmall
            )

            let rotation = CABasicAnimation(keyPath: "transform.rotation")
            rotation.fromValue = 0
            rotation.toValue = 2 * Double.pi
            rotation.duration = 1.1
            rotation.repeatCount = Float.infinity
            stateImageView.layer.add(rotation, forKey: "Spin")
            
        case .failed, .canceled:
            stateImage = SBUIconSetType.iconError.image(
                with: theme.failedStateColor,
                to: SBUIconSetType.Metric.defaultIconSizeSmall
            )
        case .succeeded:
            if let receiptState = receiptState {
                switch receiptState {
                case .none:
                    stateImage = SBUIconSetType.iconDone.image(
                        with: theme.succeededStateColor,
                        to: SBUIconSetType.Metric.defaultIconSizeSmall
                    )
                case .readReceipt:
                    stateImage = SBUIconSetType.iconDoneAll.image(
                        with: theme.readReceiptStateColor,
                        to: SBUIconSetType.Metric.defaultIconSizeSmall
                    )
                case .deliveryReceipt:
                    stateImage = SBUIconSetType.iconDoneAll.image(
                        with: theme.deliveryReceiptStateColor,
                        to: SBUIconSetType.Metric.defaultIconSizeSmall
                    )
                }
            } else {
                stateImage = nil
            }
        @unknown default:
            stateImage = nil
        }
        self.stateImageView.image = stateImage
        
        self.layoutIfNeeded()
        self.updateConstraints()
    }
}
