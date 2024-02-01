//
//  SBUCategoryFilterCell.swift
//  QuickStart
//
//  Created by Jed Gyeong on 8/21/23.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

open class SBUCategoryFilterCell: UICollectionViewCell, SBUViewLifeCycle {
    var label: UILabel = UILabel()
    
    var categoryFilterCellTheme: SBUNotificationTheme.CategoryFilter {
        switch SBUTheme.colorScheme {
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupLayouts()
        setupStyles()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: .zero)
        setupViews()
        setupLayouts()
        setupStyles()
    }
    
    // MARK: SBUViewLifeCycle
    public func setupViews() {
        self.label.numberOfLines = 1
        let radius = min(self.categoryFilterCellTheme.radius, SBUFeedNotificationChannelModule.CategoryFilter.Constants.categoryCellHeight / 2)
        self.label.roundCorners(corners: .allCorners, radius: radius)
        self.label.textAlignment = .center

        self.label.font = SBUFontSet.notificationsFont(
            size: self.categoryFilterCellTheme.textSize,
            weight: self.categoryFilterCellTheme.fontWeight.value
        )
    }
    
    public func setupStyles() {
        self.backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    public func updateStyles() {
        
    }
    
    public func setupLayouts() {
        contentView.addSubview(self.label)
        self.label.sbu_constraint(
            equalTo: contentView,
            left: 0,
            right: 0,
            top: 0,
            bottom: 0
        )
    }
    
    public func updateLayouts() {
        
    }
    
    public func setupActions() {
        
    }
    
    func updateSelectionStatus(isSelected: Bool) {
        if isSelected {
            self.label.backgroundColor = self.categoryFilterCellTheme.selectedCellBackgroundColor
            self.label.textColor = self.categoryFilterCellTheme.selectedTextColor
        } else {
            self.label.backgroundColor = self.categoryFilterCellTheme.unselectedBackgroundColor
            self.label.textColor = self.categoryFilterCellTheme.unselectedTextColor
        }
    }
    
    func refreshSize() {
        self.label.sizeToFit()
    }
}
