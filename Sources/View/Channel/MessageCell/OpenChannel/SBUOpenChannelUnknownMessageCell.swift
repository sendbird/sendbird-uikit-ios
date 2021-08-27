//
//  SBUOpenChannelUnknownMessageCell.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2020/10/27.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

@objcMembers
open class SBUOpenChannelUnknownMessageCell: SBUOpenChannelUserMessageCell {
    open override func configure(_ message: SBDBaseMessage,
                                   hideDateView: Bool,
                                   groupPosition: MessageGroupPosition,
                                   isOverlay: Bool = false) {
        
        self.configure(
            message,
            hideDateView: hideDateView,
            groupPosition: groupPosition,
            withTextView: false,
            isOverlay: isOverlay
        )
        
        if let messageTextView = self.messageTextView as? SBUUserMessageTextView {
            let text = SBUStringSet.Message_Unknown_Title
                + "\n"
                + SBUStringSet.Message_Unknown_Desctiption
            let model = SBUUserMessageCellModel(
                message: message,
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
