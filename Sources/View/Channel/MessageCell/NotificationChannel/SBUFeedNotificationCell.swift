//
//  SBUFeedNotificationCell.swift
//  QuickStart
//
//  Created by Tez Park on 2023/02/28.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import UIKit

protocol SBUFeedNotificationCellDelegate: SBUNotificationCellDelegate {}

@IBDesignable
class SBUFeedNotificationCell: SBUNotificationCell {
    override func setupViews() {
        self.type = .feed
        super.setupViews()
    }
}
