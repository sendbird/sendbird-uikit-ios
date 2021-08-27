//
//  SBUOpenChannelAdminMessageCell.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2020/10/27.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

@objcMembers
open class SBUOpenChannelAdminMessageCell: SBUOpenChannelBaseMessageCell {

    // MARK: - Public property
    public var baseView = UIView()
    public var messageLabel = UILabel()

    // MARK: - View Lifecycle
    open override func setupViews() {
        super.setupViews()
        
        self.baseView.roundCorners(corners: [.allCorners], radius: 10)
        self.messageLabel.numberOfLines = 0

        self.baseView.addSubview(self.messageLabel)
        self.messageContentView.addSubview(self.baseView)
    }
    
    open override func setupAutolayout() {
        super.setupAutolayout()
        
        self.baseView.sbu_constraint(
            equalTo: self.messageContentView,
            leading: 12,
            trailing: -12,
            top: 0,
            bottom: 0
        )
        self.baseView.sbu_constraint(height: 40)
        
        self.messageLabel.sbu_constraint(
            equalTo: self.baseView,
            leading: 16,
            trailing: -16,
            top: 0,
            bottom: 0
        )
    }
    
    open override func setupStyles() {
        super.setupStyles()
     
        self.baseView.backgroundColor = self.theme.contentBackgroundColor
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let message = self.messageLabel.text ?? ""
        let attributes: [NSAttributedString.Key : Any] = [
            .font: theme.adminMessageFont,
            .foregroundColor : theme.adminMessageTextColor
        ]
        
        let attributedString = NSMutableAttributedString(string: message, attributes: attributes)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineSpacing = 8
        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSMakeRange(0, attributedString.length)
        )
        
        self.messageLabel.attributedText = attributedString
    }
    
    // MARK: - Common
    open func configure(_ message: SBDAdminMessage, hideDateView: Bool, isOverlay: Bool = false) {
        super.configure(
            message: message,
            hideDateView: hideDateView,
            isOverlay: isOverlay
        )
        self.messageLabel.text = message.message
        self.layoutIfNeeded()
    }
    
    // MARK: - Action
    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Private property
    private var adminMessage: SBDAdminMessage? {
        return self.message as? SBDAdminMessage
    }
}
