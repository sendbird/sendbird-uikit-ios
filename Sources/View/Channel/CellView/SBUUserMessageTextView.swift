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
    
    /// Called when the URL link in message is tapped.
    /// - Parameters:
    ///     textView: `SBUUserMessageTextView` object that contains the message text.
    ///     URL: The URL link that is tapped.
    /// - Since: [NEXT_VERSION]
    func userMessageTextView(_ textView: SBUUserMessageTextView, didTapURL url: URL)
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
        textView.textAlignment = .natural
        textView.textContainer.lineBreakMode = .byCharWrapping
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
    
    var longPressHandler: ((URL?) -> Void)?
    
    public var mentionManager: SBUMentionManager?
    
    public var removeMargin: Bool = false
    
    /// Check that margin should be removed. If `true`, it needs to margin
    /// - Since: 3.3.0
    public var needsToRemoveMargin: Bool {
        self.channelType == .open || self.removeMargin
    }
    
    public weak var delegate: SBUUserMessageTextViewDelegate?

    public var textTopConstraint: NSLayoutConstraint?
    public var textBottomConstraint: NSLayoutConstraint?
    public var textLeftConstraint: NSLayoutConstraint?
    public var textRightConstraint: NSLayoutConstraint?
    
    var widthConstraint: NSLayoutConstraint?
    
    var textHeightConstraint: NSLayoutConstraint?
    var textMinWidthConstraint: NSLayoutConstraint?
    
    var containerType: SBUMessageContainerType = .default
    
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
        
        if !self.needsToRemoveMargin {
            self.widthConstraint?.isActive = false
            self.widthConstraint = self.widthAnchor.constraint(
                lessThanOrEqualToConstant: Metric.textMaxWidth
            )
            self.widthConstraint?.priority = .init(999)
            self.widthConstraint?.isActive = true
        }

//        self.textHeightConstraint?.isActive = false
//        self.textMinWidthConstraint?.isActive = false
        self.textHeightConstraint = self.textView.heightAnchor.constraint(
            greaterThanOrEqualToConstant: Metric.textMinHeight
        )
        self.textHeightConstraint?.priority = .defaultHigh
        self.textMinWidthConstraint = self.textView.widthAnchor.constraint(
            greaterThanOrEqualToConstant: Metric.textMinWidth
        )
        NSLayoutConstraint.sbu_activate(baseView: self.textView, constraints: [
            self.textHeightConstraint,
            self.textMinWidthConstraint
        ])
//        self.textHeightConstraint?.isActive = true
//        self.textMinWidthConstraint?.isActive = true

        self.textView.translatesAutoresizingMaskIntoConstraints = false
        self.textTopConstraint?.isActive = false
        self.textLeftConstraint?.isActive = false
        self.textRightConstraint?.isActive = false
        self.textBottomConstraint?.isActive = false
        
        self.textTopConstraint = self.textView.topAnchor.constraint(
            equalTo: self.topAnchor,
            constant: self.removeMargin ? 0 : Metric.textTopDownMargin
        )
        self.textLeftConstraint = self.textView.leftAnchor.constraint(
            equalTo: self.leftAnchor,
            constant: (self.needsToRemoveMargin && !self.isWebType) ? 0 : Metric.textLeftRightMargin
        )
        self.textBottomConstraint = self.textView.bottomAnchor.constraint(
            equalTo: self.bottomAnchor,
            constant: self.removeMargin ? 0 : -Metric.textTopDownMargin
        )
        self.textRightConstraint = self.textView.rightAnchor.constraint(
            lessThanOrEqualTo: self.rightAnchor,
            constant: (self.needsToRemoveMargin && !self.isWebType) ? 0 : -Metric.textLeftRightMargin
        )
        self.textTopConstraint?.isActive = true
        self.textBottomConstraint?.isActive = true
        self.textLeftConstraint?.isActive = true
        self.textRightConstraint?.isActive = true
    }
    
    open func updateSideConstraint() {
        self.textLeftConstraint?.isActive = false
        self.textRightConstraint?.isActive = false
        
        self.textLeftConstraint = self.textView.leftAnchor.constraint(
            equalTo: self.leftAnchor,
            constant: (self.needsToRemoveMargin && !self.isWebType) ? 0 : Metric.textLeftRightMargin
        )
        self.textRightConstraint = self.textView.rightAnchor.constraint(
            lessThanOrEqualTo: self.rightAnchor,
            constant: (self.needsToRemoveMargin && !self.isWebType) ? 0 : -Metric.textLeftRightMargin
        )
        
        self.textLeftConstraint?.isActive = true
        self.textRightConstraint?.isActive = true
        
        self.updateConstraintsIfNeeded()
    }
    
    open override func setupStyles() { }
    
    open func configure(model: SBUUserMessageTextViewModel) {
        self.text = model.text
        self.textView.attributedText = SBUMarkdownTransfer.convert(
            with: model.attributedText,
            isEnabled: model.isMarkdownEnabled
        )        
        
        if self.currentLayoutDirection == .rightToLeft {
            if SBUUtils.isRTLCharacter(with: self.textView.attributedText.string) {
                self.textView.textAlignment = .right
            } else {
                self.textView.textAlignment = .left
            }            
        }
        
        self.textView.linkTextAttributes = [
            .foregroundColor: model.textColor,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        self.containerType = model.message?.asUiSettingContainerType ?? .default
        
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
            model.addEditedStateIfNeeded(with: mutableAttributedText)
            
            textView.attributedText = mutableAttributedText
        }
        
        self.setupLayouts()
    }
}

