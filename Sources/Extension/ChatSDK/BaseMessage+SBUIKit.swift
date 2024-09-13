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
    @available(*, deprecated, message: "`asUiSettingContainerType` has been deprecated since 3.27.2.")
    public var asUiSettingContainerType: SBUMessageContainerType { .`default` }

    /// Function to decode to custom view data using genric type.
    /// - Since: 3.11.0
    public func decodeCustomViewData<ViewData: Decodable>() throws -> ViewData? {
        try self.asExtendedMessagePayload?.decodeCustomViewData()
    }
    
    /// Indicates if the message is a stream (being updated) message.
    /// - Since: 3.26.0
    public var isStreamMessage: Bool {
        StreamData.make(self).stream == true
    }
}

extension BaseMessage {
    func setInMemoryUserInfo<Element>(key: String, data: Element) {
        var memory = self.inMemoryUserInfo ?? [:]
        memory[key] = data
        self.inMemoryUserInfo = memory
    }
    
    func getInMemoryUserInfo<Element>(key: String) -> Element? {
        self.inMemoryUserInfo?[key] as? Element
    }
    
    func getInMemoryUserInfo<Element>(key: String, defaultValue: Element) -> Element {
        self.inMemoryUserInfo?[key] as? Element ?? defaultValue
    }
        
    fileprivate struct StreamData: Codable {
        let stream: Bool?
        
        static func make(_ message: BaseMessage) -> StreamData {
            guard let jsonData = message.data.data(using: .utf8) else { return StreamData(stream: false) }
            return (try? JSONDecoder().decode(StreamData.self, from: jsonData)) ?? StreamData(stream: false)
        }
    }
}

extension BaseMessage {
    /// A value that determines whether to disable the MessageInputView.
    /// Additionally, other properties are checked as well.
    /// - Since: 3.27.0
    @available(*, deprecated, message: "Use `getChatInputDisableState(hasNext:)` in [BaseMessage]") // 3.27.2
    public func getChatInputDisabledState(hasNext: Bool?) -> Bool {
        getChatInputDisableType(hasNext: hasNext) != .none
    }
    
    func getChatInputDisableType(hasNext: Bool?) -> ChatInputDisableType {
        guard let extendedMessagePayload = self.asExtendedMessagePayload else { return .none }
        guard extendedMessagePayload.disableChatInput == true else { return .none }
        
        if hasNext == true { return .none }
        
        if let form = self.messageForm,
           form.isValidVersion == true,
           form.isSubmitted == false,
           SendbirdUI.config.groupChannel.channel.isFormTypeMessageEnabled == true {
            return .component // message form => component
        }
        
        if extendedMessagePayload.suggestedReplies?.hasElements == true,
           SendbirdUI.config.groupChannel.channel.isSuggestedRepliesEnabled == true {
            return .component // suggested replies => component
        }
        
        // normal message => not component
        return .message
    }
    
    enum ChatInputDisableType {
        case component
        case message
        case none
    }

}
