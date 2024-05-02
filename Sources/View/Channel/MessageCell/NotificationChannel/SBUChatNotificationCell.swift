//
//  SBUChatNotificationCell.swift
//  QuickStart
//
//  Created by Tez Park on 2023/02/28.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import UIKit

@IBDesignable
class SBUChatNotificationCell: SBUNotificationCell {
    override func setupViews() {
        self.type = .chat
        self.topMargin = 16
        self.bottomMargin = 0
        super.setupViews()
    }
    
    override func setupLayouts() {
        super.setupLayouts()

        if let topMarginConstraint = self.topMarginConstraint {
            self.contentView.removeConstraint(topMarginConstraint)
        }
        if let bottomMarginConstraint = self.bottomMarginConstraint {
            self.contentView.removeConstraint(bottomMarginConstraint)
        }
        self.topMarginConstraint?.isActive = false
        self.bottomMarginConstraint?.isActive = false
        self.topMarginConstraint = self.stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: self.topMargin)
        self.bottomMarginConstraint = self.stackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: self.bottomMargin)
        self.topMarginConstraint?.isActive = true
        self.bottomMarginConstraint?.isActive = true
        self.contentView.updateConstraints()
        self.contentView.layoutIfNeeded()
    }
}
