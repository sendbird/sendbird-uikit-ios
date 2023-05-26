//
//  Double+SBUIKit.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2020/07/27.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

extension Double {
    var unitFormattedString: String {
        let units = ["", "K", "M"]
        var reducedNumber = self
        var i = 0
        while i < units.count - 1 {
            if abs(reducedNumber) < 1000.0 { break }
            i += 1
            reducedNumber /= 1000.0
        }
        
        let resultStr = "\(String(format: "%.1f", reducedNumber))\(units[i])"
            .replacingOccurrences(of: ".0", with: "")
        
        return resultStr
    }
}

extension UInt {
    var unitFormattedString: String {
        Double(self).unitFormattedString
    }
}

extension Int {
    var unitFormattedString: String {
        Double(self).unitFormattedString
    }
}

extension Float {
    var unitFormattedString: String {
        Double(self).unitFormattedString
    }
}
