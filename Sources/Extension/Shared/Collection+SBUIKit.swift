//
//  Collection+SBUIKit.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/02/26.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import Foundation

extension Collection {
    var hasElements: Bool { isEmpty == false }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
