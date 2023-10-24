//
//  SBUQuotedUserMessageView.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2021/07/28.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

open class SBUQuotedUserMessageView: SBUQuotedBaseMessageView {
    /// The label displaying quoted message text.
    /// The limit of lines is 2.
    /// - Since: 2.2.0
    public lazy var quotedMessageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        return label
    }()
    
    var quotedMessageLabelConstraintWidth: NSLayoutConstraint?
    
    open override func setupViews() {
        super.setupViews()
        
        // + ------------------ +
        // | quotedMessageLabel |
        // + ------------------ +

        self.mainContainerView.setStack([
            self.quotedMessageLabel
        ])
    }
    
    open override func setupLayouts() {
        self.translatesAutoresizingMaskIntoConstraints = false

        self.quotedMessageLabelConstraintWidth?.isActive = false
        self.quotedMessageLabelConstraintWidth = self.quotedMessageLabel.widthAnchor.constraint(
            lessThanOrEqualToConstant: SBUConstant.messageCellMaxWidth
        )
        self.quotedMessageLabelConstraintWidth?.isActive = true
        
        self.quotedMessageLabel.sbu_constraint(
            equalTo: self.mainContainerView,
            leading: 12,
            trailing: -12,
            top: 6,
            bottom: 12
        )
        super.setupLayouts()
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
        self.quotedMessageLabel.textColor = self.theme.quotedMessageTextColor
        self.quotedMessageLabel.font = self.theme.quotedMessageTextFont
    }
    
    open override func configure(with configuration: SBUQuotedBaseMessageViewParams) {
        guard configuration.useQuotedMessage else { return }
        self.quotedMessageLabel.text = configuration.text
        self.quotedMessageLabel.isAccessibilityElement = true
        super.configure(with: configuration)
        self.updateConstraintsIfNeeded()
    }
}
