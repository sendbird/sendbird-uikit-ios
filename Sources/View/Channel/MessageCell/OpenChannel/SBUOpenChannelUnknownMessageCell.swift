//
//  SBUOpenChannelUnknownMessageCell.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2020/10/27.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

open class SBUOpenChannelUnknownMessageCell: SBUOpenChannelUserMessageCell {
    open override func configure(_ message: BaseMessage,
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
        
        let theme = self.isOverlay ? self.overlayTheme : self.theme
        
        if let messageTextView = self.messageTextView as? SBUUserMessageTextView {
            let text = SBUStringSet.Message_Unknown_Title
            + "\n"
            + SBUStringSet.Message_Unknown_Description
            let model = SBUUserMessageTextViewModel(
                message: message,
                text: text,
                font: theme.unknownMessageDescFont,
                textColor: theme.unknownMessageDescLeftTextColor,
                isEdited: false
            )
            messageTextView.configure(model: model)
        }
        self.layoutIfNeeded()
    }
}
