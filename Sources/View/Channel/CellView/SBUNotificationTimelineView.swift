//
//  SBUNotificationTimelineView.swift
//  QuickStart
//
//  Created by Tez Park on 2023/03/02.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import UIKit

/// This class used to display the date separator in the message list.
class SBUNotificationTimelineView: SBUMessageDateView {
     
    var listTheme: SBUNotificationTheme.List {
        switch SBUTheme.colorScheme {
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    override func setupViews() {
        self.dateLabel = SBUTemplateLabel()
        self.dateLabel.clipsToBounds = true
        
        super.setupViews()
    }
    override func setupStyles() {
        self.backgroundColor = .clear
        
        self.dateLabel.font = self.listTheme.timelineFont
        self.dateLabel.textColor = self.listTheme.timelineTextColor
        self.dateLabel.backgroundColor = self.listTheme.timelineBackgroundColor
    }
    
    override func setupLayouts() {

        self.dateLabel
            .setConstraint(from: self, centerX: true, centerY: true)
            .setConstraint(from: self, top: 0, bottom: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        (self.dateLabel as? SBUTemplateLabel)?.padding = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        let radius = self.dateLabel.frame.height / 2
        self.dateLabel.layer.cornerRadius = radius
    }
}
