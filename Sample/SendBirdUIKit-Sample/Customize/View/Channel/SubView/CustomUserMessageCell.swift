//
//  CustomUserMessageCell.swift
//  SendBirdUIKit-Sample
//
//  Created by Tez Park on 2020/07/07.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

class CustomUserMessageCell: SBUUserMessageCell {
    override func setupStyles() {
        super.setupStyles()
        
        if self.message.customType == "highlight" {
            self.messageTextView.backgroundColor = UIColor(hex: "#F78900")
        }
    }
}
