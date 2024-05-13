//
//  SBUMessageTemplate.Sizes.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/09/30.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit

extension SBUMessageTemplate.Syntax {
    
    // MARK: - Size
    class SizeSpec: Decodable {
        var type: SizeType
        var value: Int // flex -> 0: fillParent, 1: wrapContent
        
        var internalSizeType: InternalSizeType
        
        enum CodingKeys: String, CodingKey {
            case type, value
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.type = try container.decode(SizeType.self, forKey: .type)
            
            self.value = SBUMessageTemplate.decodeMultipleTypeForInt(
                forKey: .value,
                from: container
            )
            
            self.internalSizeType = InternalSizeType(type: self.type, value: self.value)
            
            if self.internalSizeType.isValid == false {
                throw DecodingError.dataCorruptedError(
                    forKey: .value,
                    in: container,
                    debugDescription: "Invalid size spec value."
                )
            }
        }
        
        init(type: SizeType = .fixed, value: Int = 0) {
            self.type = type
            self.value = value
            self.internalSizeType = InternalSizeType(type: type, value: value)
        }
        
        class func fillParent() -> SizeSpec {
            let sizeSpec = SizeSpec(
                type: .flex,
                value: FlexSizeType.fillParent.rawValue
            )
            return sizeSpec
        }
        
        class func wrapContent() -> SizeSpec {
            let sizeSpec = SizeSpec(
                type: .flex,
                value: FlexSizeType.wrapContent.rawValue
            )
            return sizeSpec
        }
    }
    
    class MetaData: Decodable {
        var pixelWidth: Int
        var pixelHeight: Int
        
        enum CodingKeys: String, CodingKey {
            case pixelWidth, pixelHeight
        }
        
        var isValid: Bool { pixelWidth > 0 && pixelHeight > 0 }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.pixelWidth = SBUMessageTemplate.decodeMultipleTypeForInt(
                forKey: .pixelWidth,
                from: container
            )
            self.pixelHeight = SBUMessageTemplate.decodeMultipleTypeForInt(
                forKey: .pixelHeight,
                from: container
            )
        }
    }
    
    // MARK: - Margin, Padding
    class Margin: Decodable {
        let top: CGFloat
        let bottom: CGFloat
        let left: CGFloat
        let right: CGFloat
        
        enum CodingKeys: String, CodingKey {
            case top, bottom, left, right
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.top = SBUMessageTemplate.decodeMultipleTypeForCGFloat(
                forKey: .top,
                from: container
            )
            self.bottom = SBUMessageTemplate.decodeMultipleTypeForCGFloat(
                forKey: .bottom,
                from: container
            )
            self.left = SBUMessageTemplate.decodeMultipleTypeForCGFloat(
                forKey: .left,
                from: container
            )
            self.right = SBUMessageTemplate.decodeMultipleTypeForCGFloat(
                forKey: .right,
                from: container
            )
        }
    }
    
    class Padding: Decodable {
        var top: CGFloat
        var bottom: CGFloat
        var left: CGFloat
        var right: CGFloat
        
        enum CodingKeys: String, CodingKey {
            case top, bottom, left, right
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.top = SBUMessageTemplate.decodeMultipleTypeForCGFloat(
                forKey: .top,
                from: container
            )
            self.bottom = SBUMessageTemplate.decodeMultipleTypeForCGFloat(
                forKey: .bottom,
                from: container
            )
            self.left = SBUMessageTemplate.decodeMultipleTypeForCGFloat(
                forKey: .left,
                from: container
            )
            self.right = SBUMessageTemplate.decodeMultipleTypeForCGFloat(
                forKey: .right,
                from: container
            )
        }
        
        init(top: CGFloat, bottom: CGFloat, left: CGFloat, right: CGFloat) {
            self.top = top
            self.bottom = bottom
            self.left = left
            self.right = right
        }
    }
}
