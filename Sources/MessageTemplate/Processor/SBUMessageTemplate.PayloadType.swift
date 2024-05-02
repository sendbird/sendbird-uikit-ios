//
//  SBUMessageTemplate.PayloadType.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/03/14.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import Foundation

extension SBUMessageTemplate {
    enum PayloadType: String {
        case `default`
        case unknown
        
        static let typeKey = "type"
        
        init(with template: [String: Any]) {
            guard let type = template[Self.typeKey] as? String else {
                self = .default
                return
            }
            
            self = PayloadType(rawValue: type) ?? .unknown
        }
    }
}
