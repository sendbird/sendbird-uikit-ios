//
//  SBUNotificationEmptyView.swift
//  QuickStart
//
//  Created by Tez Park on 2023/03/02.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import UIKit

class SBUNotificationEmptyView: SBUEmptyView {

    override func setupStyles() {
        super.setupStyles()
        
        self.backgroundColor = .clear
        
        self.statusLabel.font = SBUFontSet.notificationsFont(
            size: 14.0,
            weight: .regular
        ) // body3
        
        self.retryButton.titleLabel?.font = SBUFontSet.notificationsFont(
            size: 16.0,
            weight: .medium
        ) // button2
    }
}