extension SBUUserMessageTextView: UITextViewDelegate {
    
    /// Handles tap and longpress on a URL link or a mentioned user for iOS below 17.0.
    @available(iOS, deprecated: 17.0)
    open func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        if let mentionManager = mentionManager {
            if let mention = mentionManager.findMentions(with: characterRange).first,
                interaction == .invokeDefaultAction {
                // Mention tapped
                self.delegate?.userMessageTextView(self, didTapMention: mention.user)
                return false
            } else {
                // Mention longpressed
                (self.superview as? SBUUserMessageCell)?.longPressHandlerToContent?()
            }
        }
        if interaction == .presentActions {
            // URL link longpressed
            self.longPressHandler?(URL)
        } else if interaction == .invokeDefaultAction {
            // URL link tapped
            self.delegate?.userMessageTextView(self, didTapURL: URL)
        }

        return false
    }
    
    /// Handles tap on a URL link or a mentioned user for iOS 17.0 or above.
    /// - Since: 3.30.1
    @available(iOS 17.0, *)
    open func textView(
        _ textView: UITextView,
        primaryActionFor textItem: UITextItem,
        defaultAction: UIAction
    ) -> UIAction? {
        let characterRange = textItem.range
        if let mentionManager = mentionManager {
            if let mention = mentionManager.findMentions(with: characterRange).first {
                // Mention tapped
                return UIAction(title: "Mention Tapped") { _ in
                    self.delegate?.userMessageTextView(self, didTapMention: mention.user)
                }
            }
        } else if let tappedURL = textView.textStorage.attribute(.link, at: characterRange.location, effectiveRange: nil) as? URL {
            // URL link tapped
            return UIAction(title: "Link Tapped") { _ in
                self.delegate?.userMessageTextView(self, didTapURL: tappedURL)
            }
        }
        
        return nil
    }
    
    /// Handles longpress on a URL link or a mentioned user for iOS 17.0 or above.
    /// - Since: 3.30.1
    @available(iOS 17.0, *)
    open func textView(
        _ textView: UITextView,
        menuConfigurationFor textItem: UITextItem,
        defaultMenu: UIMenu
    ) -> UITextItem.MenuConfiguration? {
        let characterRange = textItem.range
        if let mentionManager = mentionManager {
            if mentionManager.findMentions(with: characterRange).first != nil {
                // Mention longpressed
                self.longPressHandler?(nil)
            }
        } else if let tappedURL = textView.textStorage.attribute(.link, at: characterRange.location, effectiveRange: nil) as? URL {
            // URL link longpressed
            self.longPressHandler?(tappedURL)
        }
        
        return nil
    }
}
