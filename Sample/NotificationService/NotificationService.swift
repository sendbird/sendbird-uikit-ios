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
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        // How to mark messages as delivered:
        // https://sendbird.com/docs/chat/v3/ios/tutorials/delivery-receipt#2-mark-messages-as-delivered
        super.didReceive(request, withContentHandler: contentHandler)
    }
}
