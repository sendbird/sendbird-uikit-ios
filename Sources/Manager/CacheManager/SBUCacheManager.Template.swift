//
//  SBUCacheManager.Template.swift
//  QuickStart
//
//  Created by Tez Park on 2023/02/26.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import UIKit

extension SBUCacheManager {
    static func template(with type: SBUTemplateType) -> SBUTemplateCacheType {
        switch type {
        case .notification: return NotificationMessageTemplate.shared
        case .message: return GroupMessageTemplate.shared
        }
    }
    
    class NotificationMessageTemplate: SBUTemplateCacheType {
        static let shared = NotificationMessageTemplate()
        static let type = SBUTemplateType.notification
        static let memoryCache = MemoryCacheForTemplate()
        static let diskCache = DiskCacheForTemplate(cacheType: type.cacheKey)
    }
    
    class GroupMessageTemplate: SBUTemplateCacheType {
        static let shared = GroupMessageTemplate()
        static let type = SBUTemplateType.message
        static let memoryCache = MemoryCacheForTemplate()
        static let diskCache = DiskCacheForTemplate(cacheType: type.cacheKey)
    }
}

protocol SBUTemplateCacheType: AnyObject {
    static var type: SBUTemplateType { get }
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
    func save(templates: [SBUMessageTemplate.TemplateModel]) {
        Self.memoryCache.set(templates: templates)
        Self.diskCache.set(templates: templates)
    }
    
    @discardableResult
    func loadAllTemplates() -> [String: SBUMessageTemplate.TemplateModel]? {
        if let templateList = Self.memoryCache.getAllTemplates() {
//                SBULog.info("Loaded templates from memory cache")
            return templateList
        } else if let templateList = Self.diskCache.getAllTemplates() {
//                SBULog.info("Loaded templates from disk cache")
            Self.memoryCache.set(templates: Array(templateList.values))
            return templateList
        }
        
        SBULog.info("No have templates in cache")
        return nil
    }
    
    func upsert(templates: [SBUMessageTemplate.TemplateModel]) {
        self.save(templates: templates)
    }
    
    // MARK: - Single template
    func save(template: SBUMessageTemplate.TemplateModel) {
        self.save(templates: [template])
    }
    
