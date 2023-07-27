//
//  SBUUserMessageTextView.swift
//  SendbirdUIKit
//
//  Created by Wooyoung Chung on 7/8/20.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

public protocol SBUUserMessageTextViewDelegate: AnyObject {
    /// Called when the mention in message has been tapped.
    /// - Parameters:
    ///     textView: `SBUUserMessageTextView` object that contains the message text.
    ///     user: The user corresponding to tapped mention.
    func userMessageTextView(_ textView: SBUUserMessageTextView, didTapMention user: SBUUser)
}

open class SBUUserMessageTextView: SBUView {
    public struct Metric {
        public static var textLeftRightMargin = 12.f
        public static var textTopDownMargin = 7.f
        public static var textMaxWidth = SBUConstant.messageCellMaxWidth
        public static var textMinHeight = 16.f
        public static var textMinWidth = 10.f
        public static var viewCornerRadius = 16.f
        public static var viewBorderWidth = 1.f
    }
    
    public internal(set) var text: String = ""
    
    public var textView: SBULinkClickableTextView = {
        var textView = SBULinkClickableTextView()
        textView.backgroundColor = .clear
        textView.textAlignment = .left
        textView.showsVerticalScrollIndicator = false
        textView.showsHorizontalScrollIndicator = false
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.isSelectable = true

        textView.dataDetectorTypes = [.link, .phoneNumber]
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        textView.font = SBUTheme.messageCellTheme.userMessageFont
        return textView
    }()
    
    public var channelType: ChannelType = .group
    public var isWebType = false
    
    var longPressHandler: ((URL) -> Void)?
    
    public var textLeftConstraint: NSLayoutConstraint!
    public var textRightConstraint: NSLayoutConstraint!

    // Create a variable to store text height constraint
    public var textHeightConstraint: NSLayoutConstraint!

    public var mentionManager: SBUMentionManager?
    
    public var removeMargin: Bool = false
    
    /// Check that margin should be removed. If `true`, it needs to margin
    /// - Since: 3.3.0
    public var needsToRemoveMargin: Bool {
        self.channelType == .open || self.removeMargin
    }
    
    public weak var delegate: SBUUserMessageTextViewDelegate?
    
    public override init() {
        super.init()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public init(channelType: ChannelType = .group, removeMargin: Bool = false) {
        self.channelType = channelType
        self.removeMargin = removeMargin

        super.init()
    }
    
    open override func setupViews() {
        self.textView.delegate = self
        
        self.addSubview(self.textView)
    }
    
    open override func setupLayouts() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if self.needsToRemoveMargin {
            self.widthAnchor.constraint(
                lessThanOrEqualToConstant: Metric.textMaxWidth
            ).isActive = true
        }

        self.textHeightConstraint = self.textView.heightAnchor.constraint(
            greaterThanOrEqualToConstant: Metric.textMinHeight
        )
        let textMinWidthConstraint = self.textView.widthAnchor.constraint(
            greaterThanOrEqualToConstant: Metric.textMinWidth
        )

        NSLayoutConstraint.activate([
            self.textHeightConstraint,
            textMinWidthConstraint
        ])

        self.textView.translatesAutoresizingMaskIntoConstraints = false
        let textTopConstraint = self.textView.topAnchor.constraint(
            equalTo: self.topAnchor,
            constant: self.removeMargin ? 0 : Metric.textTopDownMargin
        )
        self.textLeftConstraint = self.textView.leftAnchor.constraint(
            equalTo: self.leftAnchor,
            constant: (self.needsToRemoveMargin && !self.isWebType) ? 0 : Metric.textLeftRightMargin
        )
        let textBottomConstraint = self.textView.bottomAnchor.constraint(
            equalTo: self.bottomAnchor,
            constant: self.removeMargin ? 0 : -Metric.textTopDownMargin
        )
        self.textRightConstraint = self.textView.rightAnchor.constraint(
            lessThanOrEqualTo: self.rightAnchor,
            constant: (self.needsToRemoveMargin && !self.isWebType) ? 0 : -Metric.textLeftRightMargin
        )
        NSLayoutConstraint.activate([
            textTopConstraint,
            self.textLeftConstraint,
            textBottomConstraint,
            self.textRightConstraint
        ])
    }
    
    open func updateSideConstraint() {
        NSLayoutConstraint.deactivate([
            self.textLeftConstraint,
            self.textRightConstraint
        ])
        self.textLeftConstraint = self.textView.leftAnchor.constraint(
            equalTo: self.leftAnchor,
            constant: (self.needsToRemoveMargin && !self.isWebType) ? 0 : Metric.textLeftRightMargin
        )
        self.textRightConstraint = self.textView.rightAnchor.constraint(
            lessThanOrEqualTo: self.rightAnchor,
            constant: (self.needsToRemoveMargin && !self.isWebType) ? 0 : -Metric.textLeftRightMargin
        )
        NSLayoutConstraint.activate([
            self.textLeftConstraint,
            self.textRightConstraint
        ])
        
        self.updateConstraintsIfNeeded()
    }

    open func updateHeightConstraint() {
        // calculate the height of the text
        let textHeight = self.textView.sizeThatFits(CGSize(width: Metric.textMaxWidth, height: CGFloat.greatestFiniteMagnitude)).height

        // Update the constraint constant to the new height, if it's greater than minimum height
        if textHeight > Metric.textMinHeight {
            self.textHeightConstraint.constant = textHeight
        } else {
            self.textHeightConstraint.constant = Metric.textMinHeight
        }

        // refresh the layout
        self.layoutIfNeeded()
    }
    
    open override func setupStyles() { }
    
    open func configure(model: SBUUserMessageTextViewModel) {
        self.text = model.text
        self.textView.attributedText = model.attributedText
        self.textView.linkTextAttributes = [
            .foregroundColor: model.textColor,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        if model.hasMentionedMessage, SendbirdUI.config.groupChannel.channel.isMentionEnabled {
            guard let mentionedMessageTemplate = model.message?.mentionedMessageTemplate,
                  let mentionedUsers = model.message?.mentionedUsers,
                  !mentionedUsers.isEmpty else { return }
            self.mentionManager = SBUMentionManager()
            mentionManager!.configure(
                defaultTextAttributes: model.defaultAttributes,
                mentionTextAttributes: model.mentionedAttributes
            )
            
            let attributedText = mentionManager!.generateMentionedMessage(
                with: mentionedMessageTemplate,
                mentionedUsers: SBUUser.convertUsers(mentionedUsers)
            )
            let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
            model.addMentionedUserHighlightIfNeeded(with: mutableAttributedText, mentionedList: mentionManager?.mentionedList)
//            model.addEditedStateIfNeeded(with: mutableAttributedText)
            
            textView.attributedText = mutableAttributedText
        }
    }
}

extension SBUUserMessageTextView: UITextViewDelegate {
    open func textView(_ textView: UITextView,
                  shouldInteractWith URL: URL,
                  in characterRange: NSRange,
                  interaction: UITextItemInteraction) -> Bool {
        if let mentionManager = mentionManager {
            if let mention = mentionManager.findMentions(with: characterRange).first,
                interaction == .invokeDefaultAction {
                self.delegate?.userMessageTextView(self, didTapMention: mention.user)
                return false
            } else {
                (self.superview as? SBUUserMessageCell)?.longPressHandlerToContent?()
            }
        }
        if interaction == .presentActions {
            self.longPressHandler?(URL)
        } else if interaction == .invokeDefaultAction {
            URL.open()
        }

        return false
    }
}
