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
                    // 저장된 버전 문자열에 큰 숫자가 있으면 곱셈이나 덧셈이 넘쳐 앱이 종료되므로,
                    // 넘치면 가장 오래된 버전(0)으로 보고 이미지 캐시를 한 번 비우게 합니다.
                    let (product, productOverflow) = componentNumber.multipliedReportingOverflow(by: Int(power))
                    let (sum, sumOverflow) = number.addingReportingOverflow(product)
                    if productOverflow || sumOverflow { return 0 }
                    number = sum
                }
            }
            
            return number
        }
    }
}
