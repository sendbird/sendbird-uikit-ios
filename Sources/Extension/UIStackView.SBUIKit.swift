//
//  UIStackView.SBUIKit.swift
//  SendBirdUIKit
//
//  Created by Jaesung Lee on 2021/07/02.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

extension UIStackView {
    // MARK: - Public
    
    /// Adds arranged subviews to the horizontal stack view.
    /// - Parameter views: `UIView` objects that are added to the stack view.
    /// - Returns: Return `UIStackView` containing the arranged subviews.
    /// ```swift
    /// self.stackView.setHStack([
    ///    self.dateView,
    ///    self.messageContentView
    /// ])
    ///
    /// // same as
    /// self.stackView.addArrangedSubview(dateView)
    /// self.stackView.addArrangedSubview(messageContentView)
    /// ```
    @discardableResult
    public func setHStack(_ views: [UIView?]) -> Self {
        guard self.axis == .horizontal else { return self }
        views.forEach {
            if let view = $0 {
                self.addArrangedSubview(view)
            }
        }
        return self
    }
    
    /// Adds arranged subviews to the vertical stack view.
    /// - Parameter views: `UIView` objects that are added to the stack view.
    /// - Returns: Return `UIStackView` containing the arranged subviews.
    /// ```swift
    /// self.stackView.setVStack([
    ///    self.dateView,
    ///    self.messageContentView
    /// ])
    ///
    /// // same as
    /// self.stackView.addArrangedSubview(dateView)
    /// self.stackView.addArrangedSubview(messageContentView)
    /// ```
    @discardableResult
    public func setVStack(_ views: [UIView?]) -> Self {
        guard self.axis == .vertical else { return self }
        views.forEach {
            if let view = $0 {
                self.addArrangedSubview(view)
            }
        }
        return self
    }
}
