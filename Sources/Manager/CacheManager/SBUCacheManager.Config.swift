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
        
        static func getConfig() -> SBUConfig? {
            if let memoryConfig = self.memoryCache.getConfig() {
                return memoryConfig
            } else if let diskConfig = self.diskCache.getConfig() {
                self.memoryCache.set(config: diskConfig)
                return diskConfig
            }
            return nil
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
        let diskQueue = DispatchQueue(label: "\(SBUConstant.bundleIdentifier).queue.diskcache.config", qos: .background)
        var fileSemaphore = DispatchSemaphore(value: 1)
        
        let lastUpdatedAtKey = "sbu_config_updated_at"
        let configKey = "sbu_config_config"
        
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
        
        func hasConfigCache() -> Bool {
            return self.cacheExists(key: configKey)
        }

        func get(fullPath: URL, needToSync: Bool = true) -> SBUConfig? {
            let config: SBUConfig? = {
                do {
                    let data = try Data(contentsOf: fullPath)
                    let config = try JSONDecoder().decode(SBUConfig.self, from: data)
                    return config as SBUConfig
                } catch {
                    SBULog.info(error.localizedDescription)
                }
                return nil
            }()
            
            if needToSync {
                return self.diskQueue.sync {
                    self.fileSemaphore.wait()
                    defer { self.fileSemaphore.signal() }
                    
                    return config
                }
            } else {
                return config
            }
        }
        
        func getConfig() -> SBUConfig? {
            guard cacheExists(key: configKey) else { return nil }
            
            let filePath = URL(fileURLWithPath: self.pathForKey(configKey))
            return self.get(fullPath: filePath)
        }
        
        func set(config: SBUConfig) {
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(config)
                self.set(key: configKey, data: data as NSData)
            } catch {
                SBULog.error("Failed to save config to disk cache: \(error)")
            }
        }
        
        func set(key: String, data: NSData, completionHandler: SBUCacheCompletionHandler? = nil) {
            diskQueue.sync {
                self.fileSemaphore.wait()
                defer { self.fileSemaphore.signal() }
                
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
                        completionHandler?(nil, nil)
                    }
                    return
                }
                
                data.write(to: filePath, atomically: true)
                DispatchQueue.main.async {
                    completionHandler?(filePath, data)
                }
            }
        }
        
        func removeLastUpdatedAt() {
            diskQueue.sync {
                self.fileSemaphore.wait()
                defer { self.fileSemaphore.signal() }
                
                do {
                    let path = self.pathForKey(lastUpdatedAtKey)
                    let fileManager = self.fileManager
                    try fileManager.removeItem(atPath: path)
                } catch {
                    SBULog.error("Could not remove file: \(error)")
                }
            }
        }
        
        func removeConfig() {
            diskQueue.sync {
                self.fileSemaphore.wait()
                defer { self.fileSemaphore.signal() }
                
                do {
                    let path = self.pathForKey(configKey)
                    let fileManager = self.fileManager
                    try fileManager.removeItem(atPath: path)
                } catch {
                    SBULog.error("Could not remove file: \(error)")
                }
            }
        }
        
        func removePath() {
            diskQueue.sync {
                self.fileSemaphore.wait()
                defer { self.fileSemaphore.signal() }
                
                do {
                    let path = self.cachePathURL()
                    let fileManager = self.fileManager
                    try fileManager.removeItem(at: path)
                } catch {
                    SBULog.error("Could not remove path: \(error)")
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
        func loadLastUpdatedAt() -> Int64 {
            return self.diskQueue.sync {
                self.fileSemaphore.wait()
                defer { self.fileSemaphore.signal() }
                
                let cachePathURL = cachePathURL()
                let filePath = cachePathURL.appendingPathComponent(lastUpdatedAtKey)
                let retrievedString: String
                do {
                    retrievedString = try String(contentsOf: filePath, encoding: .utf8)
                } catch {
                    SBULog.info("No last update time value file cached in the file path: \(filePath)")
                    return 0
                }
                
                guard let retrievedInt = Int64(retrievedString) else {
                    let storedValue = Int64(UserDefaults.standard.integer(forKey: lastUpdatedAtKey))
                    if storedValue != 0 {
                        self.saveLastUpdatedAt(storedValue)
                        return storedValue
                    }
                    SBULog.info("No last update time value cached")
                    return 0
                }
                return retrievedInt
            }
        }
        
        func saveLastUpdatedAt(_ value: Int64) {
            diskQueue.sync {
                self.fileSemaphore.wait()
                defer { self.fileSemaphore.signal() }
                
                do {
                    try self.createDirectoryIfNeeded()
                    let cachePathURL = cachePathURL()
                    let filePath = cachePathURL.appendingPathComponent(lastUpdatedAtKey)
                    let valueString = "\(value)"
                    try valueString.write(to: filePath, atomically: true, encoding: .utf8)
                } catch {
                    SBULog.error("Error writing to file: lastUpdatedAtKey value")
                }
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
