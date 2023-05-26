//
//  SBUAdminMessageCell.swift
//  SendbirdUIKit
//
//  Created by Harry Kim on 2020/02/20.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

 @IBDesignable
open class SBUAdminMessageCell: SBUBaseMessageCell {

    // MARK: - Public property
    public var messageLabel = UILabel()
    
    // MARK: - View Lifecycle
    open override func setupViews() {
        super.setupViews()
        self.messageContentView.addSubview(self.messageLabel)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
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
        let attributes: [NSAttributedString.Key: Any] = [
            .font: theme.adminMessageFont,
            .foregroundColor: theme.adminMessageTextColor
        ]
        
        let attributedString = NSMutableAttributedString(string: message, attributes: attributes)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 8
        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: attributedString.length)
        )
        
        self.messageLabel.attributedText = attributedString
    }
    
    // MARK: - Common
    open override func configure(with configuration: SBUBaseMessageCellParams) {
        guard let configuration = configuration as? SBUAdminMessageCellParams else { return }
        guard let message = configuration.adminMessage else { return }
        // Configure Content base message cell
        super.configure(with: configuration)
        
        // Set up message label
        self.messageLabel.numberOfLines = 0
        self.messageLabel.textAlignment = .center
        self.messageLabel.text = message.message
        self.layoutIfNeeded()
    }
    
    @available(*, deprecated, renamed: "configure(with:)") // 2.2.0
    open func configure(_ message: AdminMessage, hideDateView: Bool) {
        let configuration = SBUAdminMessageCellParams(
            message: message,
            hideDateView: hideDateView
        )
        self.configure(with: configuration)
    }
    
    // MARK: - Action
    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
