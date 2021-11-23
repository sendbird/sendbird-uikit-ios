//
//  SBUView.swift
//  SendBirdUIKit
//
//  Created by Jaesung Lee on 2021/07/05.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import Foundation

/// The protocol to manage the life cylce of some views. It defines setting views, styles, auto layouts and actions.
///
/// - Since: 2.2.0

@objc
public protocol SBUViewLifeCycle {
    /// This function handles the initialization of views.
    func setupViews()
    
    /// This function handles the initialization of styles.
    func setupStyles()
    
    /// This function handles the initialization of autolayouts.
    func setupAutolayout()
    
    /// This function handles the initialization of actions.
    func setupActions()
}
