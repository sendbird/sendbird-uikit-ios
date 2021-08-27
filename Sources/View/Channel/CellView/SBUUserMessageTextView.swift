//
//  SBUUserMessageTextView.swift
//  SendBirdUIKit
//
//  Created by Wooyoung Chung on 7/8/20.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

class SBUUserMessageTextView: UIView {
    struct Metric {
        static let textLeftRightMargin = 12.f
        static let textTopDownMargin = 7.f
        static let textMaxWidth = SBUConstant.messageCellMaxWidth
        static let textMinHeight = 20.f
        static let textMinWidth = 10.f
        static let viewCornerRadius = 16.f
        static let viewBorderWidth = 1.f
    }
    
    var text: String = ""
    
    var textView: SBULinkClickableTextView = {
        var textView = SBULinkClickableTextView()
        textView.backgroundColor = .clear
        textView.textAlignment = .left
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.isSelectable = true

        textView.dataDetectorTypes = [.link, .phoneNumber]
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        textView.font = SBUTheme.messageCellTheme.userMessageFont
        return textView
    }()
    
    var channelType: ChannelType = .group
    var isWebType = false
    
    var longPressHandler: ((URL) -> ())? = nil
    
    var textLeftConstraint: NSLayoutConstraint!
    var textRightConstraint: NSLayoutConstraint!
    
    init() {
        super.init(frame: .zero)
        self.setupViews()
        self.setupStyles()
        self.setupAutolayout()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
        self.setupStyles()
        self.setupAutolayout()
    }
    
    public init(channelType: ChannelType) {
        super.init(frame: .zero)
        
        self.channelType = channelType
        
        self.setupViews()
        self.setupStyles()
        self.setupAutolayout()
    }
    
    @available(*, unavailable, renamed: "UserMessageTextView(frame:)")
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupViews() {
        self.textView.delegate = self
        self.addSubview(self.textView)
    }
    
    func setupAutolayout() {
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
    
    func setupStyles() { }
    
    func configure(model: SBUUserMessageCellModel) {
        self.text = model.text
        self.textView.attributedText = model.attributedText
        self.textView.linkTextAttributes = [
            .foregroundColor: model.textColor,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
    }
}

extension SBUUserMessageTextView: UITextViewDelegate {
    func textView(_ textView: UITextView,
                  shouldInteractWith URL: URL,
                  in characterRange: NSRange,
                  interaction: UITextItemInteraction) -> Bool {
        
        if interaction == .presentActions {
            self.longPressHandler?(URL)
        } else if interaction == .invokeDefaultAction {
            URL.open()
        }

        return false
    }
}
