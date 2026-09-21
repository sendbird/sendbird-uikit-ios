//
//  SBUMessageTemplateManager.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/02/17.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK
#if canImport(SendbirdUIMessageTemplate)
import SendbirdUIMessageTemplate
#endif

public class SBUMessageTemplateManager: NSObject {
    /// Resets notification template cache
    /// - Since: 3.21.0
    public static func resetNotificationTemplateCache() {
        SBUCacheManager.template(with: .notification).resetCache()
    }
    
    /// Resets message template cache
    /// - Since: 3.21.0
    public static func resetMessageTemplateCache() {
        SBUCacheManager.template(with: .message).resetCache()
    }
    
    static let exeucuteQueue = DispatchQueue(label: "com.sendbird.message_template.images")
}

// for view model
extension SBUMessageTemplateManager {
    /// Loads the template list for the connect flow.
    ///
    /// Cache token read, template decode and writes run on the template disk queue;
    /// `completionHandler` is always called on the main thread.
    static func loadTemplateList(
        type: SBUMessageTemplate.TemplateType,
        completionHandler: ((_ success: Bool) -> Void)?
    ) {
        let cache = SBUCacheManager.template(with: type)
        let serverToken = type.getRemoteToken()
        
        cache.loadLastToken { lastToken in
            let cachedToken = Int64(lastToken) ?? 0
            
            guard cachedToken < serverToken else {
                cache.loadAllTemplates { templates in
                    completionHandler?(templates != nil)
                }
                return
            }
            
            type.loadTemplateList(token: lastToken) { json, token in
                // Parse the response off the main thread.
                cache.performOnDiskQueue {
                    guard let templateList = MessageTemplate.templateList(from: json) else {
                        Thread.executeOnMain { completionHandler?(false) }
                        return
                    }
                    
                    Thread.executeOnMain {
                        // Update the memory cache on main; disk encoding and writes remain asynchronous.
                        cache.save(templates: templateList)
                        cache.lastToken = token ?? ""
                        cache.loadAllTemplates { _ in
                            completionHandler?(true)
                        }
                    }
                }
            }
        }
    }
    
    /// Restores requested keys from disk before fetching missing keys from the server.
    /// Parsing and disk writes run off main; memory updates and completion run on main.
    static func loadTemplateList(
        type: SBUMessageTemplate.TemplateType,
        keys: [String],
        completionHandler: ((_ success: Bool) -> Void)?
    ) {
        let cache = SBUCacheManager.template(with: type)
        
        cache.loadTemplates(forKeys: keys) {
            let missingKeys = Array(Set(keys.filter { cache.getMemoryTemplate(forKey: $0) == nil })).sorted()
            guard !missingKeys.isEmpty else {
                completionHandler?(true)
                return
            }

            type.loadTemplateList(keys: missingKeys) { json, _ in
                cache.performOnDiskQueue {
                    guard let templateList = MessageTemplate.templateList(from: json) else {
                        Thread.executeOnMain { completionHandler?(false) }
                        return
                    }

                    Thread.executeOnMain {
                        // Memory is updated on main; encode and disk writes are queued asynchronously.
                        cache.save(templates: templateList)
                        // All requested keys must be available before the view model marks them loaded.
                        // Replaces the `templateList.count < keys.count` check from CLNP-6062: checking
                        // actual availability also covers a response that omits a requested key.
                        completionHandler?(keys.allSatisfy { cache.getMemoryTemplate(forKey: $0) != nil })
                    }
                }
            }
        }
    }
    
    static func loadTemplateImages(
        type: SBUMessageTemplate.TemplateType,
        cacheData: [String: String],
        completionHandler: ((_ success: Bool) -> Void)?
    ) {
        let dispatchGroup = DispatchGroup()
        var loadCount = 0
        
        exeucuteQueue.async {
            for (_, url) in cacheData {
                dispatchGroup.enter()
                
                let fileName = SBUCacheManager.Image.createCacheFileName(
                    urlString: url,
                    cacheKey: nil,
                    fileNameForExtension: nil,
                    needPathExtension: true
                )
                
                if SBUCacheManager.Image.get(
                    fileName: fileName,
                    subPath: SBUCacheManager.PathType.template
                ) != nil {
                    loadCount += 1
                    dispatchGroup.leave()
                    return
                }
                
                UIImageView.getOriginalImage(
                    urlString: url,
                    subPath: SBUCacheManager.PathType.template
                ) { image, _ in
                    if image != nil {
                        loadCount += 1
                    }
                    dispatchGroup.leave()
                }
            }
            
            let result = dispatchGroup.wait(timeout: .now() + .seconds(10)) // timeout: 10 second
        
            Thread.executeOnMain {
                switch result {
                case .success:
                    completionHandler?(cacheData.count == loadCount)
                case .timedOut:
                    completionHandler?(false)
                }
            }
        }
    }
}

extension Array where Element == String {
    func toJsonString() -> String? { "[\(self.joined(separator: ","))]" }
}
