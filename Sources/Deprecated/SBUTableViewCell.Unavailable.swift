//
//  SBUTableViewCell.Unavailable.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/01/25.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

extension SBUTableViewCell {
    // MARK: - Unavailable 3.0.0
    @available(*, unavailable, renamed: "setupLayouts()")
    open func setupAutolayout() { }
    
    @available(*, unavailable, renamed: "updateLayouts()")
    open func updateAutolayout() { }
}
