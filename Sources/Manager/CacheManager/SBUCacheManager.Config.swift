//
//  SBUCacheManager.Config.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2023/06/02.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit

extension SBUCacheManager {
    class Config {
        static let cacheKey = "SBUConfig"
        static let memoryCache = MemoryCacheForConfig()
        static let diskCache = DiskCacheForConfig(cacheType: cacheKey)
        static let cachePath = diskCache.cachePathURL()
        
        // MARK: - Dashboard config updated time
        static var lastUpdatedAt: Int64 {
            get { self.loadLastUpdatedAt() }
            set { self.saveLastUpdatedAt(newValue) }
        }
        
        // MARK: updated time
        static func loadLastUpdatedAt() -> Int64 {
            if let memoryCache = self.memoryCache.lastUpdatedAt {
                return memoryCache
            } else {
                return self.diskCache.loadLastUpdatedAt()
            }
        }
        
        static func saveLastUpdatedAt(_ value: Int64) {
            self.memoryCache.lastUpdatedAt = value
            self.diskCache.saveLastUpdatedAt(value)
        }
        
        static func removeConfig() {
            self.memoryCache.removeConfig()
            self.diskCache.removeConfig()
        }
        
        // MARK: - Config
        static func save(config: SBUConfig) {
            self.memoryCache.set(config: config)
            self.diskCache.set(config: config)
        }
        
        /// Blocking variant currently used only by tests. The connect flow uses the asynchronous overload.
        static func getConfig() -> SBUConfig? {
            if let memoryConfig = self.memoryCache.getConfig() {
                return memoryConfig
            } else if let diskConfig = self.diskCache.getConfig() {
                self.memoryCache.set(config: diskConfig)
                return diskConfig
            }
            return nil
        }
        
        /// Runs `work` on this cache's disk queue (used to keep JSON parsing off the main thread).
        static func performOnDiskQueue(_ work: @escaping () -> Void) {
            self.diskCache.diskQueue.async(execute: work)
        }

        /// Reads the cached config without blocking the calling thread.
        /// The disk read and `SBUConfig` decode run on the disk queue; `completionHandler` is called on the main thread.
        static func getConfig(completionHandler: @escaping (SBUConfig?) -> Void) {
            if let memoryConfig = self.memoryCache.getConfig() {
                Thread.executeOnMain { completionHandler(memoryConfig) }
                return
            }
            self.diskCache.getConfig { diskConfig in
                Thread.executeOnMain {
                    if let diskConfig = diskConfig {
                        self.memoryCache.set(config: diskConfig)
                    }
                    completionHandler(diskConfig)
                }
            }
        }
        
        /// Reads `lastUpdatedAt` without blocking the calling thread. `completionHandler` is called on the main thread.
        static func loadLastUpdatedAt(completionHandler: @escaping (Int64) -> Void) {
            if let memoryCache = self.memoryCache.lastUpdatedAt {
                Thread.executeOnMain { completionHandler(memoryCache) }
                return
            }
            self.diskCache.loadLastUpdatedAt { value in
                Thread.executeOnMain { completionHandler(value) }
            }
        }
        
        static func removeLastUpdatedAt() {
            self.memoryCache.removeLastUpdatedAt()
            self.diskCache.removeLastUpdatedAt()
        }
        
        // MARK: - Reset
        static func resetCache() {
            self.memoryCache.resetCache()
            self.diskCache.resetCache()
        }
    }
}

extension SBUCacheManager {
    struct DiskCacheForConfig {
        // MARK: - Properties
        let fileManager = FileManager.default
        let cacheType: String
        let diskQueue = DispatchQueue(label: "\(SBUConstant.bundleIdentifier).queue.diskcache.config")
        
        let lastUpdatedAtKey = "sbu_config_updated_at"
        let configKey = "sbu_config_config"
        
