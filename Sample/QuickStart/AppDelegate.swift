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
        SendbirdUI.setLogLevel(.all)
        
        // TODO: Change to your AppId
        SendbirdUI.initialize(applicationId: "60E22A13-CC2E-4E83-98BE-578E72FC92F3") { // origin
            //
        } migrationHandler: {
            //
        } completionHandler: { error in
            //
        }
        
        SBUGlobals.accessToken = ""
        SBUGlobals.isUserProfileEnabled = true
        SBUGlobals.isOpenChannelUserProfileEnabled = true
        
        // Reply
        SBUGlobals.reply.replyType = .quoteReply
        // Channel List - Typing indicator
        SBUGlobals.isChannelListTypingIndicatorEnabled = true
        // Channel List - Message receipt state
        SBUGlobals.isChannelListMessageReceiptStateEnabled = true
        // User Mention
        SBUGlobals.isUserMentionEnabled = true
        
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
    
    /// **Notification Center - Push Notification Guide:**
    /// Image is not supported officially by Sendbird.
    /// However, You can get the image URL from the payload that contains the data of the message.
    /// For more information on message data, please refer to `MessageBlock.swift` or ``SendbirdMessage``
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Swift.Void) {
        let userInfo = response.notification.request.content.userInfo
        guard let payload: NSDictionary = userInfo["sendbird"] as? NSDictionary else { return }
        
        let hasPresentedVC = UIApplication.shared.currentWindow?.rootViewController?.presentedViewController != nil
        let isSignedIn = (UIApplication.shared.currentWindow?.rootViewController as? ViewController)?.isSignedIn ?? false
        let needToPedning = !(isSignedIn || hasPresentedVC)
        
        if needToPedning {
            self.pendingNotificationPayload = payload
        } else {
            guard let channel: NSDictionary = payload["channel"] as? NSDictionary,
                  let channelURL: String = channel["channel_url"] as? String else { return }
            
            /// **NOTIFICATION CHANNEL**
            /// Handle Push Notifications - Moves to notification channel
            if channelURL.contains(SBUStringSet.Notification_Channel_CustomType) {
                self.moveToNotificationChannel()
                return
            }
            
            else {
                if hasPresentedVC {
                    SendbirdUI.moveToChannel(channelURL: channelURL, basedOnChannelList: true)
                } else {
                    let channelListViewController = SBUGroupChannelListViewController()
                    let navigationController = UINavigationController(rootViewController: channelListViewController)
                    navigationController.modalPresentationStyle = .fullScreen
                    UIApplication.shared.currentWindow?.rootViewController?.present(navigationController, animated: true) {
                        SendbirdUI.moveToChannel(channelURL: channelURL)
                    }
                }
            }
        }
    }
    
    /// **NOTIFICATION CHANNEL**
    /// Handle Push Notifications - Moves to notification channel
    private func moveToNotificationChannel() {
        let rootViewController = UIApplication.shared.currentWindow?.rootViewController
        if let tabBarController = rootViewController?.presentedViewController as? MainChannelTabbarController {
            tabBarController.selectedIndex = 1
        } else {
            let tabBarController = MainChannelTabbarController()
            tabBarController.modalPresentationStyle = .fullScreen
            UIApplication.shared.currentWindow?.rootViewController?.present(tabBarController, animated: true) {
                tabBarController.selectedIndex = 1
            }
        }
    }
}
