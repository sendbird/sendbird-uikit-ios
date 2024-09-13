//
//  SBUExtendedMessagePayloadForUI.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/03/04.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import Foundation
import UIKit

/// UI Setting for MessageTemplate
/// - Since: 3.21.0
public struct SBUExtendedMessagePayloadForUI: Decodable {
    /// Type specifying the maximum width of the message view
    @available(*, deprecated, message: "`containerType` has been deprecated since 3.27.2.")
    public let containerType: SBUMessageContainerType = .default
    
    public init(from decoder: Decoder) throws { }
}

/// Type specifying the maximum width of the message view
/// - Since: 3.21.0
@available(*, deprecated, message: "`SBUMessageContainerType` has been deprecated since 3.27.2.")
public enum SBUMessageContainerType: String, Decodable {
    /// The default size already used
    case `default`
    /// Size using the state view area
    case wide
    /// Size using the full width of the screen
    case full
    
    public init?(decodeRawValue: String) {
        self = .default
    }
}
