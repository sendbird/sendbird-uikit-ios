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
        
        // MARK: Logic
        override init() {}
        
        func updateWithDashboardData(_ common: Common) {
            self._isUsingDefaultUserProfileEnabled.setDashboardValue(
                common.isUsingDefaultUserProfileEnabled
            )
        }
    }
}
