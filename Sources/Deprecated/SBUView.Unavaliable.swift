//
//  SBUView.Unavaliable.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/01/25.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

extension SBUView {
    // MARK: - Unavailable 3.0.0
    @available(*, unavailable, renamed: "setupLayouts()")
    public func setupAutolayout() { }
    
    @available(*, unavailable, renamed: "updateLayouts()")
    public func updateAutolayout() { }
}
