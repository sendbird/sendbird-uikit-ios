//
//  AIChatBotViewController.swift
//  QuickStart
//
//  Created by Jed Gyeong on 4/25/24.
//  Copyright © 2024 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

final class AIChatBotViewController: UIViewController {
    @IBOutlet weak var signOutButton: UIButton!

    @IBOutlet weak var chatBotItemView: MainItemView! {
        willSet {
            newValue.titleLabel.text = "Talk to an AI Chatbot"
            newValue.descriptionLabel.isHidden = true
            newValue.unreadCountLabel.isHidden = true
        }
    }
    
    @IBOutlet weak var versionLabel: UILabel!

    var botId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let params = ApplicationUserListQueryParams()
        params.userIdsFilter = [self.botId]
        let query = SendbirdChat.createApplicationUserListQuery(params: params)
        query.loadNextPage { users, error in
            if error != nil {
                return
            }
            guard let bot = users?.first else { return }
            self.chatBotItemView.titleLabel.text = bot.nickname // ?? "Talk to an AI Chatbot"
        }

        signOutButton.layer.cornerRadius = 4.0
        signOutButton.layer.borderWidth = 1.0
        signOutButton.layer.borderColor = UIColor(named: "signOutButtonBorder")?.cgColor
        
        chatBotItemView.actionButton.addTarget(
            self,
            action: #selector(onTapChatBotItemViewButton(_:)),
            for: .touchUpInside
        )
        
        self.setupVersion()
    }
    
    @IBAction func onTapChatBotItemViewButton(_ sender: UIButton) {
        SendbirdUI.startChatWithAIBot(botId: botId, isDistinct: true)
    }
    
    @IBAction func clickSignOutButton(_ sender: Any) {
        SendbirdUI.unregisterPushToken { success in
            SendbirdUI.disconnect {
                UserDefaults.removeSignedSampleApp()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func setupVersion() {
        let coreVersion: String = SendbirdChat.getSDKVersion()
        var uikitVersion: String {
            if SendbirdUI.shortVersion == "3.27.5" {
                let bundle = Bundle(identifier: "com.sendbird.uikit.sample")
                return "\(bundle?.infoDictionary?["CFBundleShortVersionString"] ?? "")"
            } else if SendbirdUI.shortVersion == "0.0.0" {
                guard let dictionary = Bundle.main.infoDictionary,
                      let appVersion = dictionary["CFBundleShortVersionString"] as? String,
                      let build = dictionary["CFBundleVersion"] as? String else {return ""}
                return "\(appVersion)(\(build))"
            } else {
                return SendbirdUI.shortVersion
            }
        }
        versionLabel.text = "UIKit v\(uikitVersion)\tSDK v\(coreVersion)"
    }
}