        // MARK: - Initializers
        init(cacheType: String) {
            self.cacheType = cacheType
            
            do {
                try self.createDirectoryIfNeeded()
            } catch {
                Log.error(error.localizedDescription)
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
        
        func hasConfigCache() -> Bool {
            return self.cacheExists(key: configKey)
        }

        /// Reads and decodes the config file. Must be called on `diskQueue`.
        private func readConfig(fullPath: URL) -> SBUConfig? {
            do {
                let data = try Data(contentsOf: fullPath)
                let config = try JSONDecoder().decode(SBUConfig.self, from: data)
                return config as SBUConfig
            } catch {
                Log.info(error.localizedDescription)
            }
            return nil
        }
        
        /// Blocking read. Prefer `getConfig(completionHandler:)` on the main thread.
        func get(fullPath: URL, needToSync: Bool = true) -> SBUConfig? {
            if needToSync {
                return self.diskQueue.sync {
                    return self.readConfig(fullPath: fullPath)
                }
            } else {
                return self.readConfig(fullPath: fullPath)
            }
        }
        
        func getConfig() -> SBUConfig? {
            let filePath = URL(fileURLWithPath: self.pathForKey(configKey))
            return self.diskQueue.sync {
                // Existence check inside the queue: writes are async, so a pending write is observed.
                guard self.cacheExists(key: self.configKey) else { return nil }
                return self.readConfig(fullPath: filePath)
            }
        }
        
        /// Non-blocking read: file read + `SBUConfig` decode run on `diskQueue`.
        /// `completionHandler` is called on `diskQueue`.
        func getConfig(completionHandler: @escaping (SBUConfig?) -> Void) {
            let filePath = URL(fileURLWithPath: self.pathForKey(configKey))
            self.diskQueue.async {
                guard self.cacheExists(key: self.configKey) else {
                    completionHandler(nil)
                    return
                }
                completionHandler(self.readConfig(fullPath: filePath))
            }
        }
        
        func set(config: SBUConfig) {
            // Encoding runs on `diskQueue` too, so the caller thread does no JSON work.
            diskQueue.async {
                do {
                    let data = try JSONEncoder().encode(config)
                    self.write(key: self.configKey, data: data as NSData)
                } catch {
                    Log.error("Failed to save config to disk cache: \(error)")
                }
            }
        }
        
        func set(key: String, data: NSData, completionHandler: SBUCacheCompletionHandler? = nil) {
            // async: the caller (connect flow on the main thread) must not wait for the file write.
            diskQueue.async {
                self.write(key: key, data: data, completionHandler: completionHandler)
            }
        }
        
        /// Writes one file. Must be called on `diskQueue`. `completionHandler` is called on the main thread.
        private func write(key: String, data: NSData, completionHandler: SBUCacheCompletionHandler? = nil) {
            let filePath = URL(fileURLWithPath: self.pathForKey(key))
            
            do {
                let subPath = filePath.deletingLastPathComponent()
                try self.fileManager.createDirectory(
                    atPath: subPath.path,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                Log.error(error.localizedDescription)
                Thread.executeOnMain {
                    completionHandler?(nil, nil)
                }
                return
            }
            
            data.write(to: filePath, atomically: true)
            Thread.executeOnMain {
                completionHandler?(filePath, data)
            }
        }
        
        func removeLastUpdatedAt() {
            diskQueue.sync {
                do {
                    let path = self.pathForKey(lastUpdatedAtKey)
                    let fileManager = self.fileManager
                    try fileManager.removeItem(atPath: path)
                } catch {
                    Log.error("Could not remove file: \(error)")
                }
            }
        }
        
        func removeConfig() {
            diskQueue.sync {
                do {
                    let path = self.pathForKey(configKey)
                    let fileManager = self.fileManager
                    try fileManager.removeItem(atPath: path)
                } catch {
                    Log.error("Could not remove file: \(error)")
                }
            }
        }
        
        func removePath() {
            diskQueue.sync {
                do {
                    let path = self.cachePathURL()
                    let fileManager = self.fileManager
                    try fileManager.removeItem(at: path)
                } catch {
                    Log.error("Could not remove path: \(error)")
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
        
        // MARK: updated time
        /// Reads the cached value. Must be called on `diskQueue`.
        private func readLastUpdatedAt() -> Int64 {
            let cachePathURL = cachePathURL()
            let filePath = cachePathURL.appendingPathComponent(lastUpdatedAtKey)
            let retrievedString: String
            do {
                retrievedString = try String(contentsOf: filePath, encoding: .utf8)
            } catch {
                Log.info("No last update time value file cached in the file path: \(filePath)")
                return 0
            }
            
            guard let retrievedInt = Int64(retrievedString) else {
                let storedValue = Int64(UserDefaults.standard.integer(forKey: lastUpdatedAtKey))
                if storedValue != 0 {
                    // Already on `diskQueue`: write inline.
                    // Finish migration before subsequent disk operations can observe the cache.
                    self.writeLastUpdatedAt(storedValue)
                    return storedValue
                }
                Log.info("No last update time value cached")
                return 0
            }
            return retrievedInt
        }
        
        /// Writes the value. Must be called on `diskQueue`.
        private func writeLastUpdatedAt(_ value: Int64) {
            do {
                try self.createDirectoryIfNeeded()
                let cachePathURL = cachePathURL()
                let filePath = cachePathURL.appendingPathComponent(lastUpdatedAtKey)
                let valueString = "\(value)"
                try valueString.write(to: filePath, atomically: true, encoding: .utf8)
            } catch {
                Log.error("Error writing to file: lastUpdatedAtKey value")
            }
        }
        
        /// Blocking read. Prefer `loadLastUpdatedAt(completionHandler:)` on the main thread.
        func loadLastUpdatedAt() -> Int64 {
            return self.diskQueue.sync {
                return self.readLastUpdatedAt()
            }
        }
        
        /// Non-blocking read. `completionHandler` is called on `diskQueue`.
        func loadLastUpdatedAt(completionHandler: @escaping (Int64) -> Void) {
            self.diskQueue.async {
                completionHandler(self.readLastUpdatedAt())
            }
        }
        
        func saveLastUpdatedAt(_ value: Int64) {
            diskQueue.async {
                self.writeLastUpdatedAt(value)
            }
        }
        
        // MARK: - Reset
        func resetCache() {
            self.removePath()
        }
    }
    
    // MARK: - MemoryCache
    class MemoryCacheForConfig {
        var lastUpdatedAt: Int64?
        var config: SBUConfig?
        
        // MARK: - Memory Cache
        func set(config: SBUConfig) {
            self.config = config
        }
        
        func getConfig() -> SBUConfig? {
            return config
        }
        
        func removeLastUpdatedAt() {
            self.lastUpdatedAt = nil
        }
        
        func removeConfig() {
            self.config = nil
        }
        
        // MARK: - Reset
        func resetCache() {
            self.lastUpdatedAt = nil
            self.config = nil
        }
    }
}
