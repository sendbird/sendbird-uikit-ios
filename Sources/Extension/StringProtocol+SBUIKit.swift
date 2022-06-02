//
//  StringProtocol+SBUIKit.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/05/24.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import Foundation

// https://stackoverflow.com/a/32306142
/* Example
    let str = "Hello, playground, playground, playground"
    str.index(of: "play")      // 7
    str.endIndex(of: "play")   // 11
    str.indices(of: "play")    // [7, 19, 31]
    str.ranges(of: "play")     // [{lowerBound 7, upperBound 11}, {lowerBound 19, upperBound 23}, {lowerBound 31, upperBound 35}]
 **/
extension StringProtocol {
    func index<S: StringProtocol>(
        of string: S,
        options: String.CompareOptions = []
    ) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    
    func endIndex<S: StringProtocol>(
        of string: S,
        options: String.CompareOptions = []
    ) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    
    func indices<S: StringProtocol>(
        of string: S,
        options: String.CompareOptions = []
    ) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }
    
    func ranges<S: StringProtocol>(
        of string: S,
        options: String.CompareOptions = []
    ) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
              let range = self[startIndex...]
            .range(of: string, options: options) {
            result.append(range)
            startIndex = range.lowerBound < range.upperBound ? range.upperBound :
            index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
