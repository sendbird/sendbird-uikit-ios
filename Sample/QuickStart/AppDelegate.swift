//
//  AppDelegate.swift
//  SendbirdUIKit-Sample
//
//  Created by Tez Park on 13/03/2020.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK
@_exported import SendbirdUIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    var pendingNotificationPayload: NSDictionary?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        SendbirdUI.setLogLevel(.all)
        #if INSPECTION
        SendbirdUI.setLogLevel(.all)
        self.renderViewForInspection()
        #endif
        self.uikitConfigs()
        
        // INFO: This method could cause the 800100 error. However, it's not a problem because the device push token will be kept by the ChatSDK and the token will be registered after the connection is established.
        self.initializeRemoteNotification()
        #if INSPECTION
        self.addObserversForInspection()
        #endif
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
    
    func initializeRemoteNotification() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.sound, .alert]) { granted, error in
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Register a device token to SendBird server.
        SendbirdUI.registerPush(deviceToken: deviceToken) { success in
            
        }
    }
    
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void)
    {
        #if INSPECTION
        self.saveForegroundRemoteNotificationPayload(payload: notification.request.content.userInfo)
        #endif
        // Foreground setting
//        completionHandler( [.alert, .badge, .sound])
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Swift.Void) {
        let userInfo = response.notification.request.content.userInfo
        guard let payload: NSDictionary = userInfo["sendbird"] as? NSDictionary else { return }

        #if INSPECTION
        // This code is not for general purpose and can only be available in Inspection mode sample.
        self.markPushNotificationAsClicked(remoteNotificationPayload: userInfo)
        #else
        SendbirdChat.markPushNotificationAsClicked(remoteNotificationPayload: userInfo)
        #endif

        let signedInApp = UserDefaults.loadSignedInSampleApp()
        if signedInApp != .none {
            self.pendingNotificationPayload = payload
            
            guard let channel: NSDictionary = payload["channel"] as? NSDictionary, let channelURL: String = channel["channel_url"] as? String else { return }
            
            guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else { return }
            
            var topController = rootViewController
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            if topController is UINavigationController && !topController.children.isEmpty {
                topController = topController.children.last!
            }

            switch topController {
            case let vc as BasicUsagesViewController:
                guard let channelType = payload["channel_type"] as? String else { return }
                
                if channelType == "group_messaging" {
                    vc.startGroupChatAction(channelURL: channelURL)
                }
            case let vc as MainChannelTabbarController:
                // Group Channels in Basic Usage
                if vc.selectedIndex == 1 { // My settings tab
                    vc.selectedIndex = 0 // Select Channels tab
                }
                
                if let nc = vc.selectedViewController as? UINavigationController {
                    if nc.visibleViewController is SBUGroupChannelViewController { // SBUGroupChannelViewController is already pushed.
                        nc.popViewController(animated: false) // Move to channel list
                    }
                }
                self.pendingNotificationPayload = nil
                SendbirdUI.moveToChannel(channelURL: channelURL, basedOnChannelList: true)
            case let vc as MainOpenChannelTabbarController:
                vc.dismiss(animated: false) {
                    
                }
            case let vc as BusinessMessagingSelectionViewController:
                guard let channelType = payload["channel_type"] as? String else { return }
                
                let authType = UserDefaults.loadAuthType()
                if channelType == "notification_feed" {
                    vc.openFeedOnly(channelURL: channelURL)
                } else if channelType == "chat" && authType == .websocket {
                    vc.openChatAndFeed(channelURL: channelURL)
                }
            case let vc as BusinessMessagingTabBarController:
                guard let channelType = payload["channel_type"] as? String else { return }
                vc.channelURLforPushNotification = channelURL
                
                if channelType == "notification_feed" {
                    vc.channelType = .feed
                    vc.openFeedChannelIfNeeded()
                } else if channelType == "chat" {
                    vc.channelType = .group
                    vc.openChatChannelIfNeeded()
                }
            default:
                break
            }
        }
    }
    
    func uikitConfigs() {
//        SBUGlobals.accessToken = ""
        SendbirdUI.config.common.isUsingDefaultUserProfileEnabled = true
        
        // Reply
        SendbirdUI.config.groupChannel.channel.replyType = .quoteReply
        // Channel List - Typing indicator
        SendbirdUI.config.groupChannel.channelList.isTypingIndicatorEnabled = true
        // Channel List - Message receipt state
        SendbirdUI.config.groupChannel.channelList.isMessageReceiptStatusEnabled = true
        // User Mention
        SendbirdUI.config.groupChannel.channel.isMentionEnabled = true
        // GroupChannel - Voice Message
        SendbirdUI.config.groupChannel.channel.isVoiceMessageEnabled = true
        // GroupChannel - suggested replies
        SendbirdUI.config.groupChannel.channel.isSuggestedRepliesEnabled = true
        // GroupChannel - form type message
        SendbirdUI.config.groupChannel.channel.isFormTypeMessageEnabled = true
        
//        if #available(iOS 14, *) {
//            SendbirdUI.config.groupChannel.channel.isMultipleFilesMessageEnabled = true
//        }
    }

}
