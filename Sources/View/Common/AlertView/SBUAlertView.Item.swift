//
//  SBUAlertView.Item.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 4/25/24.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit

/// `SBUAlertButtonItem` is a class that represents an alert button item.
public class SBUAlertButtonItem {
    /// The completion handler type for the alert button.
    /// - Since: 3.28.0
    public var title: String
    
    /// The title color of the alert button.
    /// - Since: 3.28.0
    public var color: UIColor?
    
    /// The completion handler of the alert button.
    /// - Since: 3.28.0
    public var completionHandler: SBUAlertButtonHandler?
    
    /// This function initializes alert button item.
    /// - Parameters:
    ///   - title: Button's title text
    ///   - color: Button's title color
    ///   - completionHandler: Button's completion handler
    public init(
        title: String,
        color: UIColor? = nil,
        completionHandler: SBUAlertButtonHandler? = nil
    ) {
        self.title = title
        self.color = color
        self.completionHandler = completionHandler
    }
}
