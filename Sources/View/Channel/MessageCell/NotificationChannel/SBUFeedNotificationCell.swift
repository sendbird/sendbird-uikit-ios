//
//  SBUFeedNotificationCell.swift
//  QuickStart
//
//  Created by Tez Park on 2023/02/28.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import UIKit

@IBDesignable
class SBUFeedNotificationCell: SBUNotificationCell {
    struct Constants {
        static let topMarginForCategoryFilter = 0.0
        static let topMarginForNavigationBar = 16.0
        static let bottomMarginForCategoryFilter = -16.0
        static let bottomMarginForNavigationBar = 0.0
    }
    var isCategoryFilterEnabled: Bool = false
    
    override func setupViews() {
        self.type = .feed
        super.setupViews()
    }
    
    override func setupLayouts() {
        super.setupLayouts()
        
        self.topMargin = self.isCategoryFilterEnabled ? Constants.topMarginForCategoryFilter : Constants.topMarginForNavigationBar
        self.bottomMargin = self.isCategoryFilterEnabled ? Constants.bottomMarginForCategoryFilter : Constants.bottomMarginForNavigationBar

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
        
        self.contentView.setNeedsLayout()
        self.contentView.setNeedsUpdateConstraints()
    }
    
    override func updateLayouts() {
        super.updateLayouts()
    }
    
    override func configure(with configuration: SBUBaseMessageCellParams) {
        if let configuration = configuration as? SBUFeedNotificationCellParams {
            self.updateCategoryFilterEnabled(configuration.isCategoryFilterEnabled ?? false)
        } else {
            self.updateCategoryFilterEnabled(false)
        }
        
        super.configure(with: configuration)
    }
    
    func updateCategoryFilterEnabled(_ isCategoryFilterEnabled: Bool) {
        self.isCategoryFilterEnabled = isCategoryFilterEnabled
    }
}
