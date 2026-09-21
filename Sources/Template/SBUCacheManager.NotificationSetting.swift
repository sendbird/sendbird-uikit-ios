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
        
        /// Runs `work` on this cache's disk queue (used to keep JSON parsing off the main thread).
        static func performOnDiskQueue(_ work: @escaping () -> Void) {
            self.diskCache.diskQueue.async(execute: work)
        }

        // MARK: - Notification settings
        static func save(settings: SBUNotificationChannelManager.GlobalNotificationSettings) {
            // Both writes go to the same serial `diskQueue`, so the themes land before the
            // theme mode that describes them.
            self.save(themes: settings.themes)
            self.themeMode = settings.themeMode
        }
        
        // MARK: - Theme list
        static func save(themes: [SBUNotificationChannelManager.GlobalNotificationSettings.Theme]) {
            self.memoryCache.set(themes: themes)
            self.diskCache.set(themes: themes)
        }
        
        static func loadAllThemes() -> [String: SBUNotificationChannelManager.GlobalNotificationSettings.Theme]? {
            if let themeList = memoryCache.getAllThemes() {
//                Log.info("Loaded themes from memory cache")
                return themeList
            } else if let themeList = diskCache.getAllThemes() {
//                Log.info("Loaded themes from disk cache")
                self.memoryCache.set(themes: Array(themeList.values))
                return themeList
            }
            
            Log.info("No have themes in cache")
            return nil
        }
        
        /// Non-blocking variant of `loadAllThemesArray()`: disk read + decode run on the disk queue.
        /// `completionHandler` is called on the main thread.
        static func loadAllThemesArray(completionHandler: @escaping ([SBUNotificationChannelManager.GlobalNotificationSettings.Theme]?) -> Void) {
            if let themeList = memoryCache.getAllThemes() {
                Thread.executeOnMain { completionHandler(Array(themeList.values)) }
                return
            }
            diskCache.getAllThemes { themeList in
                Thread.executeOnMain {
                    if let themeList = themeList {
                        self.memoryCache.set(themes: Array(themeList.values))
                        completionHandler(Array(themeList.values))
                    } else {
                        Log.info("No have themes in cache")
                        completionHandler(nil)
                    }
                }
            }
        }
        
        /// Non-blocking read of `lastUpdatedTime`. `completionHandler` is called on the main thread.
        static func loadLastUpdatedTime(completionHandler: @escaping (Int64) -> Void) {
            if let memoryCache = self.memoryCache.lastUpdatedTime {
                Thread.executeOnMain { completionHandler(memoryCache) }
                return
            }
            self.diskCache.loadLastUpdatedTime { value in
                Thread.executeOnMain { completionHandler(value) }
            }
        }
        
        /// Non-blocking read of `themeMode`. `completionHandler` is called on the main thread.
        static func loadThemeMode(completionHandler: @escaping (String) -> Void) {
            if let memoryCache = self.memoryCache.themeMode {
                Thread.executeOnMain { completionHandler(memoryCache) }
                return
            }
            self.diskCache.loadThemeMode { value in
                Thread.executeOnMain {
                    // Keep the restored value in memory so per-cell reads never enter `diskQueue.sync`.
                    self.memoryCache.themeMode = value
                    completionHandler(value)
                }
            }
        }
        
        /// Blocking variant currently used only by tests. The connect flow uses the asynchronous overload.
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
        let diskQueue = DispatchQueue(label: "\(SBUConstant.bundleIdentifier).queue.diskcache.theme")
        
        let lastUpdatedTimeKey = "sbu_global_notification_settings_updated_at"
        let themeModeKey = "sbu_global_notification_settings_theme_mode"
        
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

        /// Reads and decodes one cached file. Must be called on `diskQueue`.
        private func read(fullPath: URL) -> SBUNotificationChannelManager.GlobalNotificationSettings.Theme? {
            do {
                let data = try Data(contentsOf: fullPath)
                return try JSONDecoder().decode(SBUNotificationChannelManager.GlobalNotificationSettings.Theme.self, from: data)
            } catch {
                Log.info(error.localizedDescription)
            }
            return nil
        }
        
        /// Blocking read when `needToSync` is true; otherwise the caller must already be on `diskQueue`.
        func get(fullPath: URL, needToSync: Bool = true) -> SBUNotificationChannelManager.GlobalNotificationSettings.Theme? {
            if needToSync {
                return self.diskQueue.sync {
                    return self.read(fullPath: fullPath)
                }
            } else {
                return self.read(fullPath: fullPath)
            }
        }
        
        func get(key: String) -> SBUNotificationChannelManager.GlobalNotificationSettings.Theme? {
            let filePath = URL(fileURLWithPath: self.pathForKey(key))
            return self.diskQueue.sync {
                // Existence check inside the queue: writes are async, so a pending write is observed.
                guard self.cacheExists(key: key) else { return nil }
                return self.get(fullPath: filePath, needToSync: false)
            }
        }
        
        /// Reads and decodes every cached theme. Must be called on `diskQueue`.
        private func readAllThemes() -> [String: SBUNotificationChannelManager.GlobalNotificationSettings.Theme]? {
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
                Log.info(error.localizedDescription)
            }
            
            return themeList
        }
        
        /// Blocking read. Prefer `getAllThemes(completionHandler:)` on the main thread.
        func getAllThemes() -> [String: SBUNotificationChannelManager.GlobalNotificationSettings.Theme]? {
            return self.diskQueue.sync {
                return self.readAllThemes()
            }
        }
        
        /// Non-blocking read. `completionHandler` is called on `diskQueue`.
        func getAllThemes(completionHandler: @escaping ([String: SBUNotificationChannelManager.GlobalNotificationSettings.Theme]?) -> Void) {
            self.diskQueue.async {
                completionHandler(self.readAllThemes())
            }
        }
        
        func set(themes: [SBUNotificationChannelManager.GlobalNotificationSettings.Theme]) {
            // Encoding runs on `diskQueue` too, so the caller thread does no JSON work.
            diskQueue.async {
                for theme in themes {
                    do {
                        let data = try JSONEncoder().encode(theme)
                        self.write(key: theme.key, data: data as NSData)
                    } catch {
                        Log.error("Failed to save theme to disk cache: \(error)")
                    }
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
        
        func remove(key: String) {
            diskQueue.sync {
                do {
                    let path = self.pathForKey(key)
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
        /// Must be called on `diskQueue`.
        private func readLastUpdatedTime() -> Int64 {
            let cachePathURL = cachePathURL()
            let filePath = cachePathURL.appendingPathComponent(lastUpdatedTimeKey)
            guard let retrievedString = try? String(contentsOf: filePath, encoding: .utf8),
                  let retrievedInt = Int64(retrievedString) else {
                let storedValue = Int64(UserDefaults.standard.integer(forKey: lastUpdatedTimeKey))
                if storedValue != 0 {
                    // for backward
                    UserDefaults.standard.removeObject(forKey: lastUpdatedTimeKey)
                    self.writeLastUpdatedTime(storedValue)
                    return storedValue
                }
                return 0
            }
            return retrievedInt
        }
        
        /// Blocking read. Prefer `loadLastUpdatedTime(completionHandler:)` on the main thread.
        func loadLastUpdatedTime() -> Int64 {
            return self.diskQueue.sync {
                return self.readLastUpdatedTime()
            }
        }
        
        /// Non-blocking read. `completionHandler` is called on `diskQueue`.
        func loadLastUpdatedTime(completionHandler: @escaping (Int64) -> Void) {
            self.diskQueue.async {
                completionHandler(self.readLastUpdatedTime())
            }
        }
        
        /// Writes inline. Must be called on `diskQueue`.
        private func writeLastUpdatedTime(_ value: Int64) {
            do {
                try self.createDirectoryIfNeeded()
                let cachePathURL = cachePathURL()
                let filePath = cachePathURL.appendingPathComponent(lastUpdatedTimeKey)
                let valueString = "\(value)"

                try valueString.write(to: filePath, atomically: true, encoding: .utf8)
            } catch {
                Log.error("Error writing to file: lastUpdatedTimeKey value")
            }
        }

        func saveLastUpdatedTime(_ value: Int64) {
            self.diskQueue.async { self.writeLastUpdatedTime(value) }
        }
        
        // MARK: theme mode
        /// Must be called on `diskQueue`.
        private func readThemeMode() -> String {
            let cachePathURL = cachePathURL()
            let filePath = cachePathURL.appendingPathComponent(themeModeKey)
            guard let retrievedString = try? String(contentsOf: filePath, encoding: .utf8) else {
                if let storedValue = UserDefaults.standard.string(forKey: themeModeKey) {
                    // for backward
                    UserDefaults.standard.removeObject(forKey: themeModeKey)
                    self.writeThemeMode(storedValue)
                    return storedValue
                }
                return "default"
            }
            return retrievedString
        }
        
        /// Blocking read. Prefer `loadThemeMode(completionHandler:)` on the main thread.
        func loadThemeMode() -> String {
            return self.diskQueue.sync {
                return self.readThemeMode()
            }
        }
        
        /// Non-blocking read. `completionHandler` is called on `diskQueue`.
        func loadThemeMode(completionHandler: @escaping (String) -> Void) {
            self.diskQueue.async {
                completionHandler(self.readThemeMode())
            }
        }
        
        /// Writes inline. Must be called on `diskQueue`.
        private func writeThemeMode(_ value: String) {
            do {
                try self.createDirectoryIfNeeded()
                let cachePathURL = cachePathURL()
                let filePath = cachePathURL.appendingPathComponent(themeModeKey)
                try value.write(to: filePath, atomically: true, encoding: .utf8)
            } catch {
                Log.error("Error writing to file: themeModeKey value")
            }
        }

        func saveThemeMode(_ value: String) {
            self.diskQueue.async { self.writeThemeMode(value) }
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
