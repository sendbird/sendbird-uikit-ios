//
//  SBUDashboardConfig.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2023/05/24.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit

class SBUDashboardConfig: Codable {
    var updatedAt: Int64
    var configuration: Configuration
    
    enum CodingKeys: String, CodingKey {
        case updatedAt
        case configuration
    }
    
    class Configuration: SBUConfig {}

    init(updatedAt: Int64 = 0, configuration: Configuration) {
        self.updatedAt = updatedAt
        self.configuration = configuration
    }
}
