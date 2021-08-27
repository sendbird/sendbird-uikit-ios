//
//  SBUMessageCache.swift
//  SendBirdUIKit
//
//  Created by Hoon Sung on 2021/02/24.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendBirdSDK

class SBUMessageCache: NSObject {
    
    private let fetchLimit: Int = 100
    private let channel: SBDBaseChannel
    
    @SBUAtomic private(set) var cachedMessageList: [SBDBaseMessage] = []
    private(set) var messageListParam: SBDMessageListParams = SBDMessageListParams()
    private var latestUpdatedAt: Int64 = 0
    
    init(channel: SBDBaseChannel) {
        self.channel = channel
    }
    
    func updateParam(param: SBDMessageListParams) {
        let messageListParam: SBDMessageListParams = param.copy() as? SBDMessageListParams ?? SBDMessageListParams()
        messageListParam.previousResultSize = self.fetchLimit
        messageListParam.nextResultSize = self.fetchLimit
        
        self.messageListParam = messageListParam
    }
    
    // MARK: - Loading messages in cache
    
    func loadInitial() {
        SBULog.info("loadInitial")
        let param: SBDMessageListParams = self.messageListParam.copy() as? SBDMessageListParams ?? SBDMessageListParams()
        param.isInclusive = true
        param.nextResultSize = 0
        
        channel.getMessagesByTimestamp(LLONG_MAX, params: param) { [weak self] (messages, error) in
            guard let self = self else { return }
            
            guard error == nil,
                  let messages = messages else {
                return
            }
            
            self.add(messages: messages)
            self.latestUpdatedAt = messages.first?.createdAt ?? 0
        }
    }
    
    func loadNext() {
        SBULog.info("loadNext from : \(self.latestUpdatedAt)")
        guard self.latestUpdatedAt > 0 else {
            SBULog.warning("lastest updatedAt is 0. loadInitial instead.")
            self.loadInitial()
            return
        }
        
        let params: SBDMessageListParams = self.messageListParam.copy() as? SBDMessageListParams ?? SBDMessageListParams()
        params.previousResultSize = 0
        
        var completion: (([SBDBaseMessage]?, SBDError?) -> Void)!
        completion = { [weak self] (messages, error) in
            guard let self = self else { return }
            
            guard error == nil,
                  let messages = messages else {
                return
            }
            
            SBULog.info("loaded next messages : \(messages), size : \(messages.count)")
            guard !messages.isEmpty else {
                return
            }
            
            self.add(messages: messages)
            let newLatestUpdatedAt = max(messages.first?.createdAt ?? 0, self.latestUpdatedAt)
            
            let latestUpdated = newLatestUpdatedAt > self.latestUpdatedAt
            if latestUpdated {
                SBULog.info("update latestUpdatedAt to : \(newLatestUpdatedAt) from : \(self.latestUpdatedAt)")
                self.latestUpdatedAt = newLatestUpdatedAt
            }
            
            guard messages.count >= self.fetchLimit,
                  latestUpdated else {
                SBULog.info("fetched to the newest. \(self)")
                return
            }
            
            self.channel.getMessagesByTimestamp(self.latestUpdatedAt, params: params, completionHandler: completion)
        }
        
        self.channel.getMessagesByTimestamp(self.latestUpdatedAt, params: params, completionHandler: completion)
    }
    
    // MARK: - Upsert messages
    
    func add(messages: [SBDBaseMessage]) {
        SBULog.info("add : \(messages.count)")
        guard !messages.isEmpty else { return }
        
        self.cachedMessageList.removeAll(where: { messages.contains($0) })
        self.cachedMessageList.append(contentsOf: messages)
        self.cachedMessageList.sort(by: { $0.createdAt > $1.createdAt })
    }
    
    func applyChangeLog(updated: [SBDBaseMessage]?, deleted: [Int64]?) {
        SBULog.info("applyChangeLog. updated : \(String(describing: updated)), deleted : \(String(describing: deleted)) \(self)")
        guard !self.cachedMessageList.isEmpty else { return }
        
        if let updatedMessages = updated?.filter({ self.cachedMessageList.contains($0) }),
           !updatedMessages.isEmpty {
            updatedMessages.forEach({ message in
                if let idx = self.cachedMessageList.firstIndex(of: message) {
                    self.cachedMessageList.remove(at: idx)
                    self.cachedMessageList.insert(message, at: idx)
                }
            })
        }
        if let deletedMessageIds = deleted?.filter({ SBUUtils.contains(messageId: $0, in: self.cachedMessageList) }),
           !deletedMessageIds.isEmpty {
            self.cachedMessageList.removeAll(where: { deletedMessageIds.contains($0.messageId) })
        }
    }
    
    func flush(with messages: [SBDBaseMessage]) -> [SBDBaseMessage] {
        SBULog.info("flushing cache with : \(messages.count)")
        guard !self.cachedMessageList.isEmpty else { return messages }
        
        let mergedList: [SBDBaseMessage] =
            (self.cachedMessageList
                .filter { !SBUUtils.contains(messageId: $0.messageId, in: messages) }
                + messages)
            .sorted(by: { $0.createdAt > $1.createdAt })
        self.cachedMessageList.removeAll()
        
        SBULog.info("flush merged message : \(mergedList.count)")
        
        return mergedList
    }
    
    func clear() {
        self.cachedMessageList.removeAll()
    }
}
