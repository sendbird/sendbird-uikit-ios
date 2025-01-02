//
//  SBUCacheManager.swift
//  SendbirdUIKit
//
//  Created by Harry Kim on 2020/03/06.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import AVFoundation
import SendbirdChatSDK

typealias SBUCacheCompletionHandler = (URL?, NSData?) -> Void
typealias SBUImageCacheCompletionHandler = (URL?, NSData?, UIImage?) -> Void

class SBUCacheManager {
    
    // MARK: - Common
    static func createHashName(urlString: String) -> String {
        return "\(urlString.persistantHash)"
    }
    
    static func fileExtension(urlString: String) -> String {
        let pathExtension = URL(fileURLWithPath: URLComponents(string: urlString)?.path ?? "").pathExtension
        return pathExtension
    }
}

// swiftlint:disable missing_docs
@available(*, deprecated, message: "We can't guarantee the problems that occur with direct access to DiskCache and handling data.")
public struct DiskCache {
    
    // MARK: - Properties
    private let imageDiskCache: SBUCacheManager.DiskCache
    
    // MARK: - Initializers
    public init() {
        self.imageDiskCache = SBUCacheManager.DiskCache(cacheType: "image")
    }
    
    public func hasImage(key: String) -> Bool {
        return self.imageDiskCache.cacheExists(key: key)
    }
    
    public func get(key: String) -> NSData? {
        return self.imageDiskCache.get(key: key)
    }
    
    public func set(key: String, data: NSData) {
        let imageCacheHandler: SBUImageCacheCompletionHandler = { _, _, _ in }
        self.imageDiskCache.set(key: key, data: data, completionHandler: imageCacheHandler)
    }
    
    public func rename(key: String, newKey: String) {
        self.imageDiskCache.rename(key: key, newKey: newKey)
    }
    
    public func remove(key: String) {
        self.imageDiskCache.remove(key: key)
    }
    
    public func removeAll() {
        self.imageDiskCache.removeAll()
    }
}
// swiftlint:enable missing_docs
