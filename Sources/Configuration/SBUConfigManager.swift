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
    func loadDashboardConfig(completionHandler: ((_ success: Bool) -> Void)?) {
        if SendbirdUI.isDashboardConfigLoaded {
            completionHandler?(true)
            return
        }
        
        if hasToUpdate() {
            SendbirdChat.__getUIKitConfiguration { [weak self] uikitConfiguration, error in
                guard let self = self,
                      error == nil,
                      let jsonPayload = uikitConfiguration?.jsonPayload,
                      let dashboardConfig = self.decodeDashboardConfig(with: jsonPayload) else {
                    SBULog.error(error)
                    completionHandler?(false)
                    return
                }
                
                self.updateWithDashboardData(dashboardConfig.configuration)
                SBUCacheManager.Config.lastUpdatedAt = dashboardConfig.updatedAt
                SBUCacheManager.Config.save(config: dashboardConfig.configuration)
                SendbirdUI.isDashboardConfigLoaded = true
                completionHandler?(true)
            }
        } else {
            if let config = SBUCacheManager.Config.getConfig() {
                self.updateWithDashboardData(config)
            }
            SendbirdUI.isDashboardConfigLoaded = true
            completionHandler?(true)
        }
    }
    
    func hasToUpdate() -> Bool {
        if SendbirdChat.getAppInfo()?.uikitConfigInfo.lastUpdatedAt == 0 {
            return false
        }
        
        let cachedUpdatedAt = SBUCacheManager.Config.lastUpdatedAt
        let serverUpdatedAt = SendbirdChat.getAppInfo()?.uikitConfigInfo.lastUpdatedAt ?? 0
        
        return cachedUpdatedAt < serverUpdatedAt
    }
    
    func decodeDashboardConfig(with jsonPayload: String) -> SBUDashboardConfig? {
        guard let jsonData = jsonPayload.data(using: .utf8) else {
            SBULog.error("Failed to decode JSON")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let dashboardConfig = try decoder.decode(SBUDashboardConfig.self, from: jsonData)
            return dashboardConfig
        } catch {
            SBULog.error("Failed to decode JSON: \(error)")
        }
        
        return nil
    }
}
