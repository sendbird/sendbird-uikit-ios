//
//  SBUUserMessageCellModel.swift
//  SendBirdUIKit
//
//  Created by Wooyoung Chung on 7/8/20.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

struct SBUUserMessageCellModel {
    var text: String
    var attributedText: NSMutableAttributedString?
    var textColor: UIColor
    
    init(message: SBDBaseMessage?,
         position: MessagePosition = .right,
         text: String? = nil,
         font: UIFont? = nil,
         textColor: UIColor? = nil,
         isEdited: Bool? = nil,
         isOverlay: Bool = false,
         highlight: Bool = false) {
        
        let text = message?.message ?? text ?? ""
        
        var edited = false
        if let isEdited = isEdited {
            edited = isEdited
        } else {
            edited = message?.updatedAt != 0
        }
        
        let theme = isOverlay ? SBUTheme.overlayTheme.messageCellTheme : SBUTheme.messageCellTheme
        let font = font ?? theme.userMessageFont
        
        var editTextColor: UIColor?
        var normalTextColor: UIColor
        var highlightTextColor: UIColor
        
        if position == .left {
            normalTextColor = theme.userMessageLeftTextColor
            editTextColor = theme.userMessageLeftEditTextColor
            highlightTextColor = theme.messageLeftHighlightTextColor
        } else if position == .right {
            normalTextColor = theme.userMessageRightTextColor
            editTextColor = theme.userMessageRightEditTextColor
            highlightTextColor = theme.messageRightHighlightTextColor
        } else { //default color
            normalTextColor = theme.userMessageRightTextColor
            editTextColor = theme.userMessageRightEditTextColor
            highlightTextColor = theme.messageRightHighlightTextColor
        }
        
        if let textColor = textColor {
            normalTextColor = textColor
        }

        let paragraphStyle = SBUFontSet.body3Attributes[.paragraphStyle] ?? NSMutableParagraphStyle()
        let attributedString = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: font,
                .paragraphStyle: paragraphStyle,
                .foregroundColor: normalTextColor
            ])
        
        /// Highlighting text
        if highlight {
            let range = NSRange(location: 0, length: text.utf16.count)
            attributedString.addAttributes([.backgroundColor: SBUColorSet.highlight,
                                            .foregroundColor: highlightTextColor],
                                           range: range)
        }
        
        if let editTextColor = editTextColor, edited {
            let editedAttributedString = NSMutableAttributedString(
                string: " " + SBUStringSet.Message_Edited,
                attributes: [
                    .font: font,
                    .paragraphStyle: paragraphStyle,
                    .foregroundColor: editTextColor
                ])
            attributedString.append(editedAttributedString)
        }
        
        self.text = text
        self.textColor = normalTextColor
        self.attributedText = attributedString
    }
}
