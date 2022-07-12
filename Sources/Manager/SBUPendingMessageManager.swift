//
//  MessageManager.swift
//  SendbirdUIKit
//
//  Created by Wooyoung Chung on 12/5/20.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendbirdChatSDK


public class SBUPendingMessageManager {
    public static let shared = SBUPendingMessageManager()
    
    private init() { }
    
    /// channel url : array of pending
    private var pendingMessages: [String:[String:BaseMessage]] = [:]
    /// message requestId : file params
    private var pendingFileInfos: [String: FileMessageCreateParams] = [:]
    
    public func addFileInfo(requestId:String?, params: FileMessageCreateParams?) {
        guard let requestId = requestId, let params = params else { return }
        self.pendingFileInfos[requestId] = params
    }
    
    public func getFileInfo(requestId: String?) -> FileMessageCreateParams? {
        guard let requestId = requestId else { return nil }
        return self.pendingFileInfos[requestId]
    }
    
    func upsertPendingMessage(channelURL: String?, message: BaseMessage?) {
        guard let channelURL = channelURL, let message = message else { return }
        guard !message.requestId.isEmpty else { return }
        
        var pendingDict = self.pendingMessages[channelURL] ?? [:]
        pendingDict[message.requestId] = message
        self.pendingMessages[channelURL] = pendingDict
    }
    
    func getPendingMessages(channelURL: String?) -> [BaseMessage] {
        guard let channelURL = channelURL else { return [] }
        let pendingDict = self.pendingMessages[channelURL] ?? [:]
        return pendingDict.map { $1 }.sorted { $0.createdAt < $1.createdAt };
    }
    
    func removePendingMessage(channelURL: String?, requestId: String?) {
        guard let channelURL = channelURL,
              let requestId = requestId,
              var pendingDict = self.pendingMessages[channelURL] else {
            return
        }
        
        pendingDict.removeValue(forKey: requestId)
        self.pendingFileInfos.removeValue(forKey: requestId)
        self.pendingMessages[channelURL] = pendingDict
    }
}
