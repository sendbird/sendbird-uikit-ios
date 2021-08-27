//
//  SBUUnknownMessageCell.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2020/06/18.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

@objcMembers
open class SBUUnknownMessageCell: SBUUserMessageCell {
    open override func configure(_ message: SBDBaseMessage,
                                   hideDateView: Bool,
                                   groupPosition: MessageGroupPosition,
                                   receiptState: SBUMessageReceiptState?,
                                   useReaction: Bool) {
        self.useReaction = useReaction
        
        self.configure(
            message,
            hideDateView: hideDateView,
            receiptState: receiptState,
            groupPosition: groupPosition,
            withTextView: false
        )
        
        if let messageTextView = self.messageTextView as? SBUUserMessageTextView {
            let text = SBUStringSet.Message_Unknown_Title
                + "\n"
                + SBUStringSet.Message_Unknown_Desctiption
            let model = SBUUserMessageCellModel(
                message: message,
                position: self.position,
                text: text,
                font: theme.unknownMessageDescFont,
                textColor: theme.unknownMessageDescTextColor,
                isEdited: false
            )
            messageTextView.configure(model: model)
        }
        self.layoutIfNeeded()
    }
}
