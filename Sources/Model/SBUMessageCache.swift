//
//  SBUMessageCache.swift
//  SendbirdUIKit
//
//  Created by Hoon Sung on 2021/02/24.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendbirdChatSDK

class SBUMessageCache {
    
    private let fetchLimit: Int = 100
    private let channel: BaseChannel
    
    @SBUAtomic private(set) var cachedMessageList: [BaseMessage] = []
    /// SBUAtomic 은 읽기 한 번과 쓰기 한 번만 지킨다. 캐시를 읽고 고쳐 다시 쓰는 함수들은 이 잠금 안에서 하나씩 돈다.
    /// 앱이 Chat 콜백 큐를 concurrent 큐로 바꾸면 새 메시지 추가와 변경 로그 적용이 겹칠 수 있다.
    private let mutationLock = NSLock()
    private let messageListParam: MessageListParams
    private var latestUpdatedAt: Int64 = 0
    
    init(channel: BaseChannel,
         messageListParam: MessageListParams) {
        self.channel = channel
        
        self.messageListParam = messageListParam.copy() as? MessageListParams ?? MessageListParams()
        self.messageListParam.previousResultSize = self.fetchLimit
        self.messageListParam.nextResultSize = self.fetchLimit
    }
    
    // MARK: - Loading messages in cache
    
    func loadInitial() {
        Log.info("loadInitial")
        let param: MessageListParams = self.messageListParam.copy() as? MessageListParams ?? MessageListParams()
        param.isInclusive = true
        param.nextResultSize = 0
        
        channel.getMessagesByTimestamp(.max, params: param) { [weak self] (messages, error) in
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
        Log.info("loadNext from : \(self.latestUpdatedAt)")
        guard self.latestUpdatedAt > 0 else {
            Log.warning("lastest updatedAt is 0. loadInitial instead.")
            self.loadInitial()
            return
        }
        
        let params: MessageListParams = self.messageListParam.copy() as? MessageListParams ?? MessageListParams()
        params.previousResultSize = 0
        
        var completion: (([BaseMessage]?, SBError?) -> Void)!
        completion = { [weak self] (messages, error) in
            guard let self = self else { return }
            
            guard error == nil,
                  let messages = messages else {
                return
            }
            
            Log.info("loaded next messages : \(messages), size : \(messages.count)")
            guard !messages.isEmpty else {
                return
            }
            
            self.add(messages: messages)
            let newLatestUpdatedAt = max(messages.first?.createdAt ?? 0, self.latestUpdatedAt)
            
            let latestUpdated = newLatestUpdatedAt > self.latestUpdatedAt
            if latestUpdated {
                Log.info("update latestUpdatedAt to : \(newLatestUpdatedAt) from : \(self.latestUpdatedAt)")
                self.latestUpdatedAt = newLatestUpdatedAt
            }
            
            guard messages.count >= self.fetchLimit,
                  latestUpdated else {
                Log.info("fetched to the newest. \(self)")
                return
            }
            
            self.channel.getMessagesByTimestamp(self.latestUpdatedAt, params: params, completionHandler: completion)
        }
        
        self.channel.getMessagesByTimestamp(self.latestUpdatedAt, params: params, completionHandler: completion)
    }
    
    // MARK: - Upsert messages
    
    func add(messages: [BaseMessage]) {
        Log.info("add : \(messages.count)")
        guard !messages.isEmpty else { return }
        mutationLock.lock()
        defer { mutationLock.unlock() }
        
        var messageList = self.cachedMessageList
        messageList.removeAll(where: { messages.contains($0) })
        messageList.append(contentsOf: messages)
        messageList.sort(by: { $0.createdAt > $1.createdAt })
        self.cachedMessageList = messageList
    }
    
    func applyChangeLog(updated: [BaseMessage]?, deleted: [Int64]?) {
        Log.info("applyChangeLog. updated : \(String(describing: updated)), deleted : \(String(describing: deleted)) \(self)")
        mutationLock.lock()
        defer { mutationLock.unlock() }
        // index 를 찾은 목록과 지우는 목록이 달라지지 않도록 사본 하나에서 고치고 한 번에 쓴다.
        var messageList = self.cachedMessageList
        guard !messageList.isEmpty else { return }
        
        if let updatedMessages = updated?.filter({ messageList.contains($0) }),
           !updatedMessages.isEmpty {
            updatedMessages.forEach({ message in
                if let idx = messageList.firstIndex(of: message) {
                    messageList.remove(at: idx)
                    messageList.insert(message, at: idx)
                }
            })
            self.cachedMessageList = messageList
        }
        if let deletedMessageIds = deleted?.filter({ SBUUtils.contains(messageId: $0, in: messageList) }),
           !deletedMessageIds.isEmpty {
            messageList.removeAll(where: { deletedMessageIds.contains($0.messageId) })
            self.cachedMessageList = messageList
        }
    }
    
    func flush(with messages: [BaseMessage]) -> [BaseMessage] {
        Log.info("flushing cache with : \(messages.count)")
        mutationLock.lock()
        defer { mutationLock.unlock() }
        let cachedMessageList = self.cachedMessageList
        guard !cachedMessageList.isEmpty else { return messages }
        
        let mergedList: [BaseMessage] =
            (cachedMessageList
                .filter { !SBUUtils.contains(messageId: $0.messageId, in: messages) }
                + messages)
            .sorted(by: { $0.createdAt > $1.createdAt })
        self.cachedMessageList.removeAll()
        
        Log.info("flush merged message : \(mergedList.count)")
        
        return mergedList
    }
    
    func clear() {
        mutationLock.lock()
        defer { mutationLock.unlock() }
        self.cachedMessageList.removeAll()
    }
}
