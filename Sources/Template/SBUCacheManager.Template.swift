//
//  SBUCacheManager.Template.swift
//  QuickStart
//
//  Created by Tez Park on 2023/02/26.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import UIKit
#if canImport(SendbirdUIMessageTemplate)
import SendbirdUIMessageTemplate
#endif

extension SBUCacheManager {
    static func template(with type: SBUMessageTemplate.TemplateType) -> SBUTemplateCacheType {
        switch type {
        case .notification: return NotificationMessageTemplate.shared
        case .message: return GroupMessageTemplate.shared
        }
    }
    
    class NotificationMessageTemplate: SBUTemplateCacheType {
        static let shared = NotificationMessageTemplate()
        static let type = SBUMessageTemplate.TemplateType.notification
        static let memoryCache = MemoryCacheForTemplate()
        static let diskCache = DiskCacheForTemplate(cacheType: type.cacheKey)
    }
    
    class GroupMessageTemplate: SBUTemplateCacheType {
        static let shared = GroupMessageTemplate()
        static let type = SBUMessageTemplate.TemplateType.message
        static let memoryCache = MemoryCacheForTemplate()
        static let diskCache = DiskCacheForTemplate(cacheType: type.cacheKey)
    }
}

protocol SBUTemplateCacheType: AnyObject {
    static var type: SBUMessageTemplate.TemplateType { get }
    static var memoryCache: SBUCacheManager.MemoryCacheForTemplate { get }
    static var diskCache: SBUCacheManager.DiskCacheForTemplate { get }
}

extension SBUTemplateCacheType {
    
    // MARK: - TemplateList token (updated time)
    var lastToken: String {
        get { self.loadLastTokenKey() }
        set { self.saveLastTokenKey(newValue) }
    }
    
    // MARK: - Template list
    func save(templates: [MessageTemplate]) {
        Self.memoryCache.set(templates: templates)
        Self.diskCache.set(templates: templates)
    }
    
    /// Runs `work` on this cache's disk queue (used to keep JSON parsing off the main thread).
    func performOnDiskQueue(_ work: @escaping () -> Void) {
        Self.diskCache.diskQueue.async(execute: work)
    }
    
    /// Non-blocking read of the cached token. `completionHandler` is called on the main thread.
    func loadLastToken(completionHandler: @escaping (String) -> Void) {
        if let memoryCache = Self.memoryCache.lastToken {
            Thread.executeOnMain { completionHandler(memoryCache) }
            return
        }
        Self.diskCache.loadLastTokenKey { token in
            Thread.executeOnMain { completionHandler(token) }
        }
    }
    
    /// Non-blocking variant of `loadAllTemplates()`: disk read + decode run on the disk queue.
    /// `completionHandler` is called on the main thread.
    func loadAllTemplates(completionHandler: @escaping ([String: MessageTemplate]?) -> Void) {
        if let templateList = Self.memoryCache.getAllTemplates() {
            Thread.executeOnMain { completionHandler(templateList) }
            return
        }
        Self.diskCache.getAllTemplates { templateList in
            Thread.executeOnMain {
                if let templateList = templateList {
                    Self.memoryCache.set(templates: Array(templateList.values))
                } else {
                    Log.info("No have templates in cache")
                }
                completionHandler(templateList)
            }
        }
    }
    
    @discardableResult
    func loadAllTemplates() -> [String: MessageTemplate]? {
        if let templateList = Self.memoryCache.getAllTemplates() {
//                Log.info("Loaded templates from memory cache")
            return templateList
        } else if let templateList = Self.diskCache.getAllTemplates() {
//                Log.info("Loaded templates from disk cache")
            Self.memoryCache.set(templates: Array(templateList.values))
            return templateList
        }
        
        Log.info("No have templates in cache")
        return nil
    }
    
    func upsert(templates: [MessageTemplate]) {
        self.save(templates: templates)
    }
    
    // MARK: - Single template
    /// Rendering must not wait for disk I/O. Missing templates are loaded by the view model.
    func getMemoryTemplate(forKey key: String) -> MessageTemplate? {
        return Self.memoryCache.get(key: key)
    }

