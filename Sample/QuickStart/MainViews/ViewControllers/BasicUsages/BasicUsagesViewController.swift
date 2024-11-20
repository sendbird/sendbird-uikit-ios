//
//  BasicUsagesViewController.swift
//  QuickStart
//
//  Created by Jed Gyeong on 4/25/24.
//  Copyright © 2024 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

final class BasicUsagesViewController: UIViewController {
    @IBOutlet weak var signOutButton: UIButton!
    
    @IBOutlet weak var versionLabel: UILabel!
    
    weak var unreadCountLabel: UILabel! {
        groupChannelItemView.unreadCountLabel
    }
    
    @IBOutlet weak var groupChannelItemView: MainItemView! {
        willSet {
            newValue.titleLabel.text = "Group channel"
            newValue.descriptionLabel.text = "1 on 1, Group chat with members"
            newValue.unreadCountLabel.text = ""
        }
    }

    @IBOutlet weak var openChannelItemView: MainItemView! {
        willSet {
            newValue.titleLabel.text = "Open channel"
            newValue.descriptionLabel.text = "Live streams, Open community chat"
            newValue.unreadCountLabel.isHidden = true
        }
    }
    
    var sampleAppType: SampleAppType = .basicUsage
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
           let payload = appDelegate.pendingNotificationPayload {
            appDelegate.pendingNotificationPayload = nil

            guard let channel: NSDictionary = payload["channel"] as? NSDictionary, let channelURL: String = channel["channel_url"] as? String else { return }

            self.startGroupChatAction(channelURL: channelURL)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signOutButton.layer.cornerRadius = 4.0
        signOutButton.layer.borderWidth = 1.0
        signOutButton.layer.borderColor = UIColor(named: "signOutButtonBorder")?.cgColor
        
        groupChannelItemView.actionButton.addTarget(
            self,
            action: #selector(onTapGroupChannelItemViewButton(_:)),
            for: .touchUpInside
        )
        openChannelItemView.actionButton.addTarget(
            self,
            action: #selector(onTapOpenChannelItemViewButton(_:)), 
            for: .touchUpInside
        )
        
        SendbirdChat.addUserEventDelegate(self, identifier: self.description)
        SendbirdChat.addConnectionDelegate(self, identifier: self.description)
        
        self.updateUnreadCount()
        self.setupVersion()
    }

    deinit {
        SendbirdChat.removeUserEventDelegate(forIdentifier: self.description)
        SendbirdChat.removeConnectionDelegate(forIdentifier: self.description)
    }
    
    @IBAction func onTapGroupChannelItemViewButton(_ sender: UIButton) {
        self.startGroupChatAction()
    }
    
    @IBAction func onTapOpenChannelItemViewButton(_ sender: UIButton) {
        self.startOpenChatAction()
    }
    
    @IBAction func clickSignOutButton(_ sender: Any) {
        SendbirdUI.unregisterPushToken { success in
            SendbirdUI.disconnect {
                UserDefaults.removeSignedSampleApp()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func startGroupChatAction(channelURL: String? = nil) {
        let vc = MainChannelTabbarController()
        vc.channelURLforPushNotification = channelURL
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    func startOpenChatAction() {
        let vc = MainOpenChannelTabbarController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    func setUnreadMessageCount(unreadCount: Int32) {
//        guard self.isSignedIn else { return }
        
        var badgeValue: String?
        if unreadCount == 0 {
            badgeValue = nil
        } else if unreadCount > 99 {
            badgeValue = "99+"
        } else {
            badgeValue = "\(unreadCount)"
        }
        
        self.unreadCountLabel.text = badgeValue
        self.unreadCountLabel.isHidden = badgeValue == nil
    }
    
    func updateUnreadCount() {
        SendbirdChat.getTotalUnreadMessageCount { [weak self] totalCount, error in
            guard let self = self else { return }
            self.setUnreadMessageCount(unreadCount: Int32(totalCount))
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

extension BasicUsagesViewController: UserEventDelegate {
    func didUpdateTotalUnreadMessageCount(_ totalCount: Int32, totalCountByCustomType: [String : Int]?) {
        self.setUnreadMessageCount(unreadCount: Int32(totalCount))
    }
}

extension BasicUsagesViewController: ConnectionDelegate {
    func didSucceedReconnection() {
        self.updateUnreadCount()
    }
}
