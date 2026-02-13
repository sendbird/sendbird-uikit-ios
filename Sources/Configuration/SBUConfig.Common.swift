//
//  SBUConfig.Common.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2023/06/01.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: - SBUConfig.Common
extension SBUConfig {
    public class Common: NSObject, Codable, SBUUpdatableConfigProtocol {
        // MARK: Property
        
        /// When clicking on a user profile image in the channel or user list, utilize the mini profile popup.
        @SBUPrioritizedConfig public var isUsingDefaultUserProfileEnabled: Bool = false
        
        /// - Since: 3.34.0
        private var _isLiquidGlassEnabled: Bool = true

        /// Set this to `false` to disable liquid glass style in iOS 26.0+.
        /// Defaults to `true`.
        /// - Since: 3.34.0
        @available(iOS 26.0, *)
        public var isLiquidGlassEnabled: Bool {
            get { _isLiquidGlassEnabled }
            set { _isLiquidGlassEnabled = newValue }
        }

        /// Flag that checks if liquid glass should be applied or not.
        /// - Since: 3.34.0
        var shouldApplyLiquidGlass: Bool {
            #if compiler(>=6.2)
            if #available(iOS 26.0, *) {
                return self.isLiquidGlassEnabled
            } else {
                return false
            }
            #else
            return false
            #endif 
        }
        
        // MARK: Logic
        override init() {}
        
        func updateWithDashboardData(_ common: Common) {
            self._isUsingDefaultUserProfileEnabled.setDashboardValue(
                common.isUsingDefaultUserProfileEnabled
            )
        }
    }
}
