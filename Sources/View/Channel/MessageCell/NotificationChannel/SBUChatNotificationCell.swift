//
//  SBUChatNotificationCell.swift
//  QuickStart
//
//  Created by Tez Park on 2023/02/28.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import UIKit

protocol SBUChatNotificationCellDelegate: SBUNotificationCellDelegate {}

@IBDesignable
class SBUChatNotificationCell: SBUNotificationCell {
    override func setupViews() {
        self.type = .chat
        super.setupViews()
    }
}
