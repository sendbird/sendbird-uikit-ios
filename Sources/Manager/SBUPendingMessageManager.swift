//
//  SBDMessageManager.swift
//  SendBirdUIKit
//
//  Created by Wooyoung Chung on 12/5/20.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendBirdSDK

@objcMembers
public class SBUPendingMessageManager: NSObject {
    public static let shared = SBUPendingMessageManager()
    private override init() {}
    
    /// channel url : array of pending
    private var pendingMessages: [String:[String:SBDBaseMessage]] = [:]
    /// message requestId : file params
    private var pendingFileInfos: [String: SBDFileMessageParams] = [:]
    
    public func addFileInfo(requestId:String?, params: SBDFileMessageParams?) {
        guard let requestId = requestId, let params = params else { return }
        self.pendingFileInfos[requestId] = params
    }
    
    public func getFileInfo(requestId: String?) -> SBDFileMessageParams? {
        guard let requestId = requestId else { return nil }
        return self.pendingFileInfos[requestId]
    }
    
    func upsertPendingMessage(channelUrl: String?, message: SBDBaseMessage?) {
        guard let channelUrl = channelUrl, let message = message else { return }
        guard !message.requestId.isEmpty else { return }
        
        var pendingDict = self.pendingMessages[channelUrl] ?? [:]
        pendingDict[message.requestId] = message
        self.pendingMessages[channelUrl] = pendingDict
    }
    
    func getPendingMessages(channelUrl: String?) -> [SBDBaseMessage] {
        guard let channelUrl = channelUrl else { return [] }
        let pendingDict = self.pendingMessages[channelUrl] ?? [:]
        return pendingDict.map { $1 }.sorted { $0.createdAt < $1.createdAt };
    }
    
    func removePendingMessage(channelUrl: String?, requestId: String?) {
        guard let channelUrl = channelUrl,
              let requestId = requestId,
              var pendingDict = self.pendingMessages[channelUrl] else {
            return
        }
        
        pendingDict.removeValue(forKey: requestId)
        self.pendingFileInfos.removeValue(forKey: requestId)
        self.pendingMessages[channelUrl] = pendingDict
    }
}
