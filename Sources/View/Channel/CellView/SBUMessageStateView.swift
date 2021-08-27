//
//  SBUMessageStateView.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2020/10/27.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

public class SBUMessageStateView: UIView {
    var theme: SBUMessageCellTheme = SBUTheme.messageCellTheme
    
    var stackView: UIStackView = {
     let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()
    var stateImageView: UIImageView = UIImageView()
    var timeLabel: UILabel = UILabel()

    private let timeLabelWidth: CGFloat = 55
    private let timeLabelHeight: CGFloat = 12
     
    var timestamp: Int64 = 0
    var sendingState: SBDMessageSendingStatus = .none
    var receiptState: SBUMessageReceiptState? = nil
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
    
    func setupStyles() {
        self.theme = SBUTheme.messageCellTheme
        
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
                   receiptState: SBUMessageReceiptState?,
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
