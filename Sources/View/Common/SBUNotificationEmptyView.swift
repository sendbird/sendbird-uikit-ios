//
//  SBUNotificationEmptyView.swift
//  QuickStart
//
//  Created by Tez Park on 2023/03/02.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import UIKit

class SBUNotificationEmptyView: SBUEmptyView {
    /// Determines whether the `statusImageView` is shown.
    /// - Since: 3.18.0
    var showEmptyViewIcon: Bool = true

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
    
    override func reloadData(_ type: EmptyViewType) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.type = type
            
            self.retryButton.isHidden = (self.type != .error)
            self.statusImageView.isHidden = !self.showEmptyViewIcon
            self.updateViews()
            
            self.layoutIfNeeded()
            self.updateConstraintsIfNeeded()
        }
    }
}
