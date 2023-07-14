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
    private var pendingMessages: [String: [String: BaseMessage]] = [:]
    /// message requestId : file params
    private var pendingFileInfos: [String: FileMessageCreateParams] = [:]
    
    /// channel url : array of pending
    private var pendingThreadMessages: [String: [String: BaseMessage]] = [:]
    /// message requestId : file params
    private var pendingThreadFileInfos: [String: FileMessageCreateParams] = [:]
    
    public func addFileInfo(requestId: String, params: FileMessageCreateParams?, forMessageThread: Bool = false) {
        guard !requestId.isEmpty, let params = params else { return }
        if forMessageThread {
            self.pendingThreadFileInfos[requestId] = params
        } else {
            self.pendingFileInfos[requestId] = params
        }
    }
    
    public func getFileInfo(requestId: String, forMessageThread: Bool = false) -> FileMessageCreateParams? {
        guard !requestId.isEmpty else { return nil }
        if forMessageThread {
            return self.pendingThreadFileInfos[requestId]
        } else {
            return self.pendingFileInfos[requestId]
        }
    }
    
    func upsertPendingMessage(channelURL: String?, message: BaseMessage?, forMessageThread: Bool = false) {
        guard let channelURL = channelURL,
              let message = message,
              message.isRequestIdValid else { return }
        
        if forMessageThread {
            var pendingDict = self.pendingThreadMessages[channelURL] ?? [:]
            pendingDict[message.requestId] = message
            self.pendingThreadMessages[channelURL] = pendingDict
        } else {
            var pendingDict = self.pendingMessages[channelURL] ?? [:]
            pendingDict[message.requestId] = message
            self.pendingMessages[channelURL] = pendingDict
        }
    }
    
    func getPendingMessages(channelURL: String?, forMessageThread: Bool = false) -> [BaseMessage] {
        guard let channelURL = channelURL else { return [] }
        if forMessageThread {
            let pendingDict = self.pendingThreadMessages[channelURL] ?? [:]
            return pendingDict.map { $1 }.sorted { $0.createdAt < $1.createdAt }
        } else {
            let pendingDict = self.pendingMessages[channelURL] ?? [:]
            return pendingDict.map { $1 }.sorted { $0.createdAt < $1.createdAt }
        }
    }
    
    func removePendingMessage(channelURL: String?, requestId: String, forMessageThread: Bool = false) {
        guard let channelURL = channelURL,
              !requestId.isEmpty,
              var pendingDict = (forMessageThread == true)
                ? self.pendingThreadMessages[channelURL]
                : self.pendingMessages[channelURL] else {
            return
        }
        
        if forMessageThread {
            pendingDict.removeValue(forKey: requestId)
            self.pendingThreadFileInfos.removeValue(forKey: requestId)
            self.pendingThreadMessages[channelURL] = pendingDict
        } else {
            pendingDict.removeValue(forKey: requestId)
            self.pendingFileInfos.removeValue(forKey: requestId)
            self.pendingMessages[channelURL] = pendingDict

        }
    }
    
    func removePendingMessageAllTypes(channelURL: String?, requestId: String) {
        guard let channelURL = channelURL,
                !requestId.isEmpty else {
            return
        }
        
        var pendingDictForThread = self.pendingThreadMessages[channelURL]
        pendingDictForThread?.removeValue(forKey: requestId)
        self.pendingThreadFileInfos.removeValue(forKey: requestId)
        self.pendingThreadMessages[channelURL] = pendingDictForThread

        var pendingDict = self.pendingMessages[channelURL]
        pendingDict?.removeValue(forKey: requestId)
        self.pendingFileInfos.removeValue(forKey: requestId)
        self.pendingMessages[channelURL] = pendingDict
    }
}
