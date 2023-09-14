//
//  SBUFeedNotificationCellParams.swift
//  QuickStart
//
//  Created by Jed Gyeong on 8/25/23.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import Foundation

import SendbirdChatSDK

public class SBUFeedNotificationCellParams: SBUBaseMessageCellParams {
    public var adminMessage: AdminMessage? {
        self.message as? AdminMessage
    }
    
    public internal(set) var isTemplateLabelEnabled: Bool?
    public internal(set) var isCategoryFilterEnabled: Bool?
    
    public init(message: AdminMessage, hideDateView: Bool, isTemplateLabelEnabled: Bool?, isCategoryFilterEnabled: Bool?) {
        self.isTemplateLabelEnabled = isTemplateLabelEnabled
        self.isCategoryFilterEnabled = isCategoryFilterEnabled
        super.init(
            message: message,
            hideDateView: hideDateView,
            messagePosition: .center,
            groupPosition: .none,
            receiptState: SBUMessageReceiptState.notUsed
        )
    }
}
