//
//  String+SBUIKit.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2021/05/21.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import Foundation

extension String {
    var persistantHash: Int {
        return self.utf8.reduce(5381) {
            ($0 << 5) &+ $0 &+ Int($1)
        }
    }
}
