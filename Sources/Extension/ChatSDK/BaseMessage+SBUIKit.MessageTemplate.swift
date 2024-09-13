//
//  BaseMessage+SBUIKit.MessageTemplate.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/03/15.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

extension BaseMessage {
    static let messageTemplateRetryStatusKey = "messageTemplateRetryStatusKey"
    static let messageTemplateImageRetryStatusKey = "messageTemplateImageRetryStatusKey"
    static let messageTemplateCarouselView = "messageTemplateCarouselView"
}

extension BaseMessage {
    var templateDownloadRetryStatus: SBUTemplateMessageRetryStatus {
        get { self.getInMemoryUserInfo(key: Self.messageTemplateRetryStatusKey, defaultValue: .initialized) }
        set { self.setInMemoryUserInfo(key: Self.messageTemplateRetryStatusKey, data: newValue) }
    }
    
    var templateImagesRetryStatus: SBUTemplateMessageRetryStatus {
        get { self.getInMemoryUserInfo(key: Self.messageTemplateImageRetryStatusKey, defaultValue: .initialized) }
        set { self.setInMemoryUserInfo(key: Self.messageTemplateImageRetryStatusKey, data: newValue) }
    }
        
    var messageTemplateCarouselView: UIView? {
        get { self.getInMemoryUserInfo(key: Self.messageTemplateCarouselView, defaultValue: nil) }
        set { self.setInMemoryUserInfo(key: Self.messageTemplateCarouselView, data: newValue) }
    }
}

enum SBUTemplateMessageRetryStatus: Int, Codable {
    case initialized
    case retry
    case done
    case failed

    var isRetry: Bool { self == .retry }
    var isFailed: Bool { self == .failed }
    
    mutating func update(with success: Bool) {
        if success {
            self.done()
        } else {
            self.failed()
        }
    }
    
    mutating func updateRetry() -> Bool {
        switch self {
        case .initialized:
            self = .retry
            return true
        case .done:
            self = .failed
            return false
        default:
            return false
        }
    }
    mutating func done() { if self == .retry { self = .done } }
    mutating func failed() { if self == .retry { self = .failed } }
}
