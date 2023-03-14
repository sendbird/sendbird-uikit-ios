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
            get {
                Int64(UserDefaults.standard.integer(forKey: "sbu_global_notification_settings_updated_at"))
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "sbu_global_notification_settings_updated_at")
            }
        }
        
        // MARK: - TemplateList theme mode
        static var themeMode: String {
            get {
                UserDefaults.standard.string(forKey: "sbu_global_notification_settings_theme_mode") ?? "default"
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "sbu_global_notification_settings__theme_mode")
            }
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
            } else if let themes = loadAllThemes(),
                      let memoryTheme = themes[key] {
                return memoryTheme
            }
            else if let diskTheme = self.diskCache.get(key: key) {
                self.memoryCache.set(themes: [diskTheme])
                return diskTheme
            }
            return nil
        }
        
        static func upsert(theme: SBUNotificationChannelManager.GlobalNotificationSettings.Theme, forKey key: String) {
            self.save(themes: [theme])
        }
    }
}

extension SBUCacheManager {
    struct DiskCacheForNotificationSetting {
        // MARK: - Properties
        private let fileManager = FileManager.default
        private let cacheType: String
        private let diskQueue = DispatchQueue(label: "\(SBUConstant.bundleIdentifier).queue.diskcache.theme", qos: .background)
        
        // MARK: - Initializers
        init(cacheType: String) {
            self.cacheType = cacheType
            
            let cachePath = self.cachePathURL().path
            
            if self.fileManager.fileExists(atPath: cachePath) {
                return
            }
            
            do {
                try self.fileManager.createDirectory(
                    atPath: cachePath,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                SBULog.error(error.localizedDescription)
            }
        }
        
        func cacheExists(key: String) -> Bool {
            return fileManager.fileExists(atPath: self.pathForKey(key))
        }

        func get(fullPath: URL) -> SBUNotificationChannelManager.GlobalNotificationSettings.Theme? {
            do {
                let data = try Data(contentsOf: fullPath)
                let theme = try JSONDecoder().decode(SBUNotificationChannelManager.GlobalNotificationSettings.Theme.self, from: data)
                return theme as SBUNotificationChannelManager.GlobalNotificationSettings.Theme
            } catch {
                SBULog.info(error.localizedDescription)
            }
            return nil
        }
        
        func get(key: String) -> SBUNotificationChannelManager.GlobalNotificationSettings.Theme? {
            guard cacheExists(key: key) else { return nil }
            
            let filePath = URL(fileURLWithPath: self.pathForKey(key))
            return self.get(fullPath: filePath)
        }
        
        func getAllThemes() -> [String: SBUNotificationChannelManager.GlobalNotificationSettings.Theme]? {
            var themeList: [String: SBUNotificationChannelManager.GlobalNotificationSettings.Theme]? = nil
            
            do {
                let items = try fileManager.contentsOfDirectory(at: cachePathURL(), includingPropertiesForKeys: nil)
                if items.count > 0 {
                    themeList = [:]
                }
                for item in items {
                    if let theme = get(fullPath: item) {
                        themeList?[theme.key] = theme
                    }
                }
            } catch {
                SBULog.info(error.localizedDescription)
            }
            
            return themeList
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
            diskQueue.async {
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
    }
    
    // MARK: - MemoryCache
    class MemoryCacheForNotificationSetting {
        var themeList: [String: SBUNotificationChannelManager.GlobalNotificationSettings.Theme]? = nil
        
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
        
        func cacheExists(key: String) -> Bool {
            return self.themeList?[key] != nil
        }
    }
}
