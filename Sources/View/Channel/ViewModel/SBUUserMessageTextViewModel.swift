//
//  SBUUserMessageTextViewModel.swift
//  SendbirdUIKit
//
//  Created by Wooyoung Chung on 7/8/20.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

public struct SBUUserMessageTextViewModel {
    var message: BaseMessage?
    var text: String
    var attributedText: NSMutableAttributedString?
    var textColor: UIColor
    var theme: SBUMessageCellTheme
    var font: UIFont
    
    let editTextColor: UIColor?
    let edited: Bool
    
    var highlight: Bool { highlightKeyword != nil }
    let highlightKeyword: String?
    let highlightTextColor: UIColor
    
    let paragraphStyle: NSMutableParagraphStyle
    
    let mentionTextColor: UIColor
    let mentionTextBackgroundColor: UIColor
    
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
    
    public var hasMentionedMessage: Bool {
        guard let message = message else { return false }
        return message.mentionedMessageTemplate != nil && message.mentionedMessageTemplate != ""
    }
    
    public init(
        message: BaseMessage?,
        position: MessagePosition = .right,
        customText: String? = nil,
        text: String? = nil,
        font: UIFont? = nil,
        textColor: UIColor? = nil,
        isEdited: Bool? = nil,
        isOverlay: Bool = false,
        highlightKeyword: String? = nil
    ) {
        let text = customText ?? message?.message ?? text ?? ""
        
        if let isEdited = isEdited {
            edited = isEdited
        } else {
            edited = message?.updatedAt != 0
        }
        
        self.theme = isOverlay ? SBUTheme.overlayTheme.messageCellTheme : SBUTheme.messageCellTheme
        self.font = font ?? theme.userMessageFont
        
        self.highlightKeyword = highlightKeyword
        
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
        } else { // default color
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
//        self.addEditedStateIfNeeded(with: attributedString)
        self.attributedText = attributedString
    }
    
    @available(*, deprecated, renamed: "hasMentionedMessage") // 3.3.0
    public func haveMentionedMessage() -> Bool {
        return hasMentionedMessage
    }
    
    public func addhighlightIfNeeded(with attributedString: NSMutableAttributedString) {
        guard let highlightKeyword = highlightKeyword else { return }
        
        let highlightAll = highlightKeyword == ""
        /// Highlighting text
        if highlightAll, text.utf16.count <= attributedString.length {
            let range = NSRange(location: 0, length: text.utf16.count)
            attributedString.addAttributes(
                [
                    .backgroundColor: SBUColorSet.highlight,
                    .foregroundColor: highlightTextColor
                ],
                range: range
            )
        } else {
            var baseRange = NSRange(location: 0, length: attributedString.length)
            var ranges: [NSRange] = []
            // Loop until no more keyword found.
            while baseRange.location != NSNotFound {
                baseRange = (attributedString.string as NSString)
                    .range(
                        of: highlightKeyword,
                        options: .caseInsensitive,
                        range: baseRange
                    )
                ranges.append(baseRange)
                
                if baseRange.location != NSNotFound {
                    baseRange = NSRange(
                        location: NSMaxRange(baseRange),
                        length: attributedString.length - NSMaxRange(baseRange)
                    )
                }
            }
            ranges.forEach { (range) in
                attributedString.addAttributes(
                    [
                        .backgroundColor: SBUColorSet.highlight,
                        .foregroundColor: highlightTextColor
                    ],
                    range: range
                )
            }
        }
    }
    
    public func addMentionedUserHighlightIfNeeded(with attributedString: NSMutableAttributedString, mentionedList: [SBUMention]?) {
        guard let mentionedList = mentionedList,
              let currentUser = SBUGlobals.currentUser else { return }
        
        let currentUserRanges = mentionedList
            .filter { currentUser.userId == $0.user.userId }
            .map(\.range)
        
        currentUserRanges.forEach { (range) in
            attributedString.addAttributes(
                [
                    .backgroundColor: SBUColorSet.highlight,
                    .foregroundColor: highlightTextColor
                ],
                range: range
            )
        }
    }
    
    /// Adds ``SBUStringSet/Message_Edited`` string to the end of the message.
    /// - Important: If the message sender is a chat bot, it finishes immediately.
    public func addEditedStateIfNeeded(with attributedString: NSMutableAttributedString) {
        if self.message?.sender?.isBot == true { return }
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
