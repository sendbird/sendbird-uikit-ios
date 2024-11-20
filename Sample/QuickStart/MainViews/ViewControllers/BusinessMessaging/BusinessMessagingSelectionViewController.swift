//
//  BusinessMessagingSelectionViewController.swift
//  QuickStart
//
//  Created by Jed Gyeong on 4/24/24.
//  Copyright © 2024 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK 

final class BusinessMessagingSelectionViewController: UIViewController {
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var marginView: UIView!
    
    @IBOutlet weak var versionLabel: UILabel!
    
    @IBOutlet weak var feedChannelOnlyItemView: MainItemView! {
        willSet {
            newValue.titleLabel.text = "Feed channel only"
            newValue.descriptionLabel.isHidden = true
            newValue.unreadCountLabel.isHidden = true
        }
    }
    
    @IBOutlet weak var chatAndFeedChannelsItemView: MainItemView! {
        willSet {
            newValue.titleLabel.text = "Chat and feed channels"
            newValue.descriptionLabel.isHidden = true
            newValue.unreadCountLabel.isHidden = true
        }
    }
    
    var authType: AuthType = .authFeed
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        #if INSPECTION
        AppDelegate.bringInspectionViewToFront()
        #endif
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signOutButton.layer.cornerRadius = 4.0
        signOutButton.layer.borderWidth = 1.0
        signOutButton.layer.borderColor = UIColor(named: "signOutButtonBorder")?.cgColor
        
        if authType == .websocket {
            marginView.isHidden = false
            chatAndFeedChannelsItemView.isHidden = false
        } else {
            marginView.isHidden = true
            chatAndFeedChannelsItemView.isHidden = true
        }
        
        self.feedChannelOnlyItemView.actionButton.addTarget(
            self,
            action: #selector(onTapFeedChannelOnlyButton(_:)),
            for: .touchUpInside
        )
        
        self.chatAndFeedChannelsItemView.actionButton.addTarget(
            self,
            action: #selector(onTabChatAndFeedChannelButton(_:)),
            for: .touchUpInside
        )
        
        self.setupVersion()
    }
    
    @IBAction func onTapFeedChannelOnlyButton(_ sender: UIButton) {
        self.openFeedOnly()
    }
    
    @IBAction func onTabChatAndFeedChannelButton(_ sender: UIButton) {
        self.openChatAndFeed()
    }

    @IBAction func clickSignOutButton(_ sender: Any) {
        SendbirdUI.unregisterPushToken { success in
            SendbirdUI.disconnect {
                UserDefaults.removeSignedSampleApp()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func openFeedOnly(channelURL: String? = nil) {
        let vc = BusinessMessagingTabBarController(
            tabBarType: .feedOnly,
            channelURLForPushNotification: channelURL,
            channelType: .feed
        )
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    func openChatAndFeed(channelURL: String? = nil) {
        let vc = BusinessMessagingTabBarController(
            tabBarType: .chatAndFeed,
            channelURLForPushNotification: channelURL,
            channelType: .group
        )
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
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
