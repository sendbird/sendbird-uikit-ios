//
//  NotificationService.swift
//  NotificationService
//
//  Created by Tez Park on 2022/04/15.
//  Copyright © 2022 SendBird, Inc. All rights reserved.
//

import UserNotifications
import SendbirdChatSDK

class NotificationService: UNNotificationServiceExtension {
    /// > NOTE: How to mark messages as delivered:
    /// > [Reference link](https://sendbird.com/docs/chat/v3/ios/tutorials/delivery-receipt#2-mark-messages-as-delivered)
    
    // Storage for the completion handler and content.
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        self.bestAttemptContent = (request.content.mutableCopy()
              as? UNMutableNotificationContent)

        if let bestAttemptContent = bestAttemptContent {
            SendbirdChat.setAppGroup("group.com.sendbird.uikit.sample")
            #if INSPECTION
            self.prepareForInspection(bestAttemptContent: bestAttemptContent)
            #else
            SendbirdChat.markPushNotificationAsDelivered(remoteNotificationPayload: bestAttemptContent.userInfo) { error in
                print("Mark as delivered result: \(error.debugDescription)")
            }
            #endif

            // Always call the completion handler when done.
            contentHandler(bestAttemptContent)
        }
    }
    
    // Return something before time expires.
    override func serviceExtensionTimeWillExpire() {
       if let contentHandler = contentHandler,
          let bestAttemptContent = bestAttemptContent {
          contentHandler(bestAttemptContent)
       }
    }
}
