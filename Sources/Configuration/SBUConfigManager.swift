//
//  SBUConfigManager.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2023/06/06.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

extension SBUConfig {
    /// Resets config cache
    /// - Since: 3.6.0
    public func resetCache() {
        SBUCacheManager.Config.resetCache()
    }
}

extension SBUConfig {
    /// Loads the dashboard configuration and applies it to `SendbirdUI.config`.
    ///
    /// Cache reads/decodes and writes run on the config disk queue; the network decode runs on that queue too.
    /// `updateWithDashboardData` and `completionHandler` are always called on the main thread.
    /// Posts `SendbirdUI.didLoadDashboardConfigNotification` when the config becomes ready.
    func loadDashboardConfig(completionHandler: ((_ success: Bool) -> Void)?) {
        if SendbirdUI.isDashboardConfigLoaded {
            completionHandler?(true)
            return
        }
        
        self.hasToUpdate { [weak self] hasToUpdate in
            guard let self = self else {
                completionHandler?(false)
                return
            }
            
            if hasToUpdate {
                SendbirdChat.__getUIKitConfiguration { [weak self] uikitConfiguration, error in
                    guard let self = self, error == nil,
                          let jsonPayload = uikitConfiguration?.jsonPayload else {
                        Log.error(error)
                        Thread.executeOnMain { completionHandler?(false) }
                        return
                    }
                    
                    // Decode off the main thread (same queue as the cache so the write below stays ordered).
                    SBUCacheManager.Config.performOnDiskQueue { [weak self] in
                        guard let self = self,
                              let dashboardConfig = self.decodeDashboardConfig(with: jsonPayload) else {
                            Thread.executeOnMain { completionHandler?(false) }
                            return
                        }
                        
                        Thread.executeOnMain {
                            self.updateWithDashboardData(dashboardConfig.configuration)
                            SBUCacheManager.Config.save(config: dashboardConfig.configuration)
                            SBUCacheManager.Config.lastUpdatedAt = dashboardConfig.updatedAt
                            self.didLoadDashboardConfig()
                            completionHandler?(true)
                        }
                    }
                }
            } else {
                SBUCacheManager.Config.getConfig { [weak self] config in
                    guard let self = self else {
                        completionHandler?(false)
                        return
                    }
                    if let config = config {
                        self.updateWithDashboardData(config)
                    }
                    self.didLoadDashboardConfig()
                    completionHandler?(true)
                }
            }
        }
    }
    
    /// Must be called on the main thread.
    private func didLoadDashboardConfig() {
        SendbirdUI.isDashboardConfigLoaded = true
        NotificationCenter.default.post(name: SendbirdUI.didLoadDashboardConfigNotification, object: nil)
    }
    
    /// Blocking variant currently used only by tests. The connect flow uses the asynchronous overload.
    func hasToUpdate() -> Bool {
        if SendbirdChat.getAppInfo()?.uikitConfigInfo.lastUpdatedAt == 0 {
            return false
        }
        
        let cachedUpdatedAt = SBUCacheManager.Config.lastUpdatedAt
        let serverUpdatedAt = SendbirdChat.getAppInfo()?.uikitConfigInfo.lastUpdatedAt ?? 0
        
        return cachedUpdatedAt < serverUpdatedAt
    }
    
    /// Non-blocking variant: the cached `lastUpdatedAt` is read on the disk queue. Completes on the main thread.
    func hasToUpdate(completionHandler: @escaping (Bool) -> Void) {
        let serverUpdatedAt = SendbirdChat.getAppInfo()?.uikitConfigInfo.lastUpdatedAt ?? 0
        if serverUpdatedAt == 0 {
            Thread.executeOnMain { completionHandler(false) }
            return
        }
        
        SBUCacheManager.Config.loadLastUpdatedAt { cachedUpdatedAt in
            completionHandler(cachedUpdatedAt < serverUpdatedAt)
        }
    }
    
    func decodeDashboardConfig(with jsonPayload: String) -> SBUDashboardConfig? {
        guard let jsonData = jsonPayload.data(using: .utf8) else {
            Log.error("Failed to decode JSON")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let dashboardConfig = try decoder.decode(SBUDashboardConfig.self, from: jsonData)
            return dashboardConfig
        } catch {
            Log.error("Failed to decode JSON: \(error)")
        }
        
        return nil
    }
}
