//
//  SBUAdminMessageCell.swift
//  SendBirdUIKit
//
//  Created by Harry Kim on 2020/02/20.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

@objcMembers @IBDesignable
open class SBUAdminMessageCell: SBUBaseMessageCell {

    // MARK: - Public property
    public var messageLabel = UILabel()

    // MARK: - View Lifecycle
    open override func setupViews() {
        super.setupViews()
        self.messageContentView.addSubview(self.messageLabel)
    }
    
    open override func setupAutolayout() {
        super.setupAutolayout()
        
        self.messageLabel.setConstraint(
            from: self.messageContentView,
            left: 28,
            right: 27,
            top: 0,
            bottom: 0
        )
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
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 8
        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSMakeRange(0, attributedString.length)
        )
        
        self.messageLabel.attributedText = attributedString
    }
    
    // MARK: - Common
    public func configure(_ message: SBDAdminMessage, hideDateView: Bool) {
        super.configure(message: message,
                        position: .center,
                        hideDateView: hideDateView,
                        receiptState: .none)

        self.messageLabel.numberOfLines = 0
        self.messageLabel.textAlignment = .center
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
