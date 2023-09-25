//
//  SBUCacheManager.Version.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2023/09/21.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit

extension SBUCacheManager {
    class Version {
        static let cachedSBUVersion = "cached_sbu_version"
        
        static func saveCurrentVersion() {
            let currentVersion = SendbirdUI.bundleShortVersion
            UserDefaults.standard.setValue(currentVersion, forKey: cachedSBUVersion)
        }
        
        static func loadLastUsedVersion() -> String? {
            UserDefaults.standard.string(forKey: cachedSBUVersion)
        }
        
        static func checkAndClearOutdatedCache() {
            let cachedVersion = versionStringToNumber(loadLastUsedVersion() ?? "")
            
            // INFO: This version fixes an issue with thumbnails being cached as the original image.
            let thumbCacheIssueVersion = versionStringToNumber("3.9.1")
            if cachedVersion < thumbCacheIssueVersion {
                SBUCacheManager.Image.resetCache()
            }
            
            saveCurrentVersion()
        }
        
        static func versionStringToNumber(_ version: String) -> Int {
            let components = version.split(separator: ".")
            
            var number = 0
            for (index, component) in components.enumerated() {
                if let componentNumber = Int(component) {
                    let power = pow(10.0, 3.0 * (2.0 - Double(index)))
                    number += componentNumber * Int(power)
                }
            }
            
            return number
        }
    }
}
