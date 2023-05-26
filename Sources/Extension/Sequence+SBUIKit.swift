//
//  Sequence+SBUIKit.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 24/03/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

extension Sequence where Iterator.Element: Hashable {
    public func sbu_unique() -> [Iterator.Element] {
        var seen: [Iterator.Element: Bool] = [:]
        return self.filter { seen.updateValue(true, forKey: $0) == nil }
    }
}
