//
//  SBUTypingIndicatorMessageManager.swift
//  SendbirdUIKit
//
//  Created by Celine Moon on 11/13/23.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import SendbirdChatSDK

/// A manager class that manages the typing message for different group channels.
/// - Since: 3.12.0
public class SBUTypingIndicatorMessageManager {
    /// Shared instance of `SBUTypingIndicatorMessageManager` for global usage.
    public static let shared = SBUTypingIndicatorMessageManager()
    
    private init() { }
    
    var typingMessages: [String: SBUTypingIndicatorMessage] = [:]
    
    func getTypingMessage(for channel: BaseChannel?) -> SBUTypingIndicatorMessage? {
        guard let channel = channel else { return nil }
        guard let typingMessage = typingMessages[channel.channelURL] else { return nil }
        
        return typingMessage
    }
}
