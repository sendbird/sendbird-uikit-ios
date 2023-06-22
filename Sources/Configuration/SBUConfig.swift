//
//  SBUConfig.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2023/05/24.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

// MARK: - SBUUpdatableConfigProtocol
protocol SBUUpdatableConfigProtocol {
    /// Updates ``SBUConfig`` with the value from the dashboard.
    /// - Parameter config: The ``SBUConfig`` that represents the dashboard configuration settings.
    func updateWithDashboardData(_ config: Self)
}

// MARK: - SBUConfig

/// This is a class that manages configuration values used in UIKit.
///
/// - Priority:
///   - P0: Values set in code by the customer
///   - P1: Values set from Dashboard
///   - P2: UIKit default value
///   
/// - Since: 3.6.0
public class SBUConfig: NSObject, Codable, SBUUpdatableConfigProtocol {
    /// Application common configuration set
    public var common: Common = Common()
    
    /// GroupChannel configuration set
    public var groupChannel: GroupChannel = GroupChannel()
    
    /// OpenChannel configuration set
    public var openChannel: OpenChannel = OpenChannel()
    
    func updateWithDashboardData(_ dashboardConfig: SBUConfig) {
        self.common.updateWithDashboardData(dashboardConfig.common)
        self.groupChannel.updateWithDashboardData(dashboardConfig.groupChannel)
        self.openChannel.updateWithDashboardData(dashboardConfig.openChannel)
    }
}
