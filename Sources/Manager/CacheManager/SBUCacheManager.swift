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
    
    static internal let fileCacheQueue = DispatchQueue(label: "com.sendbird.cache.file", qos: .background)
    
    // MARK: - SubPath
    struct PathType {
        static let template = "template"
        static let userProfile = "user-profile"
        static let reaction = "reaction"
        static let web = "web"
    }
    
    // MARK: - Common
    static func createHashName(urlString: String) -> String {
        return "\(urlString.persistantHash)"
    }
    
    static func fileExtension(urlString: String) -> String {
        let pathExtension = URL(fileURLWithPath: URLComponents(string: urlString)?.path ?? "").pathExtension
        return pathExtension
    }
    
    // MARK: - DiskCache
    struct DiskCache {
        // MARK: - Properties
        private let fileManager = FileManager.default
        private let cacheType: String
        private let diskQueue = DispatchQueue(label: "\(SBUConstant.bundleIdentifier).queue.diskcache", qos: .background)
        
        // MARK: - Initializers
        init(cacheType: String) {
            self.cacheType = cacheType
            
            do {
                try self.createDirectoryIfNeeded()
            } catch {
                SBULog.error(error.localizedDescription)
            }
        }
        
        func createDirectoryIfNeeded() throws {
            let cachePath = self.cachePathURL().path
            
            if self.fileManager.fileExists(atPath: cachePath) {
                return
            }
            
            try self.fileManager.createDirectory(
                atPath: cachePath,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        
        func cacheExists(key: String) -> Bool {
            return fileManager.fileExists(atPath: self.pathForKey(key))
        }

        func get(fullPath: URL) -> Data? {
            do {
                let data = try Data(contentsOf: fullPath)
                return data
            } catch {
                SBULog.info(error.localizedDescription)
            }
            return nil
        }
        
        func get(key: String) -> NSData? {
            guard cacheExists(key: key) else { return nil }
            
            let filePath = URL(fileURLWithPath: self.pathForKey(key))
            
            do {
                let data = try Data(contentsOf: filePath)
                return data as NSData
            } catch {
                SBULog.info(error.localizedDescription)
            }
            return nil
        }
        
        // FIXME: Seperate image / file handling logic
        func set<T>(key: String, data: NSData, image: UIImage? = nil, completionHandler: T? = nil) {
            diskQueue.async { [weak image] in
                let filePath = URL(fileURLWithPath: self.pathForKey(key))

                do {
                    let subPath = filePath.deletingLastPathComponent()
                    try self.fileManager.createDirectory(
                        atPath: subPath.path,
                        withIntermediateDirectories: true,
                        attributes: nil
                    )
                } catch {
                    SBULog.error(error.localizedDescription)
                    DispatchQueue.main.async {
                        switch completionHandler {
                        case let cacheHandler as SBUCacheCompletionHandler:
                            cacheHandler(nil, nil)
                        case let imageCacheHandler as SBUImageCacheCompletionHandler:
                            imageCacheHandler(nil, nil, image)
                        default:
                            SBULog.error("Invalid cacheHandler type")
                        }
                    }
                    return
                }
                
                data.write(to: filePath, atomically: true)
                DispatchQueue.main.async {
                    switch completionHandler {
                    case let cacheHandler as SBUCacheCompletionHandler:
                        cacheHandler(filePath, data)
                    case let imageCacheHandler as SBUImageCacheCompletionHandler:
                        imageCacheHandler(filePath, data, image)
                    default:
                        SBULog.error("Invalid cacheHandler type")
                    }
                }
            }
        }
        
        func rename(key: String, newKey: String) {
            diskQueue.async {
                let fileManager = self.fileManager
                let atPath = self.pathForKey(key)
                let toPath = self.pathForKey(newKey)
                try? fileManager.moveItem(atPath: atPath, toPath: toPath)
            }
        }
        
        func remove(key: String) {
            diskQueue.async {
                let path = self.pathForKey(key)
                let fileManager = self.fileManager
                
                do {
                    try fileManager.removeItem(atPath: path)
                } catch {
                    SBULog.error("Could not remove file: \(error)")
                }
            }
        }
        
        func removeAll() {
            diskQueue.async {
                let fileManager = self.fileManager
                let cachePath = self.cachePathURL().path
                
                do {
                    try fileManager.removeItem(atPath: cachePath)
                } catch {
                    SBULog.error("Could not remove cache path: \(error)")
                }
            }
        }
        
        func cachePathURL() -> URL {
            guard let cacheDirectoryURL = try? FileManager.default.url(
                for: .cachesDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true) else { return URL(fileURLWithPath: "") }
            
            let cachePathURL = cacheDirectoryURL.appendingPathComponent("\(self.cacheType)/")
            return cachePathURL
        }
        
        func pathForKey(_ key: String) -> String {
            let cachePathURL = cachePathURL()
            let fullPath = cachePathURL.appendingPathComponent(key)
            return fullPath.path
        }
        
        // swiftlint:disable missing_docs
        @available(*, deprecated, renamed: "cacheExists(key:)")
        public func hasImage(key: String) -> Bool {
            self.cacheExists(key: key)
        }
        // swiftlint:enable missing_docs
        
        // Voice
        func voiceTempPath(fileName: String) -> URL? {
            let documentPath = URL(fileURLWithPath: self.pathForKey("voice_temp"))
            
            if !FileManager.default.fileExists(atPath: documentPath.path) {
                do {
                    try FileManager.default.createDirectory(at: documentPath, withIntermediateDirectories: true)
                    return documentPath.appendingPathComponent(fileName)
                } catch {
                    SBULog.error("[Failed] Create directory : \(error.localizedDescription)")
                    return nil
                }
            }
            return documentPath.appendingPathComponent(fileName)
        }
        
        func removeVoiceTemp(fileName: String?) {
            guard let fileName = fileName,
                  let path = self.voiceTempPath(fileName: fileName)?.path else { return }
            
            diskQueue.async {
                let fileManager = self.fileManager
                
                do {
                    try fileManager.removeItem(atPath: path)
                } catch {
                    SBULog.error("Could not remove file: \(error)")
                }
            }
        }
        
        // MARK: - Reset
        func resetCache() {
            self.removeAll()
        }
        
        private func executeCompletion<T>(
            _ image: UIImage? = nil,
            handler: T?
        ) {
            Thread.executeOnMain {
                switch handler {
                case let cacheHandler as SBUCacheCompletionHandler:
                    cacheHandler(nil, nil)
                case let imageCacheHandler as SBUImageCacheCompletionHandler:
                    imageCacheHandler(nil, nil, image)
                default:
                    SBULog.error("Invalid cacheHandler type")
                }
            }
        }
    }
    
    // MARK: - MemoryCache (for Image)
    struct MemoryCache {
        private let memoryQueue = DispatchQueue(label: "\(SBUConstant.bundleIdentifier).queue.memorycache", qos: .background)
        
        // MARK: - Memory Cache
        private var memoryCache: NSCache<NSString, UIImage> = {
            let cache = NSCache<NSString, UIImage>()
            cache.totalCostLimit = 10 * 1024 * 1024 // Here the size in bytes of data is used as the cost, here 10 MB limit
            cache.countLimit = 30 // 30 url limit
            return cache
        }()
        
        func set(key: String, image: UIImage) {
            memoryQueue.async {
                self.memoryCache.setObject(image, forKey: key as NSString)
            }
        }
        
        func set(key: String, data: NSData) {
            memoryQueue.async {
                guard let image = UIImage.createImage(from: data as Data) else { return }
                self.set(key: key, image: image)
            }
        }
        
        func get(key: String) -> UIImage? {
            return self.memoryCache.object(forKey: key as NSString)
        }
        
        func remove(key: String) {
            self.memoryCache.removeObject(forKey: key as NSString)
        }
        
        func cacheExists(key: String) -> Bool {
            return self.memoryCache.object(forKey: key as NSString) != nil
        }
        
        // MARK: - Reset
        func resetCache() {
            self.memoryCache.removeAllObjects()
        }
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
