//
//  SBUCacheManager.Template.swift
//  QuickStart
//
//  Created by Tez Park on 2023/02/26.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import UIKit

extension SBUCacheManager {
    class Template {
        static let memoryCache = MemoryCacheForTemplate()
        static let diskCache = DiskCacheForTemplate(cacheType: "templates")
        static let cachePath = diskCache.cachePathURL()
        static let cacheKey = "templates"


        // MARK: - TemplateList token (updated time)
        static var lastToken: String {
            get {
                UserDefaults.standard.string(forKey: "sbu_template_list_updated_at") ?? ""
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "sbu_template_list_updated_at")
            }
        }
        
        
        // MARK: - Template list
        static func save(templates: [SBUNotificationChannelManager.TemplateList.Template]) {
            self.memoryCache.set(templates: templates)
            self.diskCache.set(templates: templates)
        }
        
        static func loadAllTemplates() -> [String: SBUNotificationChannelManager.TemplateList.Template]? {
            if let templateList = memoryCache.getAllTemplates() {
//                SBULog.info("Loaded templates from memory cache")
                return templateList
            } else if let templateList = diskCache.getAllTemplates() {
//                SBULog.info("Loaded templates from disk cache")
                self.memoryCache.set(templates: Array(templateList.values))
                return templateList
            }
            
            SBULog.info("No have templates in cache")
            return nil
        }
        
        static func upsert(templates: [SBUNotificationChannelManager.TemplateList.Template]) {
            self.save(templates: templates)
        }
        
        
        // MARK: - Single template
        static func save(template: SBUNotificationChannelManager.TemplateList.Template) {
            self.save(templates: [template])
        }
        
        static func getTemplate(forKey key: String) -> SBUNotificationChannelManager.TemplateList.Template? {
            if let memoryTemplate = self.memoryCache.get(key: key) {
                return memoryTemplate
            } else if let templates = loadAllTemplates(),
                      let memoryTemplate = templates[key] {
                return memoryTemplate
            } else if let diskTemplate = self.diskCache.get(key: key) {
                self.memoryCache.set(templates: [diskTemplate])
                return diskTemplate
            }
            return nil
        }
        
        static func upsert(template: SBUNotificationChannelManager.TemplateList.Template, forKey key: String) {
            self.save(templates: [template])
//            var templates = getAllTemplates()
//            if let index = templates.firstIndex(where: { $0.key == key }) {
//                templates[index] = template
//            } else {
//                templates.append(template)
//            }
//            save(templates: templates)
        }
    }
}

extension SBUCacheManager {
    struct DiskCacheForTemplate {
        // MARK: - Properties
        private let fileManager = FileManager.default
        private let cacheType: String
        private let diskQueue = DispatchQueue(label: "\(SBUConstant.bundleIdentifier).queue.diskcache.template", qos: .background)
        
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

        func get(fullPath: URL) -> SBUNotificationChannelManager.TemplateList.Template? {
            do {
                let data = try Data(contentsOf: fullPath)
                let template = try JSONDecoder().decode(SBUNotificationChannelManager.TemplateList.Template.self, from: data)
                return template as SBUNotificationChannelManager.TemplateList.Template
            } catch {
                SBULog.info(error.localizedDescription)
            }
            return nil
        }
        
        func get(key: String) -> SBUNotificationChannelManager.TemplateList.Template? {
            guard cacheExists(key: key) else { return nil }
            
            let filePath = URL(fileURLWithPath: self.pathForKey(key))
            
            do {
                let data = try Data(contentsOf: filePath)
                let template = try JSONDecoder().decode(SBUNotificationChannelManager.TemplateList.Template.self, from: data)
                return template as SBUNotificationChannelManager.TemplateList.Template
            } catch {
                SBULog.info(error.localizedDescription)
            }
            return nil
        }
        
        func getAllTemplates() -> [String: SBUNotificationChannelManager.TemplateList.Template]? {
            var templateList: [String: SBUNotificationChannelManager.TemplateList.Template]? = nil
            
            do {
                let items = try fileManager.contentsOfDirectory(at: cachePathURL(), includingPropertiesForKeys: nil)
                if items.count > 0 {
                    templateList = [:]
                }
                for item in items {
                    if let template = get(fullPath: item) {
                        templateList?[template.key] = template
                    }
                }
            } catch {
                SBULog.info(error.localizedDescription)
            }
            
            return templateList
        }
        
        func set(templates: [SBUNotificationChannelManager.TemplateList.Template]) {
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
    class MemoryCacheForTemplate {
        var templateList: [String: SBUNotificationChannelManager.TemplateList.Template]? = nil
        
        // MARK: - Memory Cache
        func set(templates: [SBUNotificationChannelManager.TemplateList.Template]) {
            for template in templates {
                set(key: template.key, template: template)
            }
        }
        
        func set(key: String, template: SBUNotificationChannelManager.TemplateList.Template) {
            if self.templateList == nil { self.templateList = [:] }
            self.templateList?[key] = template
        }
        
        func get(key: String) -> SBUNotificationChannelManager.TemplateList.Template? {
            guard let template = self.templateList?[key] else { return nil }
            return template as SBUNotificationChannelManager.TemplateList.Template
        }
        
        func getAllTemplates() -> [String: SBUNotificationChannelManager.TemplateList.Template]? {
            return templateList
        }
        
        func remove(key: String) {
            self.templateList?.removeValue(forKey: key)
        }
        
        func cacheExists(key: String) -> Bool {
            return self.templateList?[key] != nil
        }
    }
}
