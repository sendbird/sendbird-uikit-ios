//
//  SBUHorizontalSuggestedReplyOptionView.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/04/22.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// Option view to use in horizontal scrolling suggested reply view
/// - Since: 3.23.0
open class SBUHorizontalSuggestedReplyOptionView: SBUSuggestedReplyOptionView {
    /// Button to base the view on
    public let button = UIButton(type: .custom)
    
    /// Padding value for buttons
    public var contentPadding = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15)
    
    open override func configure(
        with optionText: String,
        delegate: SBUSuggestedReplyOptionViewDelegate? = nil
    ) {
        super.configure(with: optionText, delegate: delegate)
        self.button.setTitle(optionText, for: .normal)
    }
    
    open override func setupViews() {
        super.setupViews()
        self.addSubview(button)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        self.button.sbu_constraint(equalTo: self, left: 0, right: 0, top: 0, bottom: 0)
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
        self.button.setTitleColor(self.theme.suggestedReplyTitleColor, for: .normal)
        
        self.button.contentEdgeInsets = self.contentPadding
        self.button.titleLabel?.font = SBUTheme.messageCellTheme.userMessageFont
        self.button.setBackgroundImage(UIImage.from(color: self.theme.suggestedReplyBackgroundColor), for: .normal)
        self.button.setBackgroundImage(UIImage.from(color: self.theme.suggestedReplyBackgroundSelectedColor), for: .highlighted)
        
        self.button.layer.cornerRadius = 16
        self.button.layer.borderWidth = 1
        self.button.layer.borderColor = self.theme.suggestedReplyBorderColor.cgColor
        self.button.clipsToBounds = true
        
        self.invalidateIntrinsicContentSize()
    }
    
    open override func setupActions() {
        super.setupActions()

        self.button.addTarget(self, action: #selector(self.onSelectOption), for: .touchUpInside)
    }
    
    /// Methods called when option view is selected
    @objc
    open func onSelectOption() {
        guard self.text != nil else { return }
        self.delegate?.suggestedReplyOptionViewDidSelect(self)
    }
}
