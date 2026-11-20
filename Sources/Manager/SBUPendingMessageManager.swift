//
//  MessageManager.swift
//  SendbirdUIKit
//
//  Created by Wooyoung Chung on 12/5/20.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendbirdChatSDK

/// `SBUPendingMessageManager` class.
///
/// This class is responsible for managing pending messages in the application.
public class SBUPendingMessageManager {
    /// `SBUPendingMessageManager` shared instance.
    public static let shared = SBUPendingMessageManager()
    
    private init() { }
    
    // 전송(main)과 전송 completion(Chat 콜백 큐)이 같은 딕셔너리를 고치므로 lock 안에서만 읽고 쓴다.
    private let lock = NSLock()
    
    // 테스트가 저장소를 고치는 도중에 멈춰 세워, 다른 thread의 접근이 끼어드는지 보는 지점이다. 배포 코드에서는 nil이다.
    var accessHookForTesting: (() -> Void)?
    
    // 다른 thread가 lock을 쥐고 있어 기다리기 직전에 불린다. 테스트가 시간 대신 이 지점으로 경합을 확인한다. 배포 코드에서는 nil이다.
    var lockWaitHookForTesting: (() -> Void)?
    
    private func lockStore() {
        if self.lock.try() { return }
        self.lockWaitHookForTesting?()
        self.lock.lock()
    }
    
    /// channel url : array of pending
    private var pendingMessages: [String: [String: BaseMessage]] = [:]
    /// message requestId : file params
    private var pendingFileInfos: [String: FileMessageCreateParams] = [:]
    
    /// channel url : array of pending
    private var pendingThreadMessages: [String: [String: BaseMessage]] = [:]
    /// message requestId : file params
    private var pendingThreadFileInfos: [String: FileMessageCreateParams] = [:]
    
    /// Adds a `FileMessageCreateParams` to the pending file info list.
    ///
    /// - Parameters:
    ///   - requestId: The unique identifier for the request. This is used to associate the `FileMessageCreateParams` with a specific request.
    ///   - params: The `FileMessageCreateParams` to be added. This contains the parameters for creating a file message.
    ///   - forMessageThread: A Boolean value that determines whether to add the `FileMessageCreateParams` to the thread messages list or the regular messages list.
    public func addFileInfo(requestId: String, params: FileMessageCreateParams?, forMessageThread: Bool = false) {
        guard !requestId.isEmpty, let params = params else { return }
        self.lockStore()
        defer { self.lock.unlock() }
        self.accessHookForTesting?()
        if forMessageThread {
            self.pendingThreadFileInfos[requestId] = params
        } else {
            self.pendingFileInfos[requestId] = params
        }
    }
    
    /// Retrieves the `FileMessageCreateParams` for a given request ID.
    /// 
    /// - Parameters:
    ///   - requestId: The unique identifier for the request.
    ///   - forMessageThread: A Boolean value that determines whether to fetch from thread messages or regular messages.
    /// - Returns: The `FileMessageCreateParams` associated with the request ID, or nil if no such parameters exist.
    public func getFileInfo(requestId: String, forMessageThread: Bool = false) -> FileMessageCreateParams? {
        guard !requestId.isEmpty else { return nil }
        self.lockStore()
        defer { self.lock.unlock() }
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
        
        self.lockStore()
        defer { self.lock.unlock() }
        if forMessageThread {
            var pendingDict = self.pendingThreadMessages[channelURL] ?? [:]
            self.accessHookForTesting?()
            pendingDict[message.requestId] = message
            self.pendingThreadMessages[channelURL] = pendingDict
        } else {
            var pendingDict = self.pendingMessages[channelURL] ?? [:]
            self.accessHookForTesting?()
            pendingDict[message.requestId] = message
            self.pendingMessages[channelURL] = pendingDict
        }
    }
    
    func getPendingMessages(channelURL: String?, forMessageThread: Bool = false) -> [BaseMessage] {
        guard let channelURL = channelURL else { return [] }
        self.lockStore()
        defer { self.lock.unlock() }
        if forMessageThread {
            let pendingDict = self.pendingThreadMessages[channelURL] ?? [:]
            return pendingDict.map { $1 }.sorted { $0.createdAt < $1.createdAt }
        } else {
            let pendingDict = self.pendingMessages[channelURL] ?? [:]
            return pendingDict.map { $1 }.sorted { $0.createdAt < $1.createdAt }
        }
    }
    
    func removePendingMessage(channelURL: String?, requestId: String, forMessageThread: Bool = false) {
        self.lockStore()
        defer { self.lock.unlock() }
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
        
        self.lockStore()
        defer { self.lock.unlock() }
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
