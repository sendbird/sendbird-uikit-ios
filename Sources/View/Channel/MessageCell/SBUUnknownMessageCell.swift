//
//  SBUUnknownMessageCell.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2020/06/18.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

open class SBUUnknownMessageCell: SBUUserMessageCell {
    open override func configure(with configuration: SBUBaseMessageCellParams) {
        guard let configuration = configuration as? SBUUnknownMessageCellParams else { return }
        // Configure Content base message cell
        super.configure(with: configuration)
        
        // Set up message text view
        self.setupMessageTextView()
        
        self.layoutIfNeeded()
    }
    
    open func setupMessageTextView() {
        guard let messageTextView = self.messageTextView as? SBUUserMessageTextView else { return }
        let text = SBUStringSet.Message_Unknown_Title
        + "\n"
        + SBUStringSet.Message_Unknown_Description
        let model = SBUUserMessageTextViewModel(
            message: message,
            position: self.position,
            text: text,
            font: theme.unknownMessageDescFont,
            textColor: self.position == .right
            ? theme.unknownMessageDescRightTextColor
            : theme.unknownMessageDescLeftTextColor,
            isEdited: false
        )
        messageTextView.configure(model: model)
    }
    
    @available(*, deprecated, renamed: "configure(with:)") // 2.2.0
    open override func configure(_ message: BaseMessage,
                                 hideDateView: Bool,
                                 groupPosition: MessageGroupPosition,
                                 receiptState: SBUMessageReceiptState?,
                                 useReaction: Bool) {
        guard let message = message as? UserMessage else { return }
        let configuration = SBUUnknownMessageCellParams(
            message: message,
            hideDateView: hideDateView,
            groupPosition: groupPosition,
            receiptState: receiptState ?? .none,
            useReaction: useReaction
        )
        self.configure(with: configuration)
    }
}
