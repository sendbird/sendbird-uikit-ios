//
//  String+SBUIKit.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/05/21.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import Foundation

extension String {
    var persistantHash: Int {
        self.utf8.reduce(5381) {
            ($0 << 5) &+ $0 &+ Int($1)
        }
    }
    
    func regexMatchingList(regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(
                in: self,
                range: NSRange(self.startIndex..., in: self)
            )
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            SBULog.error("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func removingRegex(_ regex: String, replace: String = "") -> String {
        // No use now
        do {
            let regex = try NSRegularExpression(pattern: regex, options: .caseInsensitive)
            let range = NSRange(location: 0, length: count)
            let removingRegexString = regex.stringByReplacingMatches(
                in: self,
                options: [],
                range: range,
                withTemplate: replace
            )
            return removingRegexString
        } catch let error {
            SBULog.error("failed removing regex: \(error.localizedDescription)")
            return self
        }
    }
    
    func unwrappingRegex(_ regex: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return nil }
        let nsString = self as NSString
        let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: nsString.length))
        let results = matches.map { result in
            (0..<result.numberOfRanges).map {
                result.range(at: $0).location != NSNotFound
                ? nsString.substring(with: result.range(at: $0))
                : ""
            }
        }
        
        guard !results.isEmpty else { return nil }
        
        var unwrappedString = self
        for result in results where result.count >= 2 {
            unwrappedString = unwrappedString.replacingOccurrences(of: result[0], with: result[1])
        }
        return unwrappedString
    }
}
