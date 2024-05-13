//
//  BaseMessage+SBUIKit.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2023/06/27.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendbirdChatSDK

extension BaseMessage {
    /// Gets the key value to be used in the cache
    /// - Since: 3.6.2
    var cacheKey: String {
        self.isRequestIdValid ? self.requestId : "\(self.messageId)"
    }
    
    /// Validates request id
    /// - Returns: `true` is valid value
    /// - Since: 3.6.2
    var isRequestIdValid: Bool {
        !self.requestId.isEmpty
    }
    
    /// Validates message id
    /// - Returns: `true` is valid value
    /// - Since: 3.6.2
    var isMessageIdValid: Bool {
        self.messageId > 0
    }
}

extension BaseMessage {
    /// Convert to ExtendedMessage model.
    var asExtendedMessagePayload: SBUExtendedMessagePayload? {
        self.extendedMessagePayload.toExtendedMessage
    }
    /// json string data.
    /// - Since: 3.11.0
    public var asCustomView: Any? { self.asExtendedMessagePayload?.customView }
    
    /// message template string data.
    /// - Since: 3.21.0
    public var asMessageTemplate: [String: Any]? { self.asExtendedMessagePayload?.template }
    
    /// Indicates if message template data exists
    /// - Since: 3.21.0
    public var hasMessageTemplate: Bool { self.asMessageTemplate?.hasElements ?? false }
    
    /// container type of message template
    /// - Since: 3.21.0
    public var asUiSettingContainerType: SBUMessageContainerType {
        if self.hasMessageTemplateCompositeType == true { return .full }
        
        switch self.asExtendedMessagePayload?.uiSettings?.containerType {
        case .wide: return .wide
        case .full: return self.hasMessageTemplate ? .full : .`default`
        default: return .`default`
        }
    }

    /// Function to decode to custom view data using genric type.
    /// - Since: 3.11.0
    public func decodeCustomViewData<ViewData: Decodable>() throws -> ViewData? {
        try self.asExtendedMessagePayload?.decodeCustomViewData()
    }
}
