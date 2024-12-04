//
//  SBUToastView.Internal.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 4/17/24.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

extension SBUToastView {
    static func show(type: SBUToastType) {
        show(item: type.item)
    }
}
