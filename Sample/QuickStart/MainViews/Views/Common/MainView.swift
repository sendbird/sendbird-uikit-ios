//
//  MainView.swift
//  QuickStart
//
//  Created by Damon Park on 2023/08/27.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import UIKit

class MainView: NibCustomView {
    @IBOutlet weak var homeStackView: UIStackView! {
        willSet {
            newValue.alpha = 0
        }
    }
    
    @IBOutlet weak var basicUsagesItemView: MainItemView! {
        willSet {
            newValue.titleLabel.text = "Basic Usages"
            newValue.descriptionLabel.isHidden = true
            newValue.unreadCountLabel.isHidden = true
        }
    }
    
    @IBOutlet weak var chatBotItemView: MainItemView! {
        willSet {
            newValue.titleLabel.text = "Talk to an AI Chatbot"
            newValue.descriptionLabel.isHidden = true
            newValue.unreadCountLabel.isHidden = true
        }
    }
    
    @IBOutlet weak var customicationSamplesItemView: MainItemView! {
        willSet {
            newValue.titleLabel.text = "Customization samples"
            newValue.descriptionLabel.isHidden = true
            newValue.unreadCountLabel.isHidden = true
        }
    }
    
    @IBOutlet weak var businessMessagingSampleItemView: MainItemView! {
        willSet {
            newValue.titleLabel.text = "Business Messaging sample"
            newValue.descriptionLabel.isHidden = true
            newValue.unreadCountLabel.isHidden = true
        }
    }
    
//    @IBOutlet weak var groupChannelItemView: MainItemView! {
//        willSet {
//            newValue.titleLabel.text = "Group channel"
//            newValue.descriptionLabel.text = "1 on 1, Group chat with members"
//        }
//    }
//    
//    @IBOutlet weak var openChannelItemView: MainItemView! {
//        willSet {
//            newValue.titleLabel.text = "Open channel"
//            newValue.descriptionLabel.text = "Live streams, Open community chat"
//            newValue.unreadCountLabel.isHidden = true
//        }
//    }
//    
//    @IBOutlet weak var signOutButton: UIButton! {
//        willSet {
//            let signOutColor = UIColor.black.withAlphaComponent(0.88)
//            newValue.layer.cornerRadius = ViewController.CornerRadius.small.rawValue
//            newValue.layer.borderWidth = 1
//            newValue.layer.borderColor = signOutColor.cgColor
//            newValue.setTitleColor(signOutColor, for: .normal)
//        }
//    }
}