    func getTemplate(forKey key: String) -> SBUMessageTemplate.TemplateModel? {
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
    
    func getTemplateList(forKeys keys: [String]) -> [String: SBUMessageTemplate.TemplateModel]? {
        let results = keys.compactMap { self.getTemplate(forKey: $0) }
        guard results.count == keys.count else { return nil }
        return results.reduce(into: [String: SBUMessageTemplate.TemplateModel]()) { $0[$1.key] = $1 }
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
    class TemplateImage {
        static let memoryCache = MemoryCacheForTemplateImageSize()
        
        static func save(messageId: Int64, viewIndex: Int, size: CGSize) {
            self.memoryCache.set(messageId: messageId, viewIndex: viewIndex, size: size)
        }
        
        static func load(messageId: Int64, viewIndex: Int) -> CGSize? {
            self.memoryCache.get(messageId: messageId, viewIndex: viewIndex)
        }
        
        static func save(key: String, size: CGSize) {
            self.memoryCache.set(key: key, size: size)
        }
        
        static func load(key: String) -> CGSize? {
            self.memoryCache.get(key: key)
        }
    }
}
    
extension SBUCacheManager {
    struct DiskCacheForTemplate {
        // MARK: - Properties
        let fileManager = FileManager.default
        let cacheType: String
        let diskQueue = DispatchQueue(label: "\(SBUConstant.bundleIdentifier).queue.diskcache.template", qos: .background)
        var fileSemaphore = DispatchSemaphore(value: 1)
        
        let lastTokenKey = "sbu_template_list_updated_at"
        
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

        func get(fullPath: URL, needToSync: Bool = true) -> SBUMessageTemplate.TemplateModel? {
            let template: SBUMessageTemplate.TemplateModel? = {
                do {
                    let data = try Data(contentsOf: fullPath)
                    let template = try JSONDecoder().decode(SBUMessageTemplate.TemplateModel.self, from: data)
                    return template as SBUMessageTemplate.TemplateModel
                } catch {
                    SBULog.info(error.localizedDescription)
                }
                return nil
            }()
            
            if needToSync {
                return self.diskQueue.sync {
                    self.fileSemaphore.wait()
                    defer { self.fileSemaphore.signal() }
                    
                    return template
                }
            } else {
                return template
            }
        }
        
        func get(key: String) -> SBUMessageTemplate.TemplateModel? {
            guard cacheExists(key: key) else { return nil }
            
            let filePath = URL(fileURLWithPath: self.pathForKey(key))
            return self.get(fullPath: filePath)
        }
        
        func getAllTemplates() -> [String: SBUMessageTemplate.TemplateModel]? {
            return self.diskQueue.sync {
                self.fileSemaphore.wait()
                defer { self.fileSemaphore.signal() }
                
                var templateList: [String: SBUMessageTemplate.TemplateModel]?
                
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
                    SBULog.info(error.localizedDescription)
                }
                
                return templateList
            }
        }
        
        func set(templates: [SBUMessageTemplate.TemplateModel]) {
            for template in templates {
                let encoder = JSONEncoder()
                do {
                    let data = try encoder.encode(template)
                    self.set(key: template.key, data: data as NSData)
                } catch {
                    SBULog.error("Failed to save template to disk cache: \(error)")
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
        
        // MARK: lastTokenKey
        func loadLastTokenKey() -> String {
            return self.diskQueue.sync {
                self.fileSemaphore.wait()
                defer { self.fileSemaphore.signal() }
                
                let cachePathURL = cachePathURL()
                let filePath = cachePathURL.appendingPathComponent(lastTokenKey)
                guard let retrievedString = try? String(contentsOf: filePath, encoding: .utf8) else {
                    if let storedValue = UserDefaults.standard.string(forKey: lastTokenKey) {
                        // for backward
                        UserDefaults.standard.removeObject(forKey: lastTokenKey)
                        self.saveLastTokenKey(storedValue)
                        return storedValue
                    }
                    return ""
                }
                return retrievedString
            }
        }
        
        func saveLastTokenKey(_ value: String) {
            self.diskQueue.async {
                do {
                    try self.createDirectoryIfNeeded()
                    let cachePathURL = cachePathURL()
                    let filePath = cachePathURL.appendingPathComponent(lastTokenKey)
                    try value.write(to: filePath, atomically: true, encoding: .utf8)
                } catch {
                    SBULog.error("Error writing to file: lastTokenKey value")
                }
            }
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
        var lastToken: String?
        var templateList: [String: SBUMessageTemplate.TemplateModel]?
        
        // MARK: - Memory Cache
        func set(templates: [SBUMessageTemplate.TemplateModel]) {
            for template in templates {
                set(key: template.key, template: template)
            }
        }
        
        func set(key: String, template: SBUMessageTemplate.TemplateModel) {
            if self.templateList == nil { self.templateList = [:] }
            self.templateList?[key] = template
        }
        
        func get(key: String) -> SBUMessageTemplate.TemplateModel? {
            guard let template = self.templateList?[key] else { return nil }
            return template as SBUMessageTemplate.TemplateModel
        }
        
        func getAllTemplates() -> [String: SBUMessageTemplate.TemplateModel]? {
            return templateList
        }
        
        func remove(key: String) {
            self.templateList?.removeValue(forKey: key)
        }
        
        func resetCache() {
            self.lastToken = nil
            self.templateList = nil
        }
        
//        func cacheExists(key: String) -> Bool {
//            return self.templateList?[key] != nil
//        }
    }
}

extension SBUCacheManager {
    class MemoryCacheForTemplateImageSize {
        var sizeCache: [String: CGSize] = [:] // The key is a combination of the message ID and the index of view item.
        
        func generateKey(messageId: Int64, viewIndex: Int) -> String {
            "\(messageId)_\(viewIndex)"
        }
        
        func set(messageId: Int64, viewIndex: Int, size: CGSize) {
            self.sizeCache[self.generateKey(messageId: messageId, viewIndex: viewIndex)] = size
        }
        
        func get(messageId: Int64, viewIndex: Int) -> CGSize? {
            self.sizeCache[self.generateKey(messageId: messageId, viewIndex: viewIndex)]
        }
        
        func set(key: String, size: CGSize) {
            self.sizeCache[key] = size
        }
        
        func get(key: String) -> CGSize? {
            self.sizeCache[key]
        }
    }
}
