//
//  AppDelegate.swift
//  SendbirdUIKit-Sample
//
//  Created by Tez Park on 13/03/2020.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    
    var pendingNotificationPayload: NSDictionary?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        SendbirdUI.setLogLevel(.none)
        
        var appId:String = ""
        var userId:String = ""
        var nickName:String = ""
        var replyType:String = ""
        
        for argument in CommandLine.arguments {
            if let appIdArg = argument.split(separator: ":").first, appIdArg == "appId" {
                appId = String(argument.split(separator: ":").last ?? "")
            }
            if let userIdArg = argument.split(separator: ":").first, userIdArg == "userId" {
                userId = String(argument.split(separator: ":").last ?? "")
            }
            if let nickNameArg = argument.split(separator: ":").first, nickNameArg == "nickName" {
                nickName = String(argument.split(separator: ":").last ?? "")
            }
            if let replyTypeArg = argument.split(separator: ":").first, replyTypeArg == "replyType" {
                replyType = String(argument.split(separator: ":").last ?? "")
            }
        }

        // TODO: Change to your AppId
        SendbirdUI.initialize(applicationId: appId.isEmpty ? "2D7B4CDB-932F-4082-9B09-A1153792DC8D" : appId) { // origin
            //
        } migrationHandler: {
            //
        } completionHandler: { error in
            //
        }
        
        UserDefaults.saveUserID(userId)
        UserDefaults.saveNickname(nickName)
        
        SBUGlobals.accessToken = ""
        SendbirdUI.config.common.isUsingDefaultUserProfileEnabled = true
        
        
        // Reply
        if replyType != "" {
            if replyType == "thread" {
                SendbirdUI.config.groupChannel.channel.replyType = .thread
            } else if replyType == "quote" {
                SendbirdUI.config.groupChannel.channel.replyType = .quoteReply
            }
        } else{
            SendbirdUI.config.groupChannel.channel.replyType = .quoteReply
        }
        
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
        
        
        self.initializeRemoteNotification()
        
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
        // Foreground setting
        //        completionHandler( [.alert, .badge, .sound])
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Swift.Void) {
        let userInfo = response.notification.request.content.userInfo
        guard let payload: NSDictionary = userInfo["sendbird"] as? NSDictionary else { return }
        
        
        let havePresentedVC = UIApplication.shared.currentWindow?.rootViewController?.presentedViewController != nil
        let isSignedIn = (UIApplication.shared.currentWindow?.rootViewController as? ViewController)?.isSignedIn ?? false
        let needToPedning = !(isSignedIn || havePresentedVC)
        
        if needToPedning {
            self.pendingNotificationPayload = payload
        } else {
            guard let channel: NSDictionary = payload["channel"] as? NSDictionary,
                  let channelURL: String = channel["channel_url"] as? String else { return }
            
            if havePresentedVC {
                SendbirdUI.moveToChannel(channelURL: channelURL, basedOnChannelList: true)
            } else {
                let mainVC = SBUGroupChannelListViewController()
                let naviVC = UINavigationController(rootViewController: mainVC)
                naviVC.modalPresentationStyle = .fullScreen
                UIApplication.shared.currentWindow?.rootViewController?.present(naviVC, animated: true) {
                    SendbirdUI.moveToChannel(channelURL: channelURL)
                }
            }
        }
    }
}
