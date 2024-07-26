//
//  SBUMessageTemplate.Types.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/09/30.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit

extension SBUMessageTemplate.Syntax {
    enum LayoutType: String, Decodable {
        case row, column
    }
    
    enum WeightType: String, Decodable {
        case normal, bold
    }
    
    enum ContentMode: String, Decodable {
        case aspectFill, aspectFit, scalesToFill
    }

    enum SizeType: String, Decodable {
        case fixed, flex
        
        init(from decoder: Decoder) throws {
            self = try SizeType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .fixed
        }
    }
    
    enum FlexSizeType: Int, Decodable {
        case fillParent = 0
        case wrapContent = 1
    }
    
    enum HorizontalAlign: String, Decodable {
        case left, center, right
    }
    
    enum VerticalAlign: String, Decodable {
        case top, center, bottom
    }
}

extension SBUMessageTemplate.Syntax {
    enum InternalSizeType {
        case fixed(value: Int)
        case fillParent
        case wrapContent
        case unknown
        
        init(type: SizeType, value: Int) {
            switch (type, value) {
            case (.fixed, _): self = .fixed(value: value)
            case (.flex, 0): self = .fillParent
            case (.flex, 1): self = .wrapContent
            default: self = .unknown
            }
        }
        
        var isValid: Bool {
            switch self {
            case .fixed: return true
            case .fillParent: return true
            case .wrapContent: return true
            case .unknown: return false
            }
        }
        
        var isFixed: Bool {
            switch self {
            case .fixed: return true
            default: return false
            }
        }
        var isFillParent: Bool {
            switch self {
            case .fillParent: return true
            default: return false
            }
        }
        var isWrapContent: Bool {
            switch self {
            case .wrapContent: return true
            default: return false
            }
        }
    }
}

extension SBUMessageTemplate.Syntax {
    enum ImageRatioType {
        case minimumWrap(cached: Bool = false)
        case ratio
        case fixedHeightRatio
        case unknown
        
        var isRatioUsed: Bool {
            switch self {
            case .ratio: return true
            case .fixedHeightRatio: return true
            default: return false
            }
        }
    }
}
