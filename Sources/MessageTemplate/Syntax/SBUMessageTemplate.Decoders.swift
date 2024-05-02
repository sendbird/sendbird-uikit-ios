//
//  SBUMessageTemplate.Decoders.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/09/30.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import Foundation

// MARK: - Utils
extension SBUMessageTemplate {
    static func decodeMultipleTypeForInt<C: CodingKey>(
        forKey key: C,
        from container: KeyedDecodingContainer<C>
    ) -> Int {
        if let stringValue = try? container.decode(String.self, forKey: key) {
            return Int(stringValue) ?? 0
        } else if let intValue = try? container.decode(Int.self, forKey: key) {
            return intValue
        } else {
            return 0
        }
    }
    
    static func decodeIfPresentMultipleTypeForInt<C: CodingKey>(
        forKey key: C,
        from container: KeyedDecodingContainer<C>,
        defaultValue: Int = 0
    ) -> Int? {
        if let stringValue = try? container.decodeIfPresent(String.self, forKey: key) {
            return Int(stringValue)
        } else if let intValue = try? container.decodeIfPresent(Int.self, forKey: key) {
            return intValue
        } else {
            return nil
        }
    }
    
    static func decodeMultipleTypeForCGFloat<C: CodingKey>(
        forKey key: C,
        from container: KeyedDecodingContainer<C>
    ) -> CGFloat {
        if let stringValue = try? container.decode(String.self, forKey: key) {
            return CGFloat(Double(stringValue) ?? 0.0)
        } else if let floatValue = try? container.decode(CGFloat.self, forKey: key) {
            return floatValue
        } else {
            return 0.0
        }
    }
    
    static func decodeIfPresentMultipleTypeForCGFloat<C: CodingKey>(
        forKey key: C,
        from container: KeyedDecodingContainer<C>,
        defaultValue: CGFloat = 0
    ) -> CGFloat? {
        if let stringValue = try? container.decodeIfPresent(String.self, forKey: key) {
            if let doubleValue = Double(stringValue) {
                return CGFloat(doubleValue)
            } else {
                return nil
            }
        } else if let floatValue = try? container.decodeIfPresent(CGFloat.self, forKey: key) {
            return floatValue
        } else {
            return nil
        }
    }
}
