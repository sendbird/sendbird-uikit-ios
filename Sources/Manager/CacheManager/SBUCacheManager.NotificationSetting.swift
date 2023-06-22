//
//  SBUCacheManager.NotificationSetting.swift
//  QuickStart
//
//  Created by Tez Park on 2023/02/27.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import UIKit

extension SBUCacheManager {
    class NotificationSetting {
        static let memoryCache = MemoryCacheForNotificationSetting()
        static let diskCache = DiskCacheForNotificationSetting(cacheType: "notificationSetting")
        static let cachePath = diskCache.cachePathURL()
        static let cacheKey = "notificationSetting"
        
        // MARK: - TemplateList updated time
        static var lastUpdatedTime: Int64 {
            get { self.loadLastUpdatedTime() }
            set { self.saveLastUpdatedTime(newValue) }
        }
        
        // MARK: - TemplateList theme mode
        static var themeMode: String {
            get { self.loadThemeMode() }
            set { self.saveThemeMode(newValue) }
        }
        
        // MARK: - Notification settings
        static func save(settings: SBUNotificationChannelManager.GlobalNotificationSettings) {
            self.themeMode = settings.themeMode
            self.save(themes: settings.themes)
        }
        
        // MARK: - Theme list
        static func save(themes: [SBUNotificationChannelManager.GlobalNotificationSettings.Theme]) {
            self.memoryCache.set(themes: themes)
            self.diskCache.set(themes: themes)
        }
        
        static func loadAllThemes() -> [String: SBUNotificationChannelManager.GlobalNotificationSettings.Theme]? {
            if let themeList = memoryCache.getAllThemes() {
//                SBULog.info("Loaded themes from memory cache")
                return themeList
            } else if let themeList = diskCache.getAllThemes() {
//                SBULog.info("Loaded themes from disk cache")
                self.memoryCache.set(themes: Array(themeList.values))
                return themeList
            }
            
            SBULog.info("No have themes in cache")
            return nil
        }
        
        static func loadAllThemesArray() -> [SBUNotificationChannelManager.GlobalNotificationSettings.Theme]? {
            if let themeList = self.loadAllThemes() {
                return Array(themeList.values)
            } else {
                return nil
            }
        }
        
        static func upsert(themes: [SBUNotificationChannelManager.GlobalNotificationSettings.Theme]) {
            self.save(themes: themes)
        }
        
        // MARK: - Single theme
        static func save(theme: SBUNotificationChannelManager.GlobalNotificationSettings.Theme) {
            self.save(themes: [theme])
        }
        
        static func getTheme(forKey key: String) -> SBUNotificationChannelManager.GlobalNotificationSettings.Theme? {
            if let memoryTheme = self.memoryCache.get(key: key) {
                return memoryTheme
            } else if let diskTheme = self.diskCache.get(key: key) {
                self.memoryCache.set(themes: [diskTheme])
                return diskTheme
            }
            return nil
        }
        
        static func removeTheme(forKey key: String) {
            self.memoryCache.remove(key: key)
            self.diskCache.remove(key: key)
        }
        
        // MARK: updated time
        static func loadLastUpdatedTime() -> Int64 {
            if let memoryCache = self.memoryCache.lastUpdatedTime {
                return memoryCache
            } else {
                return self.diskCache.loadLastUpdatedTime()
            }
        }
        
        static func saveLastUpdatedTime(_ value: Int64) {
            self.memoryCache.lastUpdatedTime = value
            self.diskCache.saveLastUpdatedTime(value)
        }
        
        // MARK: theme mode
        static func loadThemeMode() -> String {
            if let memoryCache = self.memoryCache.themeMode {
                return memoryCache
            } else {
                return self.diskCache.loadThemeMode()
            }
        }
        
        static func saveThemeMode(_ value: String) {
            self.memoryCache.themeMode = value
            self.diskCache.saveThemeMode(value)
        }
        
        // MARK: Reset
        static func resetCache() {
            self.diskCache.resetCache()
            self.memoryCache.resetCache()
        }
    }
}

extension SBUCacheManager {
    struct DiskCacheForNotificationSetting {
        // MARK: - Properties
        let fileManager = FileManager.default
        let cacheType: String
        let diskQueue = DispatchQueue(label: "\(SBUConstant.bundleIdentifier).queue.diskcache.theme", qos: .background)
        var fileSemaphore = DispatchSemaphore(value: 1)
        
        let lastUpdatedTimeKey = "sbu_global_notification_settings_updated_at"
        let themeModeKey = "sbu_global_notification_settings_theme_mode"
        
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

        func get(fullPath: URL, needToSync: Bool = true) -> SBUNotificationChannelManager.GlobalNotificationSettings.Theme? {
            let theme: SBUNotificationChannelManager.GlobalNotificationSettings.Theme? = {
                do {
                    let data = try Data(contentsOf: fullPath)
                    let theme = try JSONDecoder().decode(SBUNotificationChannelManager.GlobalNotificationSettings.Theme.self, from: data)
                    return theme as SBUNotificationChannelManager.GlobalNotificationSettings.Theme
                } catch {
                    SBULog.info(error.localizedDescription)
                }
                return nil
            }()
            
            if needToSync {
                return self.diskQueue.sync {
                    self.fileSemaphore.wait()
                    defer { self.fileSemaphore.signal() }
                    
                    return theme
                }
            } else {
                return theme
            }
        }
        
        func get(key: String) -> SBUNotificationChannelManager.GlobalNotificationSettings.Theme? {
            guard cacheExists(key: key) else { return nil }
            
            let filePath = URL(fileURLWithPath: self.pathForKey(key))
            return self.get(fullPath: filePath)
        }
        
