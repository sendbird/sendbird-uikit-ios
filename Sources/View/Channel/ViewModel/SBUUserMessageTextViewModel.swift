//
//  SBUUserMessageTextViewModel.swift
//  SendbirdUIKit
//
//  Created by Wooyoung Chung on 7/8/20.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// SBUUserMessageTextViewModel is a structure that represents the view model for user messages.
public struct SBUUserMessageTextViewModel {
    var message: BaseMessage?
    var text: String
    var attributedText: NSMutableAttributedString?
    var textColor: UIColor
    var theme: SBUMessageCellTheme
    var font: UIFont
    
    let editTextColor: UIColor?
    let edited: Bool
    
    let isMarkdownEnabled: Bool
    
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
    
    /// This computed property checks if the message has mentioned someone.
    public var hasMentionedMessage: Bool {
        guard let message = message else { return false }
        return message.mentionedMessageTemplate != nil && message.mentionedMessageTemplate != ""
    }
    
    /// Initializer for the SBUUserMessageTextViewModel structure.
    /// - Parameters:
    ///   - message: The base message object.
    ///   - position: The position of the message, default is .right.
    ///   - text: The text of the message, default is nil.
    ///   - font: The font of the message, default is nil.
    ///   - textColor: The color of the text, default is nil.
    ///   - isEdited: A boolean indicating if the message is edited, default is nil.
    ///   - isOverlay: A boolean indicating if the message is an overlay, default is false.
    ///   - highlightKeyword: The keyword to be highlighted in the message, default is nil.
    ///   - isMarkdownEnabled: A boolean indicating whether to render the Markdown syntax of the message, default is false.
    public init(
        message: BaseMessage?,
        position: MessagePosition = .right,
        text: String? = nil,
        font: UIFont? = nil,
        textColor: UIColor? = nil,
        isEdited: Bool? = nil,
        isOverlay: Bool = false,
        highlightKeyword: String? = nil,
        isMarkdownEnabled: Bool = false
    ) {
        let text = message?.message ?? text ?? ""
        
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

        self.isMarkdownEnabled = isMarkdownEnabled
        
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
    
    /// This function is deprecated and has been renamed to `hasMentionedMessage`.
    ///
    /// - Returns: A Boolean value indicating whether the message has been mentioned.
    @available(*, deprecated, renamed: "hasMentionedMessage") // 3.3.0
    public func haveMentionedMessage() -> Bool {
        return hasMentionedMessage
    }
    
    /// This function adds highlight to the text if needed.
    /// - Parameter attributedString: The attributed string to be highlighted.
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
    
    /// This function adds highlight to mentioned users in the text if needed.
    /// - Parameters:
    ///   - attributedString: The attributed string to be highlighted.
    ///   - mentionedList: The list of mentioned users.
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
    
    /// This function adds an edited state to the message if it has been edited.
    /// - Parameter attributedString: The attributed string to be modified.
    public func addEditedStateIfNeeded(with attributedString: NSMutableAttributedString) {
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
