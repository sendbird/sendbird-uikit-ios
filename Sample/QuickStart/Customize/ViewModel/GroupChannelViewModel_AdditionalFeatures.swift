//
//  GroupChannelViewModel_AdditionalFeatures.swift
//  QuickStart
//
//  Created by Celine Moon on 12/5/23.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import SendbirdChatSDK


// MARK: Custom SBUGroupChannelViewModel
class GroupChannelViewModel_AdditionalFeatures: SBUGroupChannelViewModel {
    override func channel(_ channel: BaseChannel, didReceive message: BaseMessage) {
        if let message = message as? UserMessage {
            guard let koTranslatedMessage = message.translations["ko"] else { return }
            print("\(koTranslatedMessage)")
        }
    }
    
    override func messageCollection(_ collection: MessageCollection, context: MessageContext, channel: GroupChannel, addedMessages messages: [BaseMessage]) {
        super.messageCollection(collection, context: context, channel: channel, addedMessages: messages)
        
        for message in messages {
            if let message = message as? UserMessage {
                guard let koTranslatedMessage = message.translations["ko"] else { return }
                print("\(koTranslatedMessage)")
            }
        }
    }
    
    override func messageCollection(_ collection: MessageCollection, context: MessageContext, channel: GroupChannel, updatedMessages messages: [BaseMessage]) {
        super.messageCollection(collection, context: context, channel: channel, updatedMessages: messages)
        
        var translatedMessages = [BaseMessage]()
        
        for message in messages {
            if let message = message as? UserMessage {
                guard let koTranslatedMessage = message.translations["ko"] else { return }
                print("\(koTranslatedMessage)")
            }
        }
    }
}
