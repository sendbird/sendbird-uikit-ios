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
     
    @SBUThemeWrapper(theme: SBUTheme.notificationTheme.list)
    var listTheme: SBUNotificationTheme.List
    
    override func setupStyles() {
        self.backgroundColor = .clear
        
        self.dateLabel.font = self.listTheme.timelineFont
        self.dateLabel.textColor = self.listTheme.timelineTextColor
        self.dateLabel.backgroundColor = self.listTheme.timelineBackgroundColor
    }
}
