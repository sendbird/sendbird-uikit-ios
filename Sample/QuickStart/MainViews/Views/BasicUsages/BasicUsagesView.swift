//
//  BasicUsagesView.swift
//  QuickStart
//
//  Created by Jed Gyeong on 4/24/24.
//  Copyright © 2024 SendBird, Inc. All rights reserved.
//

import Foundation

import UIKit

class BasicUsagesView: NibCustomView {
    
    @IBOutlet weak var groupChannelItemView: MainItemView! {
        willSet {
            newValue.titleLabel.text = "Group channel"
            newValue.descriptionLabel.text = "1 on 1, Group chat with members"
        }
    }

    @IBOutlet weak var openChannelItemView: MainItemView! {
        willSet {
            newValue.titleLabel.text = "Open channel"
            newValue.descriptionLabel.text = "Live streams, Open community chat"
            newValue.unreadCountLabel.isHidden = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
