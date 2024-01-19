//
//  Thread+SBUIKit.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/01/17.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import Foundation

extension Thread {
    static func executeOnMain(_ handler: @escaping () -> Void) {
        if Thread.isMainThread {
            handler()
        } else {
            DispatchQueue.main.async { handler() }
        }
    }
}