    /// Restores requested templates without blocking the main thread. Completes on main.
    func loadTemplates(forKeys keys: [String], completionHandler: @escaping () -> Void) {
        Thread.executeOnMain {
            let missingKeys = keys.filter { Self.memoryCache.get(key: $0) == nil }
            guard !missingKeys.isEmpty else {
                completionHandler()
                return
            }
            Self.diskCache.getTemplates(forKeys: missingKeys) { templates in
                Thread.executeOnMain {
                    // A server response may have populated memory while the disk read was pending.
                    for template in templates where Self.memoryCache.get(key: template.key) == nil {
                        Self.memoryCache.set(key: template.key, template: template)
                    }
                    completionHandler()
                }
            }
        }
    }

    func save(template: MessageTemplate) {
        self.save(templates: [template])
    }
    
    func getTemplate(forKey key: String) -> MessageTemplate? {
        if let memoryTemplate = Self.memoryCache.get(key: key) {
            return memoryTemplate
        } else if let templates = loadAllTemplates(),
                  let memoryTemplate = templates[key] {
            return memoryTemplate
        } else if let diskTemplate = Self.diskCache.get(key: key) {
            Self.memoryCache.set(templates: [diskTemplate])
            return diskTemplate
        }
        return nil
    }
    
    func removeTemplate(forKey key: String) {
        Self.memoryCache.remove(key: key)
        Self.diskCache.remove(key: key)
    }
    
    // MARK: lastTokenKey
    func loadLastTokenKey() -> String {
        if let memoryCache = Self.memoryCache.lastToken {
            return memoryCache
        } else {
            return Self.diskCache.loadLastTokenKey()
        }
    }
    
    func saveLastTokenKey(_ value: String) {
        Self.memoryCache.lastToken = value
        Self.diskCache.saveLastTokenKey(value)
    }
    
    // MARK: Reset
    func resetCache() {
        Self.diskCache.resetCache()
        Self.memoryCache.resetCache()
    }
}
    
extension SBUCacheManager {
    struct DiskCacheForTemplate {
        // MARK: - Properties
        let fileManager = FileManager.default
        let cacheType: String
        let diskQueue = DispatchQueue(label: "\(SBUConstant.bundleIdentifier).queue.diskcache.template")
        
        let lastTokenKey = "sbu_template_list_updated_at"
        
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
        private func read(fullPath: URL) -> MessageTemplate? {
            do {
                let data = try Data(contentsOf: fullPath)
                return try JSONDecoder().decode(MessageTemplate.self, from: data)
            } catch {
                Log.info(error.localizedDescription)
            }
            return nil
        }
        
        /// Blocking read when `needToSync` is true; otherwise the caller must already be on `diskQueue`.
        func get(fullPath: URL, needToSync: Bool = true) -> MessageTemplate? {
            if needToSync {
                return self.diskQueue.sync {
                    return self.read(fullPath: fullPath)
                }
            } else {
                return self.read(fullPath: fullPath)
            }
        }
        
        func get(key: String) -> MessageTemplate? {
            let filePath = URL(fileURLWithPath: self.pathForKey(key))
            return self.diskQueue.sync {
                // Existence check inside the queue: writes are async, so a pending write is observed.
                guard self.cacheExists(key: key) else { return nil }
                return self.get(fullPath: filePath, needToSync: false)
            }
        }
        
        /// Reads and decodes every cached template. Must be called on `diskQueue`.
        private func readAllTemplates() -> [String: MessageTemplate]? {
            var templateList: [String: MessageTemplate]?
            
            do {
                let items = try fileManager.contentsOfDirectory(at: cachePathURL(), includingPropertiesForKeys: nil)
                if items.count > 0 {
                    templateList = [:]
                }
                for item in items {
                    if let template = get(fullPath: item, needToSync: false) {
                        templateList?[template.key] = template
                    }
                }
            } catch {
                Log.info(error.localizedDescription)
            }
            
            return templateList
        }
        
        /// Blocking read. Prefer `getAllTemplates(completionHandler:)` on the main thread.
        func getAllTemplates() -> [String: MessageTemplate]? {
            return self.diskQueue.sync {
                return self.readAllTemplates()
            }
        }
        
        /// Non-blocking read. `completionHandler` is called on `diskQueue`.
        func getAllTemplates(completionHandler: @escaping ([String: MessageTemplate]?) -> Void) {
            self.diskQueue.async {
                completionHandler(self.readAllTemplates())
            }
        }
        
