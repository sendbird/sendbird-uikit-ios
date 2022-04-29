//
//  SBUUserMessageTextView.swift
//  SendbirdUIKit
//
//  Created by Wooyoung Chung on 7/8/20.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

protocol SBUUserMessageTextViewDelegate: AnyObject {
    func userMessageTextView(_ textView: SBUUserMessageTextView, didTapMention user: SBUUser)
}

class SBUUserMessageTextView: SBUView {
    struct Metric {
        static let textLeftRightMargin = 12.f
        static let textTopDownMargin = 7.f
        static let textMaxWidth = SBUConstant.messageCellMaxWidth
        static let textMinHeight = 16.f
        static let textMinWidth = 10.f
        static let viewCornerRadius = 16.f
        static let viewBorderWidth = 1.f
    }
    
    var text: String = ""
    
    var textView: SBULinkClickableTextView = {
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
    
    var channelType: ChannelCreationType = .group
    var isWebType = false
    
    var longPressHandler: ((URL) -> ())? = nil
    
    var textLeftConstraint: NSLayoutConstraint!
    var textRightConstraint: NSLayoutConstraint!
    
    var mentionManager: SBUMentionManager?
    
    weak var delegate: SBUUserMessageTextViewDelegate?
    
    override init() {
        super.init()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public init(channelType: ChannelCreationType) {
        self.channelType = channelType

        super.init()
    }
    
    override func setupViews() {
        self.textView.delegate = self
        
        self.addSubview(self.textView)
    }
    
    override func setupLayouts() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if self.channelType != .open {
            self.widthAnchor.constraint(
                lessThanOrEqualToConstant: Metric.textMaxWidth
            ).isActive = true
        }

        let textHeightConstraint = self.textView.heightAnchor.constraint(
            greaterThanOrEqualToConstant: Metric.textMinHeight
        )
        let textMinWidthConstraint = self.textView.widthAnchor.constraint(
            greaterThanOrEqualToConstant: Metric.textMinWidth
        )

        NSLayoutConstraint.activate([
            textHeightConstraint,
            textMinWidthConstraint
        ])

        self.textView.translatesAutoresizingMaskIntoConstraints = false
        let textTopConstraint = self.textView.topAnchor.constraint(
            equalTo: self.topAnchor,
            constant: Metric.textTopDownMargin
        )
        self.textLeftConstraint = self.textView.leftAnchor.constraint(
            equalTo: self.leftAnchor,
            constant: (self.channelType == .open && !self.isWebType) ? 0 : Metric.textLeftRightMargin
        )
        let textBottomConstraint = self.textView.bottomAnchor.constraint(
            equalTo: self.bottomAnchor,
            constant: -Metric.textTopDownMargin
        )
        self.textRightConstraint = self.textView.rightAnchor.constraint(
            lessThanOrEqualTo: self.rightAnchor,
            constant: (self.channelType == .open && !self.isWebType) ? 0 : -Metric.textLeftRightMargin
        )
        NSLayoutConstraint.activate([
            textTopConstraint,
            self.textLeftConstraint,
            textBottomConstraint,
            self.textRightConstraint
        ])
    }
    
    func updateSideConstraint() {
        NSLayoutConstraint.deactivate([
            self.textLeftConstraint,
            self.textRightConstraint
        ])
        self.textLeftConstraint = self.textView.leftAnchor.constraint(
            equalTo: self.leftAnchor,
            constant: (self.channelType == .open && !self.isWebType) ? 0 : Metric.textLeftRightMargin
        )
        self.textRightConstraint = self.textView.rightAnchor.constraint(
            lessThanOrEqualTo: self.rightAnchor,
            constant: (self.channelType == .open && !self.isWebType) ? 0 : -Metric.textLeftRightMargin
        )
        NSLayoutConstraint.activate([
            self.textLeftConstraint,
            self.textRightConstraint
        ])
        
        self.updateConstraintsIfNeeded()
    }
    
    override func setupStyles() { }
    
    func configure(model: SBUUserMessageTextViewModel) {
        self.text = model.text
        self.textView.attributedText = model.attributedText
        self.textView.linkTextAttributes = [
            .foregroundColor: model.textColor,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        if model.haveMentionedMessage(), SBUGlobals.isUserMentionEnabled {
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
            model.addhighlightIfNeeded(with: mutableAttributedText)
            model.addEditedStateIfNeeded(with: mutableAttributedText)
            
            textView.attributedText = mutableAttributedText
        }
    }
}

extension SBUUserMessageTextView: UITextViewDelegate {
    func textView(_ textView: UITextView,
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
