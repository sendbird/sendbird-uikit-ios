//
//  CommonProtocols.swift
//  SendbirdUIKit
//
//  Created by Wooyoung Chung on 7/8/20.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

/// Protocol for handling loading indicators
public protocol SBULoadingIndicatorProtocol {

    /// - Parameter isLoading: Whether it's loading or not
    func showLoading(_ isLoading: Bool)
}
