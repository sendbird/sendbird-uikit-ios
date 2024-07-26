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
    public let containerType: SBUMessageContainerType
    
    enum CodingKeys: String, CodingKey {
        case containerType = "container_type"
    }
    
    init(containerType: SBUMessageContainerType) {
        self.containerType = containerType
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let containerType = try? container.decodeIfPresent(String.self, forKey: .containerType)
        self.containerType = SBUMessageContainerType(
            decodeRawValue: containerType ?? SBUMessageContainerType.default.rawValue
        ) ?? .default
    }
}

/// Type specifying the maximum width of the message view
/// - Since: 3.21.0
public enum SBUMessageContainerType: String, Decodable {
    /// The default size already used
    case `default`
    /// Size using the state view area
    case wide
    /// Size using the full width of the screen
    case full
    
    public init?(decodeRawValue: String) {
        self = SBUMessageContainerType(rawValue: decodeRawValue) ?? .default
        if self == .full { self = .default }
    }
    
    var isDefaultSize: Bool { self == .`default` }
    var isBiggerWideSize: Bool { self != .`default` }
    var isWide: Bool { self == .wide }
    
    static var screenWidth: CGFloat {
        let windowBounds = (UIApplication.shared.currentWindow?.bounds ?? .zero)
        return min(windowBounds.width, windowBounds.height)
    }
    
    static var defaultMaxSize: CGFloat = 256.0
    
    var maxWidth: CGFloat {
        switch self {
        case .`default`: return SBUMessageContainerType.defaultMaxSize
        case .wide: return SBUMessageContainerType.screenWidth
        case .full: return SBUMessageContainerType.screenWidth
        }
    }
}

struct SBUMessageContainerSizeFactory {
    let type: SBUMessageContainerType
    let profileWidth: CGFloat?
    let timpstampWidth: CGFloat?
    
    init(
        type: SBUMessageContainerType,
        profileWidth: CGFloat? = nil,
        timpstampWidth: CGFloat? = nil
    ) {
        self.type = type
        self.profileWidth = profileWidth
        self.timpstampWidth = timpstampWidth
    }
    
    static var `default` = SBUMessageContainerSizeFactory(type: .default)
}

extension SBUMessageContainerSizeFactory {
    struct `Default` {
        static let margin: CGFloat = 12.0
        static let spacing: CGFloat = 4.0
        static let profile: CGFloat = 26
        static let timestamp: CGFloat = 55
    }
    
    func getProfileArea() -> CGFloat {
        let profile = self.profileWidth ?? Default.profile
        let margin = Default.margin
        return margin + profile + margin
    }
    
    func getTimestampArea() -> CGFloat {
        let timestamp = self.timpstampWidth ?? Default.timestamp
        let spacing = Default.spacing
        let margin = Default.margin
        return spacing + timestamp + margin
    }

    func getWidth(type: SBUMessageContainerType? = nil) -> CGFloat {
        let contents = CGFloat.zero
        let margin = Default.margin
        let screen = SBUMessageContainerType.screenWidth
        
        switch type ?? self.type {
        case .`default`:
            return min(self.type.maxWidth, screen - (getProfileArea() + contents + getTimestampArea()))
        case .wide:
            return min(self.type.maxWidth, screen - (getProfileArea() + contents + margin))
        case .full:
            return screen
        }
    }
}
