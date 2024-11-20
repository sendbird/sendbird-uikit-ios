//
//  SendbirdChat+SBUIKit.swift
//  InspectionQuickStart
//
//  Created by Jed Gyeong on 9/26/24.
//

import SendbirdChatSDK

extension SendbirdChat {
    static func isAuthenticated() -> Bool {
        return SendbirdChat.getCurrentUser() != nil
    }
}
