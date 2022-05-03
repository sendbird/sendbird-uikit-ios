//
//  SBUUserMessageTextViewModel.swift
//  SendbirdUIKit
//
//  Created by Wooyoung Chung on 7/8/20.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

struct SBUUserMessageTextViewModel {
    var message: SBDBaseMessage?
    var text: String
    var attributedText: NSMutableAttributedString?
    var textColor: UIColor
    var theme: SBUMessageCellTheme
    var font: UIFont
    
    var editTextColor: UIColor?
    var edited = false
    
    var highlight: Bool
    var highlightTextColor: UIColor
    
    var paragraphStyle: NSMutableParagraphStyle
    
    var mentionTextColor: UIColor
    var mentionTextBackgroundColor: UIColor
    
    var defaultAttributes: [NSAttributedString.Key: Any] = [:]
    
    /// The mentioned attributes values for the user message text view
    var mentionedAttributes: [NSAttributedString.Key: Any] {
        let mentionAttributes: [NSAttributedString.Key: Any] = [
            .font: theme.mentionTextFont,
            .backgroundColor: mentionTextBackgroundColor,
            .foregroundColor: mentionTextColor,
            .link: "",
            .underlineColor: UIColor.clear
        ]
        
        return mentionAttributes
    }
    
    
    init(message: SBDBaseMessage?,
         position: MessagePosition = .right,
         text: String? = nil,
         font: UIFont? = nil,
         textColor: UIColor? = nil,
         isEdited: Bool? = nil,
         isOverlay: Bool = false,
         highlight: Bool = false) {
        
        let text = message?.message ?? text ?? ""
        
        if let isEdited = isEdited {
            edited = isEdited
        } else {
            edited = message?.updatedAt != 0
        }
        
        self.theme = isOverlay ? SBUTheme.overlayTheme.messageCellTheme : SBUTheme.messageCellTheme
        self.font = font ?? theme.userMessageFont
        
        self.highlight = highlight
        
        var normalTextColor: UIColor
        
        if position == .left {
            normalTextColor = theme.userMessageLeftTextColor
            editTextColor = theme.userMessageLeftEditTextColor
            highlightTextColor = theme.messageLeftHighlightTextColor
            mentionTextColor = theme.mentionLeftTextColor
            mentionTextBackgroundColor = theme.mentionLeftTextBackgroundColor
        } else if position == .right {
            normalTextColor = theme.userMessageRightTextColor
            editTextColor = theme.userMessageRightEditTextColor
            highlightTextColor = theme.messageRightHighlightTextColor
            mentionTextColor = theme.mentionRightTextColor
            mentionTextBackgroundColor = theme.mentionRightTextBackgroundColor
        } else { //default color
            normalTextColor = theme.userMessageRightTextColor
            editTextColor = theme.userMessageRightEditTextColor
            highlightTextColor = theme.messageRightHighlightTextColor
            mentionTextColor = theme.mentionRightTextColor
            mentionTextBackgroundColor = theme.mentionRightTextBackgroundColor
        }
        
        if let textColor = textColor {
            normalTextColor = textColor
        }

        paragraphStyle = SBUFontSet.body3Attributes[.paragraphStyle] as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
        self.defaultAttributes = [
            .font: self.font,
            .paragraphStyle: paragraphStyle,
            .foregroundColor: normalTextColor
        ]
        let attributedString = NSMutableAttributedString(
            string: text,
            attributes: defaultAttributes
        )
        
        self.message = message
        self.text = text
        self.textColor = normalTextColor
        
        self.addhighlightIfNeeded(with: attributedString)
        self.addEditedStateIfNeeded(with: attributedString)
        self.attributedText = attributedString
    }
    
    func haveMentionedMessage() -> Bool {
        guard let message = message else { return false }
        return message.mentionedMessageTemplate != nil && message.mentionedMessageTemplate != ""
    }
    
    func addhighlightIfNeeded(with attributedString: NSMutableAttributedString) {
        /// Highlighting text
        if highlight, text.utf16.count <= attributedString.length {
            let range = NSRange(location: 0, length: text.utf16.count)
            attributedString.addAttributes(
                [
                    .backgroundColor: SBUColorSet.highlight,
                    .foregroundColor: highlightTextColor
                ],
                range: range
            )
        }
    }
    
    func addEditedStateIfNeeded(with attributedString: NSMutableAttributedString) {
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
    }
}