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
    static func loadTemplateList(
        type: SBUMessageTemplate.TemplateType,
        completionHandler: ((_ success: Bool) -> Void)?
    ) {
        let cache = SBUCacheManager.template(with: type)
        
        let cachedToken = Int64(cache.lastToken) ?? 0
        let serverToken = type.getRemoteToken()
        
        guard cachedToken < serverToken else {
            let success = cache.loadAllTemplates() != nil
            completionHandler?(success)
            return
        }
        
        type.loadTemplateList(token: cache.lastToken) { json, token in
            guard let templateList = MessageTemplate.templateList(from: json) else {
                completionHandler?(false)
                return
            }
            
            cache.save(templates: templateList)
            cache.lastToken = token ?? ""
            cache.loadAllTemplates()
            
            completionHandler?(true)           
        }
    }
    
    static func loadTemplateList(
        type: SBUMessageTemplate.TemplateType,
        keys: [String],
        completionHandler: ((_ success: Bool) -> Void)?
    ) {
        let cache = SBUCacheManager.template(with: type)
        
        type.loadTemplateList(keys: keys) { json, token in
            guard let templateList = MessageTemplate.templateList(from: json) else {
                completionHandler?(false)
                return
            }
            
            cache.save(templates: templateList)
            cache.loadAllTemplates()
            
            // FIXED: https://sendbird.atlassian.net/browse/CLNP-6062
            if templateList.count < keys.count {
                completionHandler?(false)
            } else {
                completionHandler?(true)
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