        /// Reads only the requested files. Completion runs on `diskQueue`.
        func getTemplates(forKeys keys: [String], completionHandler: @escaping ([MessageTemplate]) -> Void) {
            diskQueue.async {
                let templates = keys.compactMap { key -> MessageTemplate? in
                    guard self.cacheExists(key: key) else { return nil }
                    return self.read(fullPath: URL(fileURLWithPath: self.pathForKey(key)))
                }
                completionHandler(templates)
            }
        }

        func set(templates: [MessageTemplate]) {
            // Encoding runs on `diskQueue` too, so the caller thread does no JSON work.
            diskQueue.async {
                for template in templates {
                    do {
                        let data = try JSONEncoder().encode(template)
                        self.write(key: template.key, data: data as NSData)
                    } catch {
                        Log.error("Failed to save template to disk cache: \(error)")
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
        
        // MARK: lastTokenKey
        /// Must be called on `diskQueue`.
        private func readLastTokenKey() -> String {
            let cachePathURL = cachePathURL()
            let filePath = cachePathURL.appendingPathComponent(lastTokenKey)
            guard let retrievedString = try? String(contentsOf: filePath, encoding: .utf8) else {
                if let storedValue = UserDefaults.standard.string(forKey: lastTokenKey) {
                    // for backward
                    UserDefaults.standard.removeObject(forKey: lastTokenKey)
                    self.writeLastTokenKey(storedValue)
                    return storedValue
                }
                return ""
            }
            return retrievedString
        }
        
        /// Blocking read. Prefer `loadLastTokenKey(completionHandler:)` on the main thread.
        func loadLastTokenKey() -> String {
            return self.diskQueue.sync {
                return self.readLastTokenKey()
            }
        }
        
        /// Non-blocking read. `completionHandler` is called on `diskQueue`.
        func loadLastTokenKey(completionHandler: @escaping (String) -> Void) {
            self.diskQueue.async {
                completionHandler(self.readLastTokenKey())
            }
        }
        
        /// Writes inline. Must be called on `diskQueue`.
        private func writeLastTokenKey(_ value: String) {
            do {
                try self.createDirectoryIfNeeded()
                let cachePathURL = cachePathURL()
                let filePath = cachePathURL.appendingPathComponent(lastTokenKey)
                try value.write(to: filePath, atomically: true, encoding: .utf8)
            } catch {
                Log.error("Error writing to file: lastTokenKey value")
            }
        }

        func saveLastTokenKey(_ value: String) {
            self.diskQueue.async { self.writeLastTokenKey(value) }
        }
        
        // MARK: reset
        func resetCache() {
            self.removePath()
        }
    }
}

extension SBUCacheManager {
    // MARK: - MemoryCache
    class MemoryCacheForTemplate {
        // 셀의 조회(main), 템플릿 응답 저장, 아무 스레드에서나 불리는 공개 초기화 API 가 겹친다.
        // 사전과 토큰의 읽기, 쓰기, 초기화를 이 잠금 하나로 묶는다.
        private let lock = NSLock()
        private var _lastToken: String?
        private var _templateList: [String: MessageTemplate]?
        
        var lastToken: String? {
            get { self.locked { self._lastToken } }
            set { self.locked { self._lastToken = newValue } }
        }
        
        var templateList: [String: MessageTemplate]? {
            get { self.locked { self._templateList } }
            set { self.locked { self._templateList = newValue } }
        }
        
        // MARK: - Memory Cache
        func set(templates: [MessageTemplate]) {
            self.locked {
                for template in templates {
                    self.setLocked(key: template.key, template: template)
                }
            }
        }
        
        func set(key: String, template: MessageTemplate) {
            self.locked { self.setLocked(key: key, template: template) }
        }
        
        /// `lock` 을 잡은 채로만 부른다.
        private func setLocked(key: String, template: MessageTemplate) {
            if self._templateList == nil { self._templateList = [:] }
            self._templateList?[key] = template
        }
        
        func get(key: String) -> MessageTemplate? {
            self.locked { self._templateList?[key] }
        }
        
        func getAllTemplates() -> [String: MessageTemplate]? {
            self.locked { self._templateList }
        }
        
        func remove(key: String) {
            self.locked { _ = self._templateList?.removeValue(forKey: key) }
        }
        
        func resetCache() {
            self.locked {
                self._lastToken = nil
                self._templateList = nil
            }
        }
        
        private func locked<T>(_ work: () -> T) -> T {
            self.lock.lock()
            defer { self.lock.unlock() }
            return work()
        }
    }
}