        func getAllThemes() -> [String: SBUNotificationChannelManager.GlobalNotificationSettings.Theme]? {
            return self.diskQueue.sync {
                self.fileSemaphore.wait()
                defer { self.fileSemaphore.signal() }
                
                var themeList: [String: SBUNotificationChannelManager.GlobalNotificationSettings.Theme]?
                
                do {
                    let items = try fileManager.contentsOfDirectory(at: cachePathURL(), includingPropertiesForKeys: nil)
                    if items.count > 0 {
                        themeList = [:]
                    }
                    for item in items {
                        if let theme = get(fullPath: item, needToSync: false) {
                            themeList?[theme.key] = theme
                        }
                    }
                } catch {
                    SBULog.info(error.localizedDescription)
                }
                
                return themeList
            }
        }
        
        func set(themes: [SBUNotificationChannelManager.GlobalNotificationSettings.Theme]) {
            for theme in themes {
                let encoder = JSONEncoder()
                do {
                    let data = try encoder.encode(theme)
                    self.set(key: theme.key, data: data as NSData)
                } catch {
                    SBULog.error("Failed to save theme to disk cache: \(error)")
                }
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
        
        func remove(key: String) {
            diskQueue.sync {
                self.fileSemaphore.wait()
                defer { self.fileSemaphore.signal() }
                
                do {
                    let path = self.pathForKey(key)
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
        func loadLastUpdatedTime() -> Int64 {
            return self.diskQueue.sync {
                self.fileSemaphore.wait()
                defer { self.fileSemaphore.signal() }
                
                let cachePathURL = cachePathURL()
                let filePath = cachePathURL.appendingPathComponent(lastUpdatedTimeKey)
                guard let retrievedString = try? String(contentsOf: filePath, encoding: .utf8),
                      let retrievedInt = Int64(retrievedString) else {
                    let storedValue = Int64(UserDefaults.standard.integer(forKey: lastUpdatedTimeKey))
                    if storedValue != 0 {
                        // for backward
                        UserDefaults.standard.removeObject(forKey: lastUpdatedTimeKey)
                        self.saveLastUpdatedTime(storedValue)
                        return storedValue
                    }
                    return 0
                }
                return retrievedInt
            }
        }
        
        func saveLastUpdatedTime(_ value: Int64) {
            diskQueue.sync {
                self.fileSemaphore.wait()
                defer { self.fileSemaphore.signal() }
                
                do {
                    try self.createDirectoryIfNeeded()
                    let cachePathURL = cachePathURL()
                    let filePath = cachePathURL.appendingPathComponent(lastUpdatedTimeKey)
                    let valueString = "\(value)"
                    
                    try valueString.write(to: filePath, atomically: true, encoding: .utf8)
                } catch {
                    SBULog.error("Error writing to file: lastUpdatedTimeKey value")
                }
            }
        }
        
        // MARK: theme mode
        func loadThemeMode() -> String {
            return self.diskQueue.sync {
                self.fileSemaphore.wait()
                defer { self.fileSemaphore.signal() }
                
                let cachePathURL = cachePathURL()
                let filePath = cachePathURL.appendingPathComponent(themeModeKey)
                guard let retrievedString = try? String(contentsOf: filePath, encoding: .utf8) else {
                    if let storedValue = UserDefaults.standard.string(forKey: themeModeKey) {
                        // for backward
                        UserDefaults.standard.removeObject(forKey: themeModeKey)
                        self.saveThemeMode(storedValue)
                        return storedValue
                    }
                    return "default"
                }
                return retrievedString
            }
        }
        
        func saveThemeMode(_ value: String) {
            diskQueue.sync {
                self.fileSemaphore.wait()
                defer { self.fileSemaphore.signal() }
                
                do {
                    try self.createDirectoryIfNeeded()
                    let cachePathURL = cachePathURL()
                    let filePath = cachePathURL.appendingPathComponent(themeModeKey)
                    try value.write(to: filePath, atomically: true, encoding: .utf8)
                } catch {
                    SBULog.error("Error writing to file: themeModeKey value")
                }
            }
        }
        
        // MARK: Reset
        func resetCache() {
            self.removePath()
        }
    }
    
    // MARK: - MemoryCache
    class MemoryCacheForNotificationSetting {
        var lastUpdatedTime: Int64?
        var themeMode: String?
        var themeList: [String: SBUNotificationChannelManager.GlobalNotificationSettings.Theme]?
        
        // MARK: - Memory Cache
        func set(themes: [SBUNotificationChannelManager.GlobalNotificationSettings.Theme]) {
            for theme in themes {
                set(key: theme.key, theme: theme)
            }
        }
        
        func set(key: String, theme: SBUNotificationChannelManager.GlobalNotificationSettings.Theme) {
            if self.themeList == nil { self.themeList = [:] }
            self.themeList?[key] = theme
        }
        
        func get(key: String) -> SBUNotificationChannelManager.GlobalNotificationSettings.Theme? {
            guard let theme = self.themeList?[key] else { return nil }
            return theme as SBUNotificationChannelManager.GlobalNotificationSettings.Theme
        }
        
        func getAllThemes() -> [String: SBUNotificationChannelManager.GlobalNotificationSettings.Theme]? {
            return themeList
        }
        
        func remove(key: String) {
            self.themeList?.removeValue(forKey: key)
        }
        
        // MARK: Reset
        func resetCache() {
            self.lastUpdatedTime = nil
            self.themeMode = nil
            self.themeList = nil
        }
    }
}
